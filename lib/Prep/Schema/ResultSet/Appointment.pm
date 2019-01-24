package Prep::Schema::ResultSet::Appointment;
use common::sense;
use Moose;
use namespace::autoclean;

extends "DBIx::Class::ResultSet";

with "Prep::Role::Verification";
with 'Prep::Role::Verification::TransactionalActions::DBIC';

use Data::Verifier;
use Data::Printer;

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

						my $count = $self->result_source->schema->resultset('Appointment')->search(
                            {
                                quota_number          => $quota_number,
                                created_at            => { '>=' => \'now()::date', '<=' => \"now()::date + interval '1 day'" },
                                appointment_window_id => $appointment_window_id
                            }
                        )->count;

                        die \['quota_number', 'invalid'] if $count > 0;

                        return 1;
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

            # TODO verificar pelo WS do GCalendar para ver se o horario está
            # disponivel ainda
            my $appointment = $self->create(\%values);

            return $appointment;
        }
    };
}

1;
