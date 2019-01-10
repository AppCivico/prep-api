package Prep::Test;

use Test::More;
use Test::Mojo;
use Data::Printer;

use Mojo::Util qw(monkey_patch);

monkey_patch 'Test::Mojo', or_die => sub {
	my $t = shift;

	if (!$t->success()) {
		my (undef, $file, $line) = caller;

		p $t->tx->res->to_string;
		BAIL_OUT("Fail at line $line in $file.");
	}
};


sub import {
	strict->import;
	warnings->import;

	no strict 'refs';

	my $caller = caller;

	while (my ($name, $symbol) = each %{__PACKAGE__ . '::'}) {
		next if $name eq 'BEGIN';
		next if $name eq 'import';
		next unless *{$symbol}{CODE};

		my $imported = $caller . '::' . $name;
		*{$imported} = \*{$symbol};
	}
}

my $t = Test::Mojo->new('Prep');

sub test_instance { $t }

sub get_schema { app()->schema }

sub app { $t->app }

sub db_transaction (&) {
	my ($code) = @_;

	my $schema = get_schema;
	eval {
		$schema->txn_do(
			sub {
				$code->();
				die 'rollback';
			}
		);
	};
	die $@ unless $@ =~ m{rollback};
}

1;