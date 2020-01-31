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

            my ($term_signature, $simprep_url);
            $self->result_source->schema->txn_do(sub {
                $term_signature = $self->create(\%values);

                my $recipient = $term_signature->recipient;

                if ( $recipient->recipient_flag->is_target_audience && $recipient->recipient_flag->is_eligible_for_research ) {
                    # $simprep_url  = $recipient->register_simprep;

                    # $recipient->recipient_flag->update( { is_part_of_research => 1 } ) if $term_signature->signed == 1;
                    # $recipient->recipient_flag->update( { is_part_of_research => 0 } ) if $term_signature->signed == 0;
                }

            });

            return {
                term_signature                => $term_signature,
                offline_pre_registration_form => $simprep_url
            };
        }
    };
}

1;

