use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Prep::Test;

my $t      = test_instance;
my $schema = $t->app->schema;

use JSON;

db_transaction {
	my $security_token = $ENV{REPORT_SECURITY_TOKEN};

    # Criando question map
    $t->get_ok("/api/report?security_token=$security_token")->status_is(200);
};

done_testing();