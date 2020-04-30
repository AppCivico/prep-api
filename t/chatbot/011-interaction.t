use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Prep::Test;
use Prep::Worker::Notify;
use Prep::Worker::Interaction;

my $t      = test_instance;
my $schema = $t->app->schema;

db_transaction {
    my $security_token = $ENV{CHATBOT_SECURITY_TOKEN};

    my $notification_rs = $schema->resultset('NotificationQueue');

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

    subtest 'Chatbot | Create interaction' => sub {
        my $res = $t->post_ok(
            '/api/chatbot/recipient/interaction',
            form => {
                security_token => $security_token,
                fb_id          => '111111',
            }
        )
        ->status_is(201)
        ->tx->res->json;

        ok defined $res->{id};
        my $interaction_id = $res->{id};
        my $interaction    = $schema->resultset('Interaction')->find($interaction_id);

        db_transaction{
            ok my $worker = Prep::Worker::Interaction->new(
                schema      => $schema,
                logger      => $t->app->log,
                max_process => 1,
            );

            my @queue = $worker->_queue_rs;
            is @queue, 0;

            ok $interaction->update( { started_at => \"NOW() - interval '24 hours 1 second'" } );

            is $interaction->closed_at, undef;

            @queue = $worker->_queue_rs;
            is @queue, 1;

            ok $worker->run_once();

            ok $interaction->discard_changes;
            ok defined $interaction->closed_at;
        };

        $res = $t->post_ok(
            '/api/chatbot/recipient/interaction',
            form => {
                security_token => $security_token,
                fb_id          => '111111',
            }
        )
        ->status_is(400)
        ->tx->res->json;

        $res = $t->get_ok(
            '/api/chatbot/recipient/interaction',
            form => {
                security_token => $security_token,
                fb_id          => '111111',
            }
        )
        ->status_is(200)
        ->tx->res->json;

        is ref $res, 'ARRAY';

        ok defined $res->[0]->{started_at};
        ok !defined $res->[0]->{closed_at};

        ok $interaction->update( { started_at => \"started_at - interval '24 hours'" } );

        $res = $t->post_ok(
            '/api/chatbot/recipient/interaction/close',
            form => {
                security_token => $security_token,
                fb_id          => '111111',
                interaction_id => $interaction_id
            }
        )
        ->status_is(200)
        ->tx->res->json;

        $res = $t->get_ok(
            '/api/chatbot/recipient/interaction',
            form => {
                security_token => $security_token,
                fb_id          => '111111',
            }
        )
        ->status_is(200)
        ->tx->res->json;

    };
};

done_testing();
