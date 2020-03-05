use utf8;
package Prep::Schema::Result::Answer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Prep::Schema::Result::Answer

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

=head1 TABLE: C<answer>

=cut

__PACKAGE__->table("answer");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'answer_id_seq'

=head2 recipient_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 question_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 question_map_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 answer_value

  data_type: 'text'
  is_nullable: 0

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 question_map_iteration

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "answer_id_seq",
  },
  "recipient_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "question_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "question_map_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "answer_value",
  { data_type => "text", is_nullable => 0 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "question_map_iteration",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 question

Type: belongs_to

Related object: L<Prep::Schema::Result::Question>

=cut

__PACKAGE__->belongs_to(
  "question",
  "Prep::Schema::Result::Question",
  { id => "question_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-03-05 15:07:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:w7uTWetavj8s8nu2BxrKpg


# You can replace this text with custom code or comments, and it will be preserved on regeneration

use Scalar::Util qw( looks_like_number );

sub update_stash {
    my ($self, $finished) = @_;

    my $recipient = $self->recipient;
    my $stash     = $recipient->stashes->search( { question_map_id => $self->question_map_id } )->next;
    my $question  = $self->question;
    my $rules     = $question->rules_parsed;

    $self->result_source->schema->txn_do(sub {
        if ( !$rules ) {
            # Caso não tenham rules, verifico se há perguntas pendentes
            my $next_question = $stash->next_question;

            if ( !defined $next_question->{question} ) {
                # Verificando se o type do questionário pode ser iterado
                # Caso verdadeiro, a flag times_answered é atualizada e mantenho o bool finished como false
                # E também é resetado o value da stash.
                use DDP; p $stash->question_map->category;

                $stash->update( { finished => 1 } )
            }
        }

        my $answer = $self->answer_value;

        my $conditions_satisfied;
        if ( $rules->{qualification_conditions} && scalar @{ $rules->{qualification_conditions} } > 0 ) {
            # Verificando se a condição de qualificação é a multipla escolha
            # ou uma flag
            if ( looks_like_number( $rules->{qualification_conditions}->[0] ) ) {
                $conditions_satisfied = grep { $_ eq $answer } @{ $rules->{qualification_conditions} };
            }
            else {
                # São flags
                my %recipient_flags = $recipient->all_flags;

                $conditions_satisfied = grep { $recipient_flags{$_} == 1 } @{ $rules->{qualification_conditions} };
            }

            if ( $conditions_satisfied == 0 ) {
                # Caso seja do quiz devo desqualificar e atualizar os booleans
                $recipient->recipient_flag->update( { finished_quiz => 1 } ) if $self->question_map->category->name eq 'quiz';

                $stash->update( { finished => 1 } );
            }

        }

        if ( $rules->{logic_jumps} && scalar @{ $rules->{logic_jumps} } > 0 ) {

            for my $logic_jump ( @{ $rules->{logic_jumps} } ) {
                # Ao validar essa resposta devo verificar que há respostas de texto livre
                # ( no caso números positivos inteiros )
                # E também respostas de multipla escolha
                if ( ref $logic_jump->{values} eq 'ARRAY' ) {
                    $conditions_satisfied = grep { $_ eq $answer } @{ $logic_jump->{values} };

                    if ( $conditions_satisfied == 0 ) {
                        # Caso seja a pergunta 'AC1' não remover os saltos
                        # a não ser que tenham escolhido a 2
                        if ( $self->question->code eq 'AC1' && $self->answer_value == 2 ) {
                            my @questions_to_remove = qw( AC2 AC3 AC4 AC5 AC6 AC7 );
                            $stash->remove_question($_) for @questions_to_remove;
                        }

                        $stash->remove_question($logic_jump->{code}) unless $self->question->code eq 'AC1';
                    }
                }
                elsif ( ref $logic_jump->{values} eq 'HASH' ) {
                    my $operator = $logic_jump->{values}->{operator} or die \['operator', 'missing'];
                    my $value    = $logic_jump->{values}->{value};
                    die \['value', 'missing'] unless defined $value;

                    if ( $operator eq '==' ) {
                        $conditions_satisfied = int( $answer == $value );
                    }
                    elsif ( $operator eq '>' ) {
                        $conditions_satisfied = $answer > $value ? 1 : 0;
                    }
                    elsif ( $operator eq '<' ) {
                        $conditions_satisfied = $answer < $value ? 1 : 0;
                    }
                    else {
                        die \['operator', 'invalid'];
                    }

                    if ( $conditions_satisfied == 0 ) {
                        $stash->remove_question($logic_jump->{code});
                    }

                }
                else {
                    die \['logic_jumps', 'invalid'];
                }

            }
        }

    });

}

sub flags {
    my ($self) = @_;

    my %ret;

    # Mesmo várias perguntas interferirem no resultado da flag
    # a API só envia a flag na resposta de algumas perguntas

    my $recipient     = $self->recipient;
    my $question      = $self->question;
    my $rules         = $question->rules_parsed;
    my $question_code = $self->question->code;

    if ( $rules ) {
        if ( $rules->{flags} && scalar @{ $rules->{flags} } > 0 ) {
            for my $flag ( @{ $rules->{flags} } ) {

                $ret{$flag} = $recipient->$flag;
            }
        }
    }

    return %ret;
}

sub has_followup_messages {
    my ($self) = @_;

    my $question_map = $self->question_map;

    if ( $question_map->category->name eq 'quiz' ) {
        return 1 if $self->question->code =~ /^(AC7|A6a)$/;
    }
    elsif ($question_map->category->name eq 'quiz_brincadeira') {
        return 1 if $self->question->code eq 'AC6';
    }
    elsif( $question_map->category->name eq 'fun_questions' ) {
        return 1 if $self->question->code eq 'AC7';
    }
    else {
        return 0;
    }
}

sub followup_messages {
    my ($self) = @_;

    return undef if $self->has_followup_messages == 0;

    my $question_map = $self->question_map;
    my $question     = $self->question;

    my @messages;
    if ( $question_map->category->name eq 'quiz' ) {
        # Na A6 é enviada uma mensagem de feedback
        if ( $question->code eq 'A6a' ) {
            push @messages, 'Amando! Só mais algumas vai...';
        }
        elsif ( $question->code eq 'AC7' ) {
            # Na resposta da AC7 deve ser enviado o texto respectivo para o score
            push @messages, $self->recipient->message_for_fun_questions_score->{picture};
            push @messages, $self->recipient->message_for_fun_questions_score->{message};
            push @messages, 'Calma! Compartilha ainda não!';
        }
    }
    elsif( $question_map->category->name eq 'quiz_brincadeira' ) {
        push @messages, $self->recipient->message_for_fun_questions_score->{picture};
        push @messages, $self->recipient->message_for_fun_questions_score->{message};
    }

    return @messages;
}

sub stash {
    my $self = shift;

    return $self->recipient->stashes->search( { question_map_id => $self->question_map_id } )->next;
}

__PACKAGE__->meta->make_immutable;
1;
