use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Prep::Test;

use JSON;
use DateTime;

my $t      = test_instance;
my $schema = $t->app->schema;

db_transaction {
    my $notification_rs = $schema->resultset('NotificationQueue');

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

        # Gerando um voucher
        ok(
            $recipient->update( { integration_token => '1573221416102831' } ),
            'generating voucher'
        );

        # No fluxo real o voucher só é gerado quando a pessoa concorda em participar da pesquisa
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

    my $voucher = $recipient->integration_token;

    subtest 'Sync' => sub {
        my $flags = $recipient->recipient_flag;

        is( $flags->is_part_of_research, 1 );
        is( $flags->is_prep,             undef );

        $t->post_ok(
            '/api/internal/integration/recipient/sync' => { 'x-api-key' => $security_token },
            json => {
                voucher => 'foobar',
            }
        )
        ->status_is(400);

        $t->post_ok(
            '/api/internal/integration/recipient/sync' => => { 'x-api-key' => $security_token },
            json => {
                voucher => $voucher,
                is_prep => 'string'
            }
        )
        ->status_is(400)
        ->json_is('/form_error/is_prep', 'invalid');

        $t->post_ok(
            '/api/internal/integration/recipient/sync' => => { 'x-api-key' => $security_token },
            json => {
                voucher => $voucher,
                is_prep => 0
            }
        )
        ->status_is(200);

        ok( $flags = $flags->discard_changes, 'discard changes' );
        is( $flags->is_part_of_research, 1 );
        is( $flags->is_prep,             0 );

        is $notification_rs->count, 0;

        $t->post_ok(
            '/api/internal/integration/recipient/sync' => => { 'x-api-key' => $security_token },
            json => {
                voucher => $voucher,
                is_prep => 1,
                appointment => {
                    type_id   => 1,
                    timestamp => DateTime->now->datetime
                }
            }
        )
        ->status_is(200);

        ok( $flags = $flags->discard_changes, 'discard changes' );
        is( $flags->is_part_of_research, 1 );
        is( $flags->is_prep,             1 );

        is $notification_rs->count, 2;
    };
};

done_testing();
