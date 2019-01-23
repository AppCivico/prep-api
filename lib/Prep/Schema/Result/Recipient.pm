use utf8;
package Prep::Schema::Result::Recipient;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Prep::Schema::Result::Recipient

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

=head1 TABLE: C<recipient>

=cut

__PACKAGE__->table("recipient");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'recipient_id_seq'

=head2 fb_id

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 page_id

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 picture

  data_type: 'text'
  is_nullable: 1

=head2 opt_in

  data_type: 'boolean'
  default_value: true
  is_nullable: 0

=head2 updated_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 question_notification_sent_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 finished_quiz

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
    sequence          => "recipient_id_seq",
  },
  "fb_id",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "page_id",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "name",
  { data_type => "text", is_nullable => 0 },
  "picture",
  { data_type => "text", is_nullable => 1 },
  "opt_in",
  { data_type => "boolean", default_value => \"true", is_nullable => 0 },
  "updated_at",
  { data_type => "timestamp", is_nullable => 1 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "question_notification_sent_at",
  { data_type => "timestamp", is_nullable => 1 },
  "finished_quiz",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<recipient_fb_id_key>

=over 4

=item * L</fb_id>

=back

=cut

__PACKAGE__->add_unique_constraint("recipient_fb_id_key", ["fb_id"]);

=head1 RELATIONS

=head2 answers

Type: has_many

Related object: L<Prep::Schema::Result::Answer>

=cut

__PACKAGE__->has_many(
  "answers",
  "Prep::Schema::Result::Answer",
  { "foreign.recipient_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 chatbot_session

Type: might_have

Related object: L<Prep::Schema::Result::ChatbotSession>

=cut

__PACKAGE__->might_have(
  "chatbot_session",
  "Prep::Schema::Result::ChatbotSession",
  { "foreign.recipient_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2019-01-21 14:45:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:F+KWvbfDkttfJ4iwihf4TQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration

with 'Prep::Role::Verification';
with 'Prep::Role::Verification::TransactionalActions::DBIC';

use Prep::Utils qw(is_test);

use Text::CSV;
use DateTime;

sub verifiers_specs {
    my $self = shift;

    return {
        update => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                name => {
                    required => 0,
                    type     => 'Str'
                },
                picture => {
                    required => 0,
                    type     => 'Str',
                },
                opt_in => {
                    required => 0,
                    type     => 'Bool'
                }
            }
        ),
    };
}

sub action_specs {
    my ($self) = @_;

    return {
        update => sub {
            my $r = shift;

            my %values = $r->valid_values;
            not defined $values{$_} and delete $values{$_} for keys %values;

            $self->update(\%values);
        }
    };
}

sub get_pending_question_data {
    my ($self) = @_;

    my $question_rs  = $self->result_source->schema->resultset('Question');
    my $question_map = $self->result_source->schema->resultset('QuestionMap')->parsed;

    my @answered_questions = $self->answers->search( undef, { prefetch => 'question' } )->get_column('question.code')->all();

    my @pending_questions = sort { $a <=> $b } grep { my $k = $_; !grep { $question_map->{$k} eq $_ } @answered_questions } sort keys %{ $question_map };

    # Tratando perguntas condicionais
    # Isto é, só devem serem vistas por quem
    # alcançar certas condições
    my $ret;
    if ( my $next_question_code = $question_map->{ $pending_questions[0] } =~ /^(AC5|A[1-4])$/gm ) {
        my $conditions_satisfied = $self->verify_question_condition($next_question_code);

        if ( $conditions_satisfied == 1 ) {
            $ret = {
                question   => $question_rs->search( { code => $question_map->{ $pending_questions[0] } } )->next,
                has_more   => scalar @pending_questions > 1 ? 1 : 0,
                count_more => scalar @pending_questions
            };
        }
        else {
            # Caso as condições não tenham sido satisfeitas
            # o quiz acaba.
            $ret = {
                question   => undef,
                has_more   => 0,
                count_more => scalar @pending_questions
            };

            $self->update( { finished_quiz => 1 } );
        }
    }
    elsif ( scalar @pending_questions == 0 ) {
        # Caso não tenha mais perguntas pendentes acaba o quiz.
        $ret = {
            question   => undef,
            has_more   => 0,
            count_more => scalar @pending_questions
        };

        $self->update( { finished_quiz => 1 } );
    }
    else {

        # Caso para quando a pergunta não for condicional
        $ret = {
            question   => $question_rs->search( { code => $question_map->{ $pending_questions[0] } } )->next,
            has_more   => scalar @pending_questions > 1 ? 1 : 0,
            count_more => scalar @pending_questions
        };
    }

    return $ret;
}

sub verify_question_condition {
    my ($self, $next_question_code) = @_;

    my (@conditions, $condition);
    if ( $next_question_code eq 'AC5' ) {
        # Deve ter respondido as seguintes perguntas com as respectivas respostas:
        # B3 => 1, C1 => 1, C2 => 2 ou 3, C3 => 1, 2 ou 3, C4 => 1
        for my $question ( qw( B3 C1 C2 C3 C4 ) ) {

            my $value;
            if ( $question =~ /^(B3|C1|C4)$/gm ) {
                $value = '1';
            }
            elsif ( $question eq 'C2' ) {
                $value = [2, 3];
            }
            elsif ( $question eq 'C3' ) {
                $value = [ 1, 2, 3 ];
            }

            $condition = $self->answers->search(
                {
                    'question.code' => $question,
                    answer_value    => $value
                },
                { join => 'question'}
            )->as_query;

            push @conditions, { -exists => $condition };
        }

    }
    elsif ( $next_question_code =~ /^A[1-4]$/gm ) {
        # Deve ter concordado participar da pesquisa
        my $first_condition = $self->answers->search(
            {
                'question.code' => 'AC5',
                answer_value    => '1'
            },
            { join => 'question'}
        )->as_query;

        push @conditions, { -exists => $first_condition };
    }
    else {
        die \['code', 'invalid'];
    }


    return $self->answers->search(
        {
            -and => @conditions
        },
    );
}

sub is_prep {
    my ($self) = @_;

    if (is_test) {
        return 1;
    }

    my $answer = $self->answers->search( { code => 'AC5' } )->next;

    return $answer->answer_value eq '1' ? 1 : 0;
}


__PACKAGE__->meta->make_immutable;
1;
