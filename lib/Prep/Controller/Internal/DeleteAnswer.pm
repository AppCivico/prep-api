package Prep::Controller::Internal::DeleteAnswer;
use Mojo::Base 'Prep::Controller';

sub post {
    my $c = shift;

    $c->validate_request_params(
        fb_id => {
            required => 1,
            type     => 'Num'
        }
    );

    my $recipient_fb_id = $c->req->params->to_hash->{fb_id};
    my $recipient       = $c->schema->resultset('Recipient')->search( { fb_id => $recipient_fb_id } )->next
      or die \['fb_id', 'invalid'];

    eval {
        $recipient->answers->delete;
        $recipient->update(
            {
                finished_quiz          => 0,
                count_sent_quiz        => 0,
                count_invited_research => 0,
                count_share            => 0
            }
        );
        $recipient->stashes->delete;
    };

    return $c->render(
        status => 200,
        json   => {
            success => $@ ? 0 : 1
        }
    )
}

1;
