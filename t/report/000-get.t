use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Prep::Test;

my $t      = test_instance;
my $schema = $t->app->schema;

use JSON;

db_transaction {
	my $security_token = $ENV{REPORT_SECURITY_TOKEN};

    my $res = $t->get_ok("/api/report/interaction")
      ->status_is(400)
      ->json_is('/form_error/security_token', 'missing')
      ->tx->res->json;

    $res = $t->get_ok(
        "/api/report/interaction?security_token=wrong_st",
    )
    ->status_is(400)
    ->json_is('/form_error/security_token', 'invalid')
    ->tx->res->json;

    $res = $t->get_ok(
        "/api/report/interaction?security_token=$security_token",
    )
    ->status_is(200)
    ->json_has('/metrics')
    ->json_has('/metrics/0/value')
    ->json_has('/metrics/0/label')
    ->tx->res->json;

    use DDP; p $res;
};

done_testing();