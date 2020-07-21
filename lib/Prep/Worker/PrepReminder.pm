package Prep::Worker::PrepReminder;
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

has max_process => (
    is      => 'rw',
    isa     => 'Int',
    default => 1,
);

sub _build_schema { &get_schema }
sub _build_logger { &get_logger }
sub _build_ioloop { Mojo::IOLoop->singleton }

sub _queue_rs {
    my ($self) = @_;

    return $self->schema->resultset('PrepReminder')->search(
        {
            -and => [
                errmsg => \'IS NULL',
                -or => [
                    reminder_before      => 1,
                    reminder_after       => 1,
                ],
                reminder_temporal_wait_until => { '<=' => \'NOW()' },

                -or => [
                    reminder_temporal_confirmed_at => \'IS NULL',
                    reminder_temporal_confirmed_at => { '<=' => \"me.reminder_temporal_wait_until" }
                ]
            ]


        },
        { for => 'update' }
    );
}

sub pending_jobs {
    my ( $self, %opts ) = @_;

    return $self->_queue_rs()->search()->all();
}

sub run_once {
    my ($self, %opts) = @_;

    my ($job) = $self->pending_jobs;

    $self->process_item($job);

    return 1;
}

sub run_all {
    my ($self) = @_;

    my $queue_rs = $self->_queue_rs();
    map { $self->process_item($_) } $queue_rs->all();
}

sub listen_queue {
    my ($self) = @_;

    my $logger = $self->logger;

    my $dbh = $self->schema->storage->dbh;

    $logger->info("LISTEN Notify");
    $dbh->do("LISTEN Notify");
    eval {
        while (1) {
            my $time = time();
            my @pendings = $self->pending_jobs;

            if (scalar @pendings > 0) {
                $logger->info(sprintf("Há %d itens na fila aguardando processamento", scalar @pendings));
                eval {
                    map { $self->process_item($_) } @pendings
                };

                if ($@) {
                    $self->logger->fatal("Error on run job: $@");
                }
            }
            else {
                $logger->info("Não há itens na fila");
            }

            ON_TERM_EXIT;
            EXIT_IF_ASKED;
            sleep 70;
        }
    };
    $logger->logconfess("Fatal error: $@") if $@;
}

sub process_item {
    my ($self, $job) = @_;

    eval {
        $self->logger->info('Iniciando processamento do job=' . $job->id);

        $self->logger->info('Lembrete prep do recipient id=' . $job->recipient_id);

        $self->logger->info('reminder_before=' . $job->reminder_before);
        $self->logger->info('reminder_after=' . $job->reminder_after);

        $self->logger->info('reminder_before_interval=' . $job->reminder_before_interval) if $job->reminder_before;
        $self->logger->info('reminder_after_interval=' . $job->reminder_after_interval) if $job->reminder_after;

        $self->logger->info('reminder_wait_until=' . $job->reminder_temporal_wait_until);
        $self->logger->info('reminder_last_sent_at=' . $job->reminder_temporal_last_sent_at) if $job->reminder_temporal_last_sent_at;
        $self->logger->info('reminder_confirmed_at=' . $job->reminder_temporal_confirmed_at) if $job->reminder_temporal_confirmed_at;

        my $notification_queue_rs = $self->schema->resultset('NotificationQueue');

        # Limite de 3 notificações por hora
        my $notifications_last_hour = $notification_queue_rs->search(
            {
                'me.prep_reminder_id' => $job->id,
                'me.created_at'       => { '>=' => \"NOW() - interval '1 hour'" }
            }
        )->count;
        use DDP; p $notifications_last_hour;

        if ($notifications_last_hour >= 3) {
            $job->update(
                {
                    reminder_temporal_last_sent_at => \'NOW()',
                    reminder_temporal_wait_until   => \"NOW() + INTERVAL '3 hours'"
                }
            );
        }
        else {
            # Se for "before" a soneca dura 10 min, caso seja "after" dura 15.
            my ($notification_type, $snooze_interval);

            if ($job->reminder_before) {
                $notification_type = 9;
                $snooze_interval   = '10 minutes';
            }
            elsif ($job->reminder_after) {
                $notification_type = 10;
                $snooze_interval   = '15 minutes';
            }

            my $notification = $notification_queue_rs->create(
                {
                    recipient_id => $job->recipient_id,
                    type_id      => $notification_type,
                    prep_reminder_id => $job->id
                }
            );


            $job->update(
                {
                    reminder_temporal_last_sent_at => \'NOW()',
                    reminder_temporal_wait_until   => \"NOW() + INTERVAL '$snooze_interval'"
                }
            );
        }
    };

    if ($@) {
        $self->logger->debug('Erro ao processar job job=' . $job->id . ", erro: $@");

        $job->update( { errmsg => $@ } );

        return 0;
    }
    else {

        return 1;
    }
}

__PACKAGE__->meta->make_immutable;

1;
