package Prep::Worker::Notify;
use Moose;
use namespace::autoclean;

use Mojo::IOLoop;
use Mojo::Promise;
use Prep::SchemaConnected;
use Prep::Logger;
use Prep::TrapSignals;

with 'Prep::Worker';

has schema => (
    is      => 'rw',
    lazy    => 1,
    builder => '_build_schema',
);

has logger => (
    is      => 'rw',
    lazy    => 1,
    builder => '_build_logger',
);

has _active_queue => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { +{} },
);

has max_process => (
    is      => 'rw',
    isa     => 'Int',
    default => 4,
);

has ioloop => (
    is       => 'rw',
    isa      => 'Mojo::IOLoop',
    weak_ref => 1,
    lazy     => 1,
    builder  => '_build_ioloop',
);

sub _build_schema { &get_schema }
sub _build_logger { &get_logger }
sub _build_ioloop { Mojo::IOLoop->singleton }

sub _queue_rs {
    my ($self) = @_;

    return $self->schema->resultset('NotificationQueue')->search(
        {
            'me.sent_at' => \'IS NULL',
            '-or' => [
                'me.wait_until' => \'IS NULL',
                'me.wait_until' => { '<=' => \'NOW()' }
            ]
        },
        { for => 'update' }
    );
}

sub pending_jobs {
    my ( $self, %opts ) = @_;

    my $rows = $opts{rows} || 100;

    return $self->_queue_rs()->search(
        undef,
        { rows => $rows },
    )->all();
}

sub run_once {
    my ($self, %opts) = @_;

    my ($job) = $self->pending_jobs( rows => 1 );
    return -2 unless $job;

    my $p = $self->process_item_p($job)
      ->catch(sub {
          my $err = shift;
          $self->logger->fatal("Error on run job: $err");
      })
    ;
    $p->wait();

    return $p;
}

sub run_all {
    my ($self) = @_;

    my $queue_rs = $self->_queue_rs();
    my @promises = map { $self->process_item_p($_) } $queue_rs->all();

    Mojo::Promise->all(@promises)
      ->catch(sub {
          my $err = shift;
          $self->logger->fatal("Error on run job: $err");
      })
      ->wait();
}

sub listen_queue {
    my ($self) = @_;

    my $logger     = $self->logger;
    my $loop_times = 0;

    my $dbh = $self->schema->storage->dbh;

    $logger->info("LISTEN notify");
    $dbh->do("LISTEN notify");
    eval {
        Mojo::IOLoop->recurring(0.1 => sub {
            ON_TERM_WAIT;
            while ( my $notify = $dbh->pg_notifies ) {
                $loop_times = 0;
            }

            my $max_process = $self->max_process;
            my $running_proccess = int(scalar(keys %{ $self->_active_queue }));

            return if $running_proccess == $max_process;

            if ( $loop_times == 0 ) {
                my $empty_slots = $max_process - $running_proccess;

                if ($empty_slots > 0) {
                    my @pendings = $self->pending_jobs(
                        id_not_in => [ keys %{ $self->_active_queue } ],
                        rows      => $empty_slots + 1,
                    );

                    if (@pendings) {
                        if (scalar(@pendings) > $empty_slots) {
                            $loop_times = -1;
                            pop @pendings;
                        }

                        $logger->info(sprintf("Há %d itens na fila aguardando processamento", scalar @pendings));

                        my @promises = map { $self->process_item_p($_) } @pendings;
                        Mojo::Promise->all(@promises)
                        ->catch(sub {
                            my $err = shift;
                            $self->logger->fatal("Error on run job: $err");
                        })
                        ->wait();
                    }
                    else {
                        $logger->info("Não há itens na fila");
                    }
                }
            }
            ON_TERM_EXIT;
            EXIT_IF_ASKED;

            $loop_times = 0 if $loop_times++ == 500;
        });
    };

    $logger->logconfess("Fatal error: $@") if $@;

    $self->ioloop->start unless $self->ioloop->is_running;
}

sub process_item_p {
    my ($self, $notification) = @_;

    my $promise = Mojo::Promise->new;
    my $job_id = $notification->id;

    # $notification->on(notify_start => sub {
    #     ++$self->_active_queue->{$job_id};
    # });

    # $notification->on(notify_finish => sub {
    #     --$self->_active_queue->{$job_id};
    # });

    if ($self->max_process > 1) {

        $self->ioloop->subprocess(
            sub { $notification->send() },
            sub {
                my (undef, $err, @res) = @_;

                return $promise->reject($err, $notification) if $err;
                return $promise->resolve(@res);
            }
        );
    }
    else {

        my $res;
        eval { $res = $notification->send() };
        if ($@) {
            $promise->reject($@, $notification);
        }
        else {
            $notification->update( { sent_at => \'NOW()' } );
            $promise->resolve($res);
        }
    }

    $promise->catch(sub {
        my $err = shift;
        $notification->update( { err_msg => $err });
    });

    return $promise;
}

__PACKAGE__->meta->make_immutable;

1;

