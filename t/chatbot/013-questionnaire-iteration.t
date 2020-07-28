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
        ok my $category = $category_rs->create(
            {
                id              => $category_rs->get_column('id')->max + 1,
                name            => 'test_category',
                can_be_iterated => 1
            }
        );

        ok $question_map = $question_map_rs->create(
            {
                category_id => $category->id,
                map         => to_json(
                    {
                        1 => 'Z1',
                        2 => 'Z2',
                        3 => 'Z3'
                    }
                )
            }
        );

        for ( 1 .. 3 ) {
            my $code;
            if ($_ == 1) {
                $code = 'Z1';
            }
            elsif ($_ == 2) {
                $code = 'Z2';
            }
            else {
                $code = 'Z3';
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
        my $category = 'test_category';

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

        ok my $stash = $recipient->stashes->search( { question_map_id => $question_map->id } )->next;

        is $stash->times_answered, 0;
        is $stash->must_be_reseted, 0;

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'Z1',
                category       => $category,
                answer_value   => 1
            }
        )
        ->status_is(201)
        ->tx->res->json;

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'Z2',
                category       => $category,
                answer_value   => 1
            }
        )
        ->status_is(201)
        ->tx->res->json;

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'Z3',
                category       => $category,
                answer_value   => 1
            }
        )
        ->status_is(201)
        ->tx->res->json;

        ok $stash->discard_changes;
        is $stash->times_answered, 1;
        is $stash->must_be_reseted, 1;

        is $answer_rs->search(
            {
                recipient_id    => $recipient->id,
                question_map_id => $question_map->id
            }
        )->count, 3;

        for my $answer ( $answer_rs->all() ) {
            is $answer->question_map_iteration, 1;
        }

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

        ok defined $res->{code};

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'Z1',
                category       => $category,
                answer_value   => 1
            }
        )
        ->status_is(201)
        ->tx->res->json;

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'Z2',
                category       => $category,
                answer_value   => 1
            }
        )
        ->status_is(201)
        ->tx->res->json;

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'Z3',
                category       => $category,
                answer_value   => 1
            }
        )
        ->status_is(201)
        ->tx->res->json;

        ok $stash->discard_changes;
        is $stash->times_answered, 2;
        is $stash->must_be_reseted, 1;

        is $answer_rs->search(
            {
                recipient_id    => $recipient->id,
                question_map_id => $question_map->id
            }
        )->count, 6;

        is $answer_rs->search( { 'me.question_map_iteration' => { '>' => 1 } } )->count, 3;

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

        ok defined $res->{code};
    };

};

done_testing();
