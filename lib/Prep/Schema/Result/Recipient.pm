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

=head2 integration_token

  data_type: 'text'
  default_value: "substring"(md5((random())::text), 0, 12)
  is_nullable: 0

=head2 using_external_token

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 count_sent_quiz

  data_type: 'integer'
  default_value: 0
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
  "integration_token",
  {
    data_type     => "text",
    default_value => \"\"substring\"(md5((random())::text), 0, 12)",
    is_nullable   => 0,
  },
  "using_external_token",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "count_sent_quiz",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
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

=head2 appointments

Type: has_many

Related object: L<Prep::Schema::Result::Appointment>

=cut

__PACKAGE__->has_many(
  "appointments",
  "Prep::Schema::Result::Appointment",
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


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2019-02-08 16:16:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gaAQ0OkT6iSYlwrjAnUoQw


# You can replace this text with custom code or comments, and it will be preserved on regeneration

with 'Prep::Role::Verification';
with 'Prep::Role::Verification::TransactionalActions::DBIC';

use Prep::Utils qw(is_test);

use Text::CSV;
use DateTime;
use JSON;

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
    my ($self, $category) = @_;

    my $question_rs         = $self->result_source->schema->resultset('Question');
    my $question_map_result = $self->result_source->schema->resultset('QuestionMap')->search(
        { 'category.name' => $category },
        {
            prefetch => 'category',
            order_by => { -desc => 'created_at' }
        }
    )->next or die \['category', 'invalid'];
    my $question_map = $question_map_result->parsed;

    die \['category', 'invalid'] unless $question_map;

    my @answered_questions = $self->answers->search( { 'question.question_map_id' => $question_map_result->id }, { prefetch => 'question' } )->get_column('question.code')->all();

    my @pending_questions = sort { $a <=> $b } grep { my $k = $_; !grep { $question_map->{$k} eq $_ } @answered_questions } sort keys %{ $question_map };

    # Tratando perguntas condicionais
    # Isto é, só devem serem vistas por quem
    # alcançar certas condições
    my $ret;
    my $next_question_code = scalar @pending_questions > 0 ? $question_map->{ $pending_questions[0] } : undef;

    if ( $question_map_result->category_id == 1 ) {
        # Quiz.

        if ( $next_question_code =~ /^(AC1|AC5|A3|B1)$/gm ) {
            my $conditions_satisfied = $self->verify_question_condition( next_question_code => $next_question_code, question_map => $question_map_result );
            if ( $conditions_satisfied > 0 ) {
                $ret = {
                    question => $question_rs->search(
                        {
                            code            => $question_map->{ $pending_questions[0] },
                            question_map_id => $question_map_result->id
                        }
                    )->next,
                    has_more                 => scalar @pending_questions > 1 ? 1 : 0,
                    count_more               => scalar @pending_questions,
                    is_eligible_for_research => $self->is_eligible_for_research,
                    is_part_of_research      => $self->is_prep
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
        elsif ( scalar @pending_questions == 0  ) {
            # Caso não tenha mais perguntas pendentes acaba o quiz.
            $ret = {
                question                 => undef,
                has_more                 => 0,
                count_more               => scalar @pending_questions,
                is_eligible_for_research => $self->is_eligible_for_research,
                is_part_of_research      => $self->is_prep
            };

            $self->update( { finished_quiz => 1 } ) unless $self->finished_quiz == 1;
        }
        else {

            # Caso para quando a pergunta não for condicional
            $ret = {
                question   => $question_rs->search( { code => $question_map->{ $pending_questions[0] }, question_map_id => $question_map_result->id } )->next,
                has_more   => scalar @pending_questions > 1 ? 1 : 0,
                count_more => scalar @pending_questions,
            };
        }


    }
    else {
        # Triagem.

        my @flags;
        my $conditions_satisfied;
        if ( $next_question_code eq 'SC2' ) {
			$conditions_satisfied = $self->verify_question_condition( next_question_code => $next_question_code, question_map => $question_map_result );

            if ( $conditions_satisfied > 0 ) {
                $ret = {
                    question   => $question_rs->search( { code => $question_map->{ $pending_questions[0] }, question_map_id => $question_map_result->id } )->next,
                    has_more   => scalar @pending_questions > 1 ? 1 : 0,
                    count_more => scalar @pending_questions,
                }
            }
            else {
                $ret = {
                    question            => undef,
                    has_more            => 0,
                    count_more          => 0,
                    emergency_rerouting => 1
                }
            }
        }
        elsif ( $next_question_code eq 'SC6' ) {
            # Verificando se batem as condições para indicar consulta
            # Isto é: qualquer resposta positiva para SC2 a SC5
			$conditions_satisfied = $self->verify_question_condition( next_question_code => $next_question_code, question_map => $question_map_result );

            # Caso ele tenha respondigo sim para qualquer uma entre a SC2 e a SC5
            # Ou tenha respondido não para todas e respondeu 2 ou 3 para a SC1
            # Devo convidar a marcar uma consulta de recrutamento.
            my $first_answer_on_screening = $self->screening_first_answer;
            if ( $conditions_satisfied > 0 ) {
                $ret = {
					question            => $question_rs->search( { code => $question_map->{ $pending_questions[0] }, question_map_id => $question_map_result->id } )->next,
					has_more            => scalar @pending_questions >= 1 ? 1 : 0,
					count_more          => scalar @pending_questions,
					suggest_appointment => 1
                };
            }
            elsif ( $conditions_satisfied == 0 && $first_answer_on_screening->answer_value =~ /(2|3)/ ) {
                $ret = {
                    question   => $question_rs->search( { code => $question_map->{ $pending_questions[0] }, question_map_id => $question_map_result->id } )->next,
                    has_more   => scalar @pending_questions > 1 ? 1 : 0,
                    count_more => scalar @pending_questions,
                }
            }
            # Caso contrário, a triagem acaba e realizamos o fluxo informativo.
            else {
                $ret = {
                    question   => undef,
                    has_more   => 0,
                    count_more => 0,
                }
            }
        }
        else {
            $ret = {
                question   => $question_rs->search( { code => $question_map->{ $pending_questions[0] }, question_map_id => $question_map_result->id } )->next,
                has_more   => scalar @pending_questions > 1 ? 1 : 0,
                count_more => scalar @pending_questions,
            }
        }
    }

    return $ret;
}

sub verify_question_condition {
    my ($self, %opts) = @_;

	my @required_opts = qw( question_map next_question_code );
	defined $opts{$_} or die \["opts{$_}", 'missing'] for @required_opts;

    my @conditions = $opts{question_map}->build_conditions( recipient_id => $self->id, next_question_code => $opts{next_question_code} );

    return $self->answers->search(
        {
            -or => \@conditions
        },
    )->count;
}

sub is_prep {
    my ($self) = @_;

    if (is_test) {
        return 1;
    }

    my $answer = $self->answers->search( { 'question.code' => 'AC5' }, { prefetch => 'question' } )->next;

    my $ret;
    if ( $answer ) {
        $ret = $answer->answer_value eq '1' ? 1 : 0;
    }
    else {
        $ret = 0;
    }

    return $ret;
}

sub is_eligible_for_research {
    my ($self) = @_;

	if (is_test) {
		return 1;
	}

	my $answer = $self->answers->search( { 'question.code' => { 'in' => ['AC5', 'B3', 'C1', 'C2', 'C3', 'C4'] } }, { prefetch => 'question' } );

    my $ret = 0;
    while ( my $answer = $answer->next() ) {
        my $code = $answer->question->code;
        $ret = 1;
        if ( $code =~ /^(B3|C1|C3|C4)$/ ) {

            $ret = 0 unless $answer->answer_value eq '1';
        }
        elsif ( $code eq 'C2' ) {
            $ret = 0 unless $answer->answer_value eq '2';
        }

        next if $ret == 0;
    }

	return $ret;
}

sub upcoming_appointments {
    my ($self) = @_;

    return $self->appointments->search( { appointment_at => { '>=' => \'NOW()::date' }  } );
}

sub appointment_description {
    my ($self) = @_;

	my $answers_rs = $self->answers->search( { 'question.code' => { 'in' => [ 'B1', 'B2', 'B3', 'C1', 'C2', 'C3', 'C4', 'AC5' ] } }, { prefetch => 'question' } );

    my $answers;
    my $i = 0;

    while ( my $answer = $answers_rs->next() ) {

        my $question_text = $answer->question->text;
        $answers->[$i] = {
            "$question_text" =>  $answer->question->type eq 'multiple_choice' ? $answer->question->answer_by_choice_value( $answer->answer_value ) : $answer->answer_value
        };
        $i++;
    }

    return '' unless $answers;

    # Adicionando flag e fb_id na descrição para identificar no sync
	$answers->[$i]     = { agendamento_chatbot => 1 };
	$answers->[$i + 1] = { identificador       => $self->integration_token };

    my $json = JSON->new->pretty(1);
    $answers = $json->encode( $answers );

    $answers =~ s/(,)?(\")?(\[)?(\])?(\})?(\}\n)?(\{\n)?(\h{2,})?//gm;

    return $answers;
}

sub assign_token {
    my ($self, $integration_token) = @_;

    $self->result_source->schema->txn_do( sub {
        my $token_rs = $self->result_source->schema->resultset('ExternalIntegrationToken');
        my $token    = $token_rs->search(
            {
                value       => $integration_token,
                assigned_at => \'IS NULL'
            }
        )->next;

        die \['integration_token', 'invalid'] unless $token;

        $self->update(
            {
                integration_token    => $token->value,
                using_external_token => 1
            }
        );

        $token->update( { assigned_at => \'NOW()' } );
    });
}

sub screening_first_answer {
    my ($self) = @_;

    return $self->answers->search(
        { 'question.code' => 'SC1' },
        { prefetch => 'question' }
    )->next;
}

sub most_recent_screening {
    my ($self) = @_;

    return $self->answers->search(
        {
            'question.code' => { 'in' => [ 'SC1', 'SC2', 'SC3', 'SC4', 'SC5', 'SC6' ] }
        },
        {
            prefetch => 'question',
            group_by => \'created_at::date',
            order_by => { -desc => 'me.created_at' }
        }
    );
}

__PACKAGE__->meta->make_immutable;
1;
