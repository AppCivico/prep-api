package Prep::Controller::Chatbot::Recipient;
use Mojo::Base 'Prep::Controller';

sub post {
    my $c = shift;

    my $params = $c->req->params->to_hash;

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

sub get {
    my $c = shift;

	$c->validate_request_params(
		fb_id => {
			type     => 'Num',
			required => 1,
		},
	);

    my $params = $c->req->params->to_hash;

    my $recipient = $c->schema->resultset('Recipient')->search( { fb_id => $params->{fb_id} } )->next;
    die \['fb_id', 'invalid'] unless $recipient;

    return $c->render(
        status => 200,
        json   => {
            map {
                $_ => $recipient->$_
            } qw( id fb_id name page_id picture opt_in updated_at created_at )
        }
    )
}

sub put {
	my $c = shift;

	$c->validate_request_params(
		fb_id => {
			type     => 'Num',
			required => 1,
		},
	);

	my $params = $c->req->params->to_hash;

	my $recipient = $c->schema->resultset('Recipient')->search( { fb_id => $params->{fb_id} } )->next;
	die \['fb_id', 'invalid'] unless $recipient;

    $recipient->execute(
        $c,
        for  => 'update',
        with => $params
    );

    return $c->render(
        $c,
        code => 200,
        json => { id => $recipient->id }
    )
}

1;
