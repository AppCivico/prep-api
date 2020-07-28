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

                die \['category', 'invalid'] unless $category =~ m/(quiz|screening|quiz_brincadeira|publico_interesse|recrutamento)/;
            }
        },
    );

    if ($c->req->params->to_hash->{category} eq 'recrutamento') {
        die \['fb_id', 'invalid'] unless $recipient->recipient_flag->is_target_audience && $recipient->recipient_flag->is_target_audience == 1;
    }

    # Verificando se a stash precisa ser resetada.
    my $stash = $recipient->stashes->search(
        { 'category.name' => $c->req->params->to_hash->{category} },
        { join => { 'question_map' => 'category' } }
    )->next;

    if ($stash && $stash->must_be_reseted && $stash->finished) {
        $stash->update(
            {
                finished        => 0,
                must_be_reseted => 0
            }
        );

        $stash->initiate;
    }

    my $pending_question_data = $recipient->get_next_question_data( $c->req->params->to_hash->{category} );
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
            ( exists $pending_question_data->{is_part_of_research}      ? ( is_part_of_research => $pending_question_data->{is_part_of_research} ) : () ),
            ( exists $pending_question_data->{emergency_rerouting}      ? ( emergency_rerouting => $pending_question_data->{emergency_rerouting} ) : () ),
            ( exists $pending_question_data->{suggest_appointment}      ? ( suggest_appointment => $pending_question_data->{suggest_appointment} ) : () )
        }
    )
}

1;
