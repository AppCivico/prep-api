package Prep::Controller::Chatbot::Recipient::Appointment;
use Mojo::Base 'Prep::Controller';

sub post {
    my $c = shift;

	$c->validate_request_params(
		type => {
			type       => 'Str',
			required   => 1,
			post_check => sub {
				my $type = $c->req->params->to_hash->{type};

				die \['type', 'invalid'] unless $type =~ m/(quiz|screening)/;
			}
		},
	);

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
        json   => {
            appointments => [
                map {
					my $a = $_;

                    $a->info
                } $recipient->upcoming_appointments->all(),
            ]
        }
    )
}

1;
