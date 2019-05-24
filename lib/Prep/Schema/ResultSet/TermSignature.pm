package Prep::Schema::ResultSet::TermSignature;
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
                recipient_id => {
                    required => 1,
                    type     => 'Int'
                },

                signed => {
                    required => 1,
                    type     => 'Bool'
                },

                url => {
                    required => 0,
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

            # if ( $values{url} !~ /^((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/._]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)$/ ) {
            #     die \['url', 'invalid'];
            # }

            my $term_signature = $self->create(\%values);

            my $recipient   = $term_signature->recipient;
            my $simprep_url = $recipient->register_simprep;

            return {
                term_signature                => $term_signature,
                offline_pre_registration_form => $simprep_url
            };
        }
    };
}

1;

