use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Prep::Test;

use JSON;

my $t      = test_instance;
my $schema = $t->app->schema;

db_transaction {
	my $chatbot_security_token = $ENV{CHATBOT_SECURITY_TOKEN};
	my $security_token         = $ENV{INTEGRATION_SECURITY_TOKEN};

    my ($recipient_id, $recipient);
    subtest 'Chatbot | Create recipient' => sub {
        $t->post_ok(
            '/api/chatbot/recipient',
            form => {
                security_token => $chatbot_security_token,
                name           => 'foobar',
                page_id        => '1573221416102831',
                fb_id          => '1573221416102831'
            }
        )
        ->status_is(201);

        $recipient_id = $t->tx->res->json->{id};
        $recipient    = $schema->resultset('Recipient')->find($recipient_id);

        # Gerando um integration_token
		ok(
            $recipient->update( { integration_token => '1573221416102831' } ),
            'generating integration_token'
        );

        # No fluxo real o integration_token só é gerado quando a pessoa concorda em participar da pesquisa
        ok(
			$recipient->recipient_flag->update(
				{
					finished_quiz       => 1,
					is_target_audience  => 1,
					is_part_of_research => 1,
				}
			),
            'updating flags'
        );

    };

    my $integration_token = $recipient->integration_token;

    subtest 'Sync' => sub {
        my $flags = $recipient->recipient_flag;

		is( $flags->is_part_of_research, 1 );
		is( $flags->is_prep,             undef );

        $t->post_ok(
            '/api/internal/integration/recipient/sync',
            form => {
                security_token    => $security_token,
                integration_token => 'foobar',
            }
        )
        ->status_is(400)
		->json_is('/error', 'form_error')
		->json_is('/form_error/integration_token', 'invalid');

        $t->post_ok(
            '/api/internal/integration/recipient/sync',
            form => {
                security_token    => $security_token,
                integration_token => $integration_token,
            }
        )
        ->status_is(400)
		->json_is('/error', 'form_error')
		->json_is('/form_error/is_prep', 'missing');

        $t->post_ok(
            '/api/internal/integration/recipient/sync',
            form => {
                security_token    => $security_token,
                integration_token => $integration_token,
                is_prep           => 'string'
            }
        )
        ->status_is(400)
		->json_is('/error', 'form_error')
		->json_is('/form_error/is_prep', 'invalid');

        $t->post_ok(
            '/api/internal/integration/recipient/sync',
            form => {
                security_token    => $security_token,
                integration_token => $integration_token,
                is_prep           => 0
            }
        )
        ->status_is(200);

        ok( $flags = $flags->discard_changes, 'discard changes' );
		is( $flags->is_part_of_research, 1 );
		is( $flags->is_prep,             0 );

        $t->post_ok(
            '/api/internal/integration/recipient/sync',
            form => {
                security_token    => $security_token,
                integration_token => $integration_token,
                is_prep           => 1
            }
        )
        ->status_is(200);

		ok( $flags = $flags->discard_changes, 'discard changes' );
		is( $flags->is_part_of_research, 1 );
		is( $flags->is_prep,             1 );
    };
};

done_testing();