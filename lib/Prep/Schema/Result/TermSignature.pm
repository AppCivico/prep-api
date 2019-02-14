use utf8;
package Prep::Schema::Result::TermSignature;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Prep::Schema::Result::TermSignature

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

=head1 TABLE: C<term_signature>

=cut

__PACKAGE__->table("term_signature");

=head1 ACCESSORS

=head2 recipient_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 url

  data_type: 'text'
  is_nullable: 0

=head2 signed_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=cut

__PACKAGE__->add_columns(
  "recipient_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "url",
  { data_type => "text", is_nullable => 0 },
  "signed_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<term_signature_recipient_id_url_key>

=over 4

=item * L</recipient_id>

=item * L</url>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "term_signature_recipient_id_url_key",
  ["recipient_id", "url"],
);

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


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2019-02-13 17:09:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YW1GvIU3yqdijCiRU5rC7A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;