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
                        id        => $_->id,
                        city      => $_->city,
                        google_id => $_->google_id,
                        name      => $_->name,
                        time_zone => $_->time_zone,
                    }
                } $c->schema->resultset('Calendar')->search()->all()
            ]
        }
    )
}

1;
