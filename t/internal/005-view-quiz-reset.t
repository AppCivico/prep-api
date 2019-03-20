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
    subtest 'Create questions and question map' => sub {
        my $question_rs = $schema->resultset('Question');

        ok(
            $question_map = $schema->resultset('QuestionMap')->create(
                {
                    map => encode_json ({
                        1 => 'Q1',
                        2 => 'E4',
                        3 => 'W1',
                        4 => 'Q3'
                    }),
                    category_id => 1
                }
            ),
            'question map created'
        );

        ok(
            $first_question = $question_rs->create(
                {
                    code              => 'Q1',
                    text              => 'Foobar?',
                    type              => 'multiple_choice',
                    question_map_id   => $question_map->id,
                    is_differentiator => 0,
                    multiple_choices  => encode_json ({ 1 => 'foo', 2 => 'bar' })
                }
            ),
            'first question'
        );

        ok(
            $second_question = $question_rs->create(
                {
                    code              => 'Q3',
                    text              => 'open_text?',
                    type              => 'open_text',
                    question_map_id   => $question_map->id,
                    is_differentiator => 0
                }
            ),
            'second question'
        );

        ok(
            $third_question = $question_rs->create(
                {
                    code              => 'W1',
                    text              => 'Você gosta?',
                    type              => 'multiple_choice',
                    question_map_id   => $question_map->id,
                    is_differentiator => 1,
                    multiple_choices  => encode_json ({ 1 => 'Sim', 2 => 'Não' })
                }
            ),
            'third question'
        );

        ok(
            $fourth_question = $question_rs->create(
                {
                    code                => 'E4',
                    text                => 'barbaz?',
                    type                => 'multiple_choice',
                    question_map_id     => $question_map->id,
                    is_differentiator   => 0,
                    multiple_choices    => encode_json ({ 1 => 'Sim', 2 => 'Nunca', 3 => 'Regularmente' }),
                    extra_quick_replies => encode_json ({
                        label   => 'foo',
                        text    => 'bar bar',
                        payload => 'foobar'
                    })
                }
            ),
            'fourth question'
        );
    };

    my $fb_id = '710488549074724';
    my ($recipient_id, $recipient);
    subtest 'Chatbot | Create recipient' => sub {
        $t->post_ok(
            '/api/chatbot/recipient',
            form => {
                security_token => $security_token,
                name           => 'foobar',
                page_id        => '1573221416102831',
                fb_id          => $fb_id
            }
        )
        ->status_is(201);

        $recipient_id = $t->tx->res->json->{id};
        $recipient    = $schema->resultset('Recipient')->find($recipient_id);
    };

    subtest 'Chatbot | Create one answer' => sub {
        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'Q1',
                category       => 'quiz',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_has('/id');

        ok( my $answer = $schema->resultset('Answer')->find( $t->tx->res->json->{id} ), 'answer' );

        # Atualizando horario da resposta para 3 meses atrás
        $answer->update( { created_at => \"NOW() - interval '3 months'" } );
    };

    subtest 'Internal | Test view' => sub {
        # Testando se a view está funcionando corretamente
        # A view deve retornar apenas recipients que são do público de interesse
        # E não são elegíveis para a pesquisa.

        my $rs = $schema->resultset('ViewQuizReset');

        is( $rs->count, 0, 'no recipients' );

        # Testando booleans e timestamps
        subtest 'Booleans and timestamps' => sub {

            db_transaction {
                ok($recipient->recipient_flag->update( { is_target_audience => 1, is_eligible_for_research => 0 } ), 'flags update');
                is($rs->count, 1, 'one recipient');
            };
        };
    }
};

done_testing();
