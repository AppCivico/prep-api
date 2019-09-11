package Prep::Controller::Report;
use Mojo::Base 'Prep::Controller';

use Prep::Utils;

sub get {
    my $c = shift;

    $c->validate_request_params(
        security_token => {
            type     => 'Str',
            required => 1,
        },
    );

    my $report = $c->schema->resultset('ViewReport')->next;

    my $security_token = $ENV{REPORT_SECURITY_TOKEN};
    die \['security_token', 'invalid'] unless $c->req->params->to_hash->{security_token} eq $security_token;

    return $c->render(
        status => 200,
        json   => {
            cities => [
                {
                    general => {
                        count_all => {
                            label => 'Quantas pessoas interagiram',
                            value => $report->count_all
                        },
                        count_target_audience => {
                            label => 'Público de interesse',
                            value => $report->count_target_audience
                        },
                        count_eligible_for_research => {
                            label => 'Elegíveis',
                            value => $report->count_eligible_for_research
                        },
                        count_signed_term => {
                            label => 'Assinaram o TCLE',
                            value => $report->count_signed_term
                        },
                        count_finished_quiz => {
                            label => 'Terminaram o quiz',
                            value => $report->count_finished_quiz
                        },
                        count_created_appointment => {
                            label => 'Criaram consulta',
                            value => $report->count_created_appointment
                        },
                    }
                },
                {
                    'São Paulo' => {
                        count_all => {
                            label => 'Quantas pessoas interagiram',
                            value => $report->count_all_sp
                        },
                        count_target_audience => {
                            label => 'Público de interesse',
                            value => $report->count_target_audience_sp
                        },
                        count_eligible_for_research => {
                            label => 'Elegíveis',
                            value => $report->count_eligible_for_research_sp
                        },
                        count_signed_term => {
                            label => 'Assinaram o TCLE',
                            value => $report->count_signed_term_sp
                        },
                        count_finished_quiz => {
                            label => 'Terminaram o quiz',
                            value => $report->count_finished_quiz_sp
                        },
                        count_created_appointment => {
                            label => 'Criaram consulta',
                            value => $report->count_created_appointment_sp
                        },
                    }
                },
                {
                    'Belo Horizonte' => {
                        count_all => {
                            label => 'Quantas pessoas interagiram',
                            value => $report->count_all_bh
                        },
                        count_target_audience => {
                            label => 'Público de interesse',
                            value => $report->count_target_audience_bh
                        },
                        count_eligible_for_research => {
                            label => 'Elegíveis',
                            value => $report->count_eligible_for_research_bh
                        },
                        count_signed_term => {
                            label => 'Assinaram o TCLE',
                            value => $report->count_signed_term_bh
                        },
                        count_finished_quiz => {
                            label => 'Terminaram o quiz',
                            value => $report->count_finished_quiz_bh
                        },
                        count_created_appointment => {
                            label => 'Criaram consulta',
                            value => $report->count_created_appointment_bh
                        },
                    }
                },
				{
					'Salvador' => {
						count_all => {
							label => 'Quantas pessoas interagiram',
							value => $report->count_all_s
						},
						count_target_audience => {
							label => 'Público de interesse',
							value => $report->count_target_audience_s
						},
						count_eligible_for_research => {
							label => 'Elegíveis',
							value => $report->count_eligible_for_research_s
						},
						count_signed_term => {
							label => 'Assinaram o TCLE',
							value => $report->count_signed_term_s
						},
						count_finished_quiz => {
							label => 'Terminaram o quiz',
							value => $report->count_finished_quiz_s
						},
						count_created_appointment => {
							label => 'Criaram consulta',
							value => $report->count_created_appointment_s
						},
					}
				}
            ]
        }
    )
}

1;
