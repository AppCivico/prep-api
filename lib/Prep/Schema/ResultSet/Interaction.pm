package Prep::Schema::ResultSet::Interaction;
use common::sense;
use Moose;
use namespace::autoclean;

extends "DBIx::Class::ResultSet";

with "Prep::Role::Verification";
with 'Prep::Role::Verification::TransactionalActions::DBIC';

use Data::Verifier;
use Data::Printer;

use Data::Fake qw(Core);
use DateTime;

use WebService::GoogleCalendar;

sub verifiers_specs {
    my $self = shift;

    return {
        create => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                recipient_id => {
                    required => 1,
                    type     => 'Int'
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

            my $latest_interaction = $self->search(
                undef,
                {
                    order_by => {'-desc' => 'me.started_at'},
                    rows     => 1
                }
            )->next;

            die \['recipient_id', 'open-interaction'] if $latest_interaction && !defined $latest_interaction->closed_at;

            return $self->create(\%values);
        }
    };
}

sub build_list {
    my $self = shift;

    return [
        map {
            my $i = $_;

            +{
                id         => $i->id,
                started_at => $i->started_at,
                closed_at  => $i->closed_at
            }
        } $self->search(undef, { order_by => {'-desc' => 'me.started_at'} })->all()
    ]
}

1;
