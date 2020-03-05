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
                },
                category => {
                    required   => 1,
                    type       => 'Str',
                    post_check => sub {
                        my $category = $_[0]->get_value('category');

                        $self->result_source->schema->resultset('Category')->search( { name => $category } )->count == 1
                          or die \['category', 'invalid'];
                    }
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

            my $recipient_fb_id = delete $values{fb_id};
            my $question_code   = delete $values{code};
            my $category        = delete $values{category};

            my $question_map = $self->result_source->schema->resultset('QuestionMap')->search(
                { 'category.name' => $category },
                {
                    prefetch => 'category',
                    order_by => { -desc => 'me.created_at' }
                }
            )->next or die \['category', 'invalid'];
            $values{question_map_id} = $question_map->id;

            my $recipient              = $self->result_source->schema->resultset('Recipient')->search( { fb_id => $recipient_fb_id } )->next;
            my $pending_question_data  = $recipient->get_next_question_data($category);
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

            }

            # Verificando a iteração da resposta
            my $stash = $recipient->stashes->search( { question_map_id => $question_map->id } )->next;

            if ($stash->times_answered == 0) {
                $values{question_map_iteration} = 1;
            }
            else {
                $values{question_map_iteration} = $stash->times_answered + 1;
            }

            my $integration_failed = 0;

            my ($answer, $finished_quiz, %flags, @followup_messages, $simprep_url);
            $self->result_source->schema->txn_do( sub {
                # Caso seja a última pergunta, devo atualizar o boolean de quiz preenchido do recipient
                $answer = $self->create(\%values);
                $answer->update_stash;

                @followup_messages = $answer->followup_messages if $answer->has_followup_messages;

                if ( $answer->question->code eq 'A1' ) {
                    $recipient->update( { city => $answer->answer_value } );
                }

                $pending_question_data = $recipient->get_next_question_data($category);

                # Caso seja a A2 e a resposta da A1 tenha sido '4', ou seja, 'nenhuma dessas'.
                # O quiz deve ser finalizado.
                if ( $answer->question->code eq 'A2' ) {
                    my $first_answer = $recipient->answers->search(
                        { 'question.code' => 'A1' },
                        { join => 'question' }
                    )->next;

                    if ($first_answer->answer_value eq '4') {
                        $pending_question_data = undef;
                        $answer->stash->update( { finished => 1, updated_at => \'NOW()' } );
                    }
                }

                if ( defined $pending_question_data->{question} ) {
                    $finished_quiz = 0;
                }
                else {
                    %flags = $answer->flags;

                    if ( $answer->question_map->category->name eq 'publico_interesse' ) {
                        $recipient->recipient_flag->update( { finished_publico_interesse => 1 } );

                        if ($recipient->recipient_flag->is_target_audience == 1) {
                            # Enviando para o sisprep.
                            eval {
                                # $recipient->register_sisprep('publico_interesse');
                            };
                            p $@ if $@;

                            $answer->discard_changes;
                            $recipient->notification_queues->create(
                                {
                                    type_id    => 8,
                                    wait_until => $answer->created_at->add( days => 7 )
                                }
                            )
                        }

                    }
                    elsif ( $answer->question_map->category->name eq 'recrutamento' ) {
                        $recipient->recipient_flag->update( { finished_recrutamento => 1 } );
                        # eval { $recipient->register_sisprep('recrutamento') };
                    }
                    elsif ( $answer->question_map->category->name eq 'quiz_brincadeira' ) {
                        $recipient->recipient_flag->update( { finished_quiz_brincadeira => 1 } )
                    }

                    $recipient->recipient_flag->update( { finished_quiz => 1 } );
                    $finished_quiz = 1;
                }

            });

            return {
                answer             => $answer,
                finished_quiz      => $finished_quiz,
                integration_failed => $integration_failed,

                %flags,

                (
                    scalar @followup_messages > 0 ?
                    ( followup_messages => [ map { $_ } @followup_messages ] ) : ()
                ),

                (
                    defined $simprep_url ?
                    ( offline_pre_registration_form => $simprep_url ) : ( )
                )
            };
        }
    };
}

sub question_code_by_map_id {
    my ($self, $question_map_id) = @_;

    return $self->search( { 'question.question_map_id' => $question_map_id }, { prefetch => 'question' } )
}

1;
