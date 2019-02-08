package Prep::Controller::Chatbot::Recipient::IntegrationToken;
use Mojo::Base 'Prep::Controller';

sub post {
    my $c = shift;

	$c->validate_request_params(
		integration_token => {
			type       => 'Str',
			required   => 1
		},
	);

	my $recipient = $c->stash('recipient');

    my $integration_token = $c->req->params->to_hash->{integration_token};

	$recipient->assign_token( $integration_token );

    return $c->render(
        status => 200,
        json   => {
            id => $recipient->id
        }
    )
}

1;
