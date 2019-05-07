use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Prep::Test;

use JSON;

my $t      = test_instance;
my $schema = $t->app->schema;

db_transaction {
    my $security_token         = $ENV{INTEGRATION_SECURITY_TOKEN};
    my $chatbot_security_token = $ENV{CHATBOT_SECURITY_TOKEN};

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

    subtest 'Integration headers and security_token' => sub {
        $t->post_ok(
            '/api/internal/integration/recipient/sync' => { 'x-api-key' => $security_token },
        )
        ->status_is(400);

        # O retorno deve ser 200 mesmo sem alterar dados
        $t->post_ok(
            '/api/internal/integration/recipient/sync' => { 'x-api-key' => $security_token },
            json => {
                voucher => '1573221416102831'
            }
        )
        ->status_is(200);

        # Alterando flag de prep
        $t->post_ok(
            '/api/internal/integration/recipient/sync' => { 'x-api-key' => $security_token },
            json => {
                voucher     => '1573221416102831',
                is_prep     => 0,
                appointment => {
                    type_id   => 1,
                    timestamp => "2019-04-15 10:53:30.275685-03"
                }
            }
        )
        ->status_is(200);
    };
};

done_testing();
