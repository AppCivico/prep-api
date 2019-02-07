use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Prep::Test;

my $t      = test_instance;
my $schema = $t->app->schema;

use JSON;

db_transaction {
    # Criando question map
    ok(
        my $question_map = $schema->resultset('QuestionMap')->create(
            {
                map => encode_json({
                    1 => 'A1',
                    2 => 'A3',
                    3 => 'B4',
                    4 => 'C5'
                }),
                category_id => 1
            }
        ),
        'question map created'
    );

    ok(
        my $parsed_question_map = $question_map->parsed,
        'question_map parsed'
    );
};

done_testing();