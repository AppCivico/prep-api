use utf8;
package Prep::Schema::Result::AppointmentWindow;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Prep::Schema::Result::AppointmentWindow

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

=head1 TABLE: C<appointment_window>

=cut

__PACKAGE__->table("appointment_window");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'appointment_window_id_seq'

=head2 calendar_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 start_time

  data_type: 'time'
  is_nullable: 0

=head2 end_time

  data_type: 'time'
  is_nullable: 0

=head2 quotas

  data_type: 'integer'
  is_nullable: 0

=head2 updated_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 custom_quota_time

  data_type: 'time'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "appointment_window_id_seq",
  },
  "calendar_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "start_time",
  { data_type => "time", is_nullable => 0 },
  "end_time",
  { data_type => "time", is_nullable => 0 },
  "quotas",
  { data_type => "integer", is_nullable => 0 },
  "updated_at",
  { data_type => "timestamp", is_nullable => 1 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "custom_quota_time",
  { data_type => "time", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 appointment_window_days_of_week

Type: has_many

Related object: L<Prep::Schema::Result::AppointmentWindowDayOfWeek>

=cut

__PACKAGE__->has_many(
  "appointment_window_days_of_week",
  "Prep::Schema::Result::AppointmentWindowDayOfWeek",
  { "foreign.appointment_window_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 appointments

Type: has_many

Related object: L<Prep::Schema::Result::Appointment>

=cut

__PACKAGE__->has_many(
  "appointments",
  "Prep::Schema::Result::Appointment",
  { "foreign.appointment_window_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 calendar

Type: belongs_to

Related object: L<Prep::Schema::Result::Calendar>

=cut

__PACKAGE__->belongs_to(
  "calendar",
  "Prep::Schema::Result::Calendar",
  { id => "calendar_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2019-01-28 09:47:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LnsdPwYR7lyvanwrbZgzcQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration

use DateTime;
use Time::Piece;

use Prep::Utils qw( is_test );

sub get_quota_info {
    my ($self) = @_;

    # Parseio o começo e o fim da janela de atendimento
    my $end_time   = Time::Piece->strptime( $self->end_time, '%H:%M:%S' );
    my $start_time = Time::Piece->strptime( $self->start_time, '%H:%M:%S' );

    # Pego a diferença entre os dois em minutos
    my $delta = $end_time - $start_time;

    my ($count, $time_in_secs);
    if ( $self->custom_quota_time ) {
        $time_in_secs = Time::Piece->strptime( $self->custom_quota_time, '%H:%M:%S' );
        $time_in_secs = ( $time_in_secs->min * 60 ) + $time_in_secs->sec;

        $count = $delta / $time_in_secs;
    }
    else {
        $count        = $self->quotas;
        $time_in_secs = $delta / $self->quotas;
    }

    return {
        start_time      => $start_time,
        end_time        => $end_time,
        time_in_seconds => $time_in_secs,
        count           => $count
    };
}

sub quota_map {
    my ($self) = @_;

    my $quota_info = $self->get_quota_info;

    my $current_time = $quota_info->{start_time};
    my ($ret, $next_time);

    for ( 1 .. $quota_info->{count} ) {
        $next_time = $current_time->add( $quota_info->{time_in_seconds} );

        $ret->{$_} = {
            text  => $current_time->hms . ' - ' . $next_time->hms,
            start => $current_time->hms,
            end   => $next_time->hms
        }
    }

    return $ret;
}

sub assert_quota_number {
    my ($self, %opts) = @_;

	my @required_opts = qw( quota_number datetime_start datetime_end );
	defined $opts{$_} or die \["opts{$_}", 'missing'] for @required_opts;

    my $quota_map = $self->quota_map;

	my $start_time = Time::Piece->strptime( $opts{datetime_start}, '%Y-%m-%dT%H:%M:%S' );
	my $end_time   = Time::Piece->strptime( $opts{datetime_end},   '%Y-%m-%dT%H:%M:%S' );

    $self->appointment_window_days_of_week->search( { day_of_week => $start_time->day_of_week } )->next
      or die \['datetime_start', 'no appointments on this day of week'];

    my $selected_quota = $quota_map->{ $opts{quota_number} } or die \['quota_number', 'invalid'];

	die \['datetime_start', $selected_quota->{start}] unless is_test;

	die \[ 'datetime_start', 'does not matches quota start time' ] unless $selected_quota->{start} eq $start_time->hms;
	die \[ 'datetime_end',   'does not matches quota end time' ] unless $selected_quota->{end}   eq $end_time->hms;
}

__PACKAGE__->meta->make_immutable;
1;
