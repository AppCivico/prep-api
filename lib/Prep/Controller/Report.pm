package Prep::Controller::Report;
use Mojo::Base 'Prep::Controller';

use Prep::Utils;
use WebService::AssistenteCivico;
use DateTime;

sub base {
    my $c = shift;
    use DDP; p $c->req->params;

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
        },
        city => {
            type     => 'Str',
            required => 0
        }
    );

    my $security_token = $ENV{REPORT_SECURITY_TOKEN};
    die \['security_token', 'invalid'] unless $c->req->params->to_hash->{security_token} eq $security_token;

    # O padrão do since é 2019-06-21 00:00:00.000000+00
    # E também é o valor mínimo aceitável
    my $since = 1561086000;
    my $until = time();

    if ($c->req->params->to_hash->{since} && $c->req->params->to_hash->{since} > 1561086000) {
        $since = $c->req->params->to_hash->{since};

        my $since_dt = DateTime->from_epoch( epoch => $since )
          or die \['since', 'invalid'];
    }

    if ($c->req->params->to_hash->{until}) {
        die \['until', 'invalid'] if $c->req->params->to_hash->{until} < $since;

        $until = $c->req->params->to_hash->{until};

        my $until_dt = DateTime->from_epoch( epoch => $until )
          or die \['since', 'invalid'];
    }

    my $city = 'todas';
    if ($c->req->params->to_hash->{city}) {
        $city = lc $c->req->params->to_hash->{city};
        die \['city', 'invalid'] unless $city =~ /^(sp|bh|ssa|todas)$/;

        if ($city eq 'bh') {
            $city = 1;
        }
        elsif ($city eq 'ssa') {
            $city = 2;
        }
        elsif ($city eq 'sp') {
            $city = 3;
        }
        else {
            $city = undef
        }
    }

    $c->stash(
        since => $since,
        until => $until,
        city  => $city
    );
}

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

    my $report = $c->schema->resultset('ViewReport')->next;


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
            ],
        }
    )
}

1;
