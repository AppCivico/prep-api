use utf8;
package Prep::Schema::Result::CalendarHoliday;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Prep::Schema::Result::CalendarHoliday

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

=head1 TABLE: C<calendar_holidays>

=cut

__PACKAGE__->table("calendar_holidays");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'calendar_holidays_id_seq'

=head2 calendar_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 year

  data_type: 'integer'
  is_nullable: 0

=head2 content

  data_type: 'json'
  default_value: '{}'
  is_nullable: 0

=head2 last_sync_at

  data_type: 'timestamp'
  is_nullable: 1

=head2 next_sync_at

  data_type: 'timestamp'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "calendar_holidays_id_seq",
  },
  "calendar_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "year",
  { data_type => "integer", is_nullable => 0 },
  "content",
  { data_type => "json", default_value => "{}", is_nullable => 0 },
  "last_sync_at",
  { data_type => "timestamp", is_nullable => 1 },
  "next_sync_at",
  { data_type => "timestamp", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<calendar_holidays_calendar_id_key>

=over 4

=item * L</calendar_id>

=back

=cut

__PACKAGE__->add_unique_constraint("calendar_holidays_calendar_id_key", ["calendar_id"]);

=head1 RELATIONS

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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-11-18 15:03:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ALn8Dt4ZceLOgoBPDTy86w


# You can replace this text with custom code or comments, and it will be preserved on regeneration

use JSON;
use WebService::Holiday;
use DateTime;
use Time::Piece;

has _ws => (
    is         => 'ro',
    isa        => 'WebService::Holiday',
    lazy_build => 1,
);

sub _build__ws { WebService::Holiday->instance }

sub get_content_decoded {
    my $self = shift;

    return from_json($self->content);
}

sub get_holidays_ymd {
    my $self = shift;

    my $date_parser = DateTime::Format::Pg->new();

    my $holidays = $self->get_content_decoded;

    my @holidays;
    for my $holiday (@{$holidays->{api}}) {
        $holiday = Time::Piece->strptime( $holiday->{date}, '%d/%m/%Y' );

        push @holidays, $holiday->ymd
    }

    for my $holiday (@{$holidays->{manual_input}}) {
        push @holidays, $holiday;
    }

    return @holidays;
}

sub check_for_update {
    my $self = shift;

    if (!$self->last_sync_at) {
        my $now = DateTime->now();

        my $state = $self->calendar->address_state;
        my $city  = $self->calendar->address_city;

        if ($city eq 'São Paulo') {
            $city = 'Sao_Paulo'
        }
        elsif ($city eq 'Belo Horizonte') {
            $city = 'Belo_Horizonte'
        }

        my $ws = $self->_ws;

        my $holidays = $ws->get_holidays(
            year  => $now->year,
            state => $state,
            city  => $city
        );

        my $content = from_json($self->content);
        $content->{api} = $holidays;

        $content = to_json($content);
        $self->update( {content => $content} )
    }

    return 1;
}

__PACKAGE__->meta->make_immutable;
1;
