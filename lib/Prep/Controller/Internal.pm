package Prep::Controller::Internal;
use Mojo::Base 'Prep::Controller';

use Prep::Utils;

sub validade_security_token {
    my $c = shift;

    my $security_token = env('INTERNAL_SECURITY_TOKEN');
    my $foo = $c->req->params->to_hash->{security_token};
	$c->app->log->debug("================================================================================  $foo ================================================================================");
	$c->app->log->info("================================================================================  $foo ================================================================================");

    if ( !$c->req->params->to_hash->{security_token} || $security_token ne $c->req->params->to_hash->{security_token} ) {
        $c->reply_forbidden();
        $c->detach;
    }

    return $c;
}

1;
