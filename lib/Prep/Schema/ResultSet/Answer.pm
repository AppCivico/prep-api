package Prep::Schema::ResultSet::Answer;
use common::sense;
use Moose;
use namespace::autoclean;

extends "DBIx::Class::ResultSet";

with "Prep::Role::Verification";
with 'Prep::Role::Verification::TransactionalActions::DBIC';

use Data::Verifier;
use Data::Printer;

use Business::BR::CPF;
use Regexp::Common qw(time);
use Regexp::Common::time;

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
            my $next_question          = $pending_question_data->{question} ? $pending_question_data->{question}->decoded : undef;

            # Caso não tenha uma próxima pergunta
            # não posso aceitar respostas
            die \['fb_id', 'invalid'] unless $next_question;

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
                # nome (A1), cpf (A3) e data de nascimento (A2)
                if ( $next_question->{code} eq 'A3' ) {
                    die \['answer_value', 'invalid'] unless test_cpf($values{answer_value});

                    $values{answer_value} =~ s/[^\w]//g;
                }
                elsif ( $next_question->{code} eq 'A2' ) {
                    die \['answer_value', 'invalid'] unless $values{answer_value} =~ m/^$RE{time}{iso}\z/;
                }
            }

            my ($answer, $finished_quiz, $is_prep, $is_eligible_for_research);
            $self->result_source->schema->txn_do( sub {
                # Caso seja a última pergunta, devo atualizar o boolean de quiz preenchido do recipient
                if ( $pending_question_data->{has_more} == 0 ) {
                    my $recipient = $self->result_source->schema->resultset('Recipient')->search( { fb_id => $recipient_fb_id } )->next;
                    $recipient->update( { finished_quiz => 1 } );

                    $is_prep = $recipient->is_prep;
                    $is_eligible_for_research = $recipient->is_eligible_for_research;

                    $finished_quiz = 1;
                }
                else {
                    $finished_quiz = 0;
                }

                $answer = $self->create(\%values);
            });

            return {
                answer        => $answer,
                finished_quiz => $finished_quiz,
                ( defined $is_prep ? ( is_prep => $is_prep ) : () ),
                ( defined $is_eligible_for_research ? ( is_eligible_for_research => $is_eligible_for_research ) : () )
            };
        }
    };
}

1;
