package Prep::Controller::Chatbot::Appointment::AvailableDates;
use Mojo::Base 'Prep::Controller';

sub get {
    my $c = shift;

    # TODO verificar de onde o recipient é e verificar o calendário

    my $calendar = $c->schema->resultset('Calendar')->search(undef)->next;

    return $c->render(
        status => 200,
        json   => {
            id        => $calendar->id,
            google_id => $calendar->google_id,
            name      => $calendar->name,
            time_zone => $calendar->time_zone,
            dates     => $calendar->available_dates
        }
    )
}

1;
