use utf8;
package Prep::Schema::Result::Question;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Prep::Schema::Result::Question

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

=head1 TABLE: C<question>

=cut

__PACKAGE__->table("question");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'question_id_seq'

=head2 code

  data_type: 'varchar'
  is_nullable: 0
  size: 4

=head2 type

  data_type: 'text'
  is_nullable: 0

=head2 text

  data_type: 'text'
  is_nullable: 0

=head2 multiple_choices

  data_type: 'json'
  is_nullable: 1

=head2 extra_quick_replies

  data_type: 'json'
  is_nullable: 1

=head2 is_differentiator

  data_type: 'boolean'
  is_nullable: 0

=head2 updated_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 question_map_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "question_id_seq",
  },
  "code",
  { data_type => "varchar", is_nullable => 0, size => 4 },
  "type",
  { data_type => "text", is_nullable => 0 },
  "text",
  { data_type => "text", is_nullable => 0 },
  "multiple_choices",
  { data_type => "json", is_nullable => 1 },
  "extra_quick_replies",
  { data_type => "json", is_nullable => 1 },
  "is_differentiator",
  { data_type => "boolean", is_nullable => 0 },
  "updated_at",
  { data_type => "timestamp", is_nullable => 1 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "question_map_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 answers

Type: has_many

Related object: L<Prep::Schema::Result::Answer>

=cut

__PACKAGE__->has_many(
  "answers",
  "Prep::Schema::Result::Answer",
  { "foreign.question_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

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


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2019-01-29 16:34:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:cDwrSJDmEcvR7ifVjao8MA


# You can replace this text with custom code or comments, and it will be preserved on regeneration

use JSON;

sub decoded {
    my ($self) = @_;

    return {
        id                  => $self->id,
        code                => $self->code,
        type                => $self->type,
        text                => $self->text,
        is_differentiator   => $self->is_differentiator,
        multiple_choices    => $self->multiple_choices    ? from_json( $self->multiple_choices )    : undef,
        extra_quick_replies => $self->extra_quick_replies ? from_json( $self->extra_quick_replies ) : undef,
        updated_at          => $self->updated_at,
        created_at          => $self->created_at
    }
}

sub answer_by_choice_value {
    my ($self, $value) = @_;

    die \['value', 'missing'] unless $value;

    my $multiple_choices = from_json( $self->multiple_choices );

    return $multiple_choices->{$value};
}

__PACKAGE__->meta->make_immutable;
1;
