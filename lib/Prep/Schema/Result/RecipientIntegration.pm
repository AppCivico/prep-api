use utf8;
package Prep::Schema::Result::RecipientIntegration;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Prep::Schema::Result::RecipientIntegration

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

=head1 TABLE: C<recipient_integration>

=cut

__PACKAGE__->table("recipient_integration");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'recipient_integration_id_seq'

=head2 recipient_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 data

  data_type: 'json'
  default_value: '{}'
  is_nullable: 0

=head2 retry_count

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 err_msg

  data_type: 'text'
  is_nullable: 1

=head2 next_retry_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "recipient_integration_id_seq",
  },
  "recipient_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "data",
  { data_type => "json", default_value => "{}", is_nullable => 0 },
  "retry_count",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "err_msg",
  { data_type => "text", is_nullable => 1 },
  "next_retry_at",
  { data_type => "timestamp", is_nullable => 1 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<recipient_integration_recipient_id_key>

=over 4

=item * L</recipient_id>

=back

=cut

__PACKAGE__->add_unique_constraint("recipient_integration_recipient_id_key", ["recipient_id"]);

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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-02-04 14:23:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Lx8/oU/FNrWRfxnW0JaH5A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->load_components("InflateColumn::Serializer", "Core");
__PACKAGE__->remove_columns(qw/data/);
__PACKAGE__->add_columns(
    data => {
        'data_type'        => "json",
        default_value      => "{}",
        is_nullable        => 0,
        'serializer_class' => 'JSON'
    },
);


__PACKAGE__->meta->make_immutable;
1;
