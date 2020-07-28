use utf8;
package Prep::Schema::Result::Interaction;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Prep::Schema::Result::Interaction

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

=head1 TABLE: C<interaction>

=cut

__PACKAGE__->table("interaction");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'interaction_id_seq'

=head2 recipient_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 started_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 closed_at

  data_type: 'timestamp'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "interaction_id_seq",
  },
  "recipient_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "started_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "closed_at",
  { data_type => "timestamp", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-02-10 14:08:12
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kqykQjRCKbpGAdsnujVyyA


# You can replace this text with custom code or comments, and it will be preserved on regeneration

sub close {
    my $self = shift;

    my $now_epoch   = time();
    my $start_epoch = $self->started_at->epoch;

    die \['interaction_id', 'must be at least 24 hours'] if $now_epoch - $start_epoch < 86400;

    return 1;
}

__PACKAGE__->meta->make_immutable;
1;
