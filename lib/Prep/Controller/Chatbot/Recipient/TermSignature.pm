package Prep::Controller::Chatbot::Recipient::TermSignature;
use Mojo::Base 'Prep::Controller';

use Prep::Types qw( URI );

sub post {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    my $signature = $recipient->term_signatures->execute(
        $c,
        for  => 'create',
        with => $c->req->params->to_hash
    );

    return $c->render(
        status => 201,
        json   => {
            recipient_id => $signature->recipient_id
        }
    )
}

1;
