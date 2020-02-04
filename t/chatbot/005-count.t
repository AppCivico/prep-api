use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Prep::Test;

use JSON;

my $t      = test_instance;
my $schema = $t->app->schema;

db_transaction {
    my $security_token = $ENV{CHATBOT_SECURITY_TOKEN};

    my ($recipient_id, $recipient);
    subtest 'Chatbot | Create recipient' => sub {
        $t->post_ok(
            '/api/chatbot/recipient',
            form => {
                security_token => $security_token,
                name           => 'foobar',
                page_id        => '1573221416102831',
                fb_id          => '111111'
            }
        )
        ->status_is(201);

        $recipient_id = $t->tx->res->json->{id};
        $recipient    = $schema->resultset('Recipient')->find($recipient_id);
    };

    subtest 'Chatbot | Count quiz' => sub {
        $t->get_ok(
            '/api/chatbot/recipient/count-quiz',
            form => {
                security_token => $security_token,
                fb_id          => '111111'
            }
        )
        ->status_is(200)
        ->json_is('/count_quiz', 0);

        $t->post_ok(
            '/api/chatbot/recipient/count-quiz',
            form => {
                security_token => $security_token,
                fb_id          => '111111'
            }
        )
        ->status_is(201)
        ->json_is('/count_quiz', 1);

        $t->get_ok(
            '/api/chatbot/recipient/count-quiz',
            form => {
                security_token => $security_token,
                fb_id          => '111111'
            }
        )
        ->status_is(200)
        ->json_is('/count_quiz', 1);
    };

    subtest 'Chatbot | Count invite' => sub {
        $t->get_ok(
            '/api/chatbot/recipient/count-research-invite',
            form => {
                security_token => $security_token,
                fb_id          => '111111'
            }
        )
        ->status_is(200)
        ->json_is('/count_invited_research', 0);

        $t->post_ok(
            '/api/chatbot/recipient/count-research-invite',
            form => {
                security_token => $security_token,
                fb_id          => '111111'
            }
        )
        ->status_is(201)
        ->json_is('/count_invited_research', 1);

        $t->get_ok(
            '/api/chatbot/recipient/count-research-invite',
            form => {
                security_token => $security_token,
                fb_id          => '111111'
            }
        )
        ->status_is(200)
        ->json_is('/count_invited_research', 1);
    };

    subtest 'Chatbot | Count share' => sub {
        $t->get_ok(
            '/api/chatbot/recipient/count-share',
            form => {
                security_token => $security_token,
                fb_id          => '111111'
            }
        )
        ->status_is(200)
        ->json_is('/count_share', 0);

        $t->post_ok(
            '/api/chatbot/recipient/count-share',
            form => {
                security_token => $security_token,
                fb_id          => '111111'
            }
        )
        ->status_is(201)
        ->json_is('/count_share', 1);

        $t->get_ok(
            '/api/chatbot/recipient/count-share',
            form => {
                security_token => $security_token,
                fb_id          => '111111'
            }
        )
        ->status_is(200)
        ->json_is('/count_share', 1);
    };

    subtest 'Chatbot | Count quiz brincadeira' => sub {
        $t->get_ok(
            '/api/chatbot/recipient/count-quiz-brincadeira',
            form => {
                security_token => $security_token,
                fb_id          => '111111'
            }
        )
        ->status_is(200)
        ->json_is('/count_quiz_brincadeira', 0);

        $t->post_ok(
            '/api/chatbot/recipient/count-quiz-brincadeira',
            form => {
                security_token => $security_token,
                fb_id          => '111111'
            }
        )
        ->status_is(201)
        ->json_is('/count_quiz_brincadeira', 1);

        $t->get_ok(
            '/api/chatbot/recipient/count-quiz-brincadeira',
            form => {
                security_token => $security_token,
                fb_id          => '111111'
            }
        )
        ->status_is(200)
        ->json_is('/count_quiz_brincadeira', 1);
    };

    subtest 'Chatbot | Count recrutamento' => sub {
        $t->get_ok(
            '/api/chatbot/recipient/count-recrutamento',
            form => {
                security_token => $security_token,
                fb_id          => '111111'
            }
        )
        ->status_is(200)
        ->json_is('/count_recrutamento', 0);

        $t->post_ok(
            '/api/chatbot/recipient/count-recrutamento',
            form => {
                security_token => $security_token,
                fb_id          => '111111'
            }
        )
        ->status_is(201)
        ->json_is('/count_recrutamento', 1);

        $t->get_ok(
            '/api/chatbot/recipient/count-recrutamento',
            form => {
                security_token => $security_token,
                fb_id          => '111111'
            }
        )
        ->status_is(200)
        ->json_is('/count_recrutamento', 1);
    };

    subtest 'Chatbot | Count publico interesse' => sub {
        $t->get_ok(
            '/api/chatbot/recipient/count-publico-interesse',
            form => {
                security_token => $security_token,
                fb_id          => '111111'
            }
        )
        ->status_is(200)
        ->json_is('/count_publico_interesse', 0);

        $t->post_ok(
            '/api/chatbot/recipient/count-publico-interesse',
            form => {
                security_token => $security_token,
                fb_id          => '111111'
            }
        )
        ->status_is(201)
        ->json_is('/count_publico_interesse', 1);

        $t->get_ok(
            '/api/chatbot/recipient/count-publico-interesse',
            form => {
                security_token => $security_token,
                fb_id          => '111111'
            }
        )
        ->status_is(200)
        ->json_is('/count_publico_interesse', 1);
    };
};

done_testing();