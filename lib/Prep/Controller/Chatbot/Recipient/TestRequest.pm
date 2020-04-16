package Prep::Controller::Chatbot::Recipient::TestRequest;
use Mojo::Base 'Prep::Controller';

sub post {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    my $test_request = $recipient->test_requests->execute(
        $c,
        for  => 'create',
        with => {
            %{$c->req->params->to_hash},
            recipient_id => $recipient->id
        }
    );

    return $c->render(
        status => 201,
        json   => {
            id           => $test_request->id,
            recipient_id => $test_request->recipient_id,
        }
    )
}

1;
