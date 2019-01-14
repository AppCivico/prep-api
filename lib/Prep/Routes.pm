package Prep::Routes;
use strict;
use warnings;

sub register {
    my $r = shift;

    my $api = $r->route('/api');

    # Chatbot
    my $chatbot = $api->route('/chatbot')->under->to('chatbot#validade_security_token');

    # Recipient
    my $recipient = $chatbot->route('/recipient');
	$recipient->post('/')->to('chatbot-recipient#post');
	$recipient->get('/')->to('chatbot-recipient#get');
	$recipient->put('/')->to('chatbot-recipient#put');
}

1;
