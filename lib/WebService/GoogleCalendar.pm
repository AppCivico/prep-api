package WebService::GoogleCalendar;
use common::sense;
use MooseX::Singleton;

use Furl;
use DateTime;

has 'furl' => ( is => 'rw', lazy => 1, builder => '_build_furl' );

sub _build_furl { Furl->new() }

sub generate_token {
    my ($self, $calendar) = @_;

    my $token;
    if ( $calendar->token_valid_until < DateTime->now() ) {
        $self->_furl->get()
    }
    else {
        $token = $calendar->token;
    }

    return $token;
}

sub get_calendar_events {
    my ($self, %opts) = @_;

    my $res;
    if (is_test()) {
        $res = $Prep::Test::calendar_response;;
    }
    else {
        my $access_token = $self->generate_access_token();

        eval {
            retry {
                my $url = $ENV{GOOGLE_CALENDAR_API_URL} . '/calendars/' . $opts{calendar_id} . '/events';
                $res = $self->furl->get(
                    $url,
                    [ 'Authorization', 'Bearer' . $opts{calendar_token} ]
                );

                die $res->decoded_content unless $res->is_success;
            }
            retry_if { shift() < 3 } catch { die $_; };
        };
        die $@ if $@;

        $res = decode_json( $res->decoded_content );
    }

    return $res;
}


1;
