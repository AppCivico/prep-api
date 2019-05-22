package Prep::Schema::ResultSet::Recipient;
use common::sense;
use Moose;
use namespace::autoclean;

extends "DBIx::Class::ResultSet";

with "Prep::Role::Verification";
with 'Prep::Role::Verification::TransactionalActions::DBIC';

# use Prep::Types qw( URI );

use Data::Verifier;
use Data::Printer;

sub verifiers_specs {
    my $self = shift;

    return {
        create => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                name => {
                    required => 1,
                    type     => 'Str'
                },
                fb_id => {
                    required => 1,
                    type     => 'Num',
                },
                page_id => {
                    required => 1,
                    type     => 'Num'
                },
                picture => {
                    required => 0,
                    type     => 'Str'
                },
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

            $self->search( { fb_id => $values{fb_id} } )->count and die \['fb_id', 'invalid'];

            my $recipient;
            $self->result_source->schema->txn_do( sub {
                $recipient = $self->create(\%values);

                $self->result_source->schema->resultset('RecipientFlag')->create( { recipient_id => $recipient->id } );
            });

            return $recipient;
        }
    };
}

1;

