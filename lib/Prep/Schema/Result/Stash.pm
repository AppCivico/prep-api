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

=head2 finished

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

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
  "finished",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
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


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2019-02-17 22:17:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZFuzH1uxv82JCJT3tFLpuQ


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

sub initiate {
    my ($self) = @_;

    return $self->update( { value => $self->question_map->map } );
}

sub answered_questions {
    my ($self) = @_;

    return $self->recipient->answers->question_code_by_map_id( $self->question_map_id )->get_column('question.code')->all();
}

sub next_question {
    my ($self) = @_;

    my $ret;
    if ( $self->finished ) {
        # Caso não tenha uma próxima pergunta
        # Devo mostrar flags
        my %flags;
        if ( $self->category eq 'quiz' ) {
            %flags = $self->recipient->all_flags;
        }
        elsif ( $self->category eq 'screening' ) {
            %flags = $self->recipient->all_screening_flags;
        }

        $ret = {
            question   => undef,
            has_more   => 0,
			count_more => 0,

            %flags
        }
    }
    else {
        my $question_map       = $self->parsed;
        my @answered_questions = $self->answered_questions;

        my @pending_questions  = sort { $a <=> $b } grep { my $k = $_; !grep { $question_map->{$k} eq $_ } @answered_questions } sort keys %{ $question_map };

        my $next_question_code = scalar @pending_questions > 0 ? $question_map->{ $pending_questions[0] } : undef;
        return $next_question_code unless defined $next_question_code;

        my $question_rs   = $self->result_source->schema->resultset('Question');
        my $next_question = $question_rs->search( { code => $next_question_code, question_map_id => $self->question_map_id } )->next;

        $ret = {
			question   => $next_question,
			has_more   => scalar @pending_questions > 1 ? 1 : 0,
			count_more => scalar @pending_questions - 1,
        }
    }

    return $ret;
}

sub remove_question {
    my ($self, $code) = @_;

    die \['code', 'missing'] unless $code;

    my $map = $self->parsed;

	my %r_map = reverse %{$map};
	my $key   = $r_map{$code};
	die \['code', 'invalid'] unless $key;

    delete $map->{$key};

    # Deletando qualquer pergunta atrelada por salto de lógica
    my $question = $self->result_source->schema->resultset('Question')->search(
        {
            code            => $code,
            question_map_id => $self->question_map_id
        }
    )->next;
    my $question_rules = $question->rules_parsed;

    if ( $question_rules && scalar @{ $question_rules->{logic_jumps} } > 0 ) {
        for my $logic_jump ( @{ $question_rules->{logic_jumps} } ) {
            $key = $r_map{ $logic_jump->{code} };

            delete $map->{$key} if $key;
        }
    }

    return $self->update( { value => to_json( $map ) } );
}

sub category {
    my ($self) = @_;

    return $self->question_map->category->name;
}

__PACKAGE__->meta->make_immutable;
1;
