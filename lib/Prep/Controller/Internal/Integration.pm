package Prep::Controller::Internal::Integration;
use Mojo::Base 'Prep::Controller';

use Prep::Utils;

sub validate_header_and_pass {
    my $c = shift;

    my $api_key        = $c->req->headers->header('x-api-key');
    my $security_token = env('INTEGRATION_SECURITY_TOKEN');

    if ( !defined $api_key || defined $api_key && ($security_token ne $api_key) ) {
        $c->reply_forbidden();
        $c->detach;
    }

    return $c;
}

1;
