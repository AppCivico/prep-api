package Prep::Utils;
use strict;
use warnings;

use Crypt::PRNG qw(random_string);
use Data::Section::Simple qw(get_data_section);

use DateTime;

use vars qw(@ISA @EXPORT);

@ISA    = (qw(Exporter));
@EXPORT = qw(is_test random_string get_data_section env get_ymd_by_day_of_the_week);

sub is_test {
    if ($ENV{HARNESS_ACTIVE} || $0 =~ m{prove}) {
        return 1;
    }
    return 0;
}

sub get_ymd_by_day_of_the_week {
    my ($day_of_the_week) = @_;

    my $now = DateTime->now;

    while ( $now->day_of_week != $day_of_the_week ) {
        $now->add( days => 1 );
    }

    return $now->ymd;
}

sub env { return $ENV{${\shift}} }

1;
