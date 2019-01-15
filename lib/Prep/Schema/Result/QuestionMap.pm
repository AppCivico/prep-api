use utf8;
package Prep::Schema::Result::QuestionMap;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Prep::Schema::Result::QuestionMap

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

=head1 TABLE: C<question_map>

=cut

__PACKAGE__->table("question_map");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  default_value: 1
  is_nullable: 1

=head2 map

  data_type: 'json'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", default_value => 1, is_nullable => 1 },
  "map",
  { data_type => "json", is_nullable => 0 },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<question_map_id_key>

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->add_unique_constraint("question_map_id_key", ["id"]);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2019-01-15 09:58:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Ls/2OV+SCbM/bkwV8WvWAw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
