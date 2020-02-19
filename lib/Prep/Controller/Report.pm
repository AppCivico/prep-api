package Prep::Controller::Report;
use Mojo::Base 'Prep::Controller';

use Prep::Utils;
use WebService::AssistenteCivico;
use DateTime;

sub base {
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

    my $city;
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
            $city = undef;
        }

    }

    $c->stash(
        since => $since,
        until => $until,
        city  => $city
    );
}

1;
