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
    a.created_at AS last_answer_at
FROM
    recipient r
JOIN
    answer a ON ( a.recipient_id  = r.id )
JOIN
    question q ON ( a.question_id = q.id )
WHERE
    r.question_notification_sent_at IS NULL
    AND r.finished_quiz = false
    AND r.opt_in = true
    AND a.created_at <= NOW() - interval '3 hours'
GROUP BY
    r.id,
    r.fb_id,
    r.name,
    a.created_at
ORDER BY
    a.created_at DESC

SQL_QUERY

1;