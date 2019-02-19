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

    # Recipient::ExternalIntegrationToken
    my $recipient_integration_token = $recipient->route('/integration-token');
	$recipient_integration_token->post('/')->to('chatbot-recipient-integration_token#post');

	# Recipient::CountQuiz
	my $recipient_count_quiz = $recipient->route('/count-quiz');
	$recipient_count_quiz->post('/')->to('chatbot-recipient-count_quiz#post');
	$recipient_count_quiz->get('/')->to('chatbot-recipient-count_quiz#get');

	# Recipient::CountResearchInvite
	my $recipient_count_research_invite = $recipient->route('/count-research-invite');
	$recipient_count_research_invite->post('/')->to('chatbot-recipient-count_research_invite#post');
	$recipient_count_research_invite->get('/')->to('chatbot-recipient-count_research_invite#get');

	# Recipient::CountShare
	my $recipient_count_share = $recipient->route('/count-share');
	$recipient_count_share->post('/')->to('chatbot-recipient-count_share#post');
	$recipient_count_share->get('/')->to('chatbot-recipient-count_share#get');

	# Recipient::CountShare
	my $term_signature = $recipient->route('/term-signature');
	$term_signature->post('/')->to('chatbot-recipient-term_signature#post');

	# Recipient::ResetScreening
	my $reset_screening = $recipient->route('/reset-screening');
	$reset_screening->post('/')->to('chatbot-recipient-reset_screening#post');

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
