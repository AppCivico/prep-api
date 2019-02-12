use utf8;
package Prep::Schema::Result::MinionJob;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Prep::Schema::Result::MinionJob

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::PassphraseColumn>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");

=head1 TABLE: C<minion_jobs>

=cut

__PACKAGE__->table("minion_jobs");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'minion_jobs_id_seq'

=head2 args

  data_type: 'jsonb'
  is_nullable: 0

=head2 created

  data_type: 'timestamp with time zone'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 delayed

  data_type: 'timestamp with time zone'
  is_nullable: 0

=head2 finished

  data_type: 'timestamp with time zone'
  is_nullable: 1

=head2 priority

  data_type: 'integer'
  is_nullable: 0

=head2 result

  data_type: 'jsonb'
  is_nullable: 1

=head2 retried

  data_type: 'timestamp with time zone'
  is_nullable: 1

=head2 retries

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 started

  data_type: 'timestamp with time zone'
  is_nullable: 1

=head2 state

  data_type: 'enum'
  default_value: 'inactive'
  extra: {custom_type_name => "minion_state",list => ["inactive","active","failed","finished"]}
  is_nullable: 0

=head2 task

  data_type: 'text'
  is_nullable: 0

=head2 worker

  data_type: 'bigint'
  is_nullable: 1

=head2 queue

  data_type: 'text'
  default_value: 'default'
  is_nullable: 0

=head2 attempts

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

=head2 parents

  data_type: 'bigint[]'
  default_value: '{}'::bigint[]
  is_nullable: 0

=head2 notes

  data_type: 'jsonb'
  default_value: '{}'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "minion_jobs_id_seq",
  },
  "args",
  { data_type => "jsonb", is_nullable => 0 },
  "created",
  {
    data_type     => "timestamp with time zone",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "delayed",
  { data_type => "timestamp with time zone", is_nullable => 0 },
  "finished",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "priority",
  { data_type => "integer", is_nullable => 0 },
  "result",
  { data_type => "jsonb", is_nullable => 1 },
  "retried",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "retries",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "started",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "state",
  {
    data_type => "enum",
    default_value => "inactive",
    extra => {
      custom_type_name => "minion_state",
      list => ["inactive", "active", "failed", "finished"],
    },
    is_nullable => 0,
  },
  "task",
  { data_type => "text", is_nullable => 0 },
  "worker",
  { data_type => "bigint", is_nullable => 1 },
  "queue",
  { data_type => "text", default_value => "default", is_nullable => 0 },
  "attempts",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
  "parents",
  {
    data_type     => "bigint[]",
    default_value => \"'{}'::bigint[]",
    is_nullable   => 0,
  },
  "notes",
  { data_type => "jsonb", default_value => "{}", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2019-02-05 14:59:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fJGBpIFkGgfwsAWWRC8kLg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
