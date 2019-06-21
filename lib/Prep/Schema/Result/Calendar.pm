use utf8;
package Prep::Schema::Result::Calendar;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Prep::Schema::Result::Calendar

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

=head1 TABLE: C<calendar>

=cut

__PACKAGE__->table("calendar");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'calendar_id_seq'

=head2 google_id

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 time_zone

  data_type: 'text'
  is_nullable: 0

=head2 token

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 token_valid_until

  data_type: 'timestamp'
  is_nullable: 1

=head2 updated_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 client_id

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 client_secret

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 refresh_token

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 address_city

  data_type: 'text'
  is_nullable: 0

=head2 address_state

  data_type: 'text'
  is_nullable: 0

=head2 address_street

  data_type: 'text'
  is_nullable: 0

=head2 address_zipcode

  data_type: 'text'
  is_nullable: 0

=head2 address_number

  data_type: 'integer'
  is_nullable: 0

=head2 address_district

  data_type: 'text'
  is_nullable: 0

=head2 address_complement

  data_type: 'text'
  is_nullable: 1

=head2 phone

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "calendar_id_seq",
  },
  "google_id",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "name",
  { data_type => "text", is_nullable => 0 },
  "time_zone",
  { data_type => "text", is_nullable => 0 },
  "token",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "token_valid_until",
  { data_type => "timestamp", is_nullable => 1 },
  "updated_at",
  { data_type => "timestamp", is_nullable => 1 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "client_id",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "client_secret",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "refresh_token",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "address_city",
  { data_type => "text", is_nullable => 0 },
  "address_state",
  { data_type => "text", is_nullable => 0 },
  "address_street",
  { data_type => "text", is_nullable => 0 },
  "address_zipcode",
  { data_type => "text", is_nullable => 0 },
  "address_number",
  { data_type => "integer", is_nullable => 0 },
  "address_district",
  { data_type => "text", is_nullable => 0 },
  "address_complement",
  { data_type => "text", is_nullable => 1 },
  "phone",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<calendar_google_id_key>

=over 4

=item * L</google_id>

=back

=cut

__PACKAGE__->add_unique_constraint("calendar_google_id_key", ["google_id"]);

=head1 RELATIONS

=head2 appointment_windows

Type: has_many

Related object: L<Prep::Schema::Result::AppointmentWindow>

=cut

__PACKAGE__->has_many(
  "appointment_windows",
  "Prep::Schema::Result::AppointmentWindow",
  { "foreign.calendar_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 appointments

Type: has_many

Related object: L<Prep::Schema::Result::Appointment>

=cut

__PACKAGE__->has_many(
  "appointments",
  "Prep::Schema::Result::Appointment",
  { "foreign.calendar_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2019-02-13 10:08:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:T95CoBCMnmEbPOjn2D+HdQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration

use Prep::Utils qw(get_ymd_by_day_of_the_week);

use Time::Piece;
use DateTime;

use WebService::GoogleCalendar;

has _calendar => (
    is         => 'ro',
    isa        => 'WebService::GoogleCalendar',
    lazy_build => 1,
);

sub _build__calendar { WebService::GoogleCalendar->instance }

sub available_dates {
    my ($self, $page, $rows) = @_;

    my $appointment_rs = $self->result_source->schema->resultset('Appointment');
    my $appointment_windows = $self->appointment_windows;
    my $now = Time::Piece->new();

    return [
        map {
            my $custom_quota_time = $_->custom_quota_time;
            $custom_quota_time    = Time::Piece->strptime( $custom_quota_time, '%H:%M:%S' )
              if defined $custom_quota_time;

            my $interval;

            my $appointment_window_id = $_->id;

            # Pegando cotas disponiveis
            my @base_quotas = ( 1 .. $_->quotas );

            # Parseio o começo e o fim da janela de atendimento
            my $end_time   = Time::Piece->strptime( $_->end_time, '%H:%M:%S' );
            my $start_time = Time::Piece->strptime( $_->start_time, '%H:%M:%S' );


            # Pego a diferença entre os dois em segundos e divido pelo numero de cotas
            my $delta = ( $end_time - $start_time );
            my $seconds_per_quota = ( $custom_quota_time ? ($custom_quota_time->[9]) : ( $delta / $_->quotas ));

            my @days_of_week = $_->appointment_window_days_of_week->search( undef, { rows => 8, order_by => { -asc => 'day_of_week' } } )->get_column('day_of_week')->all();

            for ( 1 .. 2 ) {
                push @days_of_week, @days_of_week;
            }

            my $week = 0;
            map {
                my $ymd = get_ymd_by_day_of_the_week(dow => $_, week => $week);
                $week++;

                my @taken_quotas = $appointment_rs->search(
                    {
                        appointment_window_id  => $appointment_window_id,
                        appointment_at         => { '>=' => \"'$ymd'::date", '<' => \"'$ymd'::date + interval '1 day'"},
                    }
                )->get_column('quota_number')->all();

                my %taken_quotas = map { $_ => 1 } @taken_quotas;

                my @available_quotas = grep { not $taken_quotas{$_} } @base_quotas;

                +{
                    appointment_window_id => $appointment_window_id,
                    ymd                   => $ymd,
                    hours => [
                        map {
                            my $is_first_quota = $_ == 1 ? 1 : 0;

                            my $time     = $start_time->add( $seconds_per_quota * $_);
                            my $time_hms = $time->hms;

                            my $complete_time = "$ymd $time_hms";
                            $complete_time    = Time::Piece->strptime( $complete_time, '%Y-%m-%d %H:%M:%S' );

                            +{
                                quota => $_,
                                # Tratando o primeiro caso
                                # No primeiro caso o começo não deve ser somado
                                time  => $is_first_quota ?
                                    ( $start_time->hms . ' - ' . $start_time->add($seconds_per_quota * $_ )->hms ) :
                                    ( $start_time->add($seconds_per_quota * ($_ - 1))->hms . ' - ' . $start_time->add($seconds_per_quota * $_)->hms ),
                                datetime_start => $is_first_quota ?
                                    ( $ymd . 'T' . $start_time->hms ) :
                                    ( $ymd . 'T' . $start_time->add($seconds_per_quota * ($_ - 1))->hms ),
                                datetime_end => $ymd . 'T' . $start_time->add($seconds_per_quota * $_ )->hms
                            }
                        } @available_quotas
                    ]
                }
            } @days_of_week;
        } $self->appointment_windows->search(undef, { page => $page, rows => $rows } )->all()
    ];
}

sub sync_appointments {
    my ($self) = @_;

    my $res = $self->_calendar->get_calendar_events( calendar => $self, google_id => $self->google_id );

    my @manual_appointments = grep { $_->{description} !~ m/agendamento_chatbot/gm } @{ $res->{items} };

    $self->result_source->schema->txn_do( sub {
        eval {
            my $voucher;
            for my $appointment (@manual_appointments) {
                my %fields = $appointment->{description} =~ /^(voucher)*\s*:\s*(\S+)/gm;

                my $recipient = $self->result_source->schema->resultset('Recipient')->search( { integration_token => $fields{voucher} } )->next;
                next unless $recipient;

                $voucher = $recipient->integration_token;

                $recipient->appointments->find_or_create(
                    {
                        appointment_at => $appointment->{start}->{dateTime},
                        calendar_id    => $self->id
                    },
                    { key => 'recipient_calendar_id' }
                );

            }

            # Criando notificações
            my $appointment_rs = $self->result_source->schema->resultset('Appointment')->search( { notification_created_at => \'IS NULL' } );

            my (@notifications, @appointments_ids);
            while ( my $appointment = $appointment_rs->next() ) {
                my $appointment_ts = $appointment->appointment_at;

                my $day   = $appointment_ts->day;
                my $month = $appointment_ts->month;
                my $hms   = $appointment_ts->hms;

                my $text = "Bafo! Tem uma consulta chegando, olha só: dia $day/$month às $hms. E toma aqui o seu voucher: $voucher.";

                my $notification = {
                    type_id      => 2,
                    text         => $text,
                    recipient_id => $appointment->recipient_id,
                    wait_until   => $appointment->appointment_at->subtract( days => 2 )
                };

                push @notifications, $notification;
            }

            $self->result_source->schema->resultset('NotificationQueue')->populate(\@notifications);
            $appointment_rs->update( { notification_created_at => \'NOW()' } );
        };
        die $@ if $@;
    });

    return 1;
}

__PACKAGE__->meta->make_immutable;
1;
