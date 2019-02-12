package Prep::Controller::Internal;
use Mojo::Base 'Prep::Controller';

use Prep::Utils;

sub validade_security_token {
    my $c = shift;

    my $security_token = env('INTERNAL_SECURITY_TOKEN');

    if ( !$c->req->params->to_hash->{security_token} || $security_token ne $c->req->params->to_hash->{security_token} ) {
        $c->reply_forbidden();
        $c->detach;
    }

    return $c;
}

1;
