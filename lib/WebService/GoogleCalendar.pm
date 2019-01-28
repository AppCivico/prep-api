package WebService::GoogleCalendar;
use common::sense;
use MooseX::Singleton;

use Prep::Utils qw(is_test);

use Furl;
use JSON;
use Net::Google::OAuth;
use DateTime;

has 'furl' => ( is => 'rw', lazy => 1, builder => '_build_furl' );

sub _build_furl { Furl->new() }

sub generate_token {
    my ($self, $calendar) = @_;

    my $token;
    if ( !$calendar->token || $calendar->token_valid_until <= DateTime->now() ) {
		my $oauth = Net::Google::OAuth->new(
			-client_id     => $calendar->client_id,
			-client_secret => $calendar->client_secret,
		);

		$oauth->refreshToken( -refresh_token => $calendar->refresh_token );

		$token = $oauth->getAccessToken();

        $calendar->update(
            {
                token => $token,
                token_valid_until => \"NOW() + interval '1 hour'"
            }
        );
    }
    else {
        $token = $calendar->token;
    }

    return $token;
}

sub get_calendar_events {
    my ($self, %opts) = @_;

	my @required_opts = qw( calendar calendar_id );
	defined $opts{$_} or die \["opts{$_}", 'missing'] for @required_opts;

    my $res;
    if (is_test()) {
        $res = $Prep::Test::calendar_response;
    }
    else {
        my $access_token = $self->generate_token($opts{calendar});

        eval {
            retry {
				my $tomorrow = DateTime->today->add( days => 1 );
				$tomorrow    = $tomorrow . 'Z';

				my $url = $ENV{GOOGLE_CALENDAR_API_URL} . '/calendars/' . $opts{calendar_id} . "/events?timeMin=$tomorrow";

                $res = $self->furl->get(
                    $url,
                    [ 'Authorization', 'Bearer ' . $access_token ]
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

sub get_calendar_event_at_time {
    my ($self, %opts) = @_;

	my @required_opts = qw( calendar calendar_id );
	defined $opts{$_} or die \["opts{$_}", 'missing'] for @required_opts;

    my $res;
    if (is_test()) {
        $res = $Prep::Test::calendar_response;
    }
    else {
        my $access_token = $self->generate_token($opts{calendar});

        eval {
            retry {
                my $tomorrow = DateTime->today->add( days => 1 );
                $tomorrow    = $tomorrow . 'Z';

                my $url = $ENV{GOOGLE_CALENDAR_API_URL} . '/calendars/' . $opts{calendar_id} . "/events?timeMin=$tomorrow";

                $res = $self->furl->get(
                    $url,
                    [ 'Authorization', 'Bearer ' . $access_token ]
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

sub create_event {
    my ($self, %opts) = @_;

    my @required_opts = qw( calendar calendar_id datetime_start datetime_end );
	defined $opts{$_} or die \["opts{$_}", 'missing'] for @required_opts;

    my $res;
    if (is_test()) {
        $res = $Prep::Test::calendar_event_post;
    }
    else {
        my $access_token = $self->generate_token($opts{calendar});

        eval {
            retry {
                my $url = $ENV{GOOGLE_CALENDAR_API_URL} . '/calendars/' . $opts{calendar_id} . '/events';
                $res = $self->furl->get(
                    $url,
                    [
                        'Content-Type', 'application/json',
                        'Authorization', 'Bearer ' . $access_token
                    ],
                    encode_json(
                        {
                            start => {
                                date     => undef,
                                dateTime => $opts{datetime_start},
                                timeZone => $opts{calendar}->time_zone
                            },
                            end => {
                                date     => undef,
                                dateTime => $opts{datetime_end},
                                timeZone => $opts{calendar}->time_zone
                            },
                            id          => $opts{datetime_start},
                            description => 'foo'
                        }
                    )
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
