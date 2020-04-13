use utf8;
package Prep::Schema::Result::PrepReminder;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Prep::Schema::Result::PrepReminder

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

=head1 TABLE: C<prep_reminder>

=cut

__PACKAGE__->table("prep_reminder");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'prep_reminder_id_seq'

=head2 recipient_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 reminder_before

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 reminder_before_interval

  data_type: 'interval'
  is_nullable: 1

=head2 reminder_after

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 reminder_after_interval

  data_type: 'interval'
  is_nullable: 1

=head2 reminder_temporal_wait_until

  data_type: 'timestamp'
  is_nullable: 1

=head2 reminder_temporal_last_sent_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 reminder_temporal_confirmed_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 reminder_running_out

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 reminder_running_out_date

  data_type: 'date'
  is_nullable: 1

=head2 reminder_running_out_last_sent_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 errmsg

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "prep_reminder_id_seq",
  },
  "recipient_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "reminder_before",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "reminder_before_interval",
  { data_type => "interval", is_nullable => 1 },
  "reminder_after",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "reminder_after_interval",
  { data_type => "interval", is_nullable => 1 },
  "reminder_temporal_wait_until",
  { data_type => "timestamp", is_nullable => 1 },
  "reminder_temporal_last_sent_at",
  { data_type => "timestamp", is_nullable => 1 },
  "reminder_temporal_confirmed_at",
  { data_type => "timestamp", is_nullable => 1 },
  "reminder_running_out",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "reminder_running_out_date",
  { data_type => "date", is_nullable => 1 },
  "reminder_running_out_last_sent_at",
  { data_type => "timestamp", is_nullable => 1 },
  "errmsg",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<prep_reminder_recipient_id_key>

=over 4

=item * L</recipient_id>

=back

=cut

__PACKAGE__->add_unique_constraint("prep_reminder_recipient_id_key", ["recipient_id"]);

=head1 RELATIONS

=head2 notification_queues

Type: has_many

Related object: L<Prep::Schema::Result::NotificationQueue>

=cut

__PACKAGE__->has_many(
  "notification_queues",
  "Prep::Schema::Result::NotificationQueue",
  { "foreign.prep_reminder_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-04-13 15:31:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Hw8XbY14goORwYiDXUd9Tg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
