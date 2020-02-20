use common::sense;

package Prep::Schema::Result::ViewReportGeneral;
use base qw(DBIx::Class::Core);

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

# For the time being this is necessary even for virtual views
__PACKAGE__->table('ViewReportGeneral');

__PACKAGE__->add_columns(
    qw(
        count_one_interaction
        count_multiple_interactions
        count_refused_publico_interesse
        count_started_publico_interesse_after_refusal
        count_started_publico_interesse
        count_finished_publico_interesse
        count_started_quiz_brincadeira
        count_finished_quiz_brincadeira
    )
);

# do not attempt to deploy() this view
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(<<'SQL_QUERY');
WITH interaction_grouped AS (
    SELECT
        count(1) as count,
        recipient_id
    FROM
        interaction
    WHERE started_at BETWEEN to_timestamp(?) AND to_timestamp(?)
    AND closed_at IS NOT NULL
    GROUP BY recipient_id
), quick_reply_log_grouped AS (
    SELECT
        count(1) as count,
        recipient_id
    FROM
        quick_reply_log
    WHERE payload = 'desafioRecusado' AND
        created_at BETWEEN to_timestamp(?) AND to_timestamp(?)
    GROUP BY recipient_id
), answers_filtered AS (
    select
        id,
        recipient_id,
        question_id,
        created_at
    FROM
        answer
    WHERE created_at BETWEEN to_timestamp(?) AND to_timestamp(?)
)
SELECT
    (SELECT count(1) FROM interaction_grouped i WHERE i.count = 1) AS count_one_interaction,
    (SELECT count(1) FROM interaction_grouped i WHERE i.count > 1) AS count_multiple_interactions,
    (SELECT count(1) FROM quick_reply_log_grouped q) AS count_refused_publico_interesse,
    (
        SELECT
            count(1)
        FROM
            quick_reply_log_grouped q
        JOIN answer a ON q.recipient_id = a.recipient_id
    ) AS count_started_publico_interesse_after_refusal,
    ( SELECT COUNT(DISTINCT recipient_id) FROM answers_filtered ) AS count_started_publico_interesse,
    (
        SELECT
            count(1)
        FROM recipient_flags f
        JOIN answers_filtered a ON a.recipient_id = f.recipient_id
        WHERE f.finished_publico_interesse = true
    ) AS count_finished_publico_interesse,
    (SELECT count(1) FROM answers_filtered a JOIN question q ON a.question_id = q.id WHERE q.code = 'AC1' ) AS count_started_quiz_brincadeira,
    (
        SELECT
            count(1)
        FROM recipient_flags f
        WHERE f.finished_quiz_brincadeira = true AND
        EXISTS (
            SELECT
                1
            FROM answers_filtered a
            JOIN question q ON q.id = a.question_id
            WHERE q.code = 'AC8'
        )
    ) AS count_finished_quiz_brincadeira

SQL_QUERY

1;