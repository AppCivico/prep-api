package Prep::Controller::Report::Interaction;
use Mojo::Base 'Prep::Controller';

use Prep::Utils;
use WebService::AssistenteCivico;
use Prep::Logger;
use Moose;

has logger => (
    is      => 'rw',
    lazy    => 1,
    builder => '_build_logger',
);
sub _build_logger { &get_logger }

sub get_general {
    my $c = shift;

    my $city = $c->stash('city');

    my $cond = {};

    if ($city) {
        $cond->{'recipient.city'} = $city;
    }

    my $interaction_rs = $c->schema->resultset('Interaction')->search(
        $cond,
        { join => 'recipient' }
    );

    my $now_epoch = time();

    my $logger = $c->logger;
    $logger->debug("now_epoch: $now_epoch");

    # Métricas de interação.
    my ($interaction_metric_since, $interaction_metric_until);
    my @interaction_window_metrics;

    for ( 1 .. 4 ) {
        my $label;

        if ($_ == 1) {
            $label = 'Últimos 3 dias';

            $interaction_metric_since = $now_epoch - (86400 * 3);
        }
        elsif ($_ == 2) {
            $label = '4 a 7 dias';

            $interaction_metric_since = $now_epoch - (86400 * 7 - 1);
            $interaction_metric_until = $now_epoch - (86400 * 3 - 1);
        }
        elsif ($_ == 3) {
            $label = '8 a 15 dias';

            $interaction_metric_since = $now_epoch - (86400 * 15 - 1);
            $interaction_metric_until = $now_epoch - (86400 * 7 - 1);
        }
        else {
            $label = 'Mais de 15 dias';

            $interaction_metric_until = $now_epoch - (86400 * 8 - 1);
        }

        $logger->debug("label: $label");
        $logger->debug("since: $interaction_metric_since");
        $logger->debug("until: $interaction_metric_until");

        my $interaction_metric = $interaction_rs->search(
            {
                '-and' => [
                    (
                        $interaction_metric_since ?
                            (
                                \['started_at >= to_timestamp(?)', $interaction_metric_since],
                            ) :
                            ( )
                    ),

                    (
                        $interaction_metric_until ?
                            (
                                \['closed_at <= to_timestamp(?)', $interaction_metric_until],
                            ) :
                            ( )
                    )
                ]
            }
        );

        $logger->debug("count: " . $interaction_metric->count);
        # $logger->debug("query: " . $interaction_metric->as_query);


        push @interaction_window_metrics, {label => $label, value => $interaction_metric->count};

        $interaction_metric_since = undef;
        $interaction_metric_until = undef;
    }

    return $c->render(
        status => 200,
        json   => {
            metrics => \@interaction_window_metrics
        }
    );
}

sub get_target_audience {
    my $c = shift;

    my $city = $c->stash('city');

    my $interaction_rs = $c->schema->resultset('Interaction')->search(
        {
            'recipient_flag.is_target_audience' => 1,
            # 'me.closed_at' => \'IS NOT NULL',

            $city ?
              (
                  'recipient.city' => $city
              ) :
              ( )
        },
        { join => {'recipient' => 'recipient_flag'} }
    );

    my $now_epoch = time();

    my $logger = $c->logger;
    $logger->debug("now_epoch: $now_epoch");

    # Métricas de interação.
    my ($interaction_metric_since, $interaction_metric_until);
    my @interaction_window_metrics;

    for ( 1 .. 4 ) {
        my $label;

        if ($_ == 1) {
            $label = 'Últimos 3 dias';

            $interaction_metric_since = $now_epoch - (86400 * 3);
        }
        elsif ($_ == 2) {
            $label = '4 a 7 dias';

            $interaction_metric_since = $now_epoch - (86400 * 7 - 1);
            $interaction_metric_until = $now_epoch - (86400 * 3 - 1);
        }
        elsif ($_ == 3) {
            $label = '8 a 15 dias';

            $interaction_metric_since = $now_epoch - (86400 * 15 - 1);
            $interaction_metric_until = $now_epoch - (86400 * 7 - 1);
        }
        else {
            $label = 'Mais de 15 dias';

            $interaction_metric_until = $now_epoch - (86400 * 8 - 1);
        }

        $logger->debug("label: $label");
        $logger->debug("since: $interaction_metric_since");
        $logger->debug("until: $interaction_metric_until");

        my $interaction_metric = $interaction_rs->search(
            {
                '-and' => [
                    (
                        $interaction_metric_since ?
                            (
                                \['started_at >= to_timestamp(?)', $interaction_metric_since],
                            ) :
                            ( )
                    ),

                    (
                        $interaction_metric_until ?
                            (
                                \['closed_at <= to_timestamp(?)', $interaction_metric_until],
                            ) :
                            ( )
                    )
                ]
            }
        );

        $logger->debug("count: " . $interaction_metric->count);
        # $logger->debug("query: " . $interaction_metric->as_query);


        push @interaction_window_metrics, {label => $label, value => $interaction_metric->count};

        $interaction_metric_since = undef;
        $interaction_metric_until = undef;
    }

    return $c->render(
        status => 200,
        json   => {
            metrics => \@interaction_window_metrics
        }
    );
}

1;
