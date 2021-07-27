use common::sense;

package Prep::Schema::Result::ViewAvgAppointmentTime;
use base qw(DBIx::Class::Core);

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

# For the time being this is necessary even for virtual views
__PACKAGE__->table('ViewAvgAppointmentTime');

__PACKAGE__->add_columns(qw( avg_epoch ));

# do not attempt to deploy() this view
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(<<'SQL_QUERY');

WITH avg_per_recipient AS (
    SELECT
        avg (extract( epoch FROM a.created_at ) - extract(epoch FROM r.created_at )) as epoch
    FROM
        recipient r
    JOIN appointment a ON a.recipient_id = r.id
    WHERE r.created_at BETWEEN to_timestamp(?) AND to_timestamp(?)
    GROUP BY a.recipient_id
) SELECT round(avg(epoch)/3600, 2) avg_epoch FROM avg_per_recipient

SQL_QUERY

1;