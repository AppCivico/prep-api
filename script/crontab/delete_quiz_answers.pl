#!/usr/bin/env perl
use common::sense;
use Minion;
use JSON;
use Moose;

use Prep::SchemaConnected qw(get_schema);

my $schema = get_schema();

my @ids = $schema->resultset('ViewQuizReset')->get_column('recipient_id')->all();

for my $recipient_id (@ids) {
    my $recipient = $schema->resultset('Recipient')->find($recipient_id);

    $recipient->answers->search(
        { 'question_map.category_id' => 1 },
        { prefetch => 'question_map' }
    )->delete;

    $recipient->recipient_flag->update(
        {
            is_target_audience       => undef,
            is_eligible_for_research => undef,
            finished_quiz            => 0
        }
    );
}

1;
