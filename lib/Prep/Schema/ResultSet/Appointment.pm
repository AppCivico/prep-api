package Prep::Schema::ResultSet::Appointment;
use common::sense;
use Moose;
use namespace::autoclean;

extends "DBIx::Class::ResultSet";

with "Prep::Role::Verification";
with 'Prep::Role::Verification::TransactionalActions::DBIC';

use Data::Verifier;
use Data::Printer;

use Data::Fake qw(Core);

use WebService::GoogleCalendar;

sub verifiers_specs {
    my $self = shift;

    return {
        create => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                appointment_window_id => {
                    required   => 1,
                    type       => 'Int',
                    post_check => sub {
						my $appointment_window_id = $_[0]->get_value('appointment_window_id');

						$self->result_source->schema->resultset('AppointmentWindow')->search( { id => $appointment_window_id } )->count;
                    }
                },
                quota_number => {
                    required   => 1,
                    type       => 'Int',
                    post_check => sub {
						my $quota_number          = $_[0]->get_value('quota_number');
						my $appointment_window_id = $_[0]->get_value('appointment_window_id');
                        my $datetime_start        = $_[0]->get_value('datetime_start');

						my $count = $self->result_source->schema->resultset('Appointment')->search(
                            {
                                quota_number          => $quota_number,
                                appointment_at        => { '>=' => \"'$datetime_start'::date", '<=' => \"'$datetime_start'::date + interval '1 day'" },
                                appointment_window_id => $appointment_window_id
                            }
                        )->count;

                        die \['quota_number', 'invalid'] if $count > 0;

                        return 1;
                    }
                },
                datetime_start => {
                    required => 1,
                    type     => 'Str'
                },
                datetime_end => {
                    required => 1,
                    type     => 'Str'
                },
                type => {
                    required   => 1,
                    type       => 'Str',
                    post_check => sub {
						my $type = $_[0]->get_value('type');

						my $count = $self->result_source->schema->resultset('AppointmentType')->search( { name => $type } )->count or die \['type', 'invalid'];
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

            my $type = delete $values{type};
            $type    = $self->result_source->schema->resultset('AppointmentType')->search( { name => $type } )->next;

            # TODO verificar pelo WS do GCalendar para ver se o horario está
            # disponivel ainda
            my $ws = WebService::GoogleCalendar->instance();

			my $datetime_start = delete $values{datetime_start};
			my $datetime_end   = delete $values{datetime_end};

            my $appointment_window = $self->result_source->schema->resultset('AppointmentWindow')->find($values{appointment_window_id});
            my $calendar           = $appointment_window->calendar;

            $values{calendar_id}         = $calendar->id;
            $values{appointment_at}      = $datetime_start;
            $values{appointment_type_id} = $type->id;

            my $appointment = $self->create(\%values);

            my $recipient = $appointment->recipient;

            $ws->create_event(
               calendar       => $calendar,
               calendar_id    => $calendar->id,
               datetime_start => $datetime_start,
               datetime_end   => $datetime_end,
               summary        => 'Consulta de' . $type->name .  ': ' . $recipient->name,
               description    => $recipient->appointment_description
            );

            return $appointment;
        }
    };
}

1;
