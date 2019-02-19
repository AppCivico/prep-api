use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Prep::Test;

use JSON;

my $t      = test_instance;
my $schema = $t->app->schema;

db_transaction {
	my $security_token         = $ENV{INTEGRATION_SECURITY_TOKEN};

    subtest 'Integration headers and security_token' => sub {
        $t->post_ok(
            '/api/internal/integration/recipient/sync',
            form => {
                security_token => $security_token
            }
        )
        ->status_is(400)
		->json_has('/error')
		->json_has('/form_error')
		->json_has('/form_error/integration_token')
		->json_is('/error', 'form_error')
		->json_is('/form_error/integration_token', 'missing', 'missing integration_token');

        $t->post_ok(
            '/api/internal/integration/recipient/sync',
            json => {
                security_token => $security_token
            }
        )
        ->status_is(400)
        ->json_is('/error', 'header')
        ->json_is('/header/Content-Type', 'invalid');

        $t->post_ok(
            '/api/internal/integration/recipient/sync',
            form => {
                security_token    => 'this_is_a_fake_test_token',
                integration_token => 'foobar'
            }
        )
        ->status_is(403)
        ->json_is('/error', 'Forbidden');
    };
};

done_testing();