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

=head2 integration_token

  data_type: 'text'
  is_nullable: 1

=head2 using_external_token

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 count_sent_quiz

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 count_invited_research

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 count_share

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
  "integration_token",
  { data_type => "text", is_nullable => 1 },
  "using_external_token",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "count_sent_quiz",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "count_invited_research",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "count_share",
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

=head2 external_notifications

Type: has_many

Related object: L<Prep::Schema::Result::ExternalNotification>

=cut

__PACKAGE__->has_many(
  "external_notifications",
  "Prep::Schema::Result::ExternalNotification",
  { "foreign.recipient_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 recipient_flag

Type: might_have

Related object: L<Prep::Schema::Result::RecipientFlag>

=cut

__PACKAGE__->might_have(
  "recipient_flag",
  "Prep::Schema::Result::RecipientFlag",
  { "foreign.recipient_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 screenings

Type: has_many

Related object: L<Prep::Schema::Result::Screening>

=cut

__PACKAGE__->has_many(
  "screenings",
  "Prep::Schema::Result::Screening",
  { "foreign.recipient_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 stashes

Type: has_many

Related object: L<Prep::Schema::Result::Stash>

=cut

__PACKAGE__->has_many(
  "stashes",
  "Prep::Schema::Result::Stash",
  { "foreign.recipient_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 term_signatures

Type: has_many

Related object: L<Prep::Schema::Result::TermSignature>

=cut

__PACKAGE__->has_many(
  "term_signatures",
  "Prep::Schema::Result::TermSignature",
  { "foreign.recipient_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2019-02-20 14:51:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xNIajsVdMN7IuhMpX/lvaA


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
                },
                is_part_of_research => {
                    required => 0,
                    type     => 'Bool'
                },
                is_prep => {
                    required => 0,
                    type     => 'Bool'
                }
            }
        ),
        research_participation => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                is_part_of_research => {
                    required => 1,
                    type     => 'Bool'
                },
            }
        )
    };
}

sub action_specs {
    my ($self) = @_;

    return {
        update => sub {
            my $r = shift;

            my %values = $r->valid_values;
            not defined $values{$_} and delete $values{$_} for keys %values;

            my @updatable_flags = qw( is_part_of_research is_prep );
            for my $flag ( @updatable_flags ) {
                next unless defined $values{$flag};

                $self->recipient_flag->update( { $flag => $values{$flag} } );
                delete $values{$flag};
            }

            $self->update(\%values);
        },
        research_participation => sub {
            my $r = shift;

            my %values = $r->valid_values;
            not defined $values{$_} and delete $values{$_} for keys %values;

            # Caso o bool seja verdadeiro
            # devo verificar se a pessoa é elegível para a pesquisa
            if ( $self->is_target_audience == 0 || $self->is_eligible_for_research == 0 ) {
                die \['is_part_of_research', 'invalid'];
            }

            return $self->recipient_flag->update( { is_part_of_research => $values{is_part_of_research} } );
        }
    };
}

sub get_next_question_data {
    my ($self, $category) = @_;

    my $question_map_result = $self->result_source->schema->resultset('QuestionMap')->search(
        { 'category.name' => $category },
        {
            prefetch => 'category',
            order_by => { -desc => 'created_at' }
        }
    )->next or die \['category', 'invalid'];

    my $stash = $self->stashes->find_or_create(
        { question_map_id => $question_map_result->id },
        { key => 'stash_recipient_id_question_map_id_key' }
    );
    $stash->initiate if $stash->is_empty;

    return $stash->next_question;
}

sub get_pending_question_data {
    my ($self, $category) = @_;

    my $ret;
    $self->result_source->schema->txn_do( sub {

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

        my $stash = $self->stashes->find_or_create(
            { question_map_id => $question_map_result->id },
            { key => 'stash_recipient_id_question_map_id_key' }
        );

        $stash->initiate if $stash->is_empty;

        $question_map = $stash->parsed;

        my @answered_questions = $self->answers->question_code_by_map_id( $question_map_result->id )->get_column('question.code')->all();

        my @pending_questions = sort { $a <=> $b } grep { my $k = $_; !grep { $question_map->{$k} eq $_ } @answered_questions } sort keys %{ $question_map };

        # Tratando perguntas condicionais
        # Isto é, só devem serem vistas por quem
        # alcançar certas condições
        my ($has_more, $count_more, $question, %flags);
        my $next_question_code = scalar @pending_questions > 0 ? $question_map->{ $pending_questions[0] } : undef;

        if ( $question_map_result->category_id == 1 ) {
            # Quiz.

            my $conditions_satisfied;
            if ( scalar @pending_questions == 0  ) {

                # Caso não tenha mais perguntas pendentes acaba o quiz.
                $question   = undef;
                $has_more   = 0;
                $count_more = 0;

                %flags = (
                    is_eligible_for_research => $self->is_eligible_for_research,
                    is_part_of_research      => $self->is_prep
                );

                $self->recipient_flag->update( { finished_quiz => 1 } ) unless $self->finished_quiz == 1;
            }
            elsif ( $next_question_code && $next_question_code =~ /^(A5|A2|AC5|A3|B1)$/gm ) {
                $conditions_satisfied = $self->verify_question_condition( next_question_code => $next_question_code, question_map => $question_map_result );

                if ( $conditions_satisfied > 0 ) {

                    $question = $question_rs->search(
                        {
                            code            => $question_map->{ $pending_questions[0] },
                            question_map_id => $question_map_result->id
                        }
                    )->next;
                    $has_more   = scalar @pending_questions > 1 ? 1 : 0;
                    $count_more = scalar @pending_questions;

                    %flags = (
                        is_eligible_for_research => $self->is_eligible_for_research,
                        is_part_of_research      => $self->is_prep
                    );
                }
                else {
                    # Caso as condições não tenham sido satisfeitas
                    # o quiz acaba.
                    $question   = undef;
                    $has_more   = 0;
                    $count_more = 0;

                    $self->recipient_flag->update( { finished_quiz => 1 } );
                }
            }
            elsif ( $next_question_code && $next_question_code eq 'B1a' ) {
                $conditions_satisfied =  $self->verify_question_condition( next_question_code => $next_question_code, question_map => $question_map_result );

                if ( $conditions_satisfied > 0 ) {
                    $question = $question_rs->search(
                        {
                            code            => $question_map->{ $pending_questions[0] },
                            question_map_id => $question_map_result->id
                        }
                    )->next;

                    $has_more   = scalar @pending_questions > 1 ? 1 : 0;
                    $count_more = scalar @pending_questions;
                }
                else {
                    my %r_question_map = reverse %{$question_map};
                    my $key             = $r_question_map{$next_question_code};

                    delete $question_map->{$key};

                    $stash->update( { value => to_json $question_map } );

                    $question = $question_rs->search(
                        {
                            code            => $question_map->{ $pending_questions[1] },
                            question_map_id => $question_map_result->id
                        }
                    )->next;

                    $has_more   = scalar @pending_questions > 1 ? 1 : 0;
                    $count_more = scalar @pending_questions;
                }
            }
            elsif ( $next_question_code && $next_question_code eq 'B2a' ) {
                $conditions_satisfied =  $self->verify_question_condition( next_question_code => $next_question_code, question_map => $question_map_result );

                if ( $conditions_satisfied > 0 ) {
                    $question = $question_rs->search(
                        {
                            code            => $question_map->{ $pending_questions[0] },
                            question_map_id => $question_map_result->id
                        }
                    )->next;

                    $has_more   = scalar @pending_questions > 1 ? 1 : 0;
                    $count_more = scalar @pending_questions;
                }
                else {
                    # Removendo a pergunta B2a e B2b do question map stacheado
                    my %r_question_map = reverse %{ $question_map };

                    my $first_key  = $r_question_map{'B2a'};
                    my $second_key = $r_question_map{'B2b'};

                    delete $question_map->{$first_key};
                    delete $question_map->{$second_key};

                    $stash->update( { value => to_json $question_map } );

                    # Pulando as duas que foram retiradas
                    $question = $question_rs->search(
                        {
                            code            => $question_map->{ $pending_questions[2] },
                            question_map_id => $question_map_result->id
                        }
                    )->next;

                    $has_more   = scalar @pending_questions > 1 ? 1 : 0;
                    $count_more = scalar @pending_questions;
                }
            }
            elsif ( $next_question_code && $next_question_code eq 'B2b' ) {
                $conditions_satisfied =  $self->verify_question_condition( next_question_code => $next_question_code, question_map => $question_map_result );

                if ( $conditions_satisfied > 0 ) {
                    $question = $question_rs->search(
                        {
                            code            => $question_map->{ $pending_questions[0] },
                            question_map_id => $question_map_result->id
                        }
                    )->next;

                    $has_more   = scalar @pending_questions > 1 ? 1 : 0;
                    $count_more = scalar @pending_questions;
                }
                else {
                    # Removendo a pergunta B2a e B2b do question map stacheado
                    my %r_question_map = reverse %{ $question_map };

                    my $key  = $r_question_map{$next_question_code};

                    delete $question_map->{$key};

                    $stash->update( { value => to_json $question_map } );

                    # Pulando as duas que foram retiradas
                    $question = $question_rs->search(
                        {
                            code            => $question_map->{ $pending_questions[1] },
                            question_map_id => $question_map_result->id
                        }
                    )->next;

                    $has_more   = scalar @pending_questions > 1 ? 1 : 0;
                    $count_more = scalar @pending_questions;
                }
            }
            elsif ( $next_question_code && $next_question_code eq 'D4a' ) {
                $conditions_satisfied =  $self->verify_question_condition( next_question_code => $next_question_code, question_map => $question_map_result );

                if ( $conditions_satisfied > 0 ) {
                    $question = $question_rs->search(
                        {
                            code            => $question_map->{ $pending_questions[0] },
                            question_map_id => $question_map_result->id
                        }
                    )->next;

                    $has_more   = scalar @pending_questions > 1 ? 1 : 0;
                    $count_more = scalar @pending_questions;

                    # Removo a D4b do mapa
                    my %r_question_map = reverse %{$question_map};
                    my $key            = $r_question_map{'D4b'};
                    delete $question_map->{$key} if $key;

                    $stash->update( { value => to_json $question_map } );
                }
                else {
                    # Verifico se pode ir para a D4b
                    $next_question_code   = 'D4b';
                    $conditions_satisfied =  $self->verify_question_condition( next_question_code => $next_question_code, question_map => $question_map_result );

                    if ( $conditions_satisfied > 0 ) {

                        $question = $question_rs->search(
                            {
                                code            => $question_map->{ $pending_questions[1] },
                                question_map_id => $question_map_result->id
                            }
                        )->next;

                        $has_more   = scalar @pending_questions > 1 ? 1 : 0;
                        $count_more = scalar @pending_questions;

                        # Removo a D4a do mapa
                        my %r_question_map = reverse %{$question_map};
                        my $key            = $r_question_map{'D4a'};
                        delete $question_map->{$key} if $key;

                        $stash->update( { value => to_json $question_map } );
                    }
                    else {
                        # Removendo a pergunta D4b do question map stacheado
                        my %r_question_map = reverse %{ $question_map };

                        my $first_key  = $r_question_map{'D4a'};
                        my $second_key = $r_question_map{'D4b'};

                        delete $question_map->{$first_key}  if $first_key;
                        delete $question_map->{$second_key} if $second_key;

                        $stash->update( { value => to_json $question_map } );

                        $question = $question_rs->search(
                            {
                                code            => $question_map->{ $pending_questions[2] },
                                question_map_id => $question_map_result->id
                            }
                        )->next;

                        $has_more   = scalar @pending_questions > 1 ? 1 : 0;
                        $count_more = scalar @pending_questions;
                    }

                }
            }
            else {

                # Caso para quando a pergunta não for condicional
                $question   = $question_rs->search( { code => $question_map->{ $pending_questions[0] }, question_map_id => $question_map_result->id } )->next;
                $has_more   = scalar @pending_questions > 1 ? 1 : 0;
                $count_more = scalar @pending_questions;
            }

        }
        elsif ( $question_map_result->category_id == 2 ) {
            # Triagem.

            my $conditions_satisfied;

            if ( scalar @pending_questions == 0  ) {

                # Caso não tenha mais perguntas pendentes acaba o quiz.
                $question   = undef;
                $has_more   = 0;
                $count_more = 0;
            }
            elsif ( $next_question_code && $next_question_code eq 'SC2' ) {
                $conditions_satisfied = $self->verify_question_condition( next_question_code => $next_question_code, question_map => $question_map_result );

                if ( $conditions_satisfied > 0 ) {
                    $question   = $question_rs->search( { code => $question_map->{ $pending_questions[0] }, question_map_id => $question_map_result->id } )->next;
                    $has_more   = scalar @pending_questions >= 1 ? 1 : 0;
                    $count_more = scalar @pending_questions;
                }
                else {
                    $question   = undef;
                    $has_more   = 0;
                    $count_more = 0;

                    %flags = ( emergency_rerouting => 1 );
                }
            }
            elsif ( $next_question_code && $next_question_code eq 'SC6' ) {
                # Verificando se batem as condições para indicar consulta
                # Isto é: qualquer resposta positiva para SC2 a SC5
                $conditions_satisfied = $self->verify_question_condition( next_question_code => $next_question_code, question_map => $question_map_result );
                my $suggest_appointment_conditions = $self->verify_question_condition( next_question_code => 'SC6a', question_map => $question_map_result );

                # Caso ele tenha respondigo sim para qualquer uma entre a SC2 e a SC5
                # Ou tenha respondido não para todas e respondeu 2 ou 3 para a SC1
                # Devo convidar a marcar uma consulta de recrutamento.
                my $first_answer_on_screening = $self->screening_first_answer;
                if ( $conditions_satisfied == 0 && $suggest_appointment_conditions == 0 && $first_answer_on_screening->answer_value =~ /(2|3)/ ) {
                    $question   = $question_rs->search( { code => $question_map->{ $pending_questions[0] }, question_map_id => $question_map_result->id } )->next;
                    $has_more   = scalar @pending_questions >= 1 ? 1 : 0;
                    $count_more = scalar @pending_questions;

                }
                elsif ( $conditions_satisfied != 0 && $suggest_appointment_conditions > 0 ) {
                    $question   = undef;
                    $has_more   = 0;
                    $count_more = 0;

                    %flags = ( suggest_appointment => 1 );
                }
                elsif ( $conditions_satisfied == 0 && $suggest_appointment_conditions == 0 && $first_answer_on_screening->answer_value eq '4' ) {
                    $question   = undef;
                    $has_more   = 0;
                    $count_more = 0;

                    %flags = ( go_to_autotest => 1 );
                }
                # Caso contrário, a triagem acaba e realizamos o fluxo informativo.
                else {
                    $question   = undef;
                    $has_more   = 0;
                    $count_more = 0;
                }
            }
            else {
                $question   = $question_rs->search( { code => $question_map->{ $pending_questions[0] }, question_map_id => $question_map_result->id } )->next;
                $has_more   = scalar @pending_questions >= 1 ? 1 : 0;
                $count_more = scalar @pending_questions;
            }
        }
        else {
            $question   = $question_rs->search( { code => $question_map->{ $pending_questions[0] }, question_map_id => $question_map_result->id } )->next;
            $has_more   = scalar @pending_questions >= 1 ? 1 : 0;
            $count_more = scalar @pending_questions;
        }

        $ret = {
            question   => $question,
            has_more   => $has_more,
            count_more => $count_more,

            %flags
        };
    });

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

   return $self->recipient_flag->is_prep ? 1 : 0;
}

sub is_eligible_for_research {
    my ($self) = @_;

    if ( !$self->recipient_flag->is_eligible_for_research ) {
        $self->update_is_eligible_for_research()
    }

    return $self->recipient_flag->is_eligible_for_research;
}

sub update_is_eligible_for_research {
    my ($self) = @_;

    if ( !$self->is_target_audience ) {
        return $self->recipient_flag->update(
            {
                is_eligible_for_research => 0,
                updated_at               => \'NOW()'
            }
        )
    }

    my $answer_rs = $self->answers->search( { 'question.code' => { 'in' => [ 'B1a', 'B2a', 'B2b', 'B3', 'B4', 'B5', 'B6' ] } }, { prefetch => 'question' } );

    my $conditions_met = 0;
    while ( my $answer = $answer_rs->next() ) {
        my $code = $answer->question->code;

        if ( $code eq 'B4' ) {

            $conditions_met = 1 if $answer->answer_value =~ m/^(1|2|3)$/g;
        }
        else {
            $conditions_met = 1 if $answer->answer_value eq '1';
        }

        next if $conditions_met == 1;
    }

    $self->recipient_flag->update(
        {
            is_eligible_for_research => $conditions_met ? 1 : 0,
            updated_at               => \'NOW()'
        }
    )
}

sub upcoming_appointments {
    my ($self) = @_;

    return $self->appointments->search( { appointment_at => { '>=' => \'NOW()::date' }  } );
}

sub appointment_description {
    my ($self) = @_;

    my @codes = [
        'A1', 'A5', 'A2', 'A3',
        'D4', 'D4a', 'D4b', 'D5',
        'B1', 'B1a', 'B2', 'B2a',
        'B2b', 'B3', 'B4', 'B5',
        'B6', 'B7', 'AC5'
    ];

    my $answers_rs = $self->answers->search( { 'question.code' => { 'in' => @codes } }, { prefetch => 'question' } );

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

sub is_part_of_research {
    my ($self) = @_;

    return $self->recipient_flag->is_part_of_research;
}

sub update_is_target_audience {
    my ($self) = @_;

    my $question_map = $self->result_source->schema->resultset('QuestionMap')->search(
        { 'category.name' => 'quiz' },
        {
            join => 'category',
            order_by => { -desc => 'created_at' }
        }
    )->next;

    my $answer_rs = $self->answers->search(
        {
            'question.code'      => { -in => ['A2', 'A1', 'A5', 'A3'] },
            'me.question_map_id' => $question_map->id
        },
        { join => 'question' }
    );

    my $is_target_audience = 1;
    while ( my $answer = $answer_rs->next ) {
        my $code = $answer->question->code;

        if ( $code eq 'A1' ) {
            $is_target_audience = 0 unless $answer->answer_value =~ /^(15|16|17|18|19)$/;
        }
        elsif ( $code eq 'A2' ) {
            $is_target_audience = 0 unless $answer->answer_value eq '1';
        }
        elsif ( $code eq 'A3' ) {
            $is_target_audience = 0 unless $answer->answer_value !~ /^(2|3)$/;
        }
        else {
            $is_target_audience = 0 unless $answer->answer_value =~ /^(1|2)$/;
        }

        last if $is_target_audience == 0;
    }

    $self->recipient_flag->update(
        {
            is_target_audience => $is_target_audience,
            updated_at         => \'NOW()'
        }
    );
}

sub is_target_audience {
    my ($self) = @_;

    if ( !$self->recipient_flag->is_target_audience || $self->recipient_flag->is_target_audience == 1 ) {
        $self->update_is_target_audience();
    }

    return $self->recipient_flag->is_target_audience;
}

sub generate_integration_token {
    my ($self) = @_;

    return $self->update( { integration_token => \'substring( md5(random()::text), 0, 12)' } );
}

sub update_signed_term {
    my ($self) = @_;

    my $signed_term;

    if ( $self->term_signatures->count > 0 ) {
        $signed_term = 1;
    }
    else {
        $signed_term = 0;
    }

    $self->recipient_flag->update(
        {
            signed_term => $signed_term,
            updated_at  => \'NOW()'
        }
    );
}

sub signed_term {
    my ($self) = @_;

    if ( !$self->recipient_flag->signed_term ) {
        $self->update_signed_term();
    }

    return $self->recipient_flag->signed_term;
}

sub update_finished_quiz {
    my ($self) = @_;

    my $signed_term;

    my $stash = $self->stash_by_category('quiz');

    my $finished_quiz;

    if ( !$stash || ( $stash && !$stash->finished ) ) {
        $finished_quiz = 0;

        if ( $stash ) {
            return if $self->recipient_flag->finished_quiz == $finished_quiz;
        }
    }
    else {
        $finished_quiz = 1;
    }

    return $self->recipient_flag->update(
        {
            finished_quiz => $finished_quiz,
            updated_at    => \'NOW()'
        }
    )
}

sub finished_quiz {
    my ($self) = @_;

    if ( $self->recipient_flag->finished_quiz == 0 ) {
        $self->update_finished_quiz();
    }

    return $self->recipient_flag->finished_quiz;
}

sub build_screening_report {
    my ($self) = @_;

    my $question_map = $self->result_source->schema->resultset('QuestionMap')->search(
        { 'category.name' => 'screening' },
        {
            prefetch => 'category',
            order_by => { -desc => 'created_at' }
        }
    )->next;

    my $answers = $self->answers->search( { question_map_id => $question_map->id } );

    my $answers_parsed;
    my $i = 0;
    while ( my $answer = $answers->next ) {
        $answers_parsed->{$i} = {
            code  => $answer->question->code,
            value => $answer->answer_value
        };

        $i++;
    }

    my $screening = $self->screenings->create(
        {
            question_map_id => $question_map->id,
            answers         => to_json( $answers_parsed )
        }
    );

    return $screening
}

sub reset_screening {
    my ($self) = @_;

    my $question_map = $self->result_source->schema->resultset('QuestionMap')->search(
        { 'category.name' => 'screening' },
        {
            prefetch => 'category',
            order_by => { -desc => 'created_at' }
        }
    )->next;

    $self->result_source->schema->txn_do( sub {
        $self->answers->search( { question_map_id => $question_map->id } )->delete;

        my $stash = $self->stashes->search( { question_map_id => $question_map->id } )->next;
        $stash->update( { finished => 0 } ) if $stash;
    });
}

sub stash_by_category {
    my ($self, $category) = @_;

    die \['category', 'missing'] unless $category;

    return $self->stashes->search(
        { 'category.name' => $category },
        { prefetch => { 'question_map' => 'category' } }
    )->next
}

sub all_flags {
    my ($self) = @_;

    my @flags = qw( is_target_audience is_eligible_for_research is_part_of_research finished_quiz );

    return
        map {
            $_ => $self->$_
        } @flags

}

sub has_appointments {
    my ($self) = @_;

    return $self->appointments->count > 0 ? 1 : 0;
}

__PACKAGE__->meta->make_immutable;
1;
