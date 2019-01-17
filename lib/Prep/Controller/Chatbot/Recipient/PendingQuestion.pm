package Prep::Controller::Chatbot::Recipient::PendingQuestion;
use Mojo::Base 'Prep::Controller';

sub get {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    my $question = $recipient->get_pending_question;
    $question    = $question->decoded;

    return $c->render(
        status => 200,
        json   => {
            map {
                $_ => $question->{$_}
            } qw( code text type multiple_choices extra_quick_replies )
        }
    )
}

1;
