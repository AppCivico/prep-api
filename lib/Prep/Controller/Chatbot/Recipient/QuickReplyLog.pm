package Prep::Controller::Chatbot::Recipient::QuickReplyLog;
use Mojo::Base 'Prep::Controller';

sub create {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    my $quick_reply_log = $recipient->quick_reply_logs->execute(
        $c,
        for  => 'create',
        with => {
            recipient_id => $recipient->id,
            button_text  => $c->req->params->to_hash->{button_text},
            payload      => $c->req->params->to_hash->{payload},
        }
    );

    return $c->render(
        status => 201,
        json   => {
            recipient_id => $quick_reply_log->recipient_id,
            button_text  => $quick_reply_log->button_text,
            payload      => $quick_reply_log->payload
        }
    )
}

sub get {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    return $c->render(
        status => 200,
        json   => $recipient->quick_reply_logs->build_list
    )
}

1;
