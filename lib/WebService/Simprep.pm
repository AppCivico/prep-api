package WebService::Simprep;
use common::sense;
use MooseX::Singleton;

use JSON;
use LWP::UserAgent;
use Try::Tiny::Retry;
use Prep::Utils;

has 'ua' => ( is => 'rw', lazy => 1, builder => '_build_ua' );

sub _build_ua { LWP::UserAgent->new() }

sub register_recipient {
    my ( $self, %opts ) = @_;

    my @required_opts = qw( answers signed );
    defined $opts{$_} or die \["opts{$_}", 'missing'] for @required_opts;

    if (is_test()) {
        return {
            status => 'success',
            data   => {
                voucher => '00300000002',
                url     => 'https://www.google.com'
            }
        };
    }
    else {
        my $res;

        eval {
            retry {
                my $url = $ENV{SIMPREP_API_URL} . '/recrutamento/novo';

                $res = $self->ua->post(
                    $url,
                    Content_Type => 'application/json',
                    'X-API-KEY'  => $ENV{SIMPREP_TOKEN},
                    Content      => encode_json(
                        {
                            answers     => $opts{answers},
                            signed_TCLE => $opts{signed}
                        }
                    )
                );
                die $res->decoded_content unless $res->is_success;

                my $response = decode_json( $res->decoded_content );
                die 'invalid responde' unless $response->{status} eq 'success';

            }
            retry_if { shift() < 3 } catch { die $_; };
        };
        die $@ if $@;

        return decode_json( $res->decoded_content );
    }
}

sub get_form_for_notification {
    my ($self, %opts) = @_;

    my @required_opts = qw( voucher );
    defined $opts{$_} or die \["opts{$_}", 'missing'] for @required_opts;

    if (is_test()) {
        return {
            url     => 'https://www.google.com',
            voucher => $opts{voucher}
        };
    }
    else {
        my $res;
        eval {
            retry {
                my $url = $ENV{SIMPREP_API_URL} . '/form';

                $res = $self->ua->get(
                    $url
                );

                die $res->decoded_content unless $res->is_success;

                my $response = decode_json( $res->decoded_content );
                die 'invalid response' unless $response;

            }
            retry_if { shift() < 3 } catch { die $_; };
        };
        die $@ if $@;

        return decode_json( $res->decoded_content );
    }
}

sub verify_voucher {
    my ($self, %opts) = @_;

    my @required_opts = qw( voucher );
    defined $opts{$_} or die \["opts{$_}", 'missing'] for @required_opts;

    if (is_test()) {
        return {
            "status" => "success",
            "data" => {
                "voucher" => "00100000001",
                "registration" => 0,
                "eligibility" => 0,
                "is_prep" => 0,
                "is_part_of_research" => 0
            }
        };
    }
    else {
        my $res;
        eval {
            retry {
                my $url = $ENV{SIMPREP_API_URL} . '/recrutamento/' . $opts{voucher};

                $res = $self->ua->get($url, 'X-API-KEY' => $ENV{SIMPREP_TOKEN});

                my $response = decode_json( $res->decoded_content );

            }
            retry_if { shift() < 3 } catch { die $_; };
        };
        die $@ if $@;

        return decode_json( $res->decoded_content );
    }
}

1;
