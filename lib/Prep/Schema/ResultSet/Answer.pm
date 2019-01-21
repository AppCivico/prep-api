package Prep::Schema::ResultSet::Answer;
use common::sense;
use Moose;
use namespace::autoclean;

extends "DBIx::Class::ResultSet";

with "Prep::Role::Verification";
with 'Prep::Role::Verification::TransactionalActions::DBIC';

use Data::Verifier;
use Data::Printer;

sub verifiers_specs {
    my $self = shift;

    return {
        create => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                code => {
                    required   => 1,
                    type       => 'Str',
                    post_check => sub {
                        my $code = $_[0]->get_value('code');

                        $self->result_source->schema->resultset('Question')->search( { code => $code } )->count;
                    }
                },
                fb_id => {
                    required => 1,
                    type     => 'Num'
                },
                answer_value => {
                    required => 1,
                    type     => 'Num|Str'
                }
            }
        ),
    };
}

sub action_specs {
    my ($self) = @_;

    return {
        create => sub {
            my $r = shift;

            my %values = $r->valid_values;
            not defined $values{$_} and delete $values{$_} for keys %values;

            # question_map_id é sempre o id do mapa mais atual
            $values{question_map_id} = $self->result_source->schema->resultset('QuestionMap')->get_column('id')->max;

            my $recipient_fb_id        = delete $values{fb_id};
            my $question_code          = delete $values{code};
            my $recipient              = $self->result_source->schema->resultset('Recipient')->search( { fb_id => $recipient_fb_id } )->next;
            my $pending_question_data  = $recipient->get_pending_question_data;
            my $next_question          = $pending_question_data->{question}->decoded;

            # Verifico se o código enviado bate
            # com o código da próxima pergunta pendente
            if ( $next_question->{code} eq $question_code ) {
                $values{question_id} = $next_question->{id};
            }
            else {
                die \['code', 'invalid'];
            }

            # Tratando valor da resposta
            if ( $next_question->{type} eq 'multiple_choice' ) {
                $next_question->{multiple_choices}->{$values{answer_value}} or die \['answer_value', 'invalid'];
            }
            else {
                # open_text

                # Perguntas de texto aberto podem ser:
                # nome, cpf e data de nascimento
            }

            my ($answer, $finished_quiz);
            $self->result_source->schema->txn_do( sub {
                # Caso seja a última pergunta, devo atualizar o boolean de quiz preenchido do recipient
                if ( $pending_question_data->{has_more} == 0 ) {
                    my $recipient = $self->result_source->schema->resultset('Recipient')->search( { fb_id => $recipient_fb_id } )->next;
                    $recipient->update( { finished_quiz => 1 } );

                    $finished_quiz = 1;
                }
                else {
                    $finished_quiz = 0;
                }

                $answer = $self->create(\%values);
            });

            return {
                answer        => $answer,
                finished_quiz => $finished_quiz
            };
        }
    };
}

1;
