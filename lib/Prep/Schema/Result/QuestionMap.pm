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
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'question_map_id_seq'

=head2 map

  data_type: 'json'
  is_nullable: 0

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 category_id

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
    sequence          => "question_map_id_seq",
  },
  "map",
  { data_type => "json", is_nullable => 0 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "category_id",
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
  { "foreign.question_map_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 category

Type: belongs_to

Related object: L<Prep::Schema::Result::Category>

=cut

__PACKAGE__->belongs_to(
  "category",
  "Prep::Schema::Result::Category",
  { id => "category_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 questions

Type: has_many

Related object: L<Prep::Schema::Result::Question>

=cut

__PACKAGE__->has_many(
  "questions",
  "Prep::Schema::Result::Question",
  { "foreign.question_map_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 screenings

Type: has_many

Related object: L<Prep::Schema::Result::Screening>

=cut

__PACKAGE__->has_many(
  "screenings",
  "Prep::Schema::Result::Screening",
  { "foreign.question_map_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 stashes

Type: has_many

Related object: L<Prep::Schema::Result::Stash>

=cut

__PACKAGE__->has_many(
  "stashes",
  "Prep::Schema::Result::Stash",
  { "foreign.question_map_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2019-02-19 09:58:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0pP+GkpggR1VxfWzuncdug


# You can replace this text with custom code or comments, and it will be preserved on regeneration

use JSON::MaybeXS;

sub parsed {
    my ($self) = @_;

    return decode_json( $self->map );
}

sub can_be_iterated {
    my $self = shift;

    return $self->category->can_be_iterated;
}

sub count_questions {
    my $self = shift;

    my $questions = $self->parsed;

    return scalar keys %{ $questions };
}

sub build_conditions {
    my ($self, %opts) = @_;

    my @required_opts = qw( recipient_id next_question_code );
    defined $opts{$_} or die \["opts{$_}", 'missing'] for @required_opts;

    my $next_question_code = $opts{next_question_code};
    my $recipient_id       = $opts{recipient_id};

    my $answers_rs = $self->result_source->schema->resultset('Answer')->search( { recipient_id => $recipient_id } );

    my (@conditions, $condition);
    if ( $self->category_id == 1 ) {
        # Quiz

        if ( $next_question_code eq 'A3' ) {
            # Deve ter mais de 14 e menos de 20
            $condition = $answers_rs->search(
                {
                    'question.code' => 'A2',
                    answer_value    => { '>' => '14', '<' => '20' }
                },
                { join => 'question'}
            )->as_query;

            push @conditions, { -exists => $condition };
        }
        elsif ( $next_question_code eq 'A2' ) {
            # Só pode ser de SP, BH ou Salvador.
            for ( 1 .. 3 ) {
                $condition = $answers_rs->search(
                    {
                        'question.code' => 'A1',
                        answer_value    => $_
                    },
                    { join => 'question'}
                )->as_query;

                push @conditions, { -exists => $condition };

            }
        }
        elsif ( $next_question_code eq 'B1' ) {
            $condition = $answers_rs->search(
                {
                    'question.code' => 'A3',
                    answer_value    => { '!=' => '2', '!=' => '3' }
                },
                { join => 'question'}
            )->as_query;

            push @conditions, { -exists => $condition };
        }
        elsif ( $next_question_code eq 'B1a' ) {
            $condition = $answers_rs->search(
                {
                    'question.code' => 'B1',
                    answer_value    => '1'
                },
                { join => 'question'}
            )->as_query;

            push @conditions, { -exists => $condition };
        }
        elsif ( $next_question_code eq 'B2a' ) {
            $condition = $answers_rs->search(
                {
                    'question.code' => 'B2',
                    answer_value    => { '!=' => '0' }
                },
                { join => 'question'}
            )->as_query;

            push @conditions, { -exists => $condition };
        }
        elsif ( $next_question_code eq 'B2b' ) {
            $condition = $answers_rs->search(
                {
                    'question.code' => 'B2a',
                    answer_value    => '1'
                },
                { join => 'question'}
            )->as_query;

            push @conditions, { -exists => $condition };
        }
        elsif ( $next_question_code eq 'D4a' ) {
            $condition = $answers_rs->search(
                {
                    'question.code' => 'D4',
                    answer_value    => '1'
                },
                { join => 'question'}
            )->as_query;

            push @conditions, { -exists => $condition };
        }
        elsif ( $next_question_code eq 'D4b' ) {
            $condition = $answers_rs->search(
                {
                    'question.code' => 'D4',
                    answer_value    => '2'
                },
                { join => 'question'}
            )->as_query;

            push @conditions, { -exists => $condition };
        }
        else {
            die \['code', 'invalid'];
        }

    }
    else {
        # Screening

        if ( $next_question_code eq 'SC6' ) {
            for my $question ( qw( SC2 SC3 SC4 SC5 ) ) {

                $condition = $answers_rs->search(
                    {
                        'question.code' => $question,
                        answer_value    => '1'
                    },
                    { join => 'question'}
                )->as_query;

                push @conditions, { -exists => $condition };
            }
        }
        elsif ( $next_question_code eq 'SC2' ) {

            for ( 2 .. 4 ) {
                $condition = $answers_rs->search(
                    {
                        'question.code' => 'SC1',
                        answer_value    => $_
                    },
                    { join => 'question'}
                )->as_query;

                push @conditions, { -exists => $condition };

            }
        }
        elsif ( $next_question_code eq 'SC6a' ) {

            for my $question ( qw( SC2 SC3 SC4 SC5 ) ) {

                $condition = $answers_rs->search(
                    {
                        'question.code' => $question,
                        answer_value    => '1'
                    },
                    { join => 'question'}
                )->as_query;

                push @conditions, { -exists => $condition };
            }
        }
    }

    return @conditions;
}

__PACKAGE__->meta->make_immutable;
1;
