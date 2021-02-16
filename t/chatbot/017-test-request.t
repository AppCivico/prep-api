use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Prep::Test;
use Prep::Worker::PrepReminder;

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

    subtest 'Create test request' => sub {
        my $res = $t->post_ok(
            '/api/chatbot/recipient/test-request',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                address        => 'foobar'
            }
        )
        ->status_is(400)
        ->tx->res->json;

        $res = $t->post_ok(
            '/api/chatbot/recipient/test-request',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                contact        => 'foobar'
            }
        )
        ->status_is(400)
        ->tx->res->json;

        is $recipient->test_requests->count, 0;

        $res = $t->post_ok(
            '/api/chatbot/recipient/test-request',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                address        => 'foobar',
                contact        => 'foobar'
            }
        )
        ->status_is(201)
        ->json_has('/id')
        ->json_is('/recipient_id', $recipient->id)
        ->tx->res->json;

        is $recipient->test_requests->count, 1;
    };

};

done_testing();
