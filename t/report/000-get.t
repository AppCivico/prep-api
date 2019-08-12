use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Prep::Test;

my $t      = test_instance;
my $schema = $t->app->schema;

use JSON;

db_transaction {
    # Criando question map
    $t->get_ok('/api/report')->status_is(200);
};

done_testing();