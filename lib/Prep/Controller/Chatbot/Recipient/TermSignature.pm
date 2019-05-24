package Prep::Controller::Chatbot::Recipient::TermSignature;
use Mojo::Base 'Prep::Controller';

sub post {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    my $signature = $recipient->term_signatures->execute(
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
            recipient_id                  => $signature->{term_signature}->{recipient_id},
            offline_pre_registration_form => $signature->{offline_pre_registration_form}
        }
    )
}

1;
