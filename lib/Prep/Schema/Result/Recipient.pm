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


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2019-01-21 10:08:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bQZZ/sDK9XQdQEOB21w93w


# You can replace this text with custom code or comments, and it will be preserved on regeneration

with 'Prep::Role::Verification';
with 'Prep::Role::Verification::TransactionalActions::DBIC';

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

sub get_pending_question {
    my ($self) = @_;

    my $question_rs  = $self->result_source->schema->resultset('Question');
    my $question_map = $self->result_source->schema->resultset('QuestionMap')->parsed;

    my @answered_questions = $self->answers->search( undef, { prefetch => 'question' } )->get_column('question.code')->all();

    my @pending_questions = grep { my $k = $_; !grep { $question_map->{$k} eq $_ } @answered_questions } sort keys %{ $question_map };

    return $question_rs->search( { code => $question_map->{ $pending_questions[0] } } )->next;
}

__PACKAGE__->meta->make_immutable;
1;
