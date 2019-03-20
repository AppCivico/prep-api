package Prep::Controller::Chatbot::Recipient::CountResearchInvite;
use Mojo::Base 'Prep::Controller';

sub post {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    $recipient->update( { count_invited_research => $recipient->count_invited_research + 1 } );

    return $c->render(
        status => 201,
        json   => {
            id                     => $recipient->id,
            count_invited_research => $recipient->count_invited_research
        }
    )
}

sub get {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    return $c->render(
        status => 200,
        json   => {
            count_invited_research => $recipient->count_invited_research
        }
    )
}

1;
