package Prep::Controller::Chatbot::Recipient::CountPublicoInteresse;
use Mojo::Base 'Prep::Controller';

sub post {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    $recipient->update( { count_publico_interesse => $recipient->count_publico_interesse + 1 } );

    return $c->render(
        status => 201,
        json   => {
            id                     => $recipient->id,
            count_publico_interesse => $recipient->count_publico_interesse
        }
    )
}

sub get {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    return $c->render(
        status => 200,
        json   => {
            count_publico_interesse => $recipient->count_publico_interesse
        }
    )
}

1;
