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
                name            => 'deu_ruim_nao_tomei',
                can_be_iterated => 1
            }
        );

        ok $question_map = $question_map_rs->create(
            {
                category_id => $category->id,
                map         => to_json(
                    {
                        1 => 'NT1',
                        2 => 'NT2',
                        3 => 'NT3'
                    }
                )
            }
        );

        for ( 1 .. 3 ) {
            my $code;
            if ($_ == 1) {
                $code = 'NT1';
            }
            elsif ($_ == 2) {
                $code = 'NT2';
            }
            else {
                $code = 'NT3';
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
        my $category = 'deu_ruim_nao_tomei';

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

        is $res->{code}, 'NT1';

        ok my $stash = $recipient->stashes->search( { question_map_id => $question_map->id } )->next;

        is $stash->times_answered, 0;
        is $stash->must_be_reseted, 0;

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'NT1',
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

        is $res->{code}, 'NT2';

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'NT2',
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

        is $res->{code}, 'NT3';

        $res = $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'NT3',
                category       => $category,
                answer_value   => 1
            }
        )
        ->status_is(201)
        ->tx->res->json;

        ok $stash->discard_changes;
        is $stash->times_answered, 1;
        is $stash->must_be_reseted, 1;

    };

};

done_testing();
