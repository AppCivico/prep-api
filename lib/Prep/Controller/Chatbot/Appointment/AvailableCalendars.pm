package Prep::Controller::Chatbot::Appointment::AvailableCalendars;
use Mojo::Base 'Prep::Controller';

sub get {
    my $c = shift;

    $c->validate_request_params(
        city => {
            type       => 'Str',
            required   => 0,
            post_check => sub {
                my $city = $c->req->params->to_hash->{city};

                die \['city', 'invalid'] unless $city =~ m/(1|2|3)/;
            }
        },
    );

    my $address_city;
    if ($c->req->params->to_hash->{city}) {
        if ($c->req->params->to_hash->{city} == 1) {
            $address_city = 'Belo Horizonte';
        }
        elsif ($c->req->params->to_hash->{city} == 2) {
            $address_city = 'Salvador';
        }
        else {
            $address_city = 'São Paulo'
        }
    }

    return $c->render(
        status => 200,
        json   => {
            calendars => [
                map {

                    {
                        id         => $_->id,
                        city       => $_->address_city,
                        state      => $_->address_state,
                        street     => $_->address_street,
                        number     => $_->address_number,
                        zipcode    => $_->address_zipcode,
                        district   => $_->address_district,
                        complement => $_->address_complement,
                        phone      => $_->phone,
                        google_id  => $_->google_id,
                        name       => $_->name,
                        time_zone  => $_->time_zone,
                    }
                } $c->schema->resultset('Calendar')->search(
                    {
                        active => 1,
                        $address_city ? ( address_city => $address_city ) : ()
                    }
                )->all()
            ]
        }
    )
}

1;
