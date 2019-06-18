use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Prep::Test;
use Prep::Worker::Notify;

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

	ok my $worker = Prep::Worker::Notify->new(
		schema      => $schema,
		logger      => $t->app->log,
		max_process => 1,
	);

    # Criando uma notificação
    db_transaction{
        ok my $notification = $notification_rs->create(
            {
                recipient_id => $recipient_id,
                type_id      => 1
            }
        );

        ok $worker->run_once();

        ok $notification = $notification->discard_changes;
        ok defined $notification->sent_at;
    };
};

done_testing();
