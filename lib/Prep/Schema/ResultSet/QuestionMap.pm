package Prep::Schema::ResultSet::QuestionMap;
use common::sense;
use Moose;
use namespace::autoclean;

extends "DBIx::Class::ResultSet";

sub parsed {
    my ($self) = @_;

    my $map = $self->search(undef)->next;

    return $map->parsed;
}

1;

