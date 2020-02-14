package Prep::Controller::Chatbot::Recipient::Interaction;
use Mojo::Base 'Prep::Controller';

sub create {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    my $interaction = $recipient->interactions->execute(
        $c,
        for  => 'create',
        with => {
            recipient_id => $recipient->id
        }
    );

    return $c->render(
        status => 201,
        json   => {
            id => $interaction->id,
        }
    )
}

sub close {
    my $c = shift;

    $c->validate_request_params(
        interaction_id => {
            type     => 'Int',
            required => 1,
        }
    );

    my $recipient = $c->stash('recipient');

    my $interaction = $recipient->interactions->find($c->req->params->to_hash->{interaction_id});
    die \['interaction_id', 'invalid'] unless $interaction;

    # $interaction->close;

    $interaction->update( { closed_at => \'NOW()' } );

    return $c->render(
        status => 200,
        json   => {
            id => $interaction->id,
        }
    )
}

sub get {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    return $c->render(
        status => 200,
        json   => $recipient->interactions->build_list
    )
}

1;
