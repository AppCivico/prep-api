package Prep::Controller::Internal::SetProfilePrep;
use Mojo::Base 'Prep::Controller';

sub post {
    my $c = shift;

    $c->validate_request_params(
        fb_id => {
            required => 1,
            type     => 'Num'
        },
        profile => {
            required => 1,
            type     => 'Str'
        }
    );

    my $recipient_fb_id = $c->req->params->to_hash->{fb_id};
    my $recipient       = $c->schema->resultset('Recipient')->search( { fb_id => $recipient_fb_id } )->next
      or die \['fb_id', 'invalid'];

    my $profile = $c->req->params->to_hash->{profile};
    die \['profile', 'invalid'] unless $profile =~ m/^(prep|not-prep)$/;

    eval {

        if ($profile eq 'prep') {
            $recipient->recipient_flag->update(
                {
                    finished_quiz              => 1,
                    is_target_audience         => 1,
                    is_prep                    => 1,
                    finished_publico_interesse => 1,
                }
            );
        }
        else {
            $recipient->recipient_flag->update(
                {
                    finished_quiz => 1,
                    finished_publico_interesse => 1,
                    finished_recrutamento => 1,
                    is_prep => 0
                }
            );
        }
    };

    return $c->render(
        status => 200,
        json   => {
            success => $@ ? 0 : 1
        }
    )
}

1;
