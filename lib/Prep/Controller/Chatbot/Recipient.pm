package Prep::Controller::Chatbot::Recipient;
use Mojo::Base 'Prep::Controller';

sub stasher {
    my $c = shift;

    $c->validate_request_params(
        fb_id => {
            type     => 'Num',
            required => 1,
        },
    );

    $c->stash( collection => $c->schema->resultset('Recipient') );

    my $recipient = $c->schema->resultset('Recipient')->search( { fb_id => $c->req->params->to_hash->{fb_id} } )->next;
    die \['fb_id', 'invalid'] unless $recipient;

    $c->stash(
        recipient  => $recipient,
        collection => $c->stash('collection')->search_rs( { id => $recipient->id } )
    )
}

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

    my $recipient = $c->stash('recipient');

    return $c->render(
        status => 200,
        json   => {
            map {
                $_ => $recipient->$_
            } qw( id fb_id name page_id picture opt_in finished_quiz updated_at created_at is_eligible_for_research is_prep )
        }
    )
}

sub put {
    my $c = shift;

    my $params = $c->req->params->to_hash;

    my $recipient = $c->stash('recipient');

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
