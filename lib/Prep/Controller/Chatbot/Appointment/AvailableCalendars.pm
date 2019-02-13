package Prep::Controller::Chatbot::Appointment::AvailableCalendars;
use Mojo::Base 'Prep::Controller';

sub get {
    my $c = shift;

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
                } $c->schema->resultset('Calendar')->search()->all()
            ]
        }
    )
}

1;
