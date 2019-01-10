package Prep::Utils;
use strict;
use warnings;

use Crypt::PRNG qw(random_string);
use Data::Section::Simple qw(get_data_section);

use vars qw(@ISA @EXPORT);

@ISA    = (qw(Exporter));
@EXPORT = qw(is_test random_string get_data_section env);

sub is_test {
    if ($ENV{HARNESS_ACTIVE} || $0 =~ m{prove}) {
        return 1;
    }
    return 0;
}
sub env { return $ENV{${\shift}} }

1;
