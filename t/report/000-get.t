use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Prep::Test;

my $t      = test_instance;
my $schema = $t->app->schema;

use JSON;

db_transaction {
    my $chatbot_security_token = $ENV{CHATBOT_SECURITY_TOKEN};
    my $security_token         = $ENV{REPORT_SECURITY_TOKEN};

    my $res;
    subtest 'Test basic params' => sub {
        $res = $t->get_ok("/api/report/interaction")
        ->status_is(400)
        ->json_is('/form_error/security_token', 'missing')
        ->tx->res->json;

        $res = $t->get_ok(
            "/api/report/interaction?security_token=wrong_st",
        )
        ->status_is(400)
        ->json_is('/form_error/security_token', 'invalid')
        ->tx->res->json;

        $res = $t->get_ok(
            "/api/report/interaction?security_token=$security_token&since=foo",
        )
        ->status_is(400)
        ->json_is('/form_error/since', 'invalid')
        ->tx->res->json;

        $res = $t->get_ok(
            "/api/report/interaction?security_token=$security_token&until=foo",
        )
        ->status_is(400)
        ->json_is('/form_error/until', 'invalid')
        ->tx->res->json;

        my $now   = time();
        my $until = $now - 1;

        $res = $t->get_ok(
            "/api/report/interaction?security_token=$security_token&since=$now&until=$until",
        )
        ->status_is(400)
        ->json_is('/form_error/until', 'invalid')
        ->tx->res->json;

        ok $now -= 30;

        $res = $t->get_ok(
            "/api/report/interaction?security_token=$security_token&since=$now&until=$until",
        )
        ->status_is(200)
        ->tx->res->json;

        $res = $t->get_ok(
            "/api/report/interaction?security_token=$security_token",
        )
        ->status_is(200)
        ->json_has('/metrics')
        ->json_has('/metrics/0/value')
        ->json_has('/metrics/0/label')
        ->tx->res->json;
    };

    my $recipient;
    subtest 'Chatbot | Create recipient' => sub {
        $res = $t->post_ok(
            '/api/chatbot/recipient',
            form => {
                security_token => $chatbot_security_token,
                name           => 'foobar',
                page_id        => '1573221416102831',
                fb_id          => '111111'
            }
        )
        ->status_is(201)
        ->tx->res->json;

        ok $recipient = $schema->resultset('Recipient')->find($res->{id});
        ok $recipient->update( { city => 3 } )
    };

    subtest 'Test interaction' => sub {
        my $interaction_rs = $schema->resultset('Interaction');

        $res = $t->get_ok(
            "/api/report/interaction?security_token=$security_token",
        )
        ->status_is(200)
        ->tx->res->json;

        ok my $metric = $res->{metrics}->[0];
        is $metric->{label}, 'Últimos 3 dias';
        is $metric->{value}, 0;

        ok my $now = time();

        ok my $interaction = $recipient->interactions->create(
            {
                started_at => \['to_timestamp(?)', $now - 86400],
                closed_at  => \['to_timestamp(?)', $now]
            }
        );

        $res = $t->get_ok(
            "/api/report/interaction?security_token=$security_token",
        )
        ->status_is(200)
        ->tx->res->json;

        ok $metric = $res->{metrics}->[0];
        is $metric->{label}, 'Últimos 3 dias';
        is $metric->{value}, 1;

        ok $metric = $res->{metrics}->[1];
        is $metric->{label}, '4 a 7 dias';
        is $metric->{value}, 0;

        ok $interaction->update(
            {
                started_at => \['to_timestamp(?)', $now - (86400 * 4)],
                closed_at  => \['to_timestamp(?)', $now - (86400 * 3)]
            }
        );

        $res = $t->get_ok(
            "/api/report/interaction?security_token=$security_token",
        )
        ->status_is(200)
        ->tx->res->json;

        ok $metric = $res->{metrics}->[1];
        is $metric->{label}, '4 a 7 dias';
        is $metric->{value}, 1;

        ok $metric = $res->{metrics}->[2];
        is $metric->{label}, '8 a 15 dias';
        is $metric->{value}, 0;

        ok $interaction->update(
            {
                started_at => \['to_timestamp(?)', $now - (86400 * 8)],
                closed_at  => \['to_timestamp(?)', $now - (86400 * 7)]
            }
        );

        $res = $t->get_ok(
            "/api/report/interaction?security_token=$security_token",
        )
        ->status_is(200)
        ->tx->res->json;

        ok $metric = $res->{metrics}->[2];
        is $metric->{label}, '8 a 15 dias';
        is $metric->{value}, 1;

        ok $metric = $res->{metrics}->[3];
        is $metric->{label}, 'Mais de 15 dias';
        is $metric->{value}, 0;

        ok $interaction->update(
            {
                started_at => \['to_timestamp(?)', $now - (86400 * 15)],
                closed_at  => \['to_timestamp(?)', $now - (86400 * 14)]
            }
        );

        $res = $t->get_ok(
            "/api/report/interaction?security_token=$security_token",
        )
        ->status_is(200)
        ->tx->res->json;

        ok $metric = $res->{metrics}->[3];
        is $metric->{label}, 'Mais de 15 dias';
        is $metric->{value}, 1;

        $res = $t->get_ok(
            "/api/report/interaction-target-audience?security_token=$security_token",
        )
        ->status_is(200)
        ->tx->res->json;

        $res = $t->get_ok(
            "/api/report/interaction?security_token=$security_token&city=todas",
        )
        ->status_is(200)
        ->tx->res->json;

        $res = $t->get_ok(
            "/api/report/general-public?security_token=$security_token&city=todas",
        )
        ->status_is(200)
        ->tx->res->json;

        use DDP; p $res;

        # ok $metric = $res->{metrics}->[3];
        # is $metric->{label}, 'Mais de 15 dias';
        # is $metric->{value}, 0;

        # ok $recipient->update( { city => 1 } );

        # $res = $t->get_ok(
        #     "/api/report/interaction?security_token=$security_token&city=bh",
        # )
        # ->status_is(200)
        # ->tx->res->json;

        # ok $metric = $res->{metrics}->[3];
        # is $metric->{label}, 'Mais de 15 dias';
        # is $metric->{value}, 1;
    };
};

done_testing();