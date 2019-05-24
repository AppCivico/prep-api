package Prep::Controller::Internal::Integration::Recipient::Notification;
use Mojo::Base 'Prep::Controller';

sub post {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    my $notification = $recipient->external_notifications->execute(
        $c,
        for  => 'create',
        with => $c->req->params->to_hash
    );

    return $c->render(
        status => 201,
        json   => {
            id => $notification->id
        }
    )
}

1;
