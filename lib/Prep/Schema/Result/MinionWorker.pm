use utf8;
package Prep::Schema::Result::MinionWorker;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Prep::Schema::Result::MinionWorker

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

=head1 TABLE: C<minion_workers>

=cut

__PACKAGE__->table("minion_workers");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'minion_workers_id_seq'

=head2 host

  data_type: 'text'
  is_nullable: 0

=head2 pid

  data_type: 'integer'
  is_nullable: 0

=head2 started

  data_type: 'timestamp with time zone'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 notified

  data_type: 'timestamp with time zone'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 inbox

  data_type: 'jsonb'
  default_value: '[]'
  is_nullable: 0

=head2 status

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
    sequence          => "minion_workers_id_seq",
  },
  "host",
  { data_type => "text", is_nullable => 0 },
  "pid",
  { data_type => "integer", is_nullable => 0 },
  "started",
  {
    data_type     => "timestamp with time zone",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "notified",
  {
    data_type     => "timestamp with time zone",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "inbox",
  { data_type => "jsonb", default_value => "[]", is_nullable => 0 },
  "status",
  { data_type => "jsonb", default_value => "{}", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2019-02-05 14:59:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TcfsyPMz6nY/7Fzi8nn0og


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
