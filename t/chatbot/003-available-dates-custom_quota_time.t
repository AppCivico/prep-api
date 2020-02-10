use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Prep::Test;

use JSON;

my $t      = test_instance;
my $schema = $t->app->schema;

db_transaction {
    my $security_token = $ENV{CHATBOT_SECURITY_TOKEN};

    my ($calendar, $appointment_window, $second_calendar, $second_appointment_window);
    subtest 'Internal | Create calendar and event' => sub {
        ok(
            $calendar = $schema->resultset('Calendar')->create(
                {
                    name             => 'test_calendar',
                    address_city     => 'São Paulo',
                    address_state    => 'SP',
                    address_street   => 'Rua Libero Badaró',
                    address_number   => '144',
                    address_district => 'Anhangabaú',
                    address_zipcode  => '01008001',
                    google_id        => 'prep_test@group.calendar.google.com',
                    time_zone        => 'America/Sao_Paulo',
                    token            => 'foobar',
                    client_id        => 'foo',
                    client_secret    => 'bar',
                    refresh_token    => 'FOOBAR'
                }
            )
        );

        ok(
            $appointment_window = $schema->resultset('AppointmentWindow')->create(
                {
                    calendar_id                     => $calendar->id,
                    start_time                      => '13:30:00',
                    end_time                        => '15:30:00',
                    quotas                          => 3,
                    custom_quota_time               => '1 hour',
                    appointment_window_days_of_week => [
                        { day_of_week => 1 }
                    ]
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
            '/api/chatbot/appointment/available-calendars',
            form => {
                security_token => $security_token,
            }
        )
        ->status_is(200)
        ->json_has('/calendars')
        ->json_has('/calendars/0/id')
        ->json_has('/calendars/0/name')
        ->json_has('/calendars/0/city')
        ->json_has('/calendars/0/time_zone')
        ->json_has('/calendars/0/state')
        ->json_has('/calendars/0/city')
        ->json_has('/calendars/0/street')
        ->json_has('/calendars/0/number')
        ->json_has('/calendars/0/zipcode')
        ->json_has('/calendars/0/complement')
        ->json_has('/calendars/0/district')
        ->json_has('/calendars/0/phone')
        ->json_has('/calendars/0/google_id');

        $t->get_ok(
            '/api/chatbot/appointment/available-dates',
            form => {
                security_token => $security_token,
                calendar_id    => $calendar->id
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
        ->json_has('/dates/0/hours/0/time');

        my $res = $t->tx->res->json;

        my $datetime_start = $res->{dates}->[0]->{hours}->[0]->{datetime_start};
        my $datetime_end   = $res->{dates}->[0]->{hours}->[0]->{datetime_end};

        is( scalar @{ $res->{dates}->[0]->{hours} }, 1, '1 available hours' );


    };

};

done_testing();
