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
                integration_token => undef,
                count_sent_quiz        => 0,
                count_invited_research => 0,
                count_share            => 0,
                voucher_type           => undef,
                phone                  => undef,
                instagram              => undef,
            }
        );
        $recipient->recipient_flag->update(
            {
                finished_quiz              => 0,
                is_eligible_for_research   => undef,
                is_part_of_research        => 0,
                is_target_audience         => undef,
                signed_term                => 0,
                is_prep                    => undef,
                risk_group                 => undef,
                finished_publico_interesse => 0,
                finished_recrutamento      => 0,
                finished_quiz_brincadeira  => 0,
            }
        );
        $recipient->term_signatures->delete;
        $recipient->appointments->delete;
        $recipient->stashes->delete;
        $recipient->quick_reply_logs->delete;
        $recipient->interactions->delete;

        if ($recipient->prep_reminder) {
            $recipient->prep_reminder->notification_queues->delete;
            $recipient->prep_reminder->delete;
        }

        $recipient->combina_reminder->delete if $recipient->combina_reminder;

        for my $voucher ( $recipient->combina_vouchers->all ) {
            $voucher->update( { recipient_id => undef, assigned_at => undef } )
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
