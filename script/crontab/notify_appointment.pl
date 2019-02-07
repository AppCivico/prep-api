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

# Sync calendar
my @events;
while ( my $calendar = $calendar_rs->next() ) {
    my $res = $google_calendar->get_calendar_events( calendar => $calendar, calendar_id => $calendar->id );

    # Tratando os dados que o Calendar retorna
    @events = $res->{items};
    for ( my $i = 0; $i++; $i < scalar @events ) {
        use DDP;

        my $event = $events[$i];
        next if $event->{description} =~ /agendamento_chatbot/gm;
    }

}

my @upcoming_appointments = $schema->resultset('Appointment')->search( { appointment_at =>  } )

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

my $rs           = $schema->resultset('ViewRecipientQuiz');

while ( my $recipient = $rs->next() ) {

    # Build message object
    my $body = encode_json {
		messaging_type => "UPDATE",
		recipient      => { id => $recipient->fb_id },
		message        => {
			text => 'Olá! Termine de responder o quiz!',
			quick_replies => [
				{
					content_type => 'text',
					title        => "Voltar para o início",
					payload      => 'greetings'
				},
				{
					content_type => 'text',
					title        => "Terminar quiz",
					payload      => 'beginQuiz'
				},
			]
		}
    };

    $minion->enqueue( send_message => [ $config->value, $body ] );

    my $recipient = $recipient_rs->find($recipient->id);

    $recipient->update( { question_notification_sent_at => \'now()' } );
}

$minion->perform_jobs;
