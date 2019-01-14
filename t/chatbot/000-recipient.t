use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Prep::Test;

my $t      = test_instance;
my $schema = $t->app->schema;

db_transaction {
    my $security_token = $ENV{CHATBOT_SECURITY_TOKEN};

    # Toda requisição para endpoints /chatbot
    # deve conter o security token
    subtest 'Chatbot | Security token' => sub {
        # Sem security token
        $t->post_ok('/api/chatbot/recipient')->status_is(403);

        # Com security token inválido
		$t->post_ok( '/api/chatbot/recipient', form => { security_token => 'FOObar' } )->status_is(403);
    };

    subtest 'Chatbot | Create recipient' => sub {

        subtest 'Invalid' => sub {
            # Sem fb_id
            $t->post_ok(
                '/api/chatbot/recipient',
                form => {
                    security_token => $security_token,
                    name           => 'foobar',
                    page_id        => '1573221416102831'
                }
            )->status_is(400);

        };
    };
};

done_testing();