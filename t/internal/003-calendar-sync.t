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
          ), 'calendar'
        );
    };

    subtest 'Internal | Sync calendar' => sub {
        my $appointment_rs  = $schema->resultset('Appointment');
        my $notification_rs = $schema->resultset('NotificationQueue');

        is($appointment_rs->count, 0, 'no appointments');
        is($notification_rs->count, 0, 'no notifications');

        &setup_calendar_event_get;
        ok( $calendar->sync_appointments , 'calendar sync' );

        is($appointment_rs->count, 1, 'one appointment synced');
        is($notification_rs->count, 1, 'one notification');

        ok my $appointment  = $appointment_rs->next;
        ok my $notification = $notification_rs->next;
        use DDP; p $appointment;
        ok defined $appointment->notification_created_at;
        ok defined $notification->wait_until;

        # A notificação é enviada 10 dias antes da consulta acontecer
        my $time_difference = $appointment->appointment_at->subtract_datetime( $notification->wait_until );
        my $notification_time_corrected_time = $notification->wait_until->add_duration( $time_difference );

        is $notification_time_corrected_time, $appointment->appointment_at;
    };
};

done_testing();
