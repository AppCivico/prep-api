use utf8;
package Prep::Schema::Result::Appointment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Prep::Schema::Result::Appointment

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

=head1 TABLE: C<appointment>

=cut

__PACKAGE__->table("appointment");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'appointment_id_seq'

=head2 recipient_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 appointment_window_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 quota_number

  data_type: 'integer'
  is_nullable: 1

=head2 updated_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 appointment_at

  data_type: 'timestamp'
  is_nullable: 0

=head2 calendar_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 notification_sent_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 appointment_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 created_by_chatbot

  data_type: 'boolean'
  default_value: false
  is_nullable: 1

=head2 notification_created_at

  data_type: 'timestamp'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "appointment_id_seq",
  },
  "recipient_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "appointment_window_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "quota_number",
  { data_type => "integer", is_nullable => 1 },
  "updated_at",
  { data_type => "timestamp", is_nullable => 1 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "appointment_at",
  { data_type => "timestamp", is_nullable => 0 },
  "calendar_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "notification_sent_at",
  { data_type => "timestamp", is_nullable => 1 },
  "appointment_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "created_by_chatbot",
  { data_type => "boolean", default_value => \"false", is_nullable => 1 },
  "notification_created_at",
  { data_type => "timestamp", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<recipient_calendar_id>

=over 4

=item * L</recipient_id>

=item * L</calendar_id>

=item * L</appointment_at>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "recipient_calendar_id",
  ["recipient_id", "calendar_id", "appointment_at"],
);

=head1 RELATIONS

=head2 appointment_type

Type: belongs_to

Related object: L<Prep::Schema::Result::AppointmentType>

=cut

__PACKAGE__->belongs_to(
  "appointment_type",
  "Prep::Schema::Result::AppointmentType",
  { id => "appointment_type_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 appointment_window

Type: belongs_to

Related object: L<Prep::Schema::Result::AppointmentWindow>

=cut

__PACKAGE__->belongs_to(
  "appointment_window",
  "Prep::Schema::Result::AppointmentWindow",
  { id => "appointment_window_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 calendar

Type: belongs_to

Related object: L<Prep::Schema::Result::Calendar>

=cut

__PACKAGE__->belongs_to(
  "calendar",
  "Prep::Schema::Result::Calendar",
  { id => "calendar_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

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


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2019-06-10 14:34:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:e/bckeKs83gZW9jxSHVOXg


# You can replace this text with custom code or comments, and it will be preserved on regeneration

sub info {
    my ($self) = @_;

    my $quota_map = $self->appointment_window->quota_map;

    my $quota = $quota_map->{ $self->quota_number };
    my $ymd   = $self->appointment_at->ymd;

    my $calendar = $self->appointment_window->calendar;

    return +{
        id                    => $self->id,
        appointment_window_id => $self->appointment_window_id,
        quota_number          => $self->quota_number,
        type                  => $self->appointment_type->name,
        time                  => $quota->{text},
        datetime_start        => $self->appointment_at,
        datetime_end          => $ymd . 'T' . $quota->{end},
        calendar => {
            id         => $calendar->id,
            name       => $calendar->name,
            state      => $calendar->address_state,
            city       => $calendar->address_city,
            street     => $calendar->address_street,
            number     => $calendar->address_number,
            district   => $calendar->address_district,
            complement => $calendar->address_complement,
            phone      => $calendar->phone,
        }
    }
}

__PACKAGE__->meta->make_immutable;
1;
