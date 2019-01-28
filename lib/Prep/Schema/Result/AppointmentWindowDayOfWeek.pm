use utf8;
package Prep::Schema::Result::AppointmentWindowDayOfWeek;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Prep::Schema::Result::AppointmentWindowDayOfWeek

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

=head1 TABLE: C<appointment_window_days_of_week>

=cut

__PACKAGE__->table("appointment_window_days_of_week");

=head1 ACCESSORS

=head2 appointment_window_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 day_of_week

  data_type: 'smallint'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "appointment_window_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "day_of_week",
  { data_type => "smallint", is_nullable => 0 },
);

=head1 RELATIONS

=head2 appointment_window

Type: belongs_to

Related object: L<Prep::Schema::Result::AppointmentWindow>

=cut

__PACKAGE__->belongs_to(
  "appointment_window",
  "Prep::Schema::Result::AppointmentWindow",
  { id => "appointment_window_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2019-01-28 09:47:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:IWdjAAW5pOxabpn4ZhRfvw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
