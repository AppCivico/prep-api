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
                        2 => 'E4'
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
                    question_map_id   => $question_map->id,
                    type              => 'open_text',
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

    subtest 'Chatbot | Create answer' => sub {
        # Code inválido
        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'foobar',
                category       => 'quiz',
                answer_value   => '1'
            }
        )
        ->status_is(400)
        ->json_has('/form_error/code')
        ->json_is('/form_error/code', 'invalid');

        # answer_value com texto livre sendo que a pergunta é de multipla escolha
        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'Q1',
                category       => 'quiz',
                answer_value   => 'foobar'
            }
        )
        ->status_is(400)
        ->json_has('/form_error/answer_value')
        ->json_is('/form_error/answer_value', 'invalid');

        # answer_value com alternativa inexistente
        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'Q1',
                category       => 'quiz',
                answer_value   => '10'
            }
        )
        ->status_is(400)
        ->json_has('/form_error/answer_value')
        ->json_is('/form_error/answer_value', 'invalid');

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
        ->json_has('/id')
        ->json_has('/finished_quiz')
        ->json_is('/finished_quiz', 0);

        # Pergunta ja respondida
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
        ->status_is(400)
        ->json_has('/form_error/code')
        ->json_is('/form_error/code', 'invalid');

        # Essa foi a última pergunta do quiz, logo o boolean na tabela recipient
        # deve estar preenchido com true
        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'E4',
                category       => 'quiz',
                answer_value   => '3'
            }
        )
        ->status_is(201)
        ->json_has('/id')
        ->json_has('/finished_quiz')
        ->json_is('/finished_quiz', 1);

        ok( $recipient = $recipient->discard_changes, 'discard changes' );
        is( $recipient->finished_quiz, 1, 'quiz is answered' );
    };
};

done_testing();
