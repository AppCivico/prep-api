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

						die \['category', 'invalid'] unless $category =~ m/(quiz|screening|fun_questions)/;
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

                # Perguntas de texto aberto podem ser:
                # nome (A1), cpf (A3) e data de nascimento (A2)
				if ( $next_question->{code} eq 'A1' ) {
					die \['answer_value', 'invalid'] unless $values{answer_value} =~ /^\d{1,2}$/gm;
				}
				elsif ( $next_question->{code} eq 'B2' ) {
					die \['answer_value', 'invalid'] unless $values{answer_value} =~ /^\d{1,2}$/gm;
				}
                elsif ( $next_question->{code} eq 'A3' ) {
                    die \['answer_value', 'invalid'] unless test_cpf($values{answer_value});

                    $values{answer_value} =~ s/[^\w]//g;
                }
                elsif ( $next_question->{code} eq 'A2' ) {
                    die \['answer_value', 'invalid'] unless $values{answer_value} =~ m/^$RE{time}{iso}\z/;
                }
            }

            my ($answer, $finished_quiz, $is_prep, $is_eligible_for_research, $go_to_appointment, $go_to_autotest, $is_target_audience, %flags);
            $self->result_source->schema->txn_do( sub {
                # Caso seja a última pergunta, devo atualizar o boolean de quiz preenchido do recipient
                $answer = $self->create(\%values);
                $answer->update_stash;

                if ( $question_map->category_id == 1 ) {
                    $pending_question_data = $recipient->get_next_question_data($category);

                    if ( defined $pending_question_data->{question} ) {
                        $is_target_audience = $recipient->is_target_audience if $next_question->{code} eq 'A1';

                        if ( $next_question->{code} eq 'A1' ) {
                            $is_target_audience = $recipient->is_target_audience;

                            if ($answer->answer_value =~ /^(15|16|17|18|19)$/) {
                                $finished_quiz = 0;
                                $is_target_audience = 1;
                            }
                            else {
                                $finished_quiz = 1;
								$is_target_audience = 0;
                            }
                        }
                        elsif ( $next_question->{code} eq 'A5' ) {

                            if ($answer->answer_value =~ /^(1|2|3)$/) {
                                $finished_quiz = 0;
                            }
                            else {
                                $finished_quiz = 1;
                            }
                        }
                        else {
                            $finished_quiz = 0;

                        }
                    }
                    else {
                        $recipient->recipient_flag->update( { finished_quiz => 1 } );
						$is_prep                  = $recipient->is_part_of_research;
						$is_eligible_for_research = $recipient->is_eligible_for_research;
						$is_target_audience       = $recipient->is_target_audience if $next_question->{code} eq 'A1';
						$finished_quiz = 1;

						# Gerando token de integração
						$recipient->generate_integration_token;

                        %flags = $answer->flags;
                    }
                }
                elsif ($question_map->category_id == 2) {
                    $pending_question_data = $recipient->get_pending_question_data($category);

                    $finished_quiz = $pending_question_data->{has_more} == 0 ? 1 : 0;

                    if ( $question_code eq 'SC6' ) {

                        if ( $answer->answer_value eq '1' ) {
                            $go_to_appointment = 1
                        }
                        #else {
                        #    $go_to_autotest = 1
                        #}
                    }

                    if ( $finished_quiz ) {
                        $recipient->build_screening_report;
                    }
                }
                else {
                    if ( $question_code eq 'AC4' ) {
                        $recipient->recipient_flag->update( { finished_quiz => 1 } )
                    }
                }

            });

            return {
                answer        => $answer,
                finished_quiz => $finished_quiz,
                %flags,
                #( defined $is_prep ? ( is_part_of_research => $is_prep ) : () ),
                #( defined $is_eligible_for_research ? ( is_eligible_for_research => $is_eligible_for_research ) : () ),
                ( defined $go_to_appointment ? ( go_to_appointment => $go_to_appointment ) : () ),
                ( defined $pending_question_data->{go_to_autotest} ? ( go_to_autotest => $pending_question_data->{go_to_autotest} ) : () ),
                # ( defined $is_target_audience ? ( is_target_audience => $is_target_audience ) : () ),
                ( defined $pending_question_data->{suggest_appointment} ? ( suggest_appointment => $pending_question_data->{suggest_appointment} ) : () ),
				( defined $pending_question_data->{emergency_rerouting} ? ( emergency_rerouting => $pending_question_data->{emergency_rerouting} ) : () )
            };
        }
    };
}

sub question_code_by_map_id {
    my ($self, $question_map_id) = @_;

    return $self->search( { 'question.question_map_id' => $question_map_id }, { prefetch => 'question' } )
}

1;
