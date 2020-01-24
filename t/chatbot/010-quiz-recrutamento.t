use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Prep::Test;
use Prep::Worker::Notify;
use JSON;

my $t      = test_instance;
my $schema = $t->app->schema;

db_transaction {
    my $security_token = $ENV{CHATBOT_SECURITY_TOKEN};

    subtest 'Create questions and question map' => sub {

        ok(
            my $question_map = $schema->resultset('QuestionMap')->create(
                {
                    map => to_json({
                        1  => "B1",
                        2  => "B2",
                        3  => "B3",
                        4  => "B4",
                        5  => "B5",
                        6  => "B6",
                        7  => "B7",
                        8  => "B8",
                        9  => "B9",
                        10 => "B10"
                    }),
                    category_id => 4
                }
            ),
            'question map created'
        );
        my $question_rs = $schema->resultset('Question');

        ok(
            $question_rs->create(
                {
                    code              => 'B1',
                    text              => 'Foobar?',
                    type              => 'multiple_choice',
                    question_map_id   => $question_map->id,
                    is_differentiator => 0,
                    multiple_choices  => '{
                        "1": "Sim, mais de 1",
                        "2": "Sim, apenas 1",
                        "3": "Não"
                    }',
                    rules => '{
                        "logic_jumps" : [
                            {
                                "code"   : "B2",
                                "values" : [1, 2]
                            }
                        ],
                        "qualification_conditions" : []
                    }'
                }
            ),
            'B1 created'
        );

        ok(
            $question_rs->create(
                {
                    code              => 'B2',
                    text              => 'Foobar?',
                    type              => 'multiple_choice',
                    question_map_id   => $question_map->id,
                    is_differentiator => 0,
                    multiple_choices  => '{
                        "1": "Sim, é positivo",
                        "2": "Sim, é negativo",
                        "3": "Ele nunca se testou",
                        "4": "Não sei"
                    }',
                }
            ),
            'B2 created'
        );

        ok(
            $question_rs->create(
                {
                    code              => 'B3',
                    text              => 'Você gosta?',
                    type              => 'open_text',
                    question_map_id   => $question_map->id,
                    is_differentiator => 1,
                    rules => '{
                        "logic_jumps" : [
                            {
                                "code"   : "B4",
                                "values" : {
                                    "operator" : ">",
                                    "value"    : "0"
                                }
                            }
                        ],
                        "qualification_conditions" : []
                    }'
                }
            ),
            'B3 created'
        );

        ok(
            $question_rs->create(
                {
                    code              => 'B4',
                    text              => 'barbaz?',
                    type              => 'multiple_choice',
                    question_map_id   => $question_map->id,
                    is_differentiator => 0,
                    multiple_choices  => '{
                        "1": "Sim",
                        "2": "Não"
                    }',
                    rules  => '{
                        "logic_jumps" : [
                            {
                                "code"   : "B5",
                                "values" : ["1"]
                            }
                        ],
                        "qualification_conditions" : []
                    }'
                }
            ),
            'B4 created'
        );

        ok(
            $question_rs->create(
                {
                    code                => 'B5',
                    text                => 'barbaz?',
                    type                => 'multiple_choice',
                    question_map_id     => $question_map->id,
                    is_differentiator   => 0,
                    multiple_choices    => '{
                        "1": "Sim",
                        "2": "Não"
                    }',
                }
            ),
            'B5 created'
        );

        ok(
            $question_rs->create(
                {
                    code                => 'B6',
                    text                => 'barbaz?',
                    type                => 'multiple_choice',
                    question_map_id     => $question_map->id,
                    is_differentiator   => 0,
                    multiple_choices    => '{
                        "1": "Sim",
                        "2": "Não"
                    }',
                }
            ),
            'B6 created'
        );


        ok(
            $question_rs->create(
                {
                    code                => 'B7',
                    text                => 'barbaz?',
                    type                => 'multiple_choice',
                    question_map_id     => $question_map->id,
                    is_differentiator   => 0,
                    multiple_choices    => '{
                        "1": "Uma vez",
                        "2": "De 2 a 4 vezes",
                        "3": "5 vezes ou mais",
                        "4": "Nenhuma vez"
                    }',
                }
            ),
            'B7 created'
        );

        ok(
            $question_rs->create(
                {
                    code                => 'B8',
                    text                => 'barbaz?',
                    type                => 'multiple_choice',
                    question_map_id     => $question_map->id,
                    is_differentiator   => 0,
                    multiple_choices    => '{
                        "1": "Sim",
                        "2": "Não"
                    }',
                }
            ),
            'B8 created'
        );

        ok(
            $question_rs->create(
                {
                    code                => 'B9',
                    text                => 'barbaz?',
                    type                => 'multiple_choice',
                    question_map_id     => $question_map->id,
                    is_differentiator   => 0,
                    multiple_choices    => '{
                        "1": "Sim",
                        "2": "Não"
                    }',
                }
            ),
            'B9 created'
        );

        ok(
            $question_rs->create(
                {
                    code                => 'B10',
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
                        "flags": [ "is_eligible_for_research" ]
                    }'
                }
            ),
            'B10 created'
        );
    };

    subtest 'Answer publico-interesse flow' => sub {
        # Creating recipient
        my $fb_id = '710488549074724';
        $t->post_ok(
            '/api/chatbot/recipient',
            form => {
                security_token => $security_token,
                name           => 'foobar',
                page_id        => '1573221416102831',
                fb_id          => $fb_id
            }
        )
        ->status_is(201);

        ok my $recipient = $schema->resultset('Recipient')->search( { fb_id => $fb_id } )->next;
        ok $recipient->recipient_flag->update( { is_target_audience => 1 } );

        my $res = $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'recrutamento'
            }
        )
        ->status_is(200)
        ->tx->res->json;

        is $res->{code}, 'B1';

        subtest 'B1 logic jump' => sub {
            db_transaction{
                $res = $t->post_ok(
                    '/api/chatbot/recipient/answer',
                    form => {
                        security_token => $security_token,
                        fb_id          => $fb_id,
                        code           => 'B1',
                        category       => 'recrutamento',
                        answer_value   => '1'
                    }
                )
                ->status_is(201)
                ->tx->res->json;

                is $res->{finished_quiz}, 0;

                $res = $t->get_ok(
                    '/api/chatbot/recipient/pending-question',
                    form => {
                        security_token => $security_token,
                        fb_id          => $fb_id,
                        category       => 'recrutamento'
                    }
                )
                ->status_is(200)
                ->tx->res->json;

                is $res->{code}, 'B2';
            };

            db_transaction{
                $res = $t->post_ok(
                    '/api/chatbot/recipient/answer',
                    form => {
                        security_token => $security_token,
                        fb_id          => $fb_id,
                        code           => 'B1',
                        category       => 'recrutamento',
                        answer_value   => '2'
                    }
                )
                ->status_is(201)
                ->tx->res->json;

                is $res->{finished_quiz}, 0;

                $res = $t->get_ok(
                    '/api/chatbot/recipient/pending-question',
                    form => {
                        security_token => $security_token,
                        fb_id          => $fb_id,
                        category       => 'recrutamento'
                    }
                )
                ->status_is(200)
                ->tx->res->json;

                is $res->{code}, 'B2';
            };
        };

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'B1',
                category       => 'recrutamento',
                answer_value   => '3'
            }
        )
        ->status_is(201)
        ->tx->res->json;

        is $res->{finished_quiz}, 0;

        $res = $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'recrutamento'
            }
        )
        ->status_is(200)
        ->tx->res->json;

        is $res->{code}, 'B3';

        subtest 'B3 logic jump' => sub {
            db_transaction{
                $res = $t->post_ok(
                    '/api/chatbot/recipient/answer',
                    form => {
                        security_token => $security_token,
                        fb_id          => $fb_id,
                        code           => 'B3',
                        category       => 'recrutamento',
                        answer_value   => '1'
                    }
                )
                ->status_is(201)
                ->tx->res->json;

                is $res->{finished_quiz}, 0;

                $res = $t->get_ok(
                    '/api/chatbot/recipient/pending-question',
                    form => {
                        security_token => $security_token,
                        fb_id          => $fb_id,
                        category       => 'recrutamento'
                    }
                )
                ->status_is(200)
                ->tx->res->json;

                is $res->{code}, 'B4';

                $res = $t->post_ok(
                    '/api/chatbot/recipient/answer',
                    form => {
                        security_token => $security_token,
                        fb_id          => $fb_id,
                        code           => 'B4',
                        category       => 'recrutamento',
                        answer_value   => '1'
                    }
                )
                ->status_is(201)
                ->tx->res->json;

                is $res->{finished_quiz}, 0;

                $res = $t->get_ok(
                    '/api/chatbot/recipient/pending-question',
                    form => {
                        security_token => $security_token,
                        fb_id          => $fb_id,
                        category       => 'recrutamento'
                    }
                )
                ->status_is(200)
                ->tx->res->json;

                is $res->{code}, 'B5';

            };
        };

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'B3',
                category       => 'recrutamento',
                answer_value   => '0'
            }
        )
        ->status_is(201)
        ->tx->res->json;

        is $res->{finished_quiz}, 0;

        $res = $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'recrutamento'
            }
        )
        ->status_is(200)
        ->tx->res->json;

        is $res->{code}, 'B6';

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'B6',
                category       => 'recrutamento',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->tx->res->json;

        is $res->{finished_quiz}, 0;

        $res = $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'recrutamento'
            }
        )
        ->status_is(200)
        ->tx->res->json;

        is $res->{code}, 'B7';

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'B7',
                category       => 'recrutamento',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->tx->res->json;

        is $res->{finished_quiz}, 0;

        $res = $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'recrutamento'
            }
        )
        ->status_is(200)
        ->tx->res->json;

        is $res->{code}, 'B8';

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'B8',
                category       => 'recrutamento',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->tx->res->json;

        is $res->{finished_quiz}, 0;

        $res = $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'recrutamento'
            }
        )
        ->status_is(200)
        ->tx->res->json;

        is $res->{code}, 'B9';

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'B9',
                category       => 'recrutamento',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->tx->res->json;

        is $res->{finished_quiz}, 0;

        $res = $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'recrutamento'
            }
        )
        ->status_is(200)
        ->tx->res->json;

        is $res->{code}, 'B10';

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'B10',
                category       => 'recrutamento',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->tx->res->json;

        is $res->{finished_quiz}, 1;
    };
};

done_testing();
