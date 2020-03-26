package Prep::Routes;
use strict;
use warnings;

sub register {
    my $r = shift;

    my $api = $r->route('/api');

    # Report
    my $report = $api->route('/report')->under->to('report#base');

    # Report::Interaction
    my $report_interaction                 = $report->route('/interaction')->to('report-interaction#get_general');
    my $report_interaction_public_audience = $report->route('/interaction-target-audience')->to('report-interaction#get_target_audience');

    # Report::GeneralPublic
    my $report_general_public = $report->route('/general-public')->to('report-general_public#get');

    # Report::TargetAudience
    my $report_target_audience = $report->route('/target-audience')->to('report-target_audience#get');

    # Report::Intents
    my $report_intents = $report->route('/intents')->to('report-intents#get');

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

    # Recipient::CountQuizBrincadeira
    my $recipient_quiz_brincadeira = $recipient->route('/count-quiz-brincadeira');
    $recipient_quiz_brincadeira->post('/')->to('chatbot-recipient-count_quiz_brincadeira#post');
    $recipient_quiz_brincadeira->get('/')->to('chatbot-recipient-count_quiz_brincadeira#get');

    # Recipient::CountPublicoInteresse
    my $recipient_count_publico_interesse = $recipient->route('/count-publico-interesse');
    $recipient_count_publico_interesse->post('/')->to('chatbot-recipient-count_publico_interesse#post');
    $recipient_count_publico_interesse->get('/')->to('chatbot-recipient-count_publico_interesse#get');

    # Recipient::CountRecrutamento
    my $recipient_count_recrutamento = $recipient->route('/count-recrutamento');
    $recipient_count_recrutamento->post('/')->to('chatbot-recipient-count_recrutamento#post');
    $recipient_count_recrutamento->get('/')->to('chatbot-recipient-count_recrutamento#get');

    # Recipient::ResetScreening
    my $reset_screening = $recipient->route('/reset-screening');
    $reset_screening->post('/')->to('chatbot-recipient-reset_screening#post');

    # Recipient::Research
    my $research = $recipient->route('/research-participation');
    $research->post('/')->to('chatbot-recipient-research#post');

    # Recipient::Interaction
    my $interaction = $recipient->route('/interaction');
    $interaction->post('/')->to('chatbot-recipient-interaction#create');
    $interaction->post('/close')->to('chatbot-recipient-interaction#close');
    $interaction->get('/')->to('chatbot-recipient-interaction#get');

    # Recipient::QuickReplyLog
    my $quick_reply_log = $recipient->route('/quick-reply-log');
    $quick_reply_log->post('/')->to('chatbot-recipient-quick_reply_log#create');
    $quick_reply_log->get('/')->to('chatbot-recipient-quick_reply_log#get');

    # Appointment
    my $appointment = $chatbot->route('/appointment');

    # Appointment::AvailableCalendars
    $appointment->route('/available-calendars')->get('/')->to('chatbot-appointment-available_calendars#get');

    # Appointment::AvailableDates
    $appointment->route('/available-dates')->get('/')->to('chatbot-appointment-available_dates#get');

    # Internal
    my $internal = $api->route('/internal');

    # Internal::DeleteAnswer
    my $delete_answer = $internal->route('/delete-answers')->under->to('internal#validade_security_token');
    $delete_answer->post('/')->to('internal-delete_answer#post');

    # Internal::SetProfilePrep
    my $prep_profile = $internal->route('/set-profile')->under->to('internal#validade_security_token');
    $prep_profile->post('/')->to('internal-set_profile_prep#post');

    # Internal::Integration
    my $internal_integration = $internal->route('/integration')->under->to('internal-integration#validate_header_and_pass');

    # Internal::Integration::Recipient
    my $integration_recipient = $internal_integration->route('/recipient')->under->to('internal-integration-recipient#stasher');

    # Internal::Integration::Recipient::Sync
    my $sync = $integration_recipient->route('/sync');
    $sync->post('/')->to('internal-integration-recipient-sync#post');
}

1;
