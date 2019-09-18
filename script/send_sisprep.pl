#!/usr/bin/env perl
use common::sense;
use Moose;

use Prep::SchemaConnected qw(get_schema);

my $schema       = get_schema();
my $recipient_rs = $schema->resultset('Recipient');

my @fb_ids = qw();

for my $fb_id (@fb_ids) {
    my $recipient = $recipient_rs->search( { 'me.fb_id' => $fb_id } )->next;
    die 'could not find recipient for fb_id=' . $fb_id unless $recipient;

    $recipient->register_simprep;
}

1;
