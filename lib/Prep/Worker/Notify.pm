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

        $job->send;
    };

    if ($@) {
        $self->logger->debug('Erro ao processar job job=' . $job->id . ", erro: $@");
        return 0;
    }
    else {
        return 1;
    }
}

__PACKAGE__->meta->make_immutable;

1;
