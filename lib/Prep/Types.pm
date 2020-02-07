package Prep::Types;
use common::sense;

use MooseX::Types -declare => [
    qw( URI MobileNumber )
];

use Data::Validate::URI qw(is_uri);
use MooseX::Types::Moose qw(Str Int ArrayRef ScalarRef Num);

my $is_international_mobile_number = sub {
    my $num = shift;
    return $num =~ /^\+\d{12,13}$/ ? 1 : 0 if $num =~ /\+55/;

    return $num =~ /^\+\d{10,16}$/ ? 1 : 0;
};

subtype URI, as Str, where {
    my $uri = $_;

    return is_uri($uri);
};

my $is_mobile_number = sub {
    my $num = shift;

    return $num =~ /^\+\d{12,13}$/ ? 1 : 0 if $num =~ /\+55/;
    return $num =~ /^\+\d{10,16}$/ ? 1 : 0;
};

subtype MobileNumber, as Str, where { $is_mobile_number->($_) }, message { "$_ phone number invalido" };

1;
