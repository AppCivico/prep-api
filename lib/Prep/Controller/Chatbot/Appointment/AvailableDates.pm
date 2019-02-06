package Prep::Controller::Chatbot::Appointment::AvailableDates;
use Mojo::Base 'Prep::Controller';

sub get {
    my $c = shift;

    # Usando o primeiro calendario para retrocompatibilidade
    $c->req->params->to_hash->{calendar_id} = 1 unless defined $c->req->params->to_hash->{calendar_id};

	my $calendar = $c->schema->resultset('Calendar')->find( $c->req->params->to_hash->{calendar_id} );

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
