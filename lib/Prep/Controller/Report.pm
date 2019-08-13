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
    )
}

1;
