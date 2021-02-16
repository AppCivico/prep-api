package Prep::Schema::ResultSet::RecipientIntegration;
use common::sense;
use Moose;
use namespace::autoclean;

extends "DBIx::Class::ResultSet";

with "Prep::Role::Verification";
with 'Prep::Role::Verification::TransactionalActions::DBIC';

use Data::Verifier;
use Data::Printer;
use JSON;

sub verifiers_specs {
    my $self = shift;

    return {
        create => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                recipient_id => {
                    required => 1,
                    type     => 'Int',
                },
                data => {
                    required => 1,
                    type     => 'HashRef'
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

            eval { $values{data} = to_json($values{data}) };
            die \['data', 'invalid'] if ref $values{data} eq 'HASH' || $@;

            $self->search( { recipient_id => $values{recipient_id} } )->count and die \['recipient_id', 'invalid'];

            return $self->create(\%values);
        }
    };
}

1;

