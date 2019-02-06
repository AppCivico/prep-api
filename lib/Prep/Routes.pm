package Prep::Routes;
use strict;
use warnings;

sub register {
    my $r = shift;

    my $api = $r->route('/api');

    # Chatbot
    my $chatbot = $api->route('/chatbot')->under->to('chatbot#validade_security_token');

    # Recipient
    my $recipient = $chatbot->route('/recipient')->under->to('chatbot-recipient#stasher');
    $recipient->get('/')->to('chatbot-recipient#get');
    $recipient->put('/')->to('chatbot-recipient#put');

    # Recipient POST
    # Para não passar pelo método stasher
    $chatbot->route('/recipient')->post('/')->to('chatbot-recipient#post');

    # Recipient::PendingQuestion
    my $pending_question = $recipient->route('/pending-question');
    $pending_question->get('/')->to('chatbot-recipient-pending_question#get');

    # Recipient::Answer
    my $answer = $recipient->route('/answer');
    $answer->post('/')->to('chatbot-recipient-answer#post');

	# Recipient::Appointment
	my $recipient_appointment = $recipient->route('/appointment');
	$recipient_appointment->post('/')->to('chatbot-recipient-appointment#post');
	$recipient_appointment->get('/')->to('chatbot-recipient-appointment#get');

    # Appointment
	my $appointment = $chatbot->route('/appointment');

	# Appointment::AvailableCalendars
	$appointment->route('/available-calendars')->get('/')->to('chatbot-appointment-available_calendars#get');

    # Appointment::AvailableDates
	$appointment->route('/available-dates')->get('/')->to('chatbot-appointment-available_dates#get');

    # Internal
    my $internal = $api->route('/internal')->under->to('internal#validade_security_token');

    # Internal::DeleteAnswer
    $internal->route('/delete-answers')->post('/')->to('internal-delete_answer#post');
}

1;
