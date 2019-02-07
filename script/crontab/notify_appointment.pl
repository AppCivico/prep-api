#!/usr/bin/env perl
use common::sense;
use Minion;
use JSON;
use Moose;

use Prep::SchemaConnected qw(get_schema);
use WebService::GoogleCalendar;
use WebService::Facebook;

my $facebook        = WebService::Facebook->instance;
my $google_calendar = WebService::GoogleCalendar->instance;

my $schema = get_schema();

my $appointment_rs = $schema->resultset('Appointment');
my $recipient_rs   = $schema->resultset('Recipient');
my $calendar_rs    = $schema->resultset('Calendar');
my $config         = $schema->resultset('Config')->search( { key => 'ACCESS_TOKEN' } )->next;

my ($host, $port, $user, $password, $dbname) =
    @ENV{qw(POSTGRESQL_HOST POSTGRESQL_PORT POSTGRESQL_USER POSTGRESQL_PASSWORD POSTGRESQL_DBNAME)};

my $minion = Minion->new(Pg => "postgresql://$user:$password\@$host:$port/$dbname");

$minion->add_task(
	send_message => sub {
		my ( $job, $access_token, $content ) = @_;

		$facebook->send_message(
			access_token => $access_token,
			content      => $content
		);
	}
);

# Sync calendar
my @manual_appointments;
while ( my $calendar = $calendar_rs->next() ) {
	$calendar->sync_appointments;
}

my $rs = $schema->resultset('Appointment')->search(
    {
        appointment_at       => { '>=' => \'now()::date', '<=' => \"(now() + interval '1 day')::date" },
        notification_sent_at => \'IS NULL'
    }
);

while ( my $appointment = $rs->next() ) {

    my $recipient        = $appointment->recipient;
    my $appointment_time = $appointment->appointment_at;

    # Build message object
    my $body = encode_json {
		messaging_type => "UPDATE",
		recipient      => { id => $recipient->fb_id },
		message        => {
			text => "Olá! Você tem uma consulta em breve! Horário: $appointment_time",
			quick_replies => [
				{
					content_type => 'text',
					title        => "Voltar para o início",
					payload      => 'greetings'
				}
			]
		}
    };

    $minion->enqueue( send_message => [ $config->value, $body ] );

    $appointment->update( { notification_sent_at => \'now()' } );
}

$minion->perform_jobs;
