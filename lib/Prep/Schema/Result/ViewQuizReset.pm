use common::sense;

package Prep::Schema::Result::ViewQuizReset;
use base qw(DBIx::Class::Core);

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

# For the time being this is necessary even for virtual views
__PACKAGE__->table('ViewQuizReset');

__PACKAGE__->add_columns(qw( recipient_id ));

# do not attempt to deploy() this view
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(<<'SQL_QUERY');
select
    a.recipient_id,
    max(a.created_at) as max_created_at
from
    answer a
join
    recipient_flags f on (a.recipient_id = f.recipient_id)
where
    a.created_at <= now() - interval '3 months' AND
    f.is_target_audience = true AND
    f.is_eligible_for_research = false
group by
    a.recipient_id

SQL_QUERY

1;