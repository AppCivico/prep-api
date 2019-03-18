package Prep::Schema::ResultSet::ExternalNotification;
use common::sense;
use Moose;
use namespace::autoclean;

extends "DBIx::Class::ResultSet";

with "Prep::Role::Verification";
with 'Prep::Role::Verification::TransactionalActions::DBIC';

use Prep::Types qw( URI );
use WebService::Facebook;

use Data::Verifier;
use Data::Printer;

use JSON;

sub verifiers_specs {
    my $self = shift;

    return {
        create => Data::Verifier->new(
            filters => [qw(trim)],
            profile => {
                url => {
                    required => 1,
                    type     => URI
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

            my $external_notification;
            $self->result_source->schema->txn_do( sub {
                $external_notification = $self->create(\%values);

                my $recipient = $external_notification->recipient;
                my $config    = $self->result_source->schema->resultset('Config')->search( { key => 'ACCESS_TOKEN' } )->next;

                my $content = encode_json {
                    messaging_type => "UPDATE",
                    recipient      => { id => $recipient->fb_id },
                    message        => {
                        text => 'Você tem um novo formulário para preencher! Vamos lá? ' . $external_notification->url,
                        quick_replies => [
                            {
                                content_type => 'text',
                                title        => "Voltar para o início",
                                payload      => 'greetings'
                            },
                        ]
                    }
                };

                my $facebook = WebService::Facebook->instance;
                eval {
                    $facebook->send_message(
                        access_token => $config->value,
                        content      => $content
                    );
                };
                die \['notification', 'failed on facebook send'] if $@;

                $external_notification->update( { sent_at => \'NOW()' } );

            });

            return $external_notification;
        }
    };
}

1;

