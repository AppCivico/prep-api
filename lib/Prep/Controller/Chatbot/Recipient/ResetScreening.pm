package Prep::Controller::Chatbot::Recipient::ResetScreening;
use Mojo::Base 'Prep::Controller';

sub post {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    eval { $recipient->reset_screening };

    return $c->render(
        status => 200,
        json   => {
            success => $@ ? 0 : 1
        }
    )
}

1;
