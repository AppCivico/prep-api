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

    my $fb_id = '111111';
    my $recipient;
    subtest 'Chatbot | Create recipient' => sub {
        $res = $t->post_ok(
            '/api/chatbot/recipient',
            form => {
                security_token => $chatbot_security_token,
                name           => 'foobar',
                page_id        => '1573221416102831',
                fb_id          => $fb_id
            }
        )
        ->status_is(201)
        ->tx->res->json;

        ok $recipient = $schema->resultset('Recipient')->find($res->{id});
        ok $recipient->update( { city => 3 } )
    };

    subtest 'Create questions and question map' => sub {

        ok(
            my $question_map = $schema->resultset('QuestionMap')->create(
                {
                    map => to_json({
                        1 => 'A1',
                        2 => 'A2',
                        3 => 'A3',
                        4 => 'A4',
                        5 => 'A4a',
                        6 => 'A4b',
                        7 => 'A5',
                        8 => 'A6',
                        9 => 'A6a'
                    }),
                    category_id => 3
                }
            ),
            'question map created'
        );
        my $question_rs = $schema->resultset('Question');

        ok(
            $question_rs->create(
                {
                    code              => 'A1',
                    text              => 'Foobar?',
                    type              => 'multiple_choice',
                    question_map_id   => $question_map->id,
                    is_differentiator => 0,
                    multiple_choices  => to_json ({ 1 => 'foo', 2 => 'bar', 3 => 'FOOBAR', 4 => 'foobar' })
                }
            ),
            'A1 created'
        );

        ok(
            $question_rs->create(
                {
                    code              => 'A2',
                    text              => 'open_text?',
                    type              => 'open_text',
                    question_map_id   => $question_map->id,
                    is_differentiator => 0,
                    rules             => '{
                        "logic_jumps": [],
                        "qualification_conditions": [15, 16, 17, 18, 19],
                        "flags": [ "is_target_audience" ]
                    }'
                }
            ),
            'A2 created'
        );

        ok(
            $question_rs->create(
                {
                    code              => 'A3',
                    text              => 'Você gosta?',
                    type              => 'multiple_choice',
                    question_map_id   => $question_map->id,
                    is_differentiator => 1,
                    multiple_choices  => to_json (
                        {
                            1 => 'Sim',
                            2 => 'Não',
                            3 => 'FOOBAR',
                            4 => 'barvaz',
                            5 => 'foo',
                            6 => 'bar',
                            7 => 'foobar',
                            8 => 'quz'
                        }
                    ),
                    rules => '{
                        "logic_jumps": [],
                        "qualification_conditions": [1, 4, 5, 6, 7],
                        "flags": [ "is_target_audience" ]
                    }'
                }
            ),
            'A3 created'
        );

        ok(
            $question_rs->create(
                {
                    code              => 'A4',
                    text              => 'barbaz?',
                    type              => 'multiple_choice',
                    question_map_id   => $question_map->id,
                    is_differentiator => 0,
                    multiple_choices  => to_json ({ 1 => 'Sim', 2 => 'Nunca', 3 => 'Regularmente' }),
                    rules             => '{
                        "logic_jumps": [
                        {
                            "code": "A4a",
                            "values": [1]
                        },
                        {
                            "code": "A4b",
                            "values": [2]
                        }
                        ],
                        "qualification_conditions": [],
                        "flags": []
                    }'
                }
            ),
            'A4 created'
        );

        ok(
            $question_rs->create(
                {
                    code                => 'A4a',
                    text                => 'barbaz?',
                    type                => 'multiple_choice',
                    question_map_id     => $question_map->id,
                    is_differentiator   => 0,
                    multiple_choices    => '{
                        "1": "1º ano E.Fundamental",
                        "2": "2º ano E.Fundamental",
                        "3": "3º ano E.Fundamental",
                        "4": "4º ano E.Fundamental",
                        "5": "5º ano E.Fundamental",
                        "6": "6º ano E.Fundamental",
                        "7": "7º ano E.Fundamental",
                        "8": "8º ano E.Fundamental",
                        "9": "9º ano E.Fundamental"
                    }',
                }
            ),
            'A4a created'
        );

        ok(
            $question_rs->create(
                {
                    code                => 'A4b',
                    text                => 'barbaz?',
                    type                => 'multiple_choice',
                    question_map_id     => $question_map->id,
                    is_differentiator   => 0,
                    multiple_choices    => '{
                        "1": "1º ano E.Médio",
                        "2": "2º ano E.Médio",
                        "3": "3º ano E.Médio"
                    }',
                }
            ),
            'A4b created'
        );


        ok(
            $question_rs->create(
                {
                    code                => 'A5',
                    text                => 'barbaz?',
                    type                => 'multiple_choice',
                    question_map_id     => $question_map->id,
                    is_differentiator   => 0,
                    multiple_choices    => '{
                        "1": "Branca",
                        "2": "Preta",
                        "3": "Amarela",
                        "4": "Parda",
                        "5": "Indígena"
                    }',
                }
            ),
            'A5 created'
        );

        ok(
            $question_rs->create(
                {
                    code                => 'A6',
                    text                => 'barbaz?',
                    type                => 'multiple_choice',
                    question_map_id     => $question_map->id,
                    is_differentiator   => 0,
                    multiple_choices    => '{
                        "1": "Sim",
                        "2": "Não"
                    }',
                    rules => '{
                        "logic_jumps": [ ],
                        "qualification_conditions": [1],
                        "flags": [ "is_target_audience" ]
                    }'
                }
            ),
            'A6 created'
        );

        ok(
            $question_rs->create(
                {
                    code                => 'A6a',
                    text                => 'barbaz?',
                    type                => 'multiple_choice',
                    question_map_id     => $question_map->id,
                    is_differentiator   => 0,
                    multiple_choices    => '{
                        "1": "Sim",
                        "2": "Não"
                    }',
                    rules => '{
                        "logic_jumps": [ ],
                        "qualification_conditions": [],
                        "flags": [ "is_target_audience", "risk_group" ]
                    }'
                }
            ),
            'A6a created'
        );
    };

    subtest 'Answer publico-interesse flow' => sub {
        $res = $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $chatbot_security_token,
                fb_id          => $fb_id,
                category       => 'publico_interesse'
            }
        )
        ->status_is(200)
        ->tx->res->json;

        is $res->{code}, 'A1';

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $chatbot_security_token,
                fb_id          => $fb_id,
                code           => 'A1',
                category       => 'publico_interesse',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->tx->res->json;

        is $res->{finished_quiz}, 0;

        $res = $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $chatbot_security_token,
                fb_id          => $fb_id,
                category       => 'publico_interesse'
            }
        )
        ->status_is(200)
        ->tx->res->json;

        is $res->{code}, 'A2';

        # Testing qualifying conditions for A2.
        subtest 'A2 qualifying' => sub {
            for (1 .. 14) {
                db_transaction{
                    $res = $t->post_ok(
                        '/api/chatbot/recipient/answer',
                        form => {
                            security_token => $chatbot_security_token,
                            fb_id          => $fb_id,
                            code           => 'A2',
                            category       => 'publico_interesse',
                            answer_value   => $_
                        }
                    )
                    ->status_is(201)
                    ->tx->res->json;

                    is $res->{finished_quiz}, 1;
                };
            }
        };

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $chatbot_security_token,
                fb_id          => $fb_id,
                code           => 'A2',
                category       => 'publico_interesse',
                answer_value   => 19
            }
        )
        ->status_is(201)
        ->tx->res->json;

        is $res->{finished_quiz}, 0;

        $res = $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $chatbot_security_token,
                fb_id          => $fb_id,
                category       => 'publico_interesse'
            }
        )
        ->status_is(200)
        ->tx->res->json;

        is $res->{code}, 'A3';

        # Testing qualifying conditions for A3 (1, 4, 5, 6, 7)
        subtest 'A3 qualifying' => sub {

            for (1 .. 3) {
                my $i;

                if ($_ == 1) {
                    $i = 2;
                }
                elsif ($_ == 2) {
                    $i = 3;
                }
                else {
                    $i = 8;
                }

                db_transaction{
                    $res = $t->post_ok(
                        '/api/chatbot/recipient/answer',
                        form => {
                            security_token => $chatbot_security_token,
                            fb_id          => $fb_id,
                            code           => 'A3',
                            category       => 'publico_interesse',
                            answer_value   => $i
                        }
                    )
                    ->status_is(201)
                    ->tx->res->json;

                    is $res->{finished_quiz}, 1;
                };
            }
        };

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $chatbot_security_token,
                fb_id          => $fb_id,
                code           => 'A3',
                category       => 'publico_interesse',
                answer_value   => 1
            }
        )
        ->status_is(201)
        ->tx->res->json;

        is $res->{finished_quiz}, 0;

        $res = $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $chatbot_security_token,
                fb_id          => $fb_id,
                category       => 'publico_interesse'
            }
        )
        ->status_is(200)
        ->tx->res->json;

        is $res->{code}, 'A4';

        # Testing A4 logic jumps
        subtest 'A4 logic jumps' => sub {
            db_transaction{
                $res = $t->post_ok(
                    '/api/chatbot/recipient/answer',
                    form => {
                        security_token => $chatbot_security_token,
                        fb_id          => $fb_id,
                        code           => 'A4',
                        category       => 'publico_interesse',
                        answer_value   => 1
                    }
                )
                ->status_is(201)
                ->tx->res->json;

                is $res->{finished_quiz}, 0;

                $res = $t->get_ok(
                    '/api/chatbot/recipient/pending-question',
                    form => {
                        security_token => $chatbot_security_token,
                        fb_id          => $fb_id,
                        category       => 'publico_interesse'
                    }
                )
                ->status_is(200)
                ->tx->res->json;

                is $res->{code}, 'A4a';

                $res = $t->post_ok(
                    '/api/chatbot/recipient/answer',
                    form => {
                        security_token => $chatbot_security_token,
                        fb_id          => $fb_id,
                        code           => 'A4a',
                        category       => 'publico_interesse',
                        answer_value   => 1
                    }
                )
                ->status_is(201)
                ->tx->res->json;

                is $res->{finished_quiz}, 0;

                $res = $t->get_ok(
                    '/api/chatbot/recipient/pending-question',
                    form => {
                        security_token => $chatbot_security_token,
                        fb_id          => $fb_id,
                        category       => 'publico_interesse'
                    }
                )
                ->status_is(200)
                ->tx->res->json;

                is $res->{code}, 'A5';
            };

            db_transaction{
                $res = $t->post_ok(
                    '/api/chatbot/recipient/answer',
                    form => {
                        security_token => $chatbot_security_token,
                        fb_id          => $fb_id,
                        code           => 'A4',
                        category       => 'publico_interesse',
                        answer_value   => 2
                    }
                )
                ->status_is(201)
                ->tx->res->json;

                is $res->{finished_quiz}, 0;

                $res = $t->get_ok(
                    '/api/chatbot/recipient/pending-question',
                    form => {
                        security_token => $chatbot_security_token,
                        fb_id          => $fb_id,
                        category       => 'publico_interesse'
                    }
                )
                ->status_is(200)
                ->tx->res->json;

                is $res->{code}, 'A4b';

                $res = $t->post_ok(
                    '/api/chatbot/recipient/answer',
                    form => {
                        security_token => $chatbot_security_token,
                        fb_id          => $fb_id,
                        code           => 'A4b',
                        category       => 'publico_interesse',
                        answer_value   => 1
                    }
                )
                ->status_is(201)
                ->tx->res->json;

                is $res->{finished_quiz}, 0;

                $res = $t->get_ok(
                    '/api/chatbot/recipient/pending-question',
                    form => {
                        security_token => $chatbot_security_token,
                        fb_id          => $fb_id,
                        category       => 'publico_interesse'
                    }
                )
                ->status_is(200)
                ->tx->res->json;

                is $res->{code}, 'A5';
            };
        };

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $chatbot_security_token,
                fb_id          => $fb_id,
                code           => 'A4',
                category       => 'publico_interesse',
                answer_value   => 3
            }
        )
        ->status_is(201)
        ->tx->res->json;

        is $res->{finished_quiz}, 0;

        $res = $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $chatbot_security_token,
                fb_id          => $fb_id,
                category       => 'publico_interesse'
            }
        )
        ->status_is(200)
        ->tx->res->json;

        is $res->{code}, 'A5';

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $chatbot_security_token,
                fb_id          => $fb_id,
                code           => 'A5',
                category       => 'publico_interesse',
                answer_value   => 1
            }
        )
        ->status_is(201)
        ->tx->res->json;

        is $res->{finished_quiz}, 0;

        $res = $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $chatbot_security_token,
                fb_id          => $fb_id,
                category       => 'publico_interesse'
            }
        )
        ->status_is(200)
        ->tx->res->json;

        is $res->{code}, 'A6';

        subtest 'A6 qualifying' => sub {
            db_transaction {
                $res = $t->post_ok(
                    '/api/chatbot/recipient/answer',
                    form => {
                        security_token => $chatbot_security_token,
                        fb_id          => $fb_id,
                        code           => 'A6',
                        category       => 'publico_interesse',
                        answer_value   => 2
                    }
                )
                ->status_is(201)
                ->tx->res->json;

                is $res->{finished_quiz}, 1;
            };
        };

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $chatbot_security_token,
                fb_id          => $fb_id,
                code           => 'A6',
                category       => 'publico_interesse',
                answer_value   => 1
            }
        )
        ->status_is(201)
        ->tx->res->json;

        is $res->{finished_quiz}, 0;

        $res = $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $chatbot_security_token,
                fb_id          => $fb_id,
                category       => 'publico_interesse'
            }
        )
        ->status_is(200)
        ->tx->res->json;

        is $res->{code}, 'A6a';

        subtest 'risk group flag' => sub {
            db_transaction {
                $res = $t->post_ok(
                    '/api/chatbot/recipient/answer',
                    form => {
                        security_token => $chatbot_security_token,
                        fb_id          => $fb_id,
                        code           => 'A6a',
                        category       => 'publico_interesse',
                        answer_value   => 1
                    }
                )
                ->status_is(201)
                ->tx->res->json;

                is $res->{finished_quiz}, 1;
                is $res->{is_target_audience}, 1;
                is $res->{risk_group}, 1;
            }
        };

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $chatbot_security_token,
                fb_id          => $fb_id,
                code           => 'A6a',
                category       => 'publico_interesse',
                answer_value   => 2
            }
        )
        ->status_is(201)
        ->tx->res->json;

        is $res->{finished_quiz}, 1;
        is $res->{is_target_audience}, 1;
        is $res->{risk_group}, 0;
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
                started_at => \['to_timestamp(?)', $now - (86400 * 7)],
                closed_at  => \['to_timestamp(?)', $now - (86400 * 6)]
            }
        );
        ok $interaction->discard_changes;

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
                started_at => \['to_timestamp(?)', $now - (86400 * 15)],
                closed_at  => \['to_timestamp(?)', $now - (86400 * 14)]
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
                started_at => \['to_timestamp(?)', $now - (86400 * 16)],
                closed_at  => \['to_timestamp(?)', $now - (86400 * 15)]
            }
        );
        ok $interaction->discard_changes;

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

        $res = $t->get_ok(
            "/api/report/target-audience?security_token=$security_token&city=todas",
        )
        ->status_is(200)
        ->tx->res->json;


        $res = $t->get_ok(
            "/api/report/intents?security_token=$security_token&city=todas",
        )
        ->status_is(200)
        ->tx->res->json;

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