package Prep::Controller::Chatbot::Recipient::PendingQuestion;
use Mojo::Base 'Prep::Controller';

sub get {
    my $c = shift;

    my $recipient = $c->stash('recipient');

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

    my $pending_question_data = $recipient->get_pending_question_data( $c->req->params->to_hash->{category} );
    my $question              = $pending_question_data->{question} ? $pending_question_data->{question}->decoded : undef;

    return $c->render(
        status => 200,
        json   => {
            code                => $question ? $question->{code}                : undef,
            text                => $question ? $question->{text}                : undef,
            type                => $question ? $question->{type}                : undef,
            multiple_choices    => $question ? $question->{multiple_choices}    : undef,
            extra_quick_replies => $question ? $question->{extra_quick_replies} : undef,
            has_more            => $pending_question_data->{has_more},
            count_more          => $pending_question_data->{count_more},

            # Flags condicionais
            ( exists $pending_question_data->{is_eligible_for_research} ? ( is_eligible_for_research => $pending_question_data->{is_eligible_for_research} ) : () ),
            ( exists $pending_question_data->{is_part_of_research}      ? ( is_part_of_research => $pending_question_data->{is_part_of_research} ) : () )
        }
    )
}

1;
