#!/usr/bin/env perl
use common::sense;
use Minion;
use JSON;
use Moose;

use Prep::SchemaConnected qw(get_schema);
use WebService::Facebook;

my $facebook = WebService::Facebook->instance;

my $schema = get_schema();

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
my $recipient_rs = $schema->resultset('Recipient');
my $config       = $schema->resultset('Config')->search( { key => 'ACCESS_TOKEN' } )->next;

while ( my $recipient = $rs->next() ) {

    # Build message object
    my $body = encode_json {
		messaging_type => "UPDATE",
		recipient      => { id => $recipient->fb_id },
		message        => {
			text => 'Bb, vamos terminar seu QUIZ?',
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
