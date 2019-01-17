package Prep::Types;
use common::sense;

use MooseX::Types -declare => [
    qw( URI )
];

use Data::Validate::URI qw(is_uri);
use MooseX::Types::Moose qw(Str Int ArrayRef ScalarRef Num);

subtype URI, as Str, where {
    my $uri = $_;

    return is_uri($uri);
};

1;
