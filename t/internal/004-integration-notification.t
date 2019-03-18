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

    subtest 'POST notification' => sub {
        $t->post_ok(
            '/api/internal/integration/recipient/notification',
            form => {
                security_token    => $security_token,
                integration_token => $integration_token
            }
        )
        ->status_is(400)
        ->json_is('/error', 'form_error')
        ->json_is('/form_error/url', 'missing');

        $t->post_ok(
            '/api/internal/integration/recipient/notification',
            form => {
                security_token    => $security_token,
                integration_token => $integration_token,
                url               => 'foobar'
            }
        )
        ->status_is(400)
        ->json_is('/error', 'form_error')
        ->json_is('/form_error/url', 'invalid');

        $t->post_ok(
            '/api/internal/integration/recipient/notification',
            form => {
                security_token    => $security_token,
                integration_token => $integration_token,
                url               => 'https://www.google.com'
            }
        )
        ->status_is(201);


    };
};

done_testing();
