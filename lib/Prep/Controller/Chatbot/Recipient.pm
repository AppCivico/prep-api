package Prep::Controller::Chatbot::Recipient;
use Mojo::Base 'Prep::Controller';

sub post {
    my $c = shift;

    my $params = $c->req->params->to_hash;
    use DDP; p $c->schema->resultset('Recipient');
    my $recipient = $c->schema->resultset('Recipient')->execute(
        $c,
        for  => 'create',
        with => $params
    );

	return $c
    ->redirect_to('current')
    ->render(
		json   => { id => $recipient->id },
		status => 201,
	);
}

1;
