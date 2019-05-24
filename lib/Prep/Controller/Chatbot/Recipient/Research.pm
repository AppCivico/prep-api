package Prep::Controller::Chatbot::Recipient::Research;
use Mojo::Base 'Prep::Controller';

use Prep::Types qw( URI );

sub post {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    $recipient->execute(
        $c,
        for  => 'research_participation',
        with => $c->req->params->to_hash
    );

    return $c->render(
        status => 200,
        json   => {
            recipient_id => $recipient->id
        }
    )
}

1;
