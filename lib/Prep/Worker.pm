package Prep::Worker;
use Moose::Role;

has logger => (
    is       => 'rw',
    required => 1,
    isa      => 'Any',
);

requires qw(run_once listen_queue);

1;
