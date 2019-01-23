package Prep::Controller::Chatbot::Recipient::PendingQuestion;
use Mojo::Base 'Prep::Controller';

sub get {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    my $pending_question_data = $recipient->get_pending_question_data;
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
            count_more          => $pending_question_data->{count_more}
        }
    )
}

1;
