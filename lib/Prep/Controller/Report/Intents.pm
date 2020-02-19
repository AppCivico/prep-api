package Prep::Controller::Report::Intents;
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

has _ac_ws => (
    is         => 'ro',
    isa        => 'WebService::AssistenteCivico',
    lazy_build => 1,
);

sub _build__ac_ws { WebService::AssistenteCivico->instance }
sub _build_logger { &get_logger }

sub get {
    my $c = shift;

    my $ac_ws = $c->_ac_ws;

    my $metrics_res = $ac_ws->get_metrics(
        since => $c->stash('since'),
        until => $c->stash('until'),
    );

    my @metrics;
    for my $key (keys %{$metrics_res}) {

        my ($label, $weight);
        if ($key eq 'recipients_with_intent') {
            $label  = 'Caíram em ao menos uma intenção';
            $weight = 1;
        }
        elsif ($key eq 'recipients_with_fallback_intent') {
            $label  = 'Caíram na intenção de "fallback"';
            $weight = 2;
        }
        elsif ($key eq 'most_used_intents') {
            $label  = '10 intenções mais acessadas';
            $weight = 3;
        }
        else {
            $label  = '10 intenções mais acessadas entre quem é público de interesse';
            $weight = 4;
        }

        my $value = $metrics_res->{$key};

        push @metrics, {label => $label, value => $value, weight => $weight};
    }

    @metrics = sort { $a->{weight} <=> $b->{weight} } @metrics;
    delete $_->{weight} for @metrics;

    return $c->render(
        status => 200,
        json   => {
            metrics => \@metrics
        }
    );
}

1;
