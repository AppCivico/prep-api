package Prep::Types;
use common::sense;

use MooseX::Types -declare => [
    qw( URI )
];

use Data::Validate::URI qw(is_uri);

subtype URI, as Str, where {
    my $uri = $_;

    return is_uri($uri);
};

1;
