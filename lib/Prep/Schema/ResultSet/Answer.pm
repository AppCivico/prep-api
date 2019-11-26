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

            }

            my $integration_failed = 0;

            my ($answer, $finished_quiz, %flags, @followup_messages, $simprep_url);
            $self->result_source->schema->txn_do( sub {
                # Caso seja a última pergunta, devo atualizar o boolean de quiz preenchido do recipient
                $answer = $self->create(\%values);
                $answer->update_stash;

                @followup_messages = $answer->followup_messages if $answer->has_followup_messages;

                if ( $question_map->category_id == 1 ) {
                    # Caso a resposta seja da pergunta 'A1' devo atualizar a coluna 'city' do recipient
                    # com o conteúdo da resposta
                    if ( $answer->question->code eq 'A1' ) {
                        $recipient->update( { city => $answer->answer_value } );
                    }

                    $pending_question_data = $recipient->get_next_question_data($category);

                    if ( defined $pending_question_data->{question} ) {

                        $finished_quiz = 0;
                    }
                    else {
                        $recipient->recipient_flag->update( { finished_quiz => 1 } );
                        $finished_quiz = 1;

                        my $is_eligible_for_research = $recipient->is_eligible_for_research;

                        eval { $simprep_url = $recipient->register_simprep if $answer->question->code eq 'AC9' && $answer->answer_value eq '1' };
                        $integration_failed = 1 if $@;

                        %flags = $answer->flags;

                        # Crio uma notificação para atender esse caso: https://trello.com/c/75oiZ3Tn/145-enviar-notifica%C3%A7%C3%B5es-para-pessoas-que-clicaram-em-sim-na-pergunta-23-quer-saber-mais-sobre-a-pesquisa-mas-que-n%C3%A3o-possuem-nenhum
                        # E no post do appointment, eu verifico se a pessoa possui essa notificação pendente.
                        $answer->discard_changes;
                        $recipient->notification_queues->create(
                            {
                                type_id    => 8,
                                wait_until => $answer->created_at->add( days => 7 )
                            }
                        ) if $recipient->is_target_audience;
                    }
                }
                elsif ($question_map->category_id == 2) {
                    $pending_question_data = $recipient->get_next_question_data($category);

                    if ( !$pending_question_data->{question} ) {
                        $recipient->build_screening_report;
                        %flags = $answer->flags;
                        $recipient->reset_screening;

                        $finished_quiz = 1;
                    }
                    else {
                        $finished_quiz = 0;
                    }
                }
                else {
                    $pending_question_data = $recipient->get_next_question_data($category);

                    if ( defined $pending_question_data->{question} ) {
                        $finished_quiz = 0;
                    }
                    else {
                        $finished_quiz = 1;
                    }
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
