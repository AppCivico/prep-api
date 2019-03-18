package Prep::Controller::Chatbot::Recipient::CountQuiz;
use Mojo::Base 'Prep::Controller';

sub post {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    $recipient->update( { count_sent_quiz => $recipient->count_sent_quiz + 1 } );

    return $c->render(
        status => 201,
        json   => {
            id         => $recipient->id,
            count_quiz => $recipient->count_sent_quiz
        }
    )
}

sub get {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    return $c->render(
        status => 200,
        json   => {
            count_quiz => $recipient->count_sent_quiz
        }
    )
}

1;
