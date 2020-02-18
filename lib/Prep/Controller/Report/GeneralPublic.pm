package Prep::Controller::Report::GeneralPublic;
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

sub get {
    my $c = shift;

    my $city = $c->stash('city');

    my $logger = $c->logger;

    my $since = $c->stash('since');
    my $until = $c->stash('until');

    my $view = $c->schema->resultset('ViewReportGeneral')->search(
        undef,
        { bind => [ $since, $until, $since, $until, $since, $until ] }
    )->next;

    my @metrics;
    for my $key ( keys %{$view->{_column_data}} ) {

        my ($label, $value);
        if ($key eq 'count_finished_publico_interesse') {
            $label = 'Finalizaram bloco A';
            $value = $view->count_finished_publico_interesse;
        }
        elsif ($key eq 'count_finished_quiz_brincadeira') {
            $label = 'Finalizaram quiz de brincadeira';
            $value = $view->count_finished_quiz_brincadeira;
        }
        elsif ($key eq 'count_multiple_interactions') {
            $label = 'Possuem mais de uma interação';
            $value = $view->count_multiple_interactions;
        }
        elsif ($key eq 'count_one_interaction') {
            $label = 'Possuem apenas uma interação';
            $value = $view->count_one_interaction;
        }
        elsif ($key eq 'count_refused_publico_interesse') {
            $label = 'Apertaram "agora não" no menu principal';
            $value = $view->count_refused_publico_interesse;
        }
        elsif ($key eq 'count_started_publico_interesse') {
            $label = 'Começaram o bloco A';
            $value = $view->count_started_publico_interesse;
        }
        elsif ($key eq 'count_started_publico_interesse_after_refusal') {
            $label = 'Começaram o bloco A após apertar "agora não" no menu principal';
            $value = $view->count_started_publico_interesse_after_refusal;
        }
        else {
            $label = 'Começaram o quiz de brincadeira';
            $value = $view->count_started_quiz_brincadeira;
        }

        push @metrics, { label => $label, value => $value }
    }

    return $c->render(
        status => 200,
        json   => {
            metrics => \@metrics
        }
    );
}

1;
