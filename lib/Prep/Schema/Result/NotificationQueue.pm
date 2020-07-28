use utf8;
package Prep::Schema::Result::NotificationQueue;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Prep::Schema::Result::NotificationQueue

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

=head1 TABLE: C<notification_queue>

=cut

__PACKAGE__->table("notification_queue");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'notification_queue_id_seq'

=head2 type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 recipient_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 err_msg

  data_type: 'text'
  is_nullable: 1

=head2 sent_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 wait_until

  data_type: 'timestamp'
  is_nullable: 1

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 text

  data_type: 'text'
  is_nullable: 1

=head2 prep_reminder_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "notification_queue_id_seq",
  },
  "type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "recipient_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "err_msg",
  { data_type => "text", is_nullable => 1 },
  "sent_at",
  { data_type => "timestamp", is_nullable => 1 },
  "wait_until",
  { data_type => "timestamp", is_nullable => 1 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "text",
  { data_type => "text", is_nullable => 1 },
  "prep_reminder_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 prep_reminder

Type: belongs_to

Related object: L<Prep::Schema::Result::PrepReminder>

=cut

__PACKAGE__->belongs_to(
  "prep_reminder",
  "Prep::Schema::Result::PrepReminder",
  { id => "prep_reminder_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
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

=head2 type

Type: belongs_to

Related object: L<Prep::Schema::Result::NotificationType>

=cut

__PACKAGE__->belongs_to(
  "type",
  "Prep::Schema::Result::NotificationType",
  { id => "type_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-04-13 14:20:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JH9pgEz+GkUg2drpEaxbCQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration

use Mojo::Base 'Mojo::EventEmitter';
use JSON;

use WebService::Facebook;

sub send {
    my ($self) = @_;

    my $facebook = WebService::Facebook->instance;
    my $config   = $self->result_source->schema->resultset('Config')->search( { key => 'ACCESS_TOKEN' } )->next;

    my $type = $self->type;

    my $notification_info = $type->get_info();

    my $recipient = $self->recipient;

    my $body = encode_json {
        messaging_type => "UPDATE",
        recipient      => { id => $recipient->fb_id },
        message        => {
            text          => $self->text ? $self->text : $notification_info->{text},
            quick_replies => $notification_info->{quick_replies}
        }
    };

    eval {
        $facebook->send_message(
            access_token => $config->value,
            content      => $body
        );
    };

    if ($@) {
        $self->update( { err_msg => $@ } );
    }
    else {
        $self->update( { sent_at => \'NOW()' } );
    }

    return 1;

}

__PACKAGE__->meta->make_immutable;
1;
