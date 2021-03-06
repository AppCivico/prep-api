package Prep::Controller::Report::GeneralPublic;
use Mojo::Base 'Prep::Controller';

use Prep::Utils;
use Prep::Logger;
use Moose;

has logger => (
    is      => 'rw',
    lazy    => 1,
    builder => '_build_logger',
);
sub _build_logger {&get_logger}

sub get {
    my $c = shift;

    my $city = $c->stash('city');

    my $logger = $c->logger;

    my $since = $c->stash('since');
    my $until = $c->stash('until');

    my $view = $c->schema->resultset('ViewReportGeneral')->search(
        undef,
        {bind => [$since, $until, $since, $until, $since, $until, $since, $until]}
    )->next;

    my @metrics;
    for my $key (keys %{$view->{_column_data}}) {

        my ($label, $value, $weight);
        if ($key eq 'count_finished_publico_interesse') {
            $label  = 'Finalizaram bloco A';
            $value  = $view->count_finished_publico_interesse;
            $weight = 7;
        }
        elsif ($key eq 'count_finished_quiz_brincadeira') {
            $label  = 'Finalizaram quiz de brincadeira';
            $value  = $view->count_finished_quiz_brincadeira;
            $weight = 9;
        }
        elsif ($key eq 'count_multiple_interactions') {
            $label  = 'Possuem mais de uma interação';
            $value  = $view->count_multiple_interactions;
            $weight = 3;
        }
        elsif ($key eq 'count_one_interaction') {
            $label  = 'Possuem apenas uma interação';
            $value  = $view->count_one_interaction;
            $weight = 2;
        }

        # elsif ($key eq 'count_refused_publico_interesse') {
        #     $label  = 'Apertaram "agora não" no menu principal';
        #     $value  = $view->count_refused_publico_interesse;
        #     $weight = 4;
        # }
        elsif ($key eq 'count_started_publico_interesse') {
            $label  = 'Começaram o bloco A';
            $value  = $view->count_started_publico_interesse;
            $weight = 6;
        }

        # elsif ($key eq 'count_started_publico_interesse_after_refusal') {
        #     $label  = 'Começaram o bloco A após apertar "agora não" no menu principal';
        #     $value  = $view->count_started_publico_interesse_after_refusal;
        #     $weight = 5;
        # }
        elsif ($key eq 'count_recipients') {
            $label  = 'Contatos novos no período';
            $value  = $view->count_recipients;
            $weight = 1;
        }
        elsif ($key eq 'count_started_quiz_brincadeira') {
            $label  = 'Começaram o quiz de brincadeira';
            $value  = $view->count_started_quiz_brincadeira;
            $weight = 8;
        }
        else {
            # nada
        }

        push @metrics, {label => $label, value => $value, weight => $weight} if defined $label;
    }

    @metrics = sort { $a->{weight} <=> $b->{weight} } @metrics;
    delete $_->{weight} for @metrics;

    return $c->render(
        status => 200,
        json   => {metrics => \@metrics}
    );
}

1;
