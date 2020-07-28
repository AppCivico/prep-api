use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Prep::Test;

use JSON;

my $t      = test_instance;
my $schema = $t->app->schema;

plan skip_all => "skip for now";

db_transaction {
    my $security_token = $ENV{CHATBOT_SECURITY_TOKEN};

    my ($recipient_id, $recipient);
    subtest 'Chatbot | Create recipient' => sub {
        $t->post_ok(
            '/api/chatbot/recipient',
            form => {
                security_token => $security_token,
                name           => 'foobar',
                page_id        => '1573221416102831',
                fb_id          => '111111'
            }
        )
        ->status_is(201);

        $recipient_id = $t->tx->res->json->{id};
        $recipient    = $schema->resultset('Recipient')->find($recipient_id);
    };

    subtest 'Internal | Create question map' => sub {
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
    };

    subtest 'Chatbot | term signature' => sub {
        $t->post_ok(
            '/api/chatbot/recipient/research-participation',
            form => {
                security_token => $security_token,
                fb_id          => '111111'
            }
        )
        ->status_is(400)
        ->json_is('/error', 'form_error')
        ->json_is('/form_error/is_part_of_research', 'missing');


        # O recipient deve ser do grupo de interesse e elegível para poder concordar com a participação
        $t->post_ok(
            '/api/chatbot/recipient/research-participation',
            form => {
                is_part_of_research => 1,
                security_token      => $security_token,
                fb_id               => '111111'
            }
        )
        ->status_is(400);

        ok( $recipient->recipient_flag->update( { is_target_audience => 1, is_eligible_for_research => 1 } ), 'updating flags' );
        is( $recipient->is_part_of_research, 0, 'recipient is not part of the research');

        $t->post_ok(
            '/api/chatbot/recipient/research-participation',
            form => {
                is_part_of_research => 1,
                security_token      => $security_token,
                fb_id               => '111111'
            }
        )
        ->status_is(200);

        ok( $recipient = $recipient->discard_changes, 'discard_changes' );
        is( $recipient->is_part_of_research, 1, 'recipient is now part of the research');

        $t->post_ok(
            '/api/chatbot/recipient/research-participation',
            form => {
                is_part_of_research => 0,
                security_token      => $security_token,
                fb_id               => '111111'
            }
        )
        ->status_is(200);

        ok( $recipient = $recipient->discard_changes, 'discard_changes' );
        is( $recipient->is_part_of_research, 0, 'recipient is no longer part of the research');
    };
};

done_testing();
