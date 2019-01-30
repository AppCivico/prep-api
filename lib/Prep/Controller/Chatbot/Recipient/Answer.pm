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
    # use DDP; p $answer;
    return $c->render(
        status => 201,
        json   => {
            id            => $answer->{answer}->id,
            finished_quiz => $answer->{finished_quiz},
            ( $answer->{is_part_of_research} ? ( is_part_of_research => $answer->{is_part_of_research} ) : () ),
            ( $answer->{is_eligible_for_research} ? ( is_eligible_for_research => $answer->{is_eligible_for_research} ) : () )
        }
    )
}

1;
