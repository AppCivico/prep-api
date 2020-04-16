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
        ok my $category = $category_rs->search(
            {
                name            => 'duvidas_nao_prep',
                can_be_iterated => 1
            }
        )->next;

        ok $question_map = $question_map_rs->create(
            {
                category_id => $category->id,
                map         => to_json(
                    {
                        1 => 'D1',
                        2 => 'D2',
                        3 => 'D3',
                        4 => 'D4'
                    }
                )
            }
        );

        for ( 1 .. 4 ) {
            my $code;
            if ($_ == 1) {
                $code = 'D1';
            }
            elsif ($_ == 2) {
                $code = 'D2';
            }
            elsif ($_ == 3) {
                $code = 'D3';
            }
            else {
                $code = 'D4';
            }

            ok $question_rs->create(
                {
                    code              => $code,
                    type              => 'multiple_choice',
                    text              => 'foobar',
                    is_differentiator => 0,
                    question_map_id   => $question_map->id,

                    multiple_choices => to_json(
                        {
                            1 => 'sim',
                            2 => 'não'
                        }
                    )
                }
            );
        }
    };

    subtest 'Iterating questionnaire' => sub {
        my $category = 'duvidas_nao_prep';

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

        is $res->{code}, 'D1';

        ok my $stash = $recipient->stashes->search( { question_map_id => $question_map->id } )->next;

        is $stash->times_answered, 0;
        is $stash->must_be_reseted, 0;

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'D1',
                category       => $category,
                answer_value   => 1
            }
        )
        ->status_is(201)
        ->tx->res->json;

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

        is $res->{code}, 'D2';

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'D2',
                category       => $category,
                answer_value   => 2
            }
        )
        ->status_is(201)
        ->tx->res->json;

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

        is $res->{code}, 'D3';

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'D3',
                category       => $category,
                answer_value   => 1
            }
        )
        ->status_is(201)
        ->tx->res->json;

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

        is $res->{code}, 'D4';

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'D4',
                category       => $category,
                answer_value   => 1
            }
        )
        ->status_is(201)
        ->tx->res->json;

        ok scalar $res->{followup_messages} > 0;

        ok $stash->discard_changes;
        is $stash->times_answered, 1;
        is $stash->must_be_reseted, 1;

    };

};

done_testing();
