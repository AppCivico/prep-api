use utf8;
package Prep::Schema::Result::RecipientFlag;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Prep::Schema::Result::RecipientFlag

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

=head1 TABLE: C<recipient_flags>

=cut

__PACKAGE__->table("recipient_flags");

=head1 ACCESSORS

=head2 recipient_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 is_eligible_for_research

  data_type: 'boolean'
  is_nullable: 1

=head2 is_part_of_research

  data_type: 'boolean'
  is_nullable: 1

=head2 is_prep

  data_type: 'boolean'
  is_nullable: 1

=head2 updated_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 is_target_audience

  data_type: 'boolean'
  is_nullable: 1

=head2 signed_term

  data_type: 'boolean'
  is_nullable: 1

=head2 finished_quiz

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "recipient_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "is_eligible_for_research",
  { data_type => "boolean", is_nullable => 1 },
  "is_part_of_research",
  { data_type => "boolean", is_nullable => 1 },
  "is_prep",
  { data_type => "boolean", is_nullable => 1 },
  "updated_at",
  { data_type => "timestamp", is_nullable => 1 },
  "is_target_audience",
  { data_type => "boolean", is_nullable => 1 },
  "signed_term",
  { data_type => "boolean", is_nullable => 1 },
  "finished_quiz",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</recipient_id>

=back

=cut

__PACKAGE__->set_primary_key("recipient_id");

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


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2019-02-19 09:59:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vG2MRJbRRH9ncfKe69Icmw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
