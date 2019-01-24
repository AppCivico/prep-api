package Prep::Controller::Chatbot::Recipient::Appointment;
use Mojo::Base 'Prep::Controller';

sub post {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    my $appointment = $recipient->appointments->execute(
        $c,
        for  => 'create',
        with => $c->req->params->to_hash
    );

    return $c->render(
        status => 201,
        json   => {
            id => $appointment->id
        }
    )
}

1;
