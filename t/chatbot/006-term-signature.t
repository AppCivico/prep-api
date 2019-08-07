use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Prep::Test;

use JSON;

my $t      = test_instance;
my $schema = $t->app->schema;

db_transaction {
    my $security_token = $ENV{CHATBOT_SECURITY_TOKEN};

    my ($recipient_id, $recipient, $fb_id);
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
        $fb_id        = $recipient->fb_id;
    };

    my $question_map;
    subtest 'Create questions and question map' => sub {
        my $question_rs = $schema->resultset('Question');

        ok(
            $question_map = $schema->resultset('QuestionMap')->create(
                {
                    map => to_json({
                        "1"  => "A1",
                        "2"  => "A2",
                        "3"  => "A3",
                        "4"  => "A4",
                        "5"  => "A4a",
                        "6"  => "A4b",
                        "7"  => "A5",
                        "8"  => "A6",
                        "9"  => "AC1",
                        "10" => "AC2",
                        "11" => "AC3",
                        "12" => "AC4",
                        "13" => "AC5",
                        "14" => "AC6",
                        "15" => "AC7",
                        "16" => "AC8",
                        "17" => "B1",
                        "18" => "B2",
                        "19" => "B3",
                        "20" => "B4",
                        "21" => "B5",
                        "22" => "B6",
                        "23" => "B7",
                        "24" => "B8",
                        "25" => "B9",
                        "26" => "B10",
                    }),
                    category_id => 1
                }
            ),
            'question map created'
        );

        # Criando as perguntas do AppCivico que não são importantes
        # para o resultado final
        for ( 1 .. 8 ) {
            ok(
                $question_rs->create(
                    {
                        code              => 'AC' . $_,
                        text              => 'Foobar?',
                        question_map_id   => $question_map->id,
                        type              => 'multiple_choice',
                        is_differentiator => 0,
                        multiple_choices  => to_json(
                            {
                                1 => 'foo',
                                2 => 'bar',
                                3 => 'baz',
                                4 => 'foobar',
                                5 => 'barbaz',
                                6 => 'FOOBAR'
                            }
                        )
                    }
                )
            );
        }

        # Atualizando as regras da primeira pergunta do AppCivico
        my $question = $schema->resultset('Question')->search( { 'me.code' => 'AC1' } )->next;
        ok $question->update(
            {
                rules => to_json(
                    {
                        "logic_jumps" => [{"code" => "AC2","values" => [1]},{"code" => "AC8","values" => [2]}],"qualification_conditions" => [],"flags" => []
                    }
                )
            }
        );

        # Atualizando as regras das perguntas AC2 até AC6 para adicionar scores
        for ( 2 .. 7 ) {
            ok $question = $schema->resultset('Question')->search( { 'me.code' => 'AC' . $_ } )->next;
            ok $question->update(
                {
                    rules => to_json(
                        {
                            "multiple_choice_score_map" => {
                                1 => 0,
                                2 => 10,
                                3 => 20,
                                4 => 30,
                                5 => 40,
                                6 => 50
                            }
                        }
                    )
                }
            )
        }

        # Perguntas da parte B
        subtest 'Creating B section questions' => sub {
            ok(
                $question_rs->create(
                    {
                        code              => 'B1',
                        text              => 'Nos últimos doze meses, você teve relações sexuais com algum parceiro (homem ou mulher transexual ou travesti) que você considera fixo?',
                        type              => 'multiple_choice',
                        question_map_id   => $question_map->id,
                        is_differentiator => 1,
                        multiple_choices  => to_json(
                            {
                                1 => "Sim",
                                2 => "Não"
                            }
                        ),
                        rules => to_json(
                            {
                                logic_jumps => [
                                    {
                                        code   => 'B2',
                                        values => ['1']
                                    }
                                ],
                                qualification_conditions => [],
                            }
                        )
                    }
                )
            );

            ok(
                $question_rs->create(
                    {
                        code              => 'B2',
                        text              => 'Você sabe o resultado do teste de HIV desse seu parceiro fixo?',
                        type              => 'multiple_choice',
                        question_map_id   => $question_map->id,
                        is_differentiator => 1,
                        multiple_choices  => to_json(
                            {
                                1 => 'Sim, é negativo',
                                2 => 'Sim, é positivo',
                                3 => 'Ele nunca se testou',
                                4 => 'Não sei'
                            }
                        ),
                        rules => to_json(
                            {
                                logic_jumps => [],
                                qualification_conditions => [],
                            }
                        )
                    }
                )
            );

            ok(
                $question_rs->create(
                    {
                        code              => 'B3',
                        text              => 'Considerando só seus parceiros homens: nos últimos doze meses, quantos parceiros casuais você teve?',
                        type              => 'open_text',
                        question_map_id   => $question_map->id,
                        is_differentiator => 1,
                        rules => to_json(
                            {
                                logic_jumps => [
                                    {
                                        code   => 'B4',
                                        values => {
                                            operator => '>',
                                            value    => '0'
                                        }
                                    }
                                ],
                                qualification_conditions => [],
                            }
                        )
                    }
                )
            );

            ok(
                $question_rs->create(
                    {
                        code              => 'B4',
                        text              => 'Você sabe o resultado do teste de HIV desse seu parceiro fixo?',
                        type              => 'multiple_choice',
                        question_map_id   => $question_map->id,
                        is_differentiator => 1,
                        multiple_choices  => to_json(
                            {
                                1 => "Sim",
                                2 => "Não"
                            }
                        ),
                        rules => to_json(
                            {
                                logic_jumps => [
                                    {
                                        code   => 'B5',
                                        values => ['1']
                                    }
                                ],
                                qualification_conditions => [],
                            }
                        )
                    }
                )
            );

            ok(
                $question_rs->create(
                    {
                        code              => 'B5',
                        text              => 'Você sabe o resultado do teste de HIV desse seu parceiro fixo?',
                        type              => 'multiple_choice',
                        question_map_id   => $question_map->id,
                        is_differentiator => 1,
                        multiple_choices  => to_json(
                            {
                                1 => "Sim",
                                2 => "Não"
                            }
                        ),
                        rules => to_json(
                            {
                                logic_jumps => [],
                                qualification_conditions => [],
                            }
                        )
                    }
                )
            );

            ok(
                $question_rs->create(
                    {
                        code              => 'B6',
                        text              => 'Nos últimos doze meses, alguma vez você recebeu dinheiro, presentes ou favores para fazer sexo?',
                        type              => 'multiple_choice',
                        question_map_id   => $question_map->id,
                        is_differentiator => 1,
                        multiple_choices  => to_json(
                            {
                                1 => "Sim",
                                2 => "Não"
                            }
                        ),
                        rules => to_json(
                            {
                                logic_jumps => [],
                                qualification_conditions => [],
                            }
                        )
                    }
                )
            );

            ok(
                $question_rs->create(
                    {
                        code              => 'B7',
                        text              => 'Nos últimos doze meses, alguma vez você recebeu dinheiro, presentes ou favores para fazer sexo?',
                        type              => 'multiple_choice',
                        question_map_id   => $question_map->id,
                        is_differentiator => 1,
                        multiple_choices  => to_json(
                            {
                                1 => "Uma vez",
                                2 => "De 2 a 4 vezes",
                                3 => "5 vezes ou mais",
                                4 => "Nenhuma vez"
                            }
                        ),
                        rules => to_json(
                            {
                                logic_jumps => [],
                                qualification_conditions => [],
                            }
                        )
                    }
                )
            );

            ok(
                $question_rs->create(
                    {
                        code              => 'B8',
                        text              => 'Nos últimos doze meses, alguma vez você recebeu dinheiro, presentes ou favores para fazer sexo?',
                        type              => 'multiple_choice',
                        question_map_id   => $question_map->id,
                        is_differentiator => 1,
                        multiple_choices  => to_json(
                            {
                                1 => "Sim",
                                2 => "Não"
                            }
                        ),
                        rules => to_json(
                            {
                                logic_jumps => [],
                                qualification_conditions => [],
                            }
                        )
                    }
                )
            );

            ok(
                $question_rs->create(
                    {
                        code              => 'B9',
                        text              => 'Nos últimos doze meses, alguma vez você recebeu dinheiro, presentes ou favores para fazer sexo?',
                        type              => 'multiple_choice',
                        question_map_id   => $question_map->id,
                        is_differentiator => 1,
                        multiple_choices  => to_json(
                            {
                                1 => "Sim",
                                2 => "Não"
                            }
                        ),
                        rules => to_json(
                            {
                                logic_jumps => [],
                                qualification_conditions => [],
                            }
                        )
                    }
                )
            );

            ok(
                $question_rs->create(
                    {
                        code              => 'B10',
                        text              => 'Nos últimos doze meses, alguma vez você recebeu dinheiro, presentes ou favores para fazer sexo?',
                        type              => 'multiple_choice',
                        question_map_id   => $question_map->id,
                        is_differentiator => 1,
                        multiple_choices  => to_json(
                            {
                                1 => "Sim, já ouvi falar",
                                2 => "Não, nunca ouvi falar"
                            }
                        ),
                        rules => to_json(
                            {
                                logic_jumps => [],
                                qualification_conditions => [ 'is_eligible_for_research' ],
                                flags => [ 'is_eligible_for_research' ]
                            }
                        )
                    }
                )
            );
        };


        # Perguntas da parte A
        subtest 'Creating A section questions' => sub {
            ok(
                $question_rs->create(
                    {
                        code              => 'A2',
                        text              => 'Qual é a sua idade?',
                        type              => 'open_text',
                        question_map_id   => $question_map->id,
                        is_differentiator => 1,
                        rules             => to_json(
                            {
                                logic_jumps => [],
                                qualification_conditions => ['15','16','17','18','19'],
                                flags => [ 'is_target_audience' ]
                            }
                        )
                    }
                )
            );

            ok(
                $question_rs->create(
                    {
                        code              => 'A6',
                        text              => 'Nos últimos doze meses, você teve relações sexuais com homens ou com mulheres transexuais ou com travestis?',
                        type              => 'multiple_choice',
                        question_map_id   => $question_map->id,
                        is_differentiator => 1,
                        multiple_choices  => to_json(
                            {
                                1 => "Sim",
                                2 => "Não"
                            }
                        ),
                        rules => to_json(
                            {
                                logic_jumps => [],
                                qualification_conditions => ['1'],
                                flags => [ 'is_target_audience' ]
                            }
                        )
                    }
                )
            );

            ok(
                $question_rs->create(
                    {
                        code              => 'A3',
                        text              => 'Você se considera: ',
                        question_map_id   => $question_map->id,
                        type              => 'multiple_choice',
                        is_differentiator => 1,
                        multiple_choices  => to_json(
                            {
                                1 => "Mulher transexual",
                                2 => "Mulher cisgênero",
                                3 => "Homem transexual",
                                4 => "Homem cisgênero",
                                5 => "Travesti"
                            }
                        ),
                        rules => to_json(
                            {
                                logic_jumps => [],
                                qualification_conditions => ['1','4','5'],
                                flags => [ 'is_target_audience' ]
                            }
                        )
                    }
                )
            );

            ok(
                $question_rs->create(
                    {
                        code              => 'A1',
                        text              => 'Em q cidade vc está?',
                        question_map_id   => $question_map->id,
                        type              => 'multiple_choice',
                        is_differentiator => 1,
                        multiple_choices  => to_json(
                            {
                                1 => "SP",
                                2 => "MG",
                                3 => "BA",
                                4 => "Nenhuma"
                            }
                        ),
                        rules => to_json(
                            {
                                logic_jumps => [],
                                qualification_conditions => ['1','2','3'],
                                flags => [ 'is_target_audience' ]
                            }
                        )
                    }
                )
            );

            ok(
                $question_rs->create(
                    {
                        code              => 'A4',
                        text              => 'Que série da escola você está cursando? (Caso não esteja estudando, responda a série na qual você parou de estudar)?',
                        question_map_id   => $question_map->id,
                        type              => 'multiple_choice',
                        is_differentiator => 1,
                        multiple_choices  => to_json(
                            {
                                1 => "Ensino Fundamental",
                                2 => "Ensino Médio",
                                3 => "Ensino Superior"
                            }
                        ),
                        rules => to_json(
                            {
                                logic_jumps => [
                                    {
                                        code   => 'A4a',
                                        values => ['1']
                                    },
                                    {
                                        code   => 'A4b',
                                        values => ['2']
                                    }
                                ],
                                qualification_conditions => [],
                            }
                        )
                    }
                )
            );

            ok(
                $question_rs->create(
                    {
                        code              => 'A4a',
                        text              => 'Que série?',
                        question_map_id   => $question_map->id,
                        type              => 'multiple_choice',
                        is_differentiator => 1,
                        multiple_choices  => to_json(
                            {
                                1 => '1º ano E.Fundamental',
                                2 => '2º ano E.Fundamental',
                                3 => '3º ano E.Fundamental',
                                4 => '4º ano E.Fundamental',
                                5 => '5º ano E.Fundamental',
                                6 => '6º ano E.Fundamental',
                                7 => '7º ano E.Fundamental',
                                8 => '8º ano E.Fundamental',
                                9 => '9º ano E.Fundamental'
                            }
                        )
                    }
                )
            );

            ok(
                $question_rs->create(
                    {
                        code              => 'A4b',
                        text              => 'Que série?',
                        question_map_id   => $question_map->id,
                        type              => 'multiple_choice',
                        is_differentiator => 1,
                        multiple_choices  => to_json(
                            {
                                1 => '1º ano E.Médio',
                                2 => '2º ano E.Médio',
                                3 => '3º ano E.Médio',
                            }
                        )
                    }
                )
            );

            ok(
                $question_rs->create(
                    {
                        code              => 'A5',
                        text              => 'Que série?',
                        question_map_id   => $question_map->id,
                        type              => 'multiple_choice',
                        is_differentiator => 1,
                        multiple_choices  => to_json(
                            {
                                1 => '1º ano E.Médio',
                                2 => '2º ano E.Médio',
                                3 => '3º ano E.Médio',
                            }
                        )
                    }
                )
            );
        };
    };

    subtest 'Chatbot | Answers' => sub {
        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'A1');

        db_transaction {
            $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'A1',
                    category       => 'quiz',
                    answer_value   => '4'
                }
            )
            ->status_is(201)
            ->json_is('/finished_quiz', 1)
            ->json_is('/is_target_audience', 0);
        };

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'A1',
                category       => 'quiz',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'A2');

        db_transaction{
            $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'A2',
                    category       => 'quiz',
                    answer_value   => '12'
                }
            )
            ->status_is(201)
            ->json_is('/finished_quiz', 1)
            ->json_is('/is_target_audience', 0);
        };

        db_transaction{
            $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'A2',
                    category       => 'quiz',
                    answer_value   => '20'
                }
            )
            ->status_is(201)
            ->json_is('/finished_quiz', 1)
            ->json_is('/is_target_audience', 0);
        };

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'A2',
                category       => 'quiz',
                answer_value   => '18'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'A3');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'A3',
                category       => 'quiz',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'A4');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'A4',
                category       => 'quiz',
                answer_value   => '3'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'A5');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'A5',
                category       => 'quiz',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'A6');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'A6',
                category       => 'quiz',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'AC1');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'AC1',
                category       => 'quiz',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'AC2');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'AC2',
                category       => 'quiz',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'AC3');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'AC3',
                category       => 'quiz',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'AC4');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'AC4',
                category       => 'quiz',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'AC5');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'AC5',
                category       => 'quiz',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'AC6');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'AC6',
                category       => 'quiz',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'AC7');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'AC7',
                category       => 'quiz',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'AC8');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'AC8',
                category       => 'quiz',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'B1');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'B1',
                category       => 'quiz',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'B2');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'B2',
                category       => 'quiz',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'B3');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'B3',
                category       => 'quiz',
                answer_value   => '2'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz',
            }
        )
        ->status_is(200)
        ->json_is('/code', 'B4');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'B4',
                category       => 'quiz',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'B5');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'B5',
                category       => 'quiz',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'B6');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'B6',
                category       => 'quiz',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'B7');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'B7',
                category       => 'quiz',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'B8');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'B8',
                category       => 'quiz',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                category       => 'quiz',
                fb_id          => $fb_id
            }
        )
        ->status_is(200)
        ->json_is('/code', 'B9');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'B9',
                category       => 'quiz',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'B10');

        ok( my $recipient = $schema->resultset('Recipient')->find($recipient_id), 'recipient' );

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'B10',
                category       => 'quiz',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 1)
        ->json_is('/is_eligible_for_research', 1);

        ok( $recipient = $recipient->discard_changes, 'recipient discard changes' );
    };

    db_transaction {
        subtest 'Chatbot | term signature' => sub {
            is $recipient->integration_token, undef;
            is $recipient->recipient_flag->is_part_of_research, 0;

            $t->post_ok(
                '/api/chatbot/recipient/term-signature',
                form => {
                    security_token => $security_token,
                    fb_id          => '111111',
                    url            => 'https://www.google.com',
                    signed         => 0
                }
            )
            ->status_is(201);

            ok $recipient = $recipient->discard_changes;
            ok defined $recipient->integration_token;
            is $recipient->recipient_flag->is_part_of_research, 0;
        }
    };

    subtest 'Chatbot | term signature' => sub {
        ok $recipient = $recipient->discard_changes;
        is $recipient->recipient_flag->is_part_of_research, 0;

        $t->post_ok(
            '/api/chatbot/recipient/term-signature',
            form => {
                security_token => $security_token,
                fb_id          => '111111',
                url            => 'https://www.google.com',
                signed         => 1
            }
        )
        ->status_is(201);

        ok $recipient = $recipient->discard_changes;
        is $recipient->recipient_flag->is_part_of_research, 1;
    };
};

done_testing();