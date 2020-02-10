package Prep::Controller::Report;
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

    my $report = $c->schema->resultset('ViewReport')->next;

    my $assistente_civico         = WebService::AssistenteCivico->instance;
    my $assistente_civico_metrics = $assistente_civico->get_metrics(since => $since, until => $until);

    return $c->render(
        status => 200,
        json   => {
            cities => [
                {
                    general => {
                        count_all => {
                            display_order => 1,
                            label         => 'Quantas pessoas interagiram',
                            value         => $report->count_all
                        },
                        count_started_quiz => {
                            display_order => 2,
                            label         => 'Começaram o quiz',
                            value         => $report->count_started_quiz
                        },
                        count_finished_quiz => {
                            display_order => 3,
                            label         => 'Terminaram o quiz',
                            value         => $report->count_finished_quiz
                        },
                        count_signed_term => {
                            display_order => 4,
                            label         => 'Assinaram o TCLE',
                            value         => $report->count_signed_term
                        },
                        count_target_audience => {
                            display_order => 5,
                            label         => 'Público de interesse',
                            value         => $report->count_target_audience
                        },
                        count_eligible_for_research => {
                            display_order => 6,
                            label         => 'Elegíveis',
                            value         => $report->count_eligible_for_research
                        },
                        count_created_appointment => {
                            display_order => 7,
                            label         => 'Criaram consulta',
                            value         => $report->count_created_appointment
                        },
                        count_answered_last_question => {
                            display_order => 8,
                            label         => 'Responderam a última pergunta do quiz',
                            value         => $report->count_answered_last_question
                        },

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
                },
                {
                    'São Paulo' => {
                        count_all => {
                            display_order => 9,
                            label         => 'Quantas pessoas interagiram',
                            value         => $report->count_all_sp
                        },
                        count_started_quiz => {
                            display_order => 10,
                            label         => 'Começaram o quiz',
                            value         => $report->count_started_quiz_sp
                        },
                        count_finished_quiz => {
                            display_order => 11,
                            label         => 'Terminaram o quiz',
                            value         => $report->count_finished_quiz_sp
                        },
                        count_signed_term => {
                            display_order => 12,
                            label         => 'Assinaram o TCLE',
                            value         => $report->count_signed_term_sp
                        },
                        count_target_audience => {
                            display_order => 13,
                            label         => 'Público de interesse',
                            value         => $report->count_target_audience_sp
                        },
                        count_eligible_for_research => {
                            display_order => 14,
                            label         => 'Elegíveis',
                            value         => $report->count_eligible_for_research_sp
                        },
                        count_created_appointment => {
                            display_order => 15,
                            label         => 'Criaram consulta',
                            value         => $report->count_created_appointment_sp
                        },
                        count_answered_last_question => {
                            display_order => 16,
                            label         => 'Responderam a última pergunta do quiz',
                            value         => $report->count_answered_last_question_sp
                        },
                    }
                },
                {
                    'Belo Horizonte' => {
                        count_all => {
                            display_order => 17,
                            label         => 'Quantas pessoas interagiram',
                            value         => $report->count_all_bh
                        },
                        count_started_quiz => {
                            display_order => 18,
                            label         => 'Começaram o quiz',
                            value         => $report->count_started_quiz_bh
                        },
                        count_finished_quiz => {
                            display_order => 19,
                            label         => 'Terminaram o quiz',
                            value         => $report->count_finished_quiz_bh
                        },
                        count_signed_term => {
                            display_order => 20,
                            label         => 'Assinaram o TCLE',
                            value         => $report->count_signed_term_bh
                        },
                        count_target_audience => {
                            display_order => 21,
                            label         => 'Público de interesse',
                            value         => $report->count_target_audience_bh
                        },
                        count_eligible_for_research => {
                            display_order => 22,
                            label         => 'Elegíveis',
                            value         => $report->count_eligible_for_research_bh
                        },
                        count_created_appointment => {
                            display_order => 23,
                            label         => 'Criaram consulta',
                            value         => $report->count_created_appointment_bh
                        },
                        count_answered_last_question => {
                            display_order => 24,
                            label         => 'Responderam a última pergunta do quiz',
                            value         => $report->count_answered_last_question_bh
                        },
                    }
                },
                {
                    'Salvador' => {
                        count_all => {
                            display_order => 25,
                            label         => 'Quantas pessoas interagiram',
                            value         => $report->count_all_s
                        },
                        count_started_quiz => {
                            display_order => 26,
                            label         => 'Começaram o quiz',
                            value         => $report->count_started_quiz_s
                        },
                        count_finished_quiz => {
                            display_order => 27,
                            label         => 'Terminaram o quiz',
                            value         => $report->count_finished_quiz_s
                        },
                        count_signed_term => {
                            display_order => 28,
                            label         => 'Assinaram o TCLE',
                            value         => $report->count_signed_term_s
                        },
                        count_target_audience => {
                            display_order => 29,
                            label         => 'Público de interesse',
                            value         => $report->count_target_audience_s
                        },
                        count_eligible_for_research => {
                            display_order => 30,
                            label         => 'Elegíveis',
                            value         => $report->count_eligible_for_research_s
                        },
                        count_created_appointment => {
                            display_order => 31,
                            label         => 'Criaram consulta',
                            value         => $report->count_created_appointment_s
                        },
                        count_answered_last_question => {
                            display_order => 32,
                            label         => 'Responderam a última pergunta do quiz',
                            value         => $report->count_answered_last_question_s
                        },
                    }
                }
            ]
        }
    )
}

1;
