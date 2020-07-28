package Prep::Schema::ResultSet::QuickReplyLog;
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
                },
                button_text => {
                    required => 1,
                    type     => 'Str'
                },
                payload => {
                    required => 1,
                    type     => 'Str'
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

            return $self->create(\%values);
        }
    };
}

sub build_list {
    my $self = shift;

    return [
        map {

            +{
                button_text => $_->button_text,
                payload     => $_->payload,
                created_at  => $_->created_at,
            }
        } $self->search(undef, { order_by => {'-desc' => 'me.created_at'} })->all()
    ]
}

1;
