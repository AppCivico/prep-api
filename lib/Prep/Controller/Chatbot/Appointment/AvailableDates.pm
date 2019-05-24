package Prep::Controller::Chatbot::Appointment::AvailableDates;
use Mojo::Base 'Prep::Controller';

sub get {
    my $c = shift;

    # Usando o primeiro calendario para retrocompatibilidade
    $c->req->params->to_hash->{calendar_id} = 1 unless defined $c->req->params->to_hash->{calendar_id};

    my $calendar = $c->schema->resultset('Calendar')->find( $c->req->params->to_hash->{calendar_id} );
    die \['calendar_id', 'invalid'] unless $calendar;

    my $page = $c->req->params->to_hash->{page};
    my $rows = $c->req->params->to_hash->{rows};

    return $c->render(
        status => 200,
        json   => {
            id        => $calendar->id,
            google_id => $calendar->google_id,
            name      => $calendar->name,
            time_zone => $calendar->time_zone,
            dates     => $calendar->available_dates($page, $rows)
        }
    )
}

1;
