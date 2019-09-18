use common::sense;

package Prep::Schema::Result::ViewReport;
use base qw(DBIx::Class::Core);

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

# For the time being this is necessary even for virtual views
__PACKAGE__->table('ViewReport');

__PACKAGE__->add_columns(
    qw(
        count_all count_target_audience count_eligible_for_research count_signed_term count_finished_quiz count_created_appointment count_started_quiz
        count_all_sp count_target_audience_sp count_eligible_for_research_sp count_signed_term_sp count_finished_quiz_sp count_created_appointment_sp count_started_quiz_sp
        count_all_bh count_target_audience_bh count_eligible_for_research_bh count_signed_term_bh count_finished_quiz_bh count_created_appointment_bh count_started_quiz_bh
        count_all_s count_target_audience_s count_eligible_for_research_s count_signed_term_s count_finished_quiz_s count_created_appointment_s count_started_quiz_s
    )
);

# do not attempt to deploy() this view
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(<<'SQL_QUERY');
WITH recipient_without_team AS (
    SELECT
        *
    FROM recipient
    WHERE
    id NOT IN(7, 26, 57, 3, 55, 17, 12, 13, 4, 1, 18, 16, 20)
)
SELECT
    -- GENERAL
    count(1) AS count_all,
    ( SELECT count(1) FROM recipient_without_team r, recipient_flags f WHERE r.id = f.recipient_id AND f.is_target_audience = true ) AS count_target_audience,
    ( SELECT count(1) FROM recipient_without_team r, recipient_flags f WHERE r.id = f.recipient_id AND EXISTS (SELECT 1 FROM answer WHERE recipient_id = r.id) ) AS count_started_quiz,
    ( SELECT count(1) FROM recipient_without_team r, recipient_flags f WHERE r.id = f.recipient_id AND f.is_eligible_for_research = true ) AS count_eligible_for_research,
    ( SELECT count(1) FROM recipient_without_team r, recipient_flags f WHERE r.id = f.recipient_id AND f.signed_term = true ) AS count_signed_term,
    ( SELECT count(1) FROM recipient_without_team r, recipient_flags f WHERE r.id = f.recipient_id AND f.finished_quiz = true ) AS count_finished_quiz,
    ( SELECT count(1) FROM (SELECT DISTINCT recipient_id FROM appointment) a ) AS count_created_appointment,

    -- SP
    ( SELECT count(1) FROM recipient_without_team r WHERE city = '3' ) AS count_all_sp,
    ( SELECT count(1) FROM recipient_without_team r, recipient_flags f WHERE r.id = f.recipient_id AND f.is_target_audience = true AND city = '3' ) AS count_target_audience_sp,
    ( SELECT count(1) FROM recipient_without_team r, recipient_flags f WHERE r.id = f.recipient_id AND r.city = '3' AND EXISTS (SELECT 1 FROM answer WHERE recipient_id = r.id) ) AS count_started_quiz_sp,
    ( SELECT count(1) FROM recipient_without_team r, recipient_flags f WHERE r.id = f.recipient_id AND f.is_eligible_for_research = true AND city = '3' ) AS count_eligible_for_research_sp,
    ( SELECT count(1) FROM recipient_without_team r, recipient_flags f WHERE r.id = f.recipient_id AND f.signed_term = true AND city = '3' ) AS count_signed_term_sp,
    ( SELECT count(1) FROM recipient_without_team r, recipient_flags f WHERE r.id = f.recipient_id AND f.finished_quiz = true AND city = '3' ) AS count_finished_quiz_sp,
    ( SELECT count(1) FROM (SELECT DISTINCT a.recipient_id FROM appointment a, recipient_without_team r WHERE a.recipient_id = r.id AND r.city = '3') a ) AS count_created_appointment_sp,

    -- BH
    ( SELECT count(1) FROM recipient_without_team r WHERE city = '1' ) AS count_all_bh,
    ( SELECT count(1) FROM recipient_without_team r, recipient_flags f WHERE r.id = f.recipient_id AND f.is_target_audience = true AND city = '1' ) AS count_target_audience_bh,
	( SELECT count(1) FROM recipient_without_team r, recipient_flags f WHERE r.id = f.recipient_id AND r.city = '1' AND EXISTS(SELECT 1 FROM answer WHERE recipient_id = r.id) ) AS count_started_quiz_bh,
    ( SELECT count(1) FROM recipient_without_team r, recipient_flags f WHERE r.id = f.recipient_id AND f.is_eligible_for_research = true AND city = '1' ) AS count_eligible_for_research_bh,
    ( SELECT count(1) FROM recipient_without_team r, recipient_flags f WHERE r.id = f.recipient_id AND f.signed_term = true AND city = '1' ) AS count_signed_term_bh,
    ( SELECT count(1) FROM recipient_without_team r, recipient_flags f WHERE r.id = f.recipient_id AND f.finished_quiz = true AND city = '1' ) AS count_finished_quiz_bh,
    ( SELECT count(1) FROM (SELECT DISTINCT a.recipient_id FROM appointment a, recipient_without_team r WHERE a.recipient_id = r.id AND r.city = '1') a ) AS count_created_appointment_bh,

    -- Salvador
    ( SELECT count(1) FROM recipient_without_team r WHERE city = '2' ) AS count_all_s,
    ( SELECT count(1) FROM recipient_without_team r, recipient_flags f WHERE r.id = f.recipient_id AND f.is_target_audience = true AND city = '2' ) AS count_target_audience_s,
	( SELECT count(1) FROM recipient_without_team r, recipient_flags f WHERE r.id = f.recipient_id AND r.city = '2' AND EXISTS(SELECT 1 FROM answer WHERE recipient_id = r.id) ) AS count_started_quiz_s,
    ( SELECT count(1) FROM recipient_without_team r, recipient_flags f WHERE r.id = f.recipient_id AND f.is_eligible_for_research = true AND city = '2' ) AS count_eligible_for_research_s,
    ( SELECT count(1) FROM recipient_without_team r, recipient_flags f WHERE r.id = f.recipient_id AND f.signed_term = true AND city = '2' ) AS count_signed_term_s,
    ( SELECT count(1) FROM recipient_without_team r, recipient_flags f WHERE r.id = f.recipient_id AND f.finished_quiz = true AND city = '2' ) AS count_finished_quiz_s,
    ( SELECT count(1) FROM (SELECT DISTINCT a.recipient_id FROM appointment a, recipient_without_team r WHERE a.recipient_id = r.id AND r.city = '2') a ) AS count_created_appointment_s

FROM recipient_without_team r

SQL_QUERY

1;