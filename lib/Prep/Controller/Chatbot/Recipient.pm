package Prep::Controller::Chatbot::Recipient;
use Mojo::Base 'Prep::Controller';

sub stasher {
    my $c = shift;

    $c->validate_request_params(
        fb_id => {
            type     => 'Num',
            required => 1,
        },
    );

    $c->stash( collection => $c->schema->resultset('Recipient') );

    my $recipient = $c->schema->resultset('Recipient')->search( { fb_id => $c->req->params->to_hash->{fb_id} } )->next;
    die \['fb_id', 'invalid'] unless $recipient;

    $c->stash(
        recipient  => $recipient,
        collection => $c->stash('collection')->search_rs( { id => $recipient->id } )
    )
}

sub post {
    my $c = shift;

    my $params = $c->req->params->to_hash;

    my $recipient = $c->schema->resultset('Recipient')->execute(
        $c,
        for  => 'create',
        with => $params
    );

    return $c
    ->redirect_to('current')
    ->render(
        json   => { id => $recipient->id },
        status => 201,
    );
}

sub get {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    return $c->render(
        status => 200,
        json   => {

            (
                map { $_ => $recipient->$_ } qw(
                    id fb_id name integration_token page_id
                    picture opt_in finished_quiz updated_at created_at
                    signed_term has_appointments city system_labels
                    phone instagram voucher_type prep_reminder_on_demand
                    combina_city
                  )
            ),

            (
                map { $_ => $recipient->recipient_flag->$_ } qw(
                    prep_since is_eligible_for_research is_part_of_research
                    is_prep is_target_audience finished_publico_interesse
                    finished_recrutamento finished_quiz_brincadeira risk_group
                  )
            ),

            (
                $recipient->prep_reminder ?
                    (
                        map { 'prep_' . $_ => $recipient->prep_reminder->$_ } qw(
                            reminder_before reminder_before_interval reminder_after reminder_after_interval
                            reminder_running_out reminder_running_out_date reminder_running_out_count
                        )
                    )
                :   ()
            ),

            (
                $recipient->combina_reminder ?
                    (
                        map { 'combina_' . $_ => $recipient->combina_reminder->$_ } qw(
                            reminder_hours_before reminder_hour_exact reminder_22h reminder_double
                        )
                    )
                :   ()
            )
        }
    )
}

sub put {
    my $c = shift;

    my $params = $c->req->params->to_hash;

    my $recipient = $c->stash('recipient');

    my $recipient_put = $recipient->execute(
        $c,
        for  => 'update',
        with => $params
    );

    return $c->render(
        $c,
        code => 200,
        json => {
            id => $recipient->id,

            ( $recipient_put->{running_out_wait_until} ? (running_out_wait_until => $recipient_put->{running_out_wait_until}) : () ),
            ( $recipient_put->{running_out_date}       ? (running_out_date => $recipient_put->{running_out_date}) : () ),
        }
    )
}

sub prep_reminder_yes {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    eval {$recipient->prep_reminder_confirmation};

    return $c->render(
        $c,
        code => $@ ? 400 : 200,
        json => { id => $recipient->id }
    )
}

sub prep_reminder_no {
    my $c = shift;

    my $recipient = $c->stash('recipient');

    eval {$recipient->notify_reminder_no};

    return $c->render(
        $c,
        code => $@ ? 400 : 200,
        json => { id => $recipient->id }
    )
}


1;
