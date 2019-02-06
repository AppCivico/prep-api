use common::sense;

package Prep::Schema::Result::ViewRecipientQuiz;
use base qw(DBIx::Class::Core);

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

# For the time being this is necessary even for virtual views
__PACKAGE__->table('ViewRecipientQuiz');

__PACKAGE__->add_columns(qw( id fb_id name last_answer_at ));

# do not attempt to deploy() this view
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(<<'SQL_QUERY');
SELECT
    r.id,
    r.fb_id,
    r.name,
    a.appointment_at AS appointment_at
FROM
    recipient r
JOIN
    appointment a ON ( a.recipient_id  = r.id )
WHERE
    a.appointment_at >= (now() + interval '1 day')::date

SQL_QUERY

1;