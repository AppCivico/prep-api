use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Prep::Test;

use JSON;

my $t      = test_instance;
my $schema = $t->app->schema;

db_transaction {
    my $security_token = $ENV{CHATBOT_SECURITY_TOKEN};

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

    my $external_integration_token;
    subtest 'Creating external integration token' => sub {
       ok $external_integration_token = $schema->resultset('ExternalIntegrationToken')->create( { value => 'foobar' } ), 'integration_token';
    };

    subtest 'Chatbot | Assign external integration token' => sub {

        $t->post_ok(
            '/api/chatbot/recipient/integration-token',
            form => {
                fb_id             => '111111',
                security_token    => $security_token,
                integration_token => 'foobar'
            }
        )
        ->status_is(200);
    }
};

done_testing();