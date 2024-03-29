package Prep::Routes;
use strict;
use warnings;

sub register {
    my $r = shift;

    my $api = $r->under('/api');

    # Report
    my $report = $api->under('/report')->to('report#base');

    # Report::Interaction
    my $report_interaction                 = $report->get('/interaction')->to('report-interaction#get_general');
    my $report_interaction_public_audience = $report->get('/interaction-target-audience')->to('report-interaction#get_target_audience');

    # Report::GeneralPublic
    my $report_general_public = $report->get('/general-public')->to('report-general_public#get');

    # Report::TargetAudience
    my $report_target_audience = $report->get('/target-audience')->to('report-target_audience#get');

    # Report::Intents
    my $report_intents = $report->get('/intents')->to('report-intents#get');

    # Chatbot
    my $chatbot = $api->under('/chatbot')->under->to('chatbot#validade_security_token');

    # Recipient
    my $recipient = $chatbot->under('/recipient')->under->to('chatbot-recipient#stasher');
    $recipient->get('/')->to('chatbot-recipient#get');
    $recipient->put('/')->to('chatbot-recipient#put');

    # Recipient::PrepReminder
    my $prep_reminder = $recipient->under('/prep-reminder-yes');
    $prep_reminder->post('/')->to('chatbot-recipient#prep_reminder_yes');
    
    my $prep_reminder_no = $recipient->under('/prep-reminder-no');
    $prep_reminder_no->post('/')->to('chatbot-recipient#prep_reminder_no');

    # Recipient POST
    # Para não passar pelo método stasher
    $chatbot->under('/recipient')->post('/')->to('chatbot-recipient#post');

    # Recipient::PendingQuestion
    my $pending_question = $recipient->under('/pending-question');
    $pending_question->get('/')->to('chatbot-recipient-pending_question#get');

    # Recipient::Answer
    my $answer = $recipient->under('/answer');
    $answer->post('/')->to('chatbot-recipient-answer#post');

    # Recipient::Appointment
    my $recipient_appointment = $recipient->under('/appointment');
    $recipient_appointment->post('/')->to('chatbot-recipient-appointment#post');
    $recipient_appointment->get('/')->to('chatbot-recipient-appointment#get');

    # Recipient::ExternalIntegrationToken
    my $recipient_integration_token = $recipient->under('/integration-token');
    $recipient_integration_token->post('/')->to('chatbot-recipient-integration_token#post');

    # Recipient::CountQuiz
    my $recipient_count_quiz = $recipient->under('/count-quiz');
    $recipient_count_quiz->post('/')->to('chatbot-recipient-count_quiz#post');
    $recipient_count_quiz->get('/')->to('chatbot-recipient-count_quiz#get');

    # Recipient::CountResearchInvite
    my $recipient_count_research_invite = $recipient->under('/count-research-invite');
    $recipient_count_research_invite->post('/')->to('chatbot-recipient-count_research_invite#post');
    $recipient_count_research_invite->get('/')->to('chatbot-recipient-count_research_invite#get');

    # Recipient::CountShare
    my $recipient_count_share = $recipient->under('/count-share');
    $recipient_count_share->post('/')->to('chatbot-recipient-count_share#post');
    $recipient_count_share->get('/')->to('chatbot-recipient-count_share#get');

    # Recipient::CountShare
    my $term_signature = $recipient->under('/term-signature');
    $term_signature->post('/')->to('chatbot-recipient-term_signature#post');

    # Recipient::CountQuizBrincadeira
    my $recipient_quiz_brincadeira = $recipient->under('/count-quiz-brincadeira');
    $recipient_quiz_brincadeira->post('/')->to('chatbot-recipient-count_quiz_brincadeira#post');
    $recipient_quiz_brincadeira->get('/')->to('chatbot-recipient-count_quiz_brincadeira#get');

    # Recipient::CountPublicoInteresse
    my $recipient_count_publico_interesse = $recipient->under('/count-publico-interesse');
    $recipient_count_publico_interesse->post('/')->to('chatbot-recipient-count_publico_interesse#post');
    $recipient_count_publico_interesse->get('/')->to('chatbot-recipient-count_publico_interesse#get');

    # Recipient::CountRecrutamento
    my $recipient_count_recrutamento = $recipient->under('/count-recrutamento');
    $recipient_count_recrutamento->post('/')->to('chatbot-recipient-count_recrutamento#post');
    $recipient_count_recrutamento->get('/')->to('chatbot-recipient-count_recrutamento#get');

    # Recipient::ResetScreening
    my $reset_screening = $recipient->under('/reset-screening');
    $reset_screening->post('/')->to('chatbot-recipient-reset_screening#post');

    # Recipient::Research
    my $research = $recipient->under('/research-participation');
    $research->post('/')->to('chatbot-recipient-research#post');

    # Recipient::Interaction
    my $interaction = $recipient->under('/interaction');
    $interaction->post('/')->to('chatbot-recipient-interaction#create');
    $interaction->post('/close')->to('chatbot-recipient-interaction#close');
    $interaction->get('/')->to('chatbot-recipient-interaction#get');

    # Recipient::QuickReplyLog
    my $quick_reply_log = $recipient->under('/quick-reply-log');
    $quick_reply_log->post('/')->to('chatbot-recipient-quick_reply_log#create');
    $quick_reply_log->get('/')->to('chatbot-recipient-quick_reply_log#get');

    # Recipient::TestRequest
    my $recipient_test = $recipient->under('/test-request');
    $recipient_test->post('/')->to('chatbot-recipient-test_request#post');

    # Appointment
    my $appointment = $chatbot->under('/appointment');

    # Appointment::AvailableCalendars
    $appointment->under('/available-calendars')->get('/')->to('chatbot-appointment-available_calendars#get');

    # Appointment::AvailableDates
    $appointment->under('/available-dates')->get('/')->to('chatbot-appointment-available_dates#get');

    # Internal
    my $internal = $api->under('/internal');

    # Internal::DeleteAnswer
    my $delete_answer = $internal->under('/delete-answers')->under->to('internal#validade_security_token');
    $delete_answer->post('/')->to('internal-delete_answer#post');

    # Internal::SetProfilePrep
    my $prep_profile = $internal->under('/set-profile')->under->to('internal#validade_security_token');
    $prep_profile->post('/')->to('internal-set_profile_prep#post');

    # Internal::Integration
    my $internal_integration = $internal->under('/integration')->to('internal-integration#validate_header_and_pass');

    # Internal::Integration::Recipient
    my $integration_recipient = $internal_integration->under('/recipient')->to('internal-integration-recipient#stasher');

    # Internal::Integration::Recipient::Sync
    my $sync = $integration_recipient->under('/sync');
    $sync->post('/')->to('internal-integration-recipient-sync#post');

    # Internal::AvailableCombinaVouchers
    my $combina_vouchers = $internal->under('/available-combina-vouchers')->under->to('internal#validade_security_token');
    $combina_vouchers->get('/')->to('internal-available_combina_vouchers#get');
}

1;
