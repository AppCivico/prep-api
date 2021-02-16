#!/usr/bin/env perl
use common::sense;
use Minion;
use JSON;
use Moose;

use Prep::SchemaConnected qw(get_schema);
use WebService::Facebook;

my $schema   = get_schema();
my $facebook = WebService::Facebook->instance;

my $recipient_rs = $schema->resultset('Recipient')->search( { id => { '-in' => [qw(55 18)] } } );

my $access_token  = '';
my $text          = 'Oieeee! Axo q me confundi #aloka!! tu pode participar da pesquisa prep1519 q qr contribuir pra reduzir HIV entre adolescentes HSH, mulheres trans e travestchys, 👌😍 Rola fááriox benefícios pra qm participa, vamo começá denovo & saber + sobre?? ✊';
my $quick_replies = [
    {
        content_type => 'text',
        title        => "quiz",
        payload      => 'beginQuiz'
    },
    {
        content_type => 'text',
        title        => "Agora não",
        payload      => 'mainMenu'
    },
];

while (my $recipient = $recipient_rs->next) {
	my $content = encode_json {
		messaging_type => "UPDATE",
		recipient      => { id => $recipient->fb_id },
		message        => {
			text => $text,
			quick_replies => $quick_replies
		}
	};

    $facebook->send_message(
        access_token => $access_token,
        content      => $content
    );
}

1;
