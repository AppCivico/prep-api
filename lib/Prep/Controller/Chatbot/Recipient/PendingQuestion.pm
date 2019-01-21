package Prep::Controller::Chatbot::Recipient::PendingQuestion;
use Mojo::Base 'Prep::Controller';

sub get {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    my $pending_question_data = $recipient->get_pending_question_data;
    my $question              = $pending_question_data->{question}->decoded;

    return $c->render(
        status => 200,
        json   => {
            code                => $question->{code},
            text                => $question->{text},
            type                => $question->{type},
            multiple_choices    => $question->{multiple_choices},
            extra_quick_replies => $question->{extra_quick_replies},
            has_more            => $pending_question_data->{has_more}
        }
    )
}

1;
