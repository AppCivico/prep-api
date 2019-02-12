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
                fb_id          => '1573221416102831'
            }
        )
        ->status_is(201);

        $recipient_id = $t->tx->res->json->{id};
        $recipient    = $schema->resultset('Recipient')->find($recipient_id);

        $recipient->update( { integration_token => '1573221416102831' } );
    };

    my $calendar;
    subtest 'Chatbot | Create calendar' => sub {
		ok ( $calendar = $schema->resultset('Calendar')->create(
			{
				name          => 'test_calendar',
				city          => 'São Paulo',
				google_id     => 'prep_test@group.calendar.google.com',
				time_zone     => 'America/Sao_Paulo',
				token         => 'foobar',
				client_id     => 'foo',
				client_secret => 'bar',
				refresh_token => 'FOOBAR'
			}
		  ), 'calendar'
        );
    };

    subtest 'Internal | Sync calendar' => sub {
        my $appointment_rs = $schema->resultset('Appointment');

        is($appointment_rs->count, 0, 'no appointments');

        &setup_calendar_event_get;
        ok( $calendar->sync_appointments , 'calendar sync' );

		is($appointment_rs->count, 1, 'one appointment synced');
    };
};

done_testing();