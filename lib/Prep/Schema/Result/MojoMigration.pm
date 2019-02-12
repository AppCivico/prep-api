use utf8;
package Prep::Schema::Result::MojoMigration;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Prep::Schema::Result::MojoMigration

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

=head1 TABLE: C<mojo_migrations>

=cut

__PACKAGE__->table("mojo_migrations");

=head1 ACCESSORS

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 version

  data_type: 'bigint'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "name",
  { data_type => "text", is_nullable => 0 },
  "version",
  { data_type => "bigint", is_nullable => 0 },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<mojo_migrations_name_key>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("mojo_migrations_name_key", ["name"]);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2019-02-05 14:59:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BKnpN/LFOP/jkrWN+MF58w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
