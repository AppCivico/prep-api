package Prep::Controller::Chatbot::Recipient::Answer;
use Mojo::Base 'Prep::Controller';

sub post {
    my $c = shift;

	$c->validate_request_params(
		category => {
			type       => 'Str',
			required   => 1,
			post_check => sub {
				my $category = $c->req->params->to_hash->{category};

				die \['category', 'invalid'] unless $category =~ m/(quiz|screening)/;
			}
		},
	);

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
            ( $answer->{is_part_of_research} ? ( is_part_of_research => $answer->{is_part_of_research} ) : () ),
            ( $answer->{is_eligible_for_research} ? ( is_eligible_for_research => $answer->{is_eligible_for_research} ) : () )
        }
    )
}

1;
