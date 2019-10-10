use common::sense;

package Prep::Schema::Result::ViewReport;
use base qw(DBIx::Class::Core);

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

# For the time being this is necessary even for virtual views
__PACKAGE__->table('ViewReport');

__PACKAGE__->add_columns(
    qw(
        count_all count_target_audience count_eligible_for_research count_signed_term count_finished_quiz count_created_appointment count_started_quiz count_answered_last_question
        count_all_sp count_target_audience_sp count_eligible_for_research_sp count_signed_term_sp count_finished_quiz_sp count_created_appointment_sp count_started_quiz_sp count_answered_last_question_sp
        count_all_bh count_target_audience_bh count_eligible_for_research_bh count_signed_term_bh count_finished_quiz_bh count_created_appointment_bh count_started_quiz_bh count_answered_last_question_bh
        count_all_s count_target_audience_s count_eligible_for_research_s count_signed_term_s count_finished_quiz_s count_created_appointment_s count_started_quiz_s count_answered_last_question_s
    )
);

# do not attempt to deploy() this view
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(<<'SQL_QUERY');
WITH recipient_with_flags AS (
    SELECT
    *
    FROM recipient r, recipient_flags f
    WHERE r.id = f.recipient_id
    AND r.created_at > '2019-06-21 00:00:00.000000+00'
    AND r.id NOT IN (7, 57, 3, 55, 17, 12, 13, 4, 1, 18, 16, 20, 22, 10, 9,15, 14, 70, 30)
)
SELECT
    --- General
    count(r.id) AS count_all,
    ( SELECT count(1) FROM recipient_with_flags r WHERE r.is_target_audience = true ) AS count_target_audience,
    ( SELECT count(1) FROM recipient_with_flags r WHERE EXISTS (SELECT 1 FROM answer WHERE recipient_id = r.id) ) AS count_started_quiz,
    ( SELECT count(1) FROM recipient_with_flags r WHERE r.is_eligible_for_research = true ) AS count_eligible_for_research,
    ( SELECT count(1) FROM recipient_with_flags r WHERE r.signed_term = true ) AS count_signed_term,
    ( SELECT count(1) FROM recipient_with_flags r WHERE r.finished_quiz = true ) AS count_finished_quiz,
    ( SELECT count(1) FROM (SELECT DISTINCT aa.recipient_id FROM appointment aa, recipient_with_flags rr WHERE aa.recipient_id = rr.id) a ) AS count_created_appointment,
    ( SELECT count(1) FROM recipient_with_flags r WHERE EXISTS (SELECT 1 FROM answer a, question q WHERE a.recipient_id = r.id AND q.id = a.question_id AND q.code = 'AC9' ) ) AS count_answered_last_question,

    --- SP
    ( SELECT count(1) FROM recipient_with_flags r WHERE city = '3' ) AS count_all_sp,
    ( SELECT count(1) FROM recipient_with_flags r WHERE is_target_audience = true AND city = '3' ) AS count_target_audience_sp,
    ( SELECT count(1) FROM recipient_with_flags r WHERE city = '3' AND EXISTS (SELECT 1 FROM answer WHERE recipient_id = r.id) ) AS count_started_quiz_sp,
    ( SELECT count(1) FROM recipient_with_flags r WHERE is_eligible_for_research = true AND city = '3' ) AS count_eligible_for_research_sp,
    ( SELECT count(1) FROM recipient_with_flags r WHERE signed_term = true AND city = '3' ) AS count_signed_term_sp,
    ( SELECT count(1) FROM recipient_with_flags r WHERE finished_quiz = true AND city = '3' ) AS count_finished_quiz_sp,
    ( SELECT count(1) FROM (SELECT DISTINCT a.recipient_id FROM appointment a, recipient_with_flags r WHERE a.recipient_id = r.id AND r.city = '3') a ) AS count_created_appointment_sp,
    ( SELECT count(1) FROM recipient_with_flags r WHERE city = '3' AND EXISTS (SELECT 1 FROM answer a, question q WHERE a.recipient_id = r.id AND q.id = a.question_id AND q.code = 'AC9' ) ) AS count_answered_last_question_sp,

    --- BH
    ( SELECT count(1) FROM recipient_with_flags r WHERE city = '1' ) AS count_all_bh,
    ( SELECT count(1) FROM recipient_with_flags r WHERE r.is_target_audience = true AND city = '1' ) AS count_target_audience_bh,
	( SELECT count(1) FROM recipient_with_flags r WHERE r.city = '1' AND EXISTS(SELECT 1 FROM answer WHERE recipient_id = r.id) ) AS count_started_quiz_bh,
    ( SELECT count(1) FROM recipient_with_flags r WHERE r.is_eligible_for_research = true AND city = '1' ) AS count_eligible_for_research_bh,
    ( SELECT count(1) FROM recipient_with_flags r WHERE r.signed_term = true AND city = '1' ) AS count_signed_term_bh,
    ( SELECT count(1) FROM recipient_with_flags r WHERE r.finished_quiz = true AND city = '1' ) AS count_finished_quiz_bh,
    ( SELECT count(1) FROM (SELECT DISTINCT a.recipient_id FROM appointment a, recipient_with_flags r WHERE a.recipient_id = r.id AND r.city = '1') a ) AS count_created_appointment_bh,
    ( SELECT count(1) FROM recipient_with_flags r WHERE city = '1' AND EXISTS (SELECT 1 FROM answer a, question q WHERE a.recipient_id = r.id AND q.id = a.question_id AND q.code = 'AC9' ) ) AS count_answered_last_question_bh,

    --- SA
    ( SELECT count(1) FROM recipient_with_flags r WHERE city = '2' ) AS count_all_s,
    ( SELECT count(1) FROM recipient_with_flags r WHERE r.is_target_audience = true AND city = '2' ) AS count_target_audience_s,
	( SELECT count(1) FROM recipient_with_flags r WHERE r.city = '2' AND EXISTS(SELECT 1 FROM answer WHERE recipient_id = r.id) ) AS count_started_quiz_s,
    ( SELECT count(1) FROM recipient_with_flags r WHERE r.is_eligible_for_research = true AND city = '2' ) AS count_eligible_for_research_s,
    ( SELECT count(1) FROM recipient_with_flags r WHERE r.signed_term = true AND city = '2' ) AS count_signed_term_s,
    ( SELECT count(1) FROM recipient_with_flags r WHERE r.finished_quiz = true AND city = '2' ) AS count_finished_quiz_s,
    ( SELECT count(1) FROM (SELECT DISTINCT a.recipient_id FROM appointment a, recipient_with_flags r WHERE a.recipient_id = r.id AND r.city = '2') a ) AS count_created_appointment_s,
    ( SELECT count(1) FROM recipient_with_flags r WHERE city = '2' AND EXISTS (SELECT 1 FROM answer a, question q WHERE a.recipient_id = r.id AND q.id = a.question_id AND q.code = 'AC9' ) ) AS count_answered_last_question_s
FROM recipient_with_flags r

SQL_QUERY

1;