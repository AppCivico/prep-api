package Prep::Controller::Internal::Integration::Recipient::Sync;
use Mojo::Base 'Prep::Controller';

sub post {
    my $c = shift;

    my $params = $c->req->json;

    my $recipient = $c->stash('recipient');

    $recipient = $recipient->execute(
        $c,
        for  => 'sync_with_simprep',
        with => $params
    );

    return $c->render(
        status => 200,
        json   => {
            recipient_integration_token => $recipient->integration_token
        }
    )
}

1;
