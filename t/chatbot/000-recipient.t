use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Prep::Test;

my $t      = test_instance;
my $schema = $t->app->schema;

db_transaction {
    my $security_token = $ENV{CHATBOT_SECURITY_TOKEN};

    # Toda requisição para endpoints /chatbot
    # deve conter o security token
    subtest 'Chatbot | Security token' => sub {
        # Sem security token
        $t->post_ok('/api/chatbot/recipient')->status_is(403);

        # Com security token inválido
        $t->post_ok( '/api/chatbot/recipient', form => { security_token => 'FOObar' } )->status_is(403);
    };

    subtest 'Chatbot | Create recipient' => sub {

        subtest 'Invalid' => sub {
            # Sem fb_id
            $t->post_ok(
                '/api/chatbot/recipient',
                form => {
                    security_token => $security_token,
                    name           => 'foobar',
                    page_id        => '1573221416102831'
                }
            )
            ->status_is(400)
            ->json_has('/form_error/fb_id')
            ->json_is('/form_error/fb_id', 'missing');

            # Sem name
            $t->post_ok(
                '/api/chatbot/recipient',
                form => {
                    security_token => $security_token,
                    page_id        => '1573221416102831',
                    fb_id          => '710488549074724'
                }
            )
            ->status_is(400)
            ->json_has('/form_error/name')
            ->json_is('/form_error/name', 'missing');

            # Sem page_id
            $t->post_ok(
                '/api/chatbot/recipient',
                form => {
                    security_token => $security_token,
                    name           => 'foobar',
                    fb_id          => '710488549074724'
                }
            )
            ->status_is(400)
            ->json_has('/form_error/page_id')
            ->json_is('/form_error/page_id', 'missing');

            # fb_id invalido
            $t->post_ok(
                '/api/chatbot/recipient',
                form => {
                    security_token => $security_token,
                    name           => 'foobar',
                    page_id        => '1573221416102831',
                    fb_id          => 'foobar'
                }
            )
            ->status_is(400)
            ->json_has('/form_error/fb_id')
            ->json_is('/form_error/fb_id', 'invalid');


            # page_id invalido
            $t->post_ok(
                '/api/chatbot/recipient',
                form => {
                    security_token => $security_token,
                    name           => 'foobar',
                    page_id        => 'foobar',
                    fb_id          => '710488549074724'
                }
            )
            ->status_is(400)
            ->json_has('/form_error/page_id')
            ->json_is('/form_error/page_id', 'invalid');
        };

        $t->post_ok(
            '/api/chatbot/recipient',
            form => {
                security_token => $security_token,
                name           => 'foobar',
                page_id        => '1573221416102831',
                fb_id          => '710488549074724'
            }
        )
        ->status_is(201)
        ->json_has('/id');

        # fb_id repetido
        $t->post_ok(
            '/api/chatbot/recipient',
            form => {
                security_token => $security_token,
                name           => 'Barbaz',
                page_id        => '1573221416102831',
                fb_id          => '710488549074724'
            }
        )
        ->status_is(400)
        ->json_has('/form_error/fb_id')
        ->json_is('/form_error/fb_id', 'invalid');
    };

    subtest 'Chatbot | Get recipient' => sub {
        # Sem fb_id
        $t->get_ok(
            '/api/chatbot/recipient',
            form => { security_token => $security_token }
        )
        ->status_is(400)
        ->json_has('/form_error/fb_id')
        ->json_is('/form_error/fb_id', 'missing');

        # Com fb_id inválido
        $t->get_ok(
            '/api/chatbot/recipient',
            form => {
                security_token => $security_token,
                fb_id          => 'foo'
            }
        )
        ->status_is(400)
        ->json_has('/form_error/fb_id')
        ->json_is('/form_error/fb_id', 'invalid');

        # Com fb_id inexistente
        $t->get_ok(
            '/api/chatbot/recipient',
            form => {
                security_token => $security_token,
                fb_id          => '1111111'
            }
        )
        ->status_is(400)
        ->json_has('/form_error/fb_id')
        ->json_is('/form_error/fb_id', 'invalid');

        $t->get_ok(
            '/api/chatbot/recipient',
            form => {
                security_token => $security_token,
                fb_id          => '710488549074724'
            }
        )
        ->status_is(200)
        ->json_has('/id')
        ->json_has('/fb_id')
        ->json_has('/page_id')
        ->json_has('/name')
        ->json_has('/picture')
        ->json_has('/updated_at')
        ->json_has('/created_at')
        ->json_has('/opt_in')
        ->json_has('/finished_quiz')
        ->json_is('/fb_id',   '710488549074724')
        ->json_is('/page_id', '1573221416102831')
        ->json_is('/name',    'foobar')
        ->json_is('/finished_quiz', 0)
        ->json_is('/opt_in',  1);
    };

    subtest 'Chatbot | Update recipient' => sub {
        # Sem fb_id
        $t->put_ok(
            '/api/chatbot/recipient',
            form => { security_token => $security_token }
        )
        ->status_is(400)
        ->json_has('/form_error/fb_id')
        ->json_is('/form_error/fb_id', 'missing');

        $t->put_ok(
            '/api/chatbot/recipient',
            form => {
                security_token => $security_token,
                fb_id          => '710488549074724',
                name           => 'foobar_1',
                opt_in         => 0
            }
        )
        ->status_is(200)
        ->json_has('/id');

        $t->get_ok(
            '/api/chatbot/recipient',
            form => {
                security_token => $security_token,
                fb_id          => '710488549074724'
            }
        )
        ->status_is(200)
        ->json_is('/name',   'foobar_1')
        ->json_is('/opt_in', 0);
    };
};

done_testing();