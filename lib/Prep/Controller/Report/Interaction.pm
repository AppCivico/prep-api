package Prep::Controller::Report::Interaction;
use Mojo::Base 'Prep::Controller';

use Prep::Utils;
use WebService::AssistenteCivico;

sub get {
    my $c = shift;

    my $city = $c->stash('city');
    use DDP; p $c->stash;

    my $interaction_rs = $c->schema->resultset('Interaction')->search(
        {
            $city ?
              (
                  'recipient.city' => $city
              ) :
              ( )
        },
        { join => 'recipient' }
    );

    my $now_epoch = time();

    # Métricas de interação.
    my ($interaction_metric_since, $interaction_metric_until);
    my @interaction_window_metrics;

    for ( 1 .. 4 ) {
        my $label;

        if ($_ == 1) {
            $label = 'Últimos 3 dias';

            $interaction_metric_since = $now_epoch - (86400 * 3);
            $interaction_metric_until = $now_epoch;
        }
        elsif ($_ == 2) {
            $label = '4 a 7 dias';

            $interaction_metric_since = $now_epoch - (86400 * 7);
            $interaction_metric_until = $now_epoch - (86400 * 4);
        }
        elsif ($_ == 3) {
            $label = '8 a 15 dias';

            $interaction_metric_since = $now_epoch - (86400 * 15);
            $interaction_metric_until = $now_epoch - (86400 * 8);
        }
        else {
            $label = 'Mais de 15 dias';

            $interaction_metric_until = $now_epoch - (86400 * 8);
        }

        my $interaction_metric = $interaction_rs->search(
            {
                '-and' => [
                    \['started_at >= to_timestamp(?)', $interaction_metric_since],
                    \['closed_at <= to_timestamp(?)', $interaction_metric_until],
                ]
            }
        )->count;

        push @interaction_window_metrics, {label => $label, value => $interaction_metric};

    }

    return $c->render(
        status => 200,
        json   => {
            metrics => \@interaction_window_metrics
        }
    );
}

1;
