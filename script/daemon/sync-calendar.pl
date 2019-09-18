#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use FindBin qw($Bin);
use lib "$Bin/../../lib";

use Prep::TrapSignals;
use Prep::Logger qw(get_logger);
use Prep::SchemaConnected;
use Prep::Worker::Notify;

my $logger = get_logger();
my $schema = get_schema( pg_advisory_lock => 1 );

my $calendar_rs = $schema->resultset('Calendar');


while (1) {
    sleep 3600;
    eval {
        while ( my $calendar = $calendar_rs->next() ) {
            $calendar->sync_appointments;
        }
    };
    if ($@) {
        print STDERR time . " - fatal error on $0: $@";
        ON_TERM_EXIT;
        EXIT_IF_ASKED;
        sleep 5;
    }
}

