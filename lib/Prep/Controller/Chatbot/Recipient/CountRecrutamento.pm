package Prep::Controller::Chatbot::Recipient::CountRecrutamento;
use Mojo::Base 'Prep::Controller';

sub post {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    $recipient->update( { count_recrutamento => $recipient->count_recrutamento + 1 } );

    return $c->render(
        status => 201,
        json   => {
            id                     => $recipient->id,
            count_recrutamento => $recipient->count_recrutamento
        }
    )
}

sub get {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    return $c->render(
        status => 200,
        json   => {
            count_recrutamento => $recipient->count_recrutamento
        }
    )
}

1;
