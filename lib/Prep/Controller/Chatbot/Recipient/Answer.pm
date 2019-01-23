package Prep::Controller::Chatbot::Recipient::Answer;
use Mojo::Base 'Prep::Controller';

sub post {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    my $answer = $recipient->answers->execute(
        $c,
        for  => 'create',
        with => $c->req->params->to_hash
    );

    return $c->render(
        status => 201,
        json   => {
            id            => $answer->{answer}->id,
            finished_quiz => $answer->{finished_quiz},
            ( $answer->{is_prep} ? ( is_prep => $answer->{is_prep} ) : () )
        }
    )
}

1;
