use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Prep::Test;
use Prep::Worker::Notify;

use JSON;

my $t      = test_instance;
my $schema = $t->app->schema;

use DDP;

db_transaction {
    my $security_token = $ENV{CHATBOT_SECURITY_TOKEN};

    ok my $category_rs     = $schema->resultset('Category');
    ok my $question_map_rs = $schema->resultset('QuestionMap');
    ok my $question_rs     = $schema->resultset('Question');
    ok my $answer_rs       = $schema->resultset('Answer');

    my $fb_id = '111111';

    my $recipient;
    subtest 'Chatbot | Create recipient' => sub {
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

        my $recipient_id = $t->tx->res->json->{id};
        $recipient    = $schema->resultset('Recipient')->find($recipient_id);
    };

    my $question_map;
    subtest 'Create iterated questionnaire' => sub {
        ok my $category = $category_rs->find_or_create(
            {
                id              => $category_rs->get_column('id')->max + 1,
                name            => 'triagem',
                can_be_iterated => 1
            }
        );

        ok $question_map = $question_map_rs->create(
            {
                category_id => $category->id,
                map         => to_json(
                    {
                        1 => 'T1',
                        2 => 'T2',
                        3 => 'T3'
                    }
                )
            }
        );

        for ( 1 .. 3 ) {
            my ($code, $rules, $choices);
            if ($_ == 1) {
                $code = 'T1';

                $rules = '{
                    "logic_jumps": [],
                    "qualification_conditions": [2, 3],
                    "flags": [ "entrar_em_contato" ]
                }';

                $choices = '{
                    "1": "Há menos de 3 dias",
                    "2": "Menos de 1 mês",
                    "3": "Mais de 1 mês"
                }';
            }
            elsif ($_ == 2) {
                $code = 'T2';

                $rules = '{
                    "logic_jumps": [],
                    "qualification_conditions": [2],
                    "flags": [ "ir_para_agendamento" ]
                }';

                $choices = '{
                    "1": "Sim",
                    "2": "Não"
                }';
            }
            else {
                $code = 'T3';

                $rules = '{
                    "logic_jumps": [],
                    "qualification_conditions": [],
                    "flags": [ "ir_para_menu" ]
                }';

                $choices = '{
                    "1": "SIM, Bora testar!",
                    "2": "Não"
                }';
            }

            ok $question_rs->create(
                {
                    code              => $code,
                    type              => 'multiple_choice',
                    text              => 'foobar',
                    is_differentiator => 0,
                    question_map_id   => $question_map->id,
                    rules             => $rules,
                    multiple_choices  => $choices
                }
            );
        }
    };

    subtest 'Iterating questionnaire' => sub {
        my $category = 'triagem';

        my $res = $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => $category
            }
        )
        ->status_is(200)
        ->tx->res->json;

        is $res->{code}, 'T1';

        ok my $stash = $recipient->stashes->search( { question_map_id => $question_map->id } )->next;

        is $stash->times_answered, 0;
        is $stash->must_be_reseted, 0;

        db_transaction {
            $res = $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'T1',
                    category       => $category,
                    answer_value   => 1
                }
            )
            ->status_is(201)
            ->tx->res->json;

            is $res->{finished_quiz}, 1;
            is $res->{entrar_em_contato}, 1;

            ok $stash->discard_changes;
            is $stash->times_answered, 1;
            is $stash->must_be_reseted, 1;

            $res = $t->get_ok(
                '/api/chatbot/recipient/pending-question',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    category       => $category
                }
            )
            ->status_is(200)
            ->tx->res->json;

            is $res->{code}, 'T1';
        };

        db_transaction {
            $res = $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'T1',
                    category       => $category,
                    answer_value   => 2
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
                    category       => $category
                }
            )
            ->status_is(200)
            ->tx->res->json;

            is $res->{code}, 'T2';

            $res = $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'T2',
                    category       => $category,
                    answer_value   => 1
                }
            )
            ->status_is(201)
            ->tx->res->json;

            is $res->{finished_quiz}, 1;
            is $res->{ir_para_agendamento}, 1;

            ok $stash->discard_changes;
            is $stash->times_answered, 1;
            is $stash->must_be_reseted, 1;

            $res = $t->get_ok(
                '/api/chatbot/recipient/pending-question',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    category       => $category
                }
            )
            ->status_is(200)
            ->tx->res->json;

            is $res->{code}, 'T1';
        };

        db_transaction {
            $res = $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'T1',
                    category       => $category,
                    answer_value   => 2
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
                    category       => $category
                }
            )
            ->status_is(200)
            ->tx->res->json;

            is $res->{code}, 'T2';

            $res = $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'T2',
                    category       => $category,
                    answer_value   => 2
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
                    category       => $category
                }
            )
            ->status_is(200)
            ->tx->res->json;

            is $res->{code}, 'T3';

            $res = $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'T3',
                    category       => $category,
                    answer_value   => 2
                }
            )
            ->status_is(201)
            ->tx->res->json;

            is $res->{finished_quiz}, 1;
            is $res->{ir_para_menu}, 1;

            ok $stash->discard_changes;

            is $stash->times_answered, 1;
            is $stash->must_be_reseted, 1;

            $res = $t->get_ok(
                '/api/chatbot/recipient/pending-question',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    category       => $category
                }
            )
            ->status_is(200)
            ->tx->res->json;

            is $res->{code}, 'T1';
        };

    };

};

done_testing();
