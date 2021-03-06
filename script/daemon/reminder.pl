#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use FindBin qw($Bin);
use lib "$Bin/../../lib";

use Prep::TrapSignals;
use Prep::Logger qw(get_logger);
use Prep::SchemaConnected;
use Prep::Worker::PrepReminder;

my $logger = get_logger();
my $schema = get_schema( pg_advisory_lock => 1 );

my $daemon = Prep::Worker::PrepReminder->new( schema => $schema, max_process => 1 );

while (1) {
    eval { $daemon->listen_queue; };
    if ($@) {
        print STDERR time . " - fatal error on $0: $@";
        ON_TERM_EXIT;
        EXIT_IF_ASKED;
        sleep 5;
    }
}

