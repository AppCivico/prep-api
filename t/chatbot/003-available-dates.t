use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Prep::Test;

use JSON;

my $t      = test_instance;
my $schema = $t->app->schema;

db_transaction {
    my $security_token = $ENV{CHATBOT_SECURITY_TOKEN};

    my ($calendar, $appointment_window);
    subtest 'Internal | Create calendar and event' => sub {
        ok(
            $calendar = $schema->resultset('Calendar')->create(
                {
                    name      => 'test_calendar',
                    google_id => 'prep_test@group.calendar.google.com',
                    time_zone => 'America/Sao_Paulo',
                    token     => 'foobar'
                }
            )
        );

        ok(
            $appointment_window = $schema->resultset('AppointmentWindow')->create(
                {
                    calendar_id => $calendar->id,
                    start_time  => '10:00 AM',
                    end_time    => '12:00 PM',
                    quotas      => 4
                }
            )
        );
    };

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

    $schema->resultset('Appointment')->create(
        {
            recipient_id => $recipient->id,
            appointment_window_id => $appointment_window->id,
            quota_number          => 1
        }
    );

    subtest 'Chatbot | Get available dates' => sub {
        $t->get_ok(
            '/api/chatbot/appointment/available-dates',
            form => {
                security_token => $security_token,
            }
        )
        ->status_is(200);



        use DDP; p $t->tx->res->json;
    };

};

done_testing();