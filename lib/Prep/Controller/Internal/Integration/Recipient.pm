package Prep::Controller::Internal::Integration::Recipient;
use Mojo::Base 'Prep::Controller';

sub stasher {
    my $c = shift;

    $c->validate_request_params(
        integration_token => {
            required => 1,
            type     => 'Num'
        },
    );

    $c->stash( collection => $c->schema->resultset('Recipient') );

    my $recipient = $c->schema->resultset('Recipient')->search( { integration_token => $c->req->params->to_hash->{integration_token} } )->next
      or die \['integration_token', 'invalid'];

    $c->stash(
        recipient  => $recipient,
        collection => $c->stash('collection')->search_rs( { id => $recipient->id } )
    )
}

sub get {
    my $c = shift;

    $c->validate_request_params(
        integration_token => {
            required => 1,
            type     => 'Num'
        },
    );

    my $recipient = $c->schema->resultset('Recipient')->search( { integration_token => $c->req->params->to_hash->{integration_token} } )->next
      or die \['integration_token', 'invalid'];

    return $c->render(
        status => 200,
        json   => {
            integration_token   => $recipient->integration_token,
            name                => $recipient->name,
            is_part_of_research => $recipient->recipient_flag->is_part_of_research,
            is_prep             => $recipient->recipient_flag->is_prep,
            signed_term         => $recipient->recipient_flag->signed_term
        }
    )
}

1;
