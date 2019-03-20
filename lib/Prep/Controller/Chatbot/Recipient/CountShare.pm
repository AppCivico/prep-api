package Prep::Controller::Chatbot::Recipient::CountShare;
use Mojo::Base 'Prep::Controller';

sub post {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    $recipient->update( { count_share => $recipient->count_share + 1 } );

    return $c->render(
        status => 201,
        json   => {
            id          => $recipient->id,
            count_share => $recipient->count_share
        }
    )
}

sub get {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    return $c->render(
        status => 200,
        json   => {
            count_share => $recipient->count_share
        }
    )
}

1;
