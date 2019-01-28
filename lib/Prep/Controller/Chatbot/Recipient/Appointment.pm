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

sub get {
    my $c = shift;

	my $recipient = $c->stash('recipient');

    return $c->render(
        status => 200,
        json   => map {
            my $a = $_;

            +{
                datetime_start        => $a->appointment_at,
                quota_number          => $a->quota_number,
                appointment_window_id => $a->appointment_window_id
            }
        } $recipient->upcoming_appointments->all()
    )
}

1;
