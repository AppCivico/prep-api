package Prep::Controller::Chatbot::Recipient::CountQuizBrincadeira;
use Mojo::Base 'Prep::Controller';

sub post {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    $recipient->update( { count_quiz_brincadeira => $recipient->count_quiz_brincadeira + 1 } );

    return $c->render(
        status => 201,
        json   => {
            id                     => $recipient->id,
            count_quiz_brincadeira => $recipient->count_quiz_brincadeira
        }
    )
}

sub get {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    return $c->render(
        status => 200,
        json   => {
            count_quiz_brincadeira => $recipient->count_quiz_brincadeira
        }
    )
}

1;
