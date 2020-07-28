package Prep::Controller::Internal::AvailableCombinaVouchers;
use Mojo::Base 'Prep::Controller';

sub get {
    my $c = shift;

    my $rs = $c->schema->resultset('CombinaVoucher');

    return $c->render(
        status => 200,
        json   => {
            available_combina_vouchers => [ map {$_} $rs->search('me.recipient_id' => undef)->get_column('value')->all() ]
        }
    )
}

1;
