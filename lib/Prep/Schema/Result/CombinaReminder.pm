use utf8;
package Prep::Schema::Result::CombinaReminder;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Prep::Schema::Result::CombinaReminder

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

=head1 TABLE: C<combina_reminder>

=cut

__PACKAGE__->table("combina_reminder");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'combina_reminder_id_seq'

=head2 recipient_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 reminder_hours_before

  data_type: 'time'
  is_nullable: 1

=head2 reminder_hour_exact

  data_type: 'time'
  is_nullable: 1

=head2 reminder_22h

  data_type: 'timestamp'
  is_nullable: 1

=head2 reminder_double

  data_type: 'timestamp'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "combina_reminder_id_seq",
  },
  "recipient_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "reminder_hours_before",
  { data_type => "time", is_nullable => 1 },
  "reminder_hour_exact",
  { data_type => "time", is_nullable => 1 },
  "reminder_22h",
  { data_type => "timestamp", is_nullable => 1 },
  "reminder_double",
  { data_type => "timestamp", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<combina_reminder_recipient_id_key>

=over 4

=item * L</recipient_id>

=back

=cut

__PACKAGE__->add_unique_constraint("combina_reminder_recipient_id_key", ["recipient_id"]);

=head1 RELATIONS

=head2 recipient

Type: belongs_to

Related object: L<Prep::Schema::Result::Recipient>

=cut

__PACKAGE__->belongs_to(
  "recipient",
  "Prep::Schema::Result::Recipient",
  { id => "recipient_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-04-24 17:07:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Y7qW+fCwFx/zI9/mlxoDqA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
