use common::sense;

package Prep::Schema::Result::ViewReport;
use base qw(DBIx::Class::Core);

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

# For the time being this is necessary even for virtual views
__PACKAGE__->table('ViewReport');

__PACKAGE__->add_columns(qw( count_all count_target_audience count_eligible_for_research count_signed_term count_finished_quiz count_created_appointment ));

# do not attempt to deploy() this view
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(<<'SQL_QUERY');
SELECT
    count(1) AS count_all,
    ( SELECT count(1) FROM recipient r, recipient_flags f WHERE r.id = f.recipient_id AND f.is_target_audience = true ) AS count_target_audience,
    ( SELECT count(1) FROM recipient r, recipient_flags f WHERE r.id = f.recipient_id AND f.is_eligible_for_research = true ) AS count_eligible_for_research,
    ( SELECT count(1) FROM recipient r, recipient_flags f WHERE r.id = f.recipient_id AND f.signed_term = true ) AS count_signed_term,
    ( SELECT count(1) FROM recipient r, recipient_flags f WHERE r.id = f.recipient_id AND f.finished_quiz = true ) AS count_finished_quiz,
    ( SELECT count(1) FROM (SELECT DISTINCT recipient_id FROM appointment) a ) AS count_created_appointment
FROM recipient r

SQL_QUERY

1;