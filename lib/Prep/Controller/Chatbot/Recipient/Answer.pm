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

    if ( $answer->{finished_quiz} == 1 && $c->req->params->to_hash->{category} eq 'screening' ) {
        $recipient->reset_screening;
    }

    return $c->render(
        status => 201,
        json   => {
            id            => $answer->{answer}->id,
            finished_quiz => $answer->{finished_quiz},
            ( exists $answer->{is_part_of_research}      ? ( is_part_of_research => $answer->{is_part_of_research} ) : () ),
            ( exists $answer->{is_target_audience}      ? ( is_target_audience => $answer->{is_target_audience} ) : () ),
            ( exists $answer->{is_eligible_for_research} ? ( is_eligible_for_research => $answer->{is_eligible_for_research} ) : () ),
            ( exists $answer->{emergency_rerouting}      ? ( emergency_rerouting => $answer->{emergency_rerouting} ) : () ),
            ( exists $answer->{suggest_appointment}      ? ( suggest_appointment => $answer->{suggest_appointment} ) : () ),
            ( exists $answer->{go_to_appointment}        ? ( go_to_appointment => $answer->{go_to_appointment} ) : () ),
            ( exists $answer->{go_to_autotest}        ? ( go_to_autotest => $answer->{go_to_autotest} ) : () ),
            ( exists $answer->{suggest_wait_for_test}        ? ( suggest_wait_for_test => $answer->{suggest_wait_for_test} ) : () ),
            ( exists $answer->{go_to_test}        ? ( go_to_test => $answer->{go_to_test} ) : () )
        }
    )
}

1;
