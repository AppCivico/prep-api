package Prep::Controller::ReportUpdated;
use Mojo::Base 'Prep::Controller';

use Prep::Utils;
use WebService::AssistenteCivico;
use DateTime;

sub get {
    my $c = shift;

    $c->validate_request_params(
        security_token => {
            type     => 'Str',
            required => 1,
        },
        since => {
            type     => 'Int',
            required => 0,
        },
        until => {
            type     => 'Int',
            required => 0
        }
    );

    my $security_token = $ENV{REPORT_SECURITY_TOKEN};
    die \['security_token', 'invalid'] unless $c->req->params->to_hash->{security_token} eq $security_token;

    my $now_epoch = time();

    my ($since, $until);

    if ($since = $c->req->params->to_hash->{since}) {
        my $since_dt = DateTime->from_epoch( epoch => $since )
          or die \['since', 'invalid'];
    }

    if ($until = $c->req->params->to_hash->{until}) {
        my $until_dt = DateTime->from_epoch( epoch => $until )
          or die \['since', 'invalid'];
    }

    if ($since && $until) {
        die \['until', 'invalid'] if $until < $since;
    }

    $since ||= $now_epoch - (86400 * 7);
    $until ||= $now_epoch;

    my $assistente_civico         = WebService::AssistenteCivico->instance;
    my $assistente_civico_metrics = $assistente_civico->get_metrics(since => $since, until => $until);

    # Métricas de interação.
    my ($interaction_metric_since, $interaction_metric_until);
    my @interaction_window_metrics;

    my $interaction_rs = $c->schema->resultset('Interaction');

    for ( 1 .. 4 ) {
        if ($_ == 1) {
            $interaction_metric_since = $now_epoch - (86400 * 3);
            $interaction_metric_until = $now_epoch;
        }
        elsif ($_ == 2) {
            $interaction_metric_since = $now_epoch - (86400 * 7);
            $interaction_metric_until = $now_epoch - (86400 * 4);
        }
        elsif ($_ == 3) {
            $interaction_metric_since = $now_epoch - (86400 * 15);
            $interaction_metric_until = $now_epoch - (86400 * 8);
        }
        else {
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

        push @interaction_window_metrics, $interaction_metric;
    }

    my @general_metrics;

    my $report_updated = $c->schema->resultset('ViewReportGeneral')->search(
        undef,
        { bind => [ $since, $until, $since, $until, $since, $until ] }
    )->next;
    use DDP; p $report_updated;

    return $c->render(
        status => 200,
        json   => {
            general_public => {
                count_one_interaction => {
                    display_order => 1,
                    label         => 'Contatos com apenas uma interação',
                    value         => $report_updated->{count_one_interaction} || 0
                },
                count_multiple_interactions => {
                    display_order => 2,
                    label         => 'Contatos com mais de uma interação',
                    value         => $assistente_civico_metrics->{count_multiple_interactions} || 0
                },
                count_refused_publico_interesse => {
                    display_order => 3,
                    label         => 'Contatos que clicaram em "agora não"',
                    value         => $assistente_civico_metrics->{count_refused_publico_interesse} || 0
                },
                count_started_publico_interesse_after_refusal => {
                    display_order => 4,
                    label         => 'Contatos que clicaram em "agora não" e depois iniciaram o bloco A',
                    value         => $assistente_civico_metrics->{count_started_publico_interesse_after_refusal} || 0
                },
                count_started_publico_interesse => {
                    display_order => 5,
                    label         => 'Contatos que iniciaram o bloco A',
                    value         => $assistente_civico_metrics->{count_started_publico_interesse} || 0
                },
                count_finished_publico_interesse => {
                    display_order => 6,
                    label         => 'Contatos que finalizaram o bloco A',
                    value         => $assistente_civico_metrics->{count_finished_publico_interesse} || 0
                },
                count_started_quiz_brincadeira => {
                    display_order => 7,
                    label         => 'Contatos que iniciaram o quiz de brincadeira',
                    value         => $assistente_civico_metrics->{count_started_quiz_brincadeira} || 0
                },
                count_finished_quiz_brincadeira => {
                    display_order => 8,
                    label         => 'Contatos que finalizaram o quiz de brincadeira',
                    value         => $assistente_civico_metrics->{count_finished_quiz_brincadeira} || 0
                },
            },
            intents => {
                count_recipients_with_intent => {
                    display_order => 9,
                    label         => 'Contatos com ao menos uma intent',
                    value         => $assistente_civico_metrics->{recipients_with_intent}
                },
                count_recipients_with_fallback_intent => {
                    display_order => 10,
                    label         => 'Contatos com intent de fallback',
                    value         => $assistente_civico_metrics->{recipients_with_fallback_intent}
                },
                most_used_intents => {
                    display_order => 11,
                    label         => 'Intentenções mais acessadas',
                    value         => $assistente_civico_metrics->{most_used_intents}
                },
                most_used_intents_target_audience => {
                    display_order => 12,
                    label         => 'Intentenções mais acessadas por quem é público de interesse',
                    value         => $assistente_civico_metrics->{most_used_intents_target_audience}
                },
            }
        }
    )
}

1;
