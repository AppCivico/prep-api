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

=head2 city

  data_type: 'text'
  is_nullable: 1

=head2 count_publico_interesse

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 count_recrutamento

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 count_quiz_brincadeira

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 phone

  data_type: 'text'
  is_nullable: 1

=head2 instagram

  data_type: 'text'
  is_nullable: 1

=head2 voucher_type

  data_type: 'text'
  is_nullable: 1

=head2 prep_reminder_on_demand

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
  "city",
  { data_type => "text", is_nullable => 1 },
  "count_publico_interesse",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "count_recrutamento",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "count_quiz_brincadeira",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "phone",
  { data_type => "text", is_nullable => 1 },
  "instagram",
  { data_type => "text", is_nullable => 1 },
  "voucher_type",
  { data_type => "text", is_nullable => 1 },
  "prep_reminder_on_demand",
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

=head2 C<voucher_unique>

=over 4

=item * L</integration_token>

=back

=cut

__PACKAGE__->add_unique_constraint("voucher_unique", ["integration_token"]);

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

=head2 interactions

Type: has_many

Related object: L<Prep::Schema::Result::Interaction>

=cut

__PACKAGE__->has_many(
  "interactions",
  "Prep::Schema::Result::Interaction",
  { "foreign.recipient_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 notification_queues

Type: has_many

Related object: L<Prep::Schema::Result::NotificationQueue>

=cut

__PACKAGE__->has_many(
  "notification_queues",
  "Prep::Schema::Result::NotificationQueue",
  { "foreign.recipient_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 prep_reminder

Type: might_have

Related object: L<Prep::Schema::Result::PrepReminder>

=cut

__PACKAGE__->might_have(
  "prep_reminder",
  "Prep::Schema::Result::PrepReminder",
  { "foreign.recipient_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 quick_reply_logs

Type: has_many

Related object: L<Prep::Schema::Result::QuickReplyLog>

=cut

__PACKAGE__->has_many(
  "quick_reply_logs",
  "Prep::Schema::Result::QuickReplyLog",
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

=head2 recipient_integration

Type: might_have

Related object: L<Prep::Schema::Result::RecipientIntegration>

=cut

__PACKAGE__->might_have(
  "recipient_integration",
  "Prep::Schema::Result::RecipientIntegration",
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

=head2 test_requests

Type: has_many

Related object: L<Prep::Schema::Result::TestRequest>

=cut

__PACKAGE__->has_many(
  "test_requests",
  "Prep::Schema::Result::TestRequest",
  { "foreign.recipient_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-04-16 13:34:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pBk1+Xp9thzLjbWxJvUnKQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration

with 'Prep::Role::Verification';
with 'Prep::Role::Verification::TransactionalActions::DBIC';

use WebService::Simprep;

has _simprep => (
    is         => 'ro',
    isa        => 'WebService::Simprep',
    lazy_build => 1,
);

use Prep::Utils qw(is_test);

use Text::CSV;
use DateTime;
use JSON;
use DateTime::Format::Pg;

use Prep::Types qw(MobileNumber);

sub _build__simprep { WebService::Simprep->instance }

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
                },
                phone => {
                    required => 0,
                    type     => MobileNumber,
                },
                instagram => {
                    required   => 0,
                    type       => 'Str',
                    max_length => 30,
                },
                voucher_type => {
                    required   => 0,
                    type       => 'Str',
                    post_check => sub {
                        my $voucher_type = $_[0]->get_value('voucher_type');

                        die \['voucher_type', 'invalid'] unless $voucher_type =~ /^(sus|sisprep|combina)$/;

                        return 1;
                    }
                },
                prep_reminder_before => {
                    required => 0,
                    type     => 'Bool'
                },
                prep_reminder_before_interval => {
                    required => 0,
                    type     => 'Str'
                    # TODO mudar type e adicionar verificação
                },
                prep_reminder_after => {
                    required => 0,
                    type     => 'Bool'
                },
                prep_reminder_after_interval => {
                    required => 0,
                    type     => 'Str'
                    # TODO mudar type e adicionar verificação
                },
                prep_reminder_on_demand => {
                    required => 0,
                    type     => 'Bool'
                },
                prep_reminder_running_out => {
                    required => 0,
                    type     => 'Bool'
                },
                prep_reminder_running_out_date => {
                    required => 0,
                    type     => 'Str'
                },
                cancel_prep_reminder => {
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
        ),
        sync_with_simprep => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                is_part_of_research => {
                    required => 0,
                    type     => 'Bool'
                },
                is_prep => {
                    required => 0,
                    type     => 'Bool'
                },
                appointment => {
                    required => 0,
                    type     => 'HashRef'
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

            for my $key (keys %values) {
                next if $key =~ /^(prep_reminder_after|prep_reminder_before)$/;
                not defined $values{$key} and delete $values{$key}
            }

            my @updatable_flags = qw( is_part_of_research is_prep );
            for my $flag ( @updatable_flags ) {
                next unless defined $values{$flag};

                $self->recipient_flag->update( { $flag => $values{$flag} } );
                delete $values{$flag};
            }

            if ($values{prep_reminder_before} && $values{prep_reminder_after}) {
                die \['prep_reminder_after', 'not-allowed'];
            }

            if ($values{prep_reminder_before}) {
                die \['prep_reminder_before_interval', 'missing'] unless $values{prep_reminder_before_interval};
            }

            if ($values{prep_reminder_after}) {
                die \['prep_reminder_after_interval', 'missing'] unless $values{prep_reminder_after_interval};
            }

            $self->result_source->schema->txn_do( sub {
                if ( defined $values{prep_reminder_after} || defined $values{prep_reminder_before} || defined $values{prep_reminder_running_out} ) {
                    die \['fb_id', 'must-be-prep'] unless $self->recipient_flag->is_prep;

                    my $dt_parser = DateTime::Format::Pg->new();
                    my $interval;

                    if ($values{prep_reminder_before}) {
                        my $parsed_interval;

                        eval { $parsed_interval = $dt_parser->parse_interval($values{prep_reminder_before_interval}) };
                        die \['prep_reminder_before_interval', 'invalid'] if $@;

                        $interval = $parsed_interval->hours . ':' . $parsed_interval->minutes . ':' . $parsed_interval->seconds;
                        $interval = \"(NOW()::date + interval '1 day') + interval '$interval'";
                    }

                    if ($values{prep_reminder_after}) {
                        my $parsed_interval;

                        eval { $parsed_interval = $dt_parser->parse_interval($values{prep_reminder_after_interval}) };
                        die \['prep_reminder_after_interval', 'invalid'] if $@;

                        $interval = $parsed_interval->hours . ':' . $parsed_interval->minutes . ':' . $parsed_interval->seconds;
                        $interval = \"(NOW()::date + interval '1 day') + interval '$interval'";
                    }

                    if ($values{prep_reminder_running_out}) {
                        my $parsed_interval;

                        eval { $parsed_interval = $dt_parser->parse_date($values{prep_reminder_running_out_date}) };
                        die \['prep_reminder_after_interval', 'invalid'] if $@;

                        $interval = $parsed_interval;
                    }

                    my $prep_reminder;
                    if ($self->prep_reminder) {
                        $prep_reminder = $self->prep_reminder;

                        $prep_reminder = $prep_reminder->update(
                            {
                                reminder_before          => $values{prep_reminder_before} ? 1 : 0,
                                reminder_before_interval => $values{prep_reminder_before_interval},
                                reminder_after           => $values{prep_reminder_after} ? 1 : 0,
                                reminder_after_interval  => $values{prep_reminder_after_interval},

                                reminder_temporal_wait_until => $interval
                            },
                        );
                    }
                    else {
                        $prep_reminder = $self->result_source->schema->resultset('PrepReminder')->create(
                            {
                                recipient_id => $self->id,

                                reminder_before          => $values{prep_reminder_before} ? 1 : 0,
                                reminder_before_interval => $values{prep_reminder_before_interval},
                                reminder_after           => $values{prep_reminder_after} ? 1 : 0,
                                reminder_after_interval  => $values{prep_reminder_after_interval},

                                reminder_temporal_wait_until => $interval
                            },
                        );
                    }
                }

                if ($values{cancel_prep_reminder}) {
                    delete $values{cancel_prep_reminder};

                    my $prep_reminder = $self->prep_reminder;

                    if ( $prep_reminder ) {
                        $prep_reminder->update(
                            {
                                reminder_before           => 0,
                                reminder_before_interval  => undef,
                                reminder_after            => 0,
                                reminder_after_interval   => undef,
                                reminder_running_out      => 0,
                                reminder_running_out_date => undef,
                            }
                        );

                        $self->result_source->schema->resultset('NotificationQueue')->search(
                            {
                                prep_reminder_id => $prep_reminder->id,
                                sent_at          => \'IS NULL',
                            }
                        )->delete;
                    }
                }


                delete $values{$_} for qw( prep_reminder_before prep_reminder_before_interval prep_reminder_after prep_reminder_after_interval prep_reminder_running_out prep_reminder_running_out_date );
                $self->update(\%values);
            });

            return $self;
        },
        research_participation => sub {
            my $r = shift;

            my %values = $r->valid_values;
            not defined $values{$_} and delete $values{$_} for keys %values;

            # Caso o bool seja verdadeiro
            # devo verificar se a pessoa é elegível para a pesquisa
            if ( ( defined $self->is_target_audience && $self->is_target_audience == 0 ) || $self->is_eligible_for_research == 0 ) {
                die \['is_part_of_research', 'invalid'];
            }

            return $self->recipient_flag->update( { is_part_of_research => $values{is_part_of_research} } );
        },
        sync_with_simprep => sub {
            my $r = shift;

            my %values = $r->valid_values;
            not defined $values{$_} and delete $values{$_} for keys %values;

            # Tratando consulta
            my $appointment = delete $values{appointment};
            if ( ref $appointment ) {
                die \['appointment', 'invalid'] unless defined $appointment->{type_id};

                # Agendando notificação
                my $type_id = $appointment->{type_id};

                if ($type_id == 1) {
                    # Notificações de recrutamento
                    $self->notification_queues->create(
                        {
                            type_id      => 3,
                            recipient_id => $self->id,
                            wait_until   => \"NOW() + '7 days'::interval"
                        }
                    );
                    $self->notification_queues->create(
                        {
                            type_id      => 4,
                            recipient_id => $self->id,
                            wait_until   => \"NOW() + '17 days'::interval"
                        }
                    );

                }
            }

            my @updatable_flags = qw( is_part_of_research is_prep );
            for my $flag (@updatable_flags) {
                next unless defined $values{$flag};

                $self->recipient_flag->update( { $flag => $values{$flag} } );
                delete $values{$flag};
            }

            return $self->update(\%values);
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

    # if ( !$self->is_target_audience ) {
    #     return $self->recipient_flag->update(
    #         {
    #             is_eligible_for_research => 0,
    #             updated_at               => \'NOW()'
    #         }
    #     )
    # }

    my $answer_rs = $self->answers->search( { 'question.code' => { 'in' => [ 'B1', 'B2', 'B4', 'B5', 'B6', 'B7', 'B8', 'B9', 'B10' ] } }, { prefetch => 'question' } );

    my $conditions_met = 0;
    my $city_condition = 0;
    my $is_eligible_for_research = $answer_rs->count > 0 ? 0 : undef;

    while ( my $answer = $answer_rs->next() ) {
        my $code = $answer->question->code;

        if ( $code eq 'B7' ) {

            $is_eligible_for_research = 1 if $answer->answer_value =~ m/^(1|2|3)$/g;
        }
        elsif ($code eq 'A1') {
            $city_condition = 1 if $answer->answer_value =~ m/^(1|2|3)$/g;
        }
        else {
            $is_eligible_for_research = 1 if $answer->answer_value eq '1';
        }

        last if $is_eligible_for_research == 1;
    }

    $self->recipient_flag->update(
        {
            is_eligible_for_research => $is_eligible_for_research,
            updated_at               => \'NOW()'
        }
    )
}

sub upcoming_appointments {
    my ($self) = @_;

    return $self->appointments->search( { appointment_at => { '>=' => \'NOW()::date' }  } );
}

sub appointment_description {
    my ($self, $appointment_id) = @_;

    die 'appointment_id missing' unless $appointment_id;

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
    $answers->[$i + 1] = { voucher             => $self->integration_token };
    $answers->[$i + 2] = { appointment_id      => $appointment_id };

    my $json = JSON->new->pretty(1);
    $answers = $json->encode( $answers );

    $answers =~ s/(,)?(\")?(\[)?(\])?(\})?(\}\n)?(\{\n)?(\h{2,})?//gm;

    return $answers;
}

sub assign_token {
    my ($self, $integration_token) = @_;

    # Verificando se alguem já está com o token.
    $self->result_source->schema->resultset('Recipient')->search( { integration_token => $integration_token } )->count
      and die \['integration_token', 'in-use'];

    $self->result_source->schema->txn_do( sub {
        # Verificando se o token existe
        my $res = $self->_simprep->verify_voucher( voucher => $integration_token );
        die \['integration_token', 'invalid'] unless $res->{status} eq 'success';

        my @required_res = qw(is_prep is_part_of_research);
        defined $res->{data}->{$_} or die \["integration_res{$_}", 'missing'] for @required_res;

        my $data = $res->{data};

        $self->recipient_flag->update(
            {
                finished_quiz       => 1,
                is_target_audience  => 1,
                is_prep             => $data->{is_prep},
                is_part_of_research => $data->{is_part_of_research}
            }
        );

        $self->update(
            {
                integration_token    => $integration_token,
                using_external_token => 1
            }
        );

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
        { 'category.name' => 'publico_interesse' },
        {
            join => 'category',
            order_by => { -desc => 'created_at' }
        }
    )->next;

    my $answer_rs = $self->answers->search(
        {
            'question.code' => { -in => ['A1', 'A2', 'A6','A3'] },
            (
                $question_map ?
                ( 'me.question_map_id' => $question_map->id ) :
                ()

            )
        },
        { join => 'question' }
    );

    my $is_target_audience;
    while ( my $answer = $answer_rs->next ) {
        $is_target_audience = 1;

        my $code = $answer->question->code;

        if ( $code eq 'A1' ) {
            $is_target_audience = 0 unless $answer->answer_value =~ /^(1|2|3)$/;
        }
        elsif ( $code eq 'A2' ) {
            $is_target_audience = 0 unless $answer->answer_value =~ /^(15|16|17|18|19)$/;
        }
        elsif ( $code eq 'A6' ) {
            $is_target_audience = 0 unless $answer->answer_value eq '1';
        }
        elsif ( $code eq 'A3' ) {
            $is_target_audience = 0 unless $answer->answer_value !~ /^(2|3|8)$/;
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

sub risk_group {
    my $self = shift;

    if ( !$self->recipient_flag->risk_group ) {
        $self->update_risk_group();
    }

    return $self->recipient_flag->risk_group;
}

sub update_risk_group {
    my $self = shift;

    my $question_map = $self->result_source->schema->resultset('QuestionMap')->search(
        { 'category.name' => 'publico_interesse' },
        {
            join => 'category',
            order_by => { -desc => 'created_at' }
        }
    )->next;

    my $answer = $self->answers->search(
        {
            'question.code'      => 'A6',
            'me.question_map_id' => $question_map->id
        },
        { join => 'question' }
    )->next;

    if ($answer) {
        my $risk_group;

        if ($answer->answer_value == 1) {
            # Procurando pela resposta da A6a

            my $next_answer = $self->answers->search(
                {
                    'question.code'      => 'A6a',
                    'me.question_map_id' => $question_map->id
                },
                { join => 'question' }
            )->next;

            if ($next_answer->answer_value == 1) {
                $risk_group = 1;
            }
            else {
                $risk_group = 0;
            }
        }
        else {
            $risk_group = 0;
        }

        $self->recipient_flag->update(
            {
                risk_group => $risk_group,
                updated_at => \'NOW()'
            }
        );
    }

    return 1;
}

sub is_target_audience {
    my ($self) = @_;

    if ( !$self->recipient_flag->is_target_audience ) {
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
        my $term_signature = $self->term_signatures->next;

        $signed_term = $term_signature->signed == 1 ? 1 : 0;
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

        my $stash = $self->stashes->search( { question_map_id => $question_map->id } )->delete;
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

    my @flags = qw( is_target_audience is_eligible_for_research is_part_of_research finished_quiz risk_group );

    return
        map {
            $_ => $self->$_
        } @flags

}

sub all_screening_flags {
    my ($self) = @_;

    my @flags = qw( emergency_rerouting go_to_appointment suggest_wait_for_test go_to_test );

    return map { $_ => $self->$_ } @flags
}

sub has_appointments {
    my ($self) = @_;

    return $self->appointments->count > 0 ? 1 : 0;
}

sub emergency_rerouting {
    my ($self) = @_;

    my $question_map = $self->result_source->schema->resultset('QuestionMap')->search( { category_id => 2 }, { order_by => { -desc => 'created_at' } } )->next;

    my $answer = $self->answers->search(
        {
            'question.code'            => 'SC1',
            'question.question_map_id' => $question_map->id
        },
        { prefetch => 'question' }
    )->next;
    return 0 unless $answer;

    return $answer->answer_value eq '1' ? 1 : 0;
}

sub go_to_appointment {
    my ($self) = @_;

    my $question_map = $self->result_source->schema->resultset('QuestionMap')->search( { category_id => 2 }, { order_by => { -desc => 'created_at' } } )->next;

    my $answer = $self->answers->search(
        {
            'question.code'            => { -in => ['SC3', 'SC2b', 'SC2a'] },
            'question.question_map_id' => $question_map->id
        },
        {
            prefetch => 'question',
            order_by => { -desc => 'me.created_at' }
        }
    )->first;
    return 0 unless $answer;

    return $answer->answer_value eq '1' ? 1 : 0;
}

sub suggest_wait_for_test {
    my ($self) = @_;

    my $question_map = $self->result_source->schema->resultset('QuestionMap')->search( { category_id => 2 }, { order_by => { -desc => 'created_at' } } )->next;

    my $answer = $self->answers->search(
        {
            'question.code'            => 'SC1',
            'question.question_map_id' => $question_map->id
        },
        { prefetch => 'question' }
    )->next;
    return 0 unless $answer;

    return $answer->answer_value eq '2' ? 1 : 0;
}

sub go_to_test {
    my ($self) = @_;

    my $question_map = $self->result_source->schema->resultset('QuestionMap')->search( { category_id => 2 }, { order_by => { -desc => 'created_at' } } )->next;

    my $answer = $self->answers->search(
        {
            'question.code'            => 'SC4',
            'question.question_map_id' => $question_map->id
        },
        { prefetch => 'question' }
    )->next;
    return 0 unless $answer;

    return $answer->answer_value eq '1' ? 1 : 0;
}

sub system_labels {
    my ($self) = @_;

    return [
        map {
            my $f = $self->$_;

            $f ? ( { name => $_ } ) : ( )
        } qw( is_target_audience is_eligible_for_research is_part_of_research finished_quiz is_prep )
    ]
}

sub answers_for_integration {
    my $self = shift;

    my @codes;
    if ($self->recipient_flag->finished_recrutamento) {
        @codes = qw(A1 A2 A3 A4 A4a A4b A5 A6 A6a B1 B2 B3 B4 B5 B6 B7 B8 B9 B10);
    }
    elsif ($self->recipient_flag->finished_publico_interesse) {
        @codes = qw(A1 A2 A3 A4 A4a A4b A5 A6);
    }
    else {
        die "must have at least 'publico_interesse' finished"
    }

    my $answer_rs = $self->answers->search(
        { 'question.code' => { -in => \@codes } },
        { join => 'question' }
    );

    my @answers = $answer_rs->all();

    my @yes_no_questions = qw( A6.1 A6.2 B4 B5 B6 B8 B9 B10 );
    my $answers = [
        map {
            my $a = $_;

            my $question_code = $a->question->code;
            my $answer        = $a->answer_value;

            # Caso seja a A4 devo verificar qual a resposta e remover todas relacionadas
            if ( $question_code eq 'A4' ) {
                if ( $answer eq '1' ) {
                    # Caso seja 1, devo verificar a resposta da A4a
                    my $logic_jump_answer = $answer_rs->search( { 'question.code' => 'A4a' }, { join => 'question' } )->next;

                    # Como a A4a é para ensino fundamental, logo são as primeiras opções
                    # Basta preencher com o número da reposta
                    $answer = $logic_jump_answer->answer_value;
                }
                elsif ( $answer eq '2' ) {
                    # Devo verificar a resposta da A4b
                    my $logic_jump_answer = $answer_rs->search( { 'question.code' => 'A4b' }, { join => 'question' } )->next;

                    if ( $logic_jump_answer->answer_value eq '1' ) {
                        $answer = '10';
                    }
                    elsif ( $logic_jump_answer->answer_value eq '2' ) {
                        $answer = '11';
                    }
                    else {
                        $answer = '12';
                    }
                }
                elsif ( $answer eq '3' ) {
                    # Devo preencher com o valor 13
                    $answer = '13'
                }
                else {
                    die 'error at Result::Recipient::answers_for_publico_interesse_integration';
                }
            }

			# Caso seja a A6 e A6a mudo para A6.1 e A6.2
			if ( $question_code eq 'A6' ) {
				$question_code = 'A6.1';
			}elsif ( $question_code eq 'A6a' ) {
				$question_code = 'A6.2';
			} else { }

            # Questões de sim/não devem ser enviadas como 1 ou 0
            if ( grep { $question_code eq $_ } @yes_no_questions ) {
                +{
                    question_code => $question_code,
                    value         => $answer eq '1' ? 1 : 0
                }
            }
            else {
                +{
                    question_code => $question_code,
                    value         => $answer
                }
            }
        } @answers
    ];

    return $answers;
}

sub register_sisprep {
    my ($self, $step) = @_;

    die 'missing step unless step' unless $step;

    my $success;
    $self->result_source->schema->txn_do( sub {
        my $recipient_integration = $self->result_source->schema->resultset('RecipientIntegration')->find_or_create(
            { recipient_id => $self->id },
            { key => 'recipient_integration_recipient_id_key' }
        );

        my $data = $recipient_integration->data;

        my $res;
        eval {
            $res = $self->_simprep->register_recipient(
                answers       => $self->answers_for_integration,
                facebook_name => $self->name
            );
        };

        if ($@ || $res->{status} ne 'success') {
            my $coded_res = $res ? to_json($res) : undef;

            $data->{$step} = {
                status => 'failed',
                epoch  => time(),
                res    => $coded_res ? $coded_res : $@
            };

            $recipient_integration->update( { errmsg => $coded_res ? $coded_res : $@ } );
            $success = 0;
        }
        else {
            $data->{$step} = {
                status => 'success',
                epoch  => time(),
            };

            $self->update( { integration_token => $res->{data}->{voucher} } );
            $success = 1;
        }

        $recipient_integration->update( { data => $data } );
    });

    return $success;
}

sub fun_questions_score {
    my ($self) = @_;

    my $question_map_rs = $self->result_source->schema->resultset('QuestionMap');

    my $latest_quiz     = $question_map_rs->search(
        { 'category.name' => 'quiz' },
        {
            join     => 'category',
            order_by => { -desc => 'created_at' }
        }
    )->next;

    my $latest_quiz_fun_questions = $question_map_rs->search(
        { 'category.name' => 'fun_questions' },
        {
            join     => 'category',
            order_by => { -desc => 'created_at' }
        }
    )->next;

    my $fun_questions_answer_count = 0;
    if ($latest_quiz_fun_questions) {
        $fun_questions_answer_count = $self->answers->search(
            { 'me.question_map_id' => $latest_quiz_fun_questions->id }
        )->count;
    }

    my $question_map = $fun_questions_answer_count > 0 ? $latest_quiz_fun_questions : $latest_quiz;
    my @questions = qw( AC2 AC3 AC4 AC5 AC6 AC7 );

    my $answer_rs = $self->answers->search(
        {
            'question.code'      => { 'in' => \@questions },
            'me.question_map_id' => $question_map->id
        },
        { prefetch => 'question' }
    );

    my $score = 0;
    while ( my $answer = $answer_rs->next() ) {
        $score += $answer->question->score_for_answer_value($answer->answer_value);
    }

    return $score;
}

sub message_for_fun_questions_score {
    my ($self) = @_;

    my $ret;
    my $score = $self->fun_questions_score;

    if ( $score <= 69 ) {
        $ret = {
            message => 'VC É A PABLLO VITTAR, YUKEEEÊ???
Famosissimah nos rolês, mas tá só nas love song que nem a Pablo, nenon? Você parece ser mais de boas quando o assunto é sexo com várias pessoas - ou pelo menos está numa fase de boas, bem romantiquinha. Pode ser que vc não sinta mta necessidady de sarrar, pode ser q esteja namorando fechado e seu tesão se direcione mais para um/uma parceiro/a fixo, pode ser q vc prefira poucos (e bons) doq muitos, pode ser mil coisas - o importante é vc fazer (ou não fazer) oq vc tiver vontade <3',
            picture => 'https://i.imgur.com/u6khXYZ.png'
        }
    }
    elsif ( $score >= 70 && $score <= 129 ) {
        $ret = {
            message => 'VC É A LINN DA QUEBRADA! #TRA #TRA
Afinal, pra qq eu kro pica se eu tenho todos esses dedo??? Pelo q eu catei, vc curte transar mas vê o sexo como algo q vai muito além de penetração - tb ama viver outras experiências além da neca no edi: chupação, dedo, linguada, de repente até um brinquedinho, nenon? Amo que a sra é super sensorial e tá aberta a experiências, acho um bapho SYM',
            picture => 'https://i.imgur.com/nZksGbf.png'
        }
    }
    elsif ( $score >= 130 && $score <= 200 ) {
        $ret = {
            message => 'VC É A GLORIA GROOVE! LIGADYNHA NO PROCEDER
Vc é GLORIOSA gatan, toda dona de vc meixxxma! Assim como a Gloria, passa logo o proceder, joga o papo reto, sabe oq tu quer (e quem tu quer, kkkk) e vive suas vontadys livremente - mto empoderada ela. Vc é rainha na pista, e convoca geral pra arrastar e sarrar com autonomia - mas sempre ligadinha na prevenção. Ai que coisa boa!',
            picture => 'https://i.imgur.com/QwscttE.png'
        }
    }
    else {
        $ret = {
            message => 'VC É A MULHER PEPITA! RANNNNNN
Uma vez piranha, smp piranha, piranha eu sempre hei de ser RANNNN kkk. Kerida, a sra é deshtruidora mesmo 🔥🔥🔥Gosta de sexo sem tabu e sem moralismo, e deve adorar novas experiências, nenon? Deve ter uns sagitário babado nesse mapa astral, aloka. E é isso ai mana, se joga - o segredynho é saber os riscos das suas escolhas e pensar um jeito babado de manter a saúde sexual em dia sem deixar de fazer nada q tu keira.',
            picture => 'https://i.imgur.com/DKuRSXT.png'
        }
    }

    return $ret;
}

sub prep_reminder_confirmation {
    my $self = shift;

    my $prep_reminder = $self->prep_reminder;

    my $interval;
    if ($prep_reminder->reminder_before) {
        $interval = $prep_reminder->reminder_before_interval;
    }
    else {
        $interval = $prep_reminder->reminder_after_interval;
    }

    return $prep_reminder->update(
        {
            reminder_temporal_confirmed_at => \'NOW()',
            reminder_temporal_wait_until   => \"(NOW()::DATE + interval '1 day') + interval '$interval'"
        }
    );
}

__PACKAGE__->meta->make_immutable;
1;
