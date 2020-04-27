use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Prep::Test;

use JSON;

my $t      = test_instance;
my $schema = $t->app->schema;

db_transaction {
    my $security_token = $ENV{CHATBOT_SECURITY_TOKEN};

    my( $first_question, $second_question, $third_question, $fourth_question, $question_map );
    subtest 'Populate vouchers table' => sub {
        my $rs = $schema->resultset('CombinaVoucher');

        for (1 .. 5) {
            ok $rs->create( { value => 'fake_voucher_' . $_ } );
        }
    };

    subtest 'Internal | Test GET available vouchers' => sub {
        my $internal_security_token = 'foo';

        my $res = $t->get_ok(
            '/api/internal/available-combina-vouchers',
            form => { security_token => $internal_security_token }
        )
        ->status_is(200)
        ->tx->res->json;

        is ref $res->{available_combina_vouchers}, 'ARRAY';
        is scalar @{$res->{available_combina_vouchers}}, 5;
    }
};

done_testing();
