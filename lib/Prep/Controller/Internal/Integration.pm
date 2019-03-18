package Prep::Controller::Internal::Integration;
use Mojo::Base 'Prep::Controller';

use Prep::Utils;

sub validate_header_and_pass {
    my $c = shift;

    if ( $c->req->method ne 'GET' ) {
        my $content_type = $c->req->headers->to_hash->{'Content-Type'};
        if ( !$content_type ) {
            $c->render(
                status => 400,
                json   => {
                    error => 'header',
                    header => {
                        'Content-Type' => 'missing'
                    }
                },
            );
            $c->detach;
        }

        if ( $content_type !~ m/(multipart\/form-data|application\/x-www-form-urlencoded)/g ) {
            $c->render(
                status => 400,
                json   => {
                    error  => 'header',
                    header => {
                        'Content-Type' => 'invalid'
                    }
                },
            );
            $c->detach;
        }

    }

    my $security_token = env('INTEGRATION_SECURITY_TOKEN');
    my $pass           = $c->req->params->to_hash->{security_token};

    if ( !$pass || $security_token ne $pass ) {
        $c->reply_forbidden();
        $c->detach;
    }

    return $c;
}

1;
