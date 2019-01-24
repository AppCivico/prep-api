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

    subtest 'Chatbot | Get available dates' => sub {
        $t->get_ok(
            '/api/chatbot/appointment/available-dates',
            form => {
                security_token => $security_token,
            }
        )
        ->status_is(200)
        ->json_has('/id')
        ->json_has('/name')
        ->json_has('/time_zone')
        ->json_has('/google_id')
        ->json_has('/dates')
        ->json_has('/dates/0/ymd')
        ->json_has('/dates/0/appointment_window_id')
        ->json_has('/dates/0/hours')
        ->json_has('/dates/0/hours/0/quota')
        ->json_has('/dates/0/hours/0/time')
        ->json_is('/dates/0/hours/0/quota', 1)
        ->json_is('/dates/0/hours/0/time', '10:00:00 - 10:30:00');

        $t->post_ok(
            '/api/chatbot/recipient/appointment',
            form => {
                security_token        => $security_token,
                fb_id                 => '111111',
                calendar_id           => $calendar->id,
                appointment_window_id => $appointment_window->id,
                quota_number          => 1,
            }
        )
        ->status_is(201)
        ->json_has('/id');

        $t->get_ok(
            '/api/chatbot/appointment/available-dates',
            form => {
                security_token => $security_token,
            }
        )
        ->status_is(200)
        ->json_is('/dates/0/hours/0/quota', 2)
        ->json_is('/dates/0/hours/0/time', '11:00:00 - 11:30:00');

    };

};

done_testing();