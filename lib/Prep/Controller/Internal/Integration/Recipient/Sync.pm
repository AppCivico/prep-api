package Prep::Controller::Internal::Integration::Recipient::Sync;
use Mojo::Base 'Prep::Controller';

sub post {
    my $c = shift;

    $c->validate_request_params(
        is_part_of_research => {
            required => 0,
            type     => 'Bool'
        },
        is_prep => {
            required => 1,
            type     => 'Bool'
        }
    );

    my $recipient = $c->stash('recipient');

    $recipient = $recipient->execute(
        $c,
        for  => 'update',
        with => $c->req->params->to_hash
    );

    return $c->render(
        status => 200,
        json   => {
            recipient_integration_token => $recipient->integration_token
        }
    )
}

1;
