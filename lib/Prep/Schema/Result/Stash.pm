use utf8;
package Prep::Schema::Result::Stash;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Prep::Schema::Result::Stash

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

=head1 TABLE: C<stash>

=cut

__PACKAGE__->table("stash");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'stash_id_seq'

=head2 recipient_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 question_map_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 value

  data_type: 'json'
  default_value: '{}'
  is_nullable: 0

=head2 updated_at

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
    sequence          => "stash_id_seq",
  },
  "recipient_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "question_map_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "value",
  { data_type => "json", default_value => "{}", is_nullable => 0 },
  "updated_at",
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

=head2 C<stash_recipient_id_question_map_id_key>

=over 4

=item * L</recipient_id>

=item * L</question_map_id>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "stash_recipient_id_question_map_id_key",
  ["recipient_id", "question_map_id"],
);

=head1 RELATIONS

=head2 question_map

Type: belongs_to

Related object: L<Prep::Schema::Result::QuestionMap>

=cut

__PACKAGE__->belongs_to(
  "question_map",
  "Prep::Schema::Result::QuestionMap",
  { id => "question_map_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
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


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2019-02-11 13:16:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sovjGa/ySPVEUZqEAKGA8Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration

use JSON;

sub is_empty {
    my ($self) = @_;

    return !$self->value || $self->value eq '{}' ? 1 : 0;
}

sub parsed {
    my ($self) = @_;

    return from_json( $self->value );
}

__PACKAGE__->meta->make_immutable;
1;
