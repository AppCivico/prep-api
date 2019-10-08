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
                    map => to_json({
                        1 => 'Z1',
                        2 => 'U4',
                        3 => 'Y5',
                    }),
                    category_id => 1
                    }
            ),
            'question map created'
        );

        ok(
            $first_question = $question_rs->create(
                {
                    code              => 'Z1',
                    text              => 'Foobar?',
                    type              => 'multiple_choice',
                    question_map_id   => $question_map->id,
                    is_differentiator => 0,
                    multiple_choices  => to_json ({ 1 => 'foo', 2 => 'bar' })
                }
            ),
            'first question'
        );

        ok(
            $second_question = $question_rs->create(
                {
                    code              => 'Y5',
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
                    code              => 'B1',
                    text              => 'Você gosta?',
                    type              => 'multiple_choice',
                    question_map_id   => $question_map->id,
                    is_differentiator => 1,
                    multiple_choices  => to_json ({ 1 => 'Sim', 2 => 'Não' })
                }
            ),
            'third question'
        );

        ok(
            $fourth_question = $question_rs->create(
                {
                    code                => 'U4',
                    text                => 'barbaz?',
                    type                => 'multiple_choice',
                    question_map_id     => $question_map->id,
                    is_differentiator   => 0,
                    multiple_choices    => to_json ({ 1 => 'Sim', 2 => 'Nunca', 3 => 'Regularmente' }),
                    extra_quick_replies => to_json ({
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
    my $recipient_id;
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
    };

    subtest 'Chatbot | Get pending question' => sub {
        # Sem fb_id
        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => { security_token => $security_token }
        )
        ->status_is(400)
        ->json_has('/form_error/fb_id')
        ->json_is('/form_error/fb_id', 'missing');

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_has('/code')
        ->json_has('/text')
        ->json_has('/type')
        ->json_has('/extra_quick_replies')
        ->json_has('/multiple_choices')
        ->json_is('/code', 'Z1')
        ->json_is('/text', 'Foobar?')
        ->json_is('/type', 'multiple_choice')
        ->json_is('/multiple_choices/1', 'foo')
        ->json_is('/multiple_choices/2', 'bar');

        # Repetindo a requisição obtenho o mesmo resultado
        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_has('/code')
        ->json_has('/text')
        ->json_has('/type')
        ->json_has('/extra_quick_replies')
        ->json_has('/multiple_choices')
        ->json_is('/code', 'Z1')
        ->json_is('/text', 'Foobar?')
        ->json_is('/type', 'multiple_choice')
        ->json_is('/multiple_choices/1', 'foo')
        ->json_is('/multiple_choices/2', 'bar');

        # Respondendo primeira pergunta
        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'Z1',
                category       => 'quiz',
                answer_value   => '1'
            }
        )
        ->status_is(201);

        # A pergunta esperada agora é a U4
        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_has('/code')
        ->json_has('/text')
        ->json_has('/type')
        ->json_has('/extra_quick_replies')
        ->json_has('/multiple_choices')
        ->json_has('/has_more')
        ->json_has('/count_more')
        ->json_is('/has_more', 1)
        ->json_is('/count_more', 1)
        ->json_is('/code', 'U4')
        ->json_is('/text', 'barbaz?')
        ->json_is('/type', 'multiple_choice')
        ->json_is('/multiple_choices/1', 'Sim')
        ->json_is('/multiple_choices/2', 'Nunca')
        ->json_is('/multiple_choices/3', 'Regularmente');

        # Respondendo a segunda pergunta
        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'U4',
                category       => 'quiz',
                answer_value   => '1'
            }
        )
        ->status_is(201);

        # A pergunta esperada agora é a última Y5
        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'Y5');

        # Respondendo a última pergunta
        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'Y5',
                category       => 'quiz',
                answer_value   => 'FOObar'
            }
        )
        ->status_is(201);

        # Não deve vir nenhuma pergunta e o has_more deve ser 0
        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'quiz'
            }
        )
        ->status_is(200)
        ->json_has('/code')
        ->json_has('/text')
        ->json_has('/type')
        ->json_has('/extra_quick_replies')
        ->json_has('/multiple_choices')
        ->json_has('/has_more')
        ->json_is('/has_more', 0)
        ->json_is('/code', undef)
        ->json_is('/text', undef)
        ->json_is('/type', undef);
    };

    # TODO testar quando houver atualização no fluxo
};

# Testando com fluxo real
db_transaction{
    my $security_token = $ENV{CHATBOT_SECURITY_TOKEN};

    my $question_map;
    subtest 'Create questions and question map' => sub {
        my $question_rs = $schema->resultset('Question');

        ok(
            $question_map = $schema->resultset('QuestionMap')->create(
                {
                    map => to_json(
                        {
                            "1" => "A1",
                            "2" => "A2",
                            "3" => "A3",
                            "4" => "A4",
                            "5" => "A4a",
                            "6" => "A4b",
                            "7" => "A5",
                            "8" => "A6",
                            "9" => "A6a",
                            "10" => "AC1",
                            "11" => "AC2",
                            "12" => "AC3",
                            "13" => "AC4",
                            "14" => "AC5",
                            "15" => "AC6",
                            "16" => "AC7",
                            "17" => "AC8",
                            "18" => "B1",
                            "19" => "B2",
                            "20" => "B3",
                            "21" => "B4",
                            "22" => "B5",
                            "23" => "B6",
                            "24" => "B7",
                            "25" => "B8",
                            "26" => "B9",
                            "27" => "B10",
                            "28" => "AC9"
                        }
                    ),
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

        ok $question_rs->create(
            {
                code            => 'AC9',
                text            => 'bar?',
                question_map_id => $question_map->id,
                type            => 'multiple_choice',
                is_differentiator => 0,
                multiple_choices => to_json(
                    {
                        1 => 'Sim',
                        2 => 'Não'
                    }
                ),
                rules => to_json(
                    {
                        "logic_jumps" => [],
                        "qualification_conditions" => [],
                        "flags" => ["is_eligible_for_research"]
                    }
                )
            }
        );

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
                        text              => 'E vc teve já relações sexuais com bofe cis (ou bicha, ou poc) ou com mulheres trans ou travestis?',
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
                        code              => 'A6a',
                        text              => 'Alguma destas relações foi nos últimos 6 meses?',
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
                                logic_jumps => [ ],
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

    my $fb_id = '710488549074724';
    my $recipient_id;
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
    };

    # Testando não elegivel
    subtest 'Chatbot | not eligible' => sub {
        db_transaction{
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

            $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'A6a',
                    category       => 'quiz',
                    answer_value   => '1'
                }
            )
            ->status_is(201)
            ->json_is('/finished_quiz', 0)
            ->json_has('/followup_messages/0');

            for ( 1 .. 6 ) {
                $t->post_ok(
                    '/api/chatbot/recipient/answer',
                    form => {
                        security_token => $security_token,
                        fb_id          => $fb_id,
                        code           => 'AC' . $_,
                        category       => 'quiz',
                        answer_value   => '1'
                    }
                )
                ->status_is(201)
                ->json_is('/finished_quiz', 0);
            }

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
            ->json_is('/finished_quiz', 0)
            ->json_has('/followup_messages/0');

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

            $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'B1',
                    category       => 'quiz',
                    answer_value   => '2'
                }
            )
            ->status_is(201)
            ->json_is('/finished_quiz', 0);

            $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'B3',
                    category       => 'quiz',
                    answer_value   => '0'
                }
            )
            ->status_is(201)
            ->json_is('/finished_quiz', 0);

            $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'B6',
                    category       => 'quiz',
                    answer_value   => '2'
                }
            )
            ->status_is(201)
            ->json_is('/finished_quiz', 0);

            $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'B7',
                    category       => 'quiz',
                    answer_value   => '4'
                }
            )
            ->status_is(201)
            ->json_is('/finished_quiz', 0);

            $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'B8',
                    category       => 'quiz',
                    answer_value   => '2'
                }
            )
            ->status_is(201)
            ->json_is('/finished_quiz', 0);

            $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'B9',
                    category       => 'quiz',
                    answer_value   => '2'
                }
            )
            ->status_is(201)
            ->json_is('/finished_quiz', 0);

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
            ->json_is('/is_eligible_for_research', '0');

            $t->get_ok(
                '/api/chatbot/recipient/pending-question',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    category       => 'quiz'
                }
            )
            ->status_is(200)
            ->json_is('/code', undef);
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

            $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'A2',
                    category       => 'quiz',
                    answer_value   => '40'
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

        db_transaction {
            $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'A4',
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
            ->json_is('/code', 'A4a');

            $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'A4a',
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
            ->json_is('/code', 'A5');
        };

        db_transaction {
            $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'A4',
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
                    category       => 'quiz'
                }
            )
            ->status_is(200)
            ->json_is('/code', 'A4b');

            $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'A4b',
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
            ->json_is('/code', 'A5');
        };

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

        db_transaction{
            $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'A6',
                    category       => 'quiz',
                    answer_value   => '2'
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
        ->json_is('/code', 'A6a');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'A6a',
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

        db_transaction{
            $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'B1',
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
                    category       => 'quiz'
                }
            )
            ->status_is(200)
            ->json_is('/code', 'B3');

        };

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

        # A B3 possui um salto de lógica
        db_transaction{
            $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'B3',
                    category       => 'quiz',
                    answer_value   => '0'
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
            ->json_is('/code', 'B6');

        };

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

        db_transaction{
            $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'B4',
                    category       => 'quiz',
                    answer_value   => '2'
                }
            )->status_is(201)
            ->json_is('/finished_quiz', 0);

            $t->get_ok(
                '/api/chatbot/recipient/pending-question',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    category       => 'quiz',
                }
            )->status_is(200)
            ->json_is('/code', 'B6');

        };

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
        ->json_is('/code', 'AC9');

        ok( my $recipient = $schema->resultset('Recipient')->find($recipient_id), 'recipient' );
        is $recipient->integration_token, undef;

        db_transaction {
            $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'AC9',
                    category       => 'quiz',
                    answer_value   => '2'
                }
            )
            ->status_is(201)
            ->json_is('/finished_quiz', 1)
            ->json_is('/is_eligible_for_research', 1);

            ok( $recipient = $recipient->discard_changes, 'recipient discard changes' );
        };

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'AC9',
                category       => 'quiz',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 1)
        ->json_has('/offline_pre_registration_form')
        ->json_is('/is_eligible_for_research', 1);

        ok( $recipient = $recipient->discard_changes, 'recipient discard changes' );
        ok defined $recipient->integration_token;
    };
};

# Test screening
db_transaction {
    my $security_token = $ENV{CHATBOT_SECURITY_TOKEN};

    my $question_map;
    subtest 'Create questions and question map' => sub {
        my $question_rs = $schema->resultset('Question');

        ok(
            $question_map = $schema->resultset('QuestionMap')->create(
                {
                    map => to_json({
                        1 => "SC1",
                        2 => "SC2",
                        3 => "SC2a",
                        4 => "SC3",
                        5 => "SC4",
                    }),
                    category_id => 2
                }
            ),
            'question map created'
        );

        ok(
            $question_rs->create(
                {
                    code              => 'SC1',
                    text              => 'Foobar?',
                    type              => 'multiple_choice',
                    question_map_id   => $question_map->id,
                    is_differentiator => 0,
                    multiple_choices  => to_json (
                        {
                            1 => 'foo',
                            2 => 'bar',
                            3 => 'baz'
                        }
                    ),
                    rules => to_json(
                        {
                            "logic_jumps" => [],
                            "qualification_conditions" => [ "2", "3" ],
                            "flags" => [ "emergency_rerouting" ]
                        }
                    )
                }
            ),
            'first question'
        );

        ok(
            $question_rs->create(
                {
                    code              => 'SC2',
                    text              => 'Foobar?',
                    type              => 'multiple_choice',
                    question_map_id   => $question_map->id,
                    is_differentiator => 0,
                    multiple_choices  => to_json (
                        {
                            1 => 'foo',
                            2 => 'bar'
                        }
                    ),
                    rules => to_json(
                        {
                            "logic_jumps" => [
                                {
                                    "code"   => "SC2a",
                                    "values" => [ "1" ]
                                }
                            ],
                            "qualification_conditions" => []
                        }
                    )
                }
            ),
            'second question'
        );

        ok(
            $question_rs->create(
                {
                    code              => 'SC2a',
                    text              => 'Foobar?',
                    type              => 'multiple_choice',
                    question_map_id   => $question_map->id,
                    is_differentiator => 0,
                    multiple_choices  => to_json (
                        {
                            1 => 'foo',
                            2 => 'bar'
                        }
                    ),
                    rules => to_json(
                        {
                            "logic_jumps" => [],
                            "qualification_conditions" => [ "2" ],
                            "flags"=> [ "go_to_appointment" ]
                        }
                    )
                }
            ),
            'third question'
        );

        ok(
            $question_rs->create(
                {
                    code              => 'SC3',
                    text              => 'Foobar?',
                    type              => 'multiple_choice',
                    question_map_id   => $question_map->id,
                    is_differentiator => 0,
                    multiple_choices  => to_json (
                        {
                            1 => 'foo',
                            2 => 'bar'
                        }
                    ),
                    rules => to_json(
                        {
                            "logic_jumps"=> [],
                            "qualification_conditions"=> [ "2" ],
                            "flags"=> [ "go_to_appointment" ]
                        }
                    )
                }
            ),
            'fourth question'
        );

        ok(
            $question_rs->create(
                {
                    code              => 'SC4',
                    text              => 'Foobar?',
                    type              => 'multiple_choice',
                    question_map_id   => $question_map->id,
                    is_differentiator => 0,
                    multiple_choices  => to_json (
                        {
                            1 => 'foo',
                            2 => 'bar'
                        }
                    ),
                    rules => to_json(
                        {
                            "logic_jumps" => [],
                            "qualification_conditions" => [],
                            "flags" => [ "go_to_test", "suggest_wait_for_test" ]
                        }
                    )
                }
            ),
            'fifth question'
        );
    };

    my $fb_id = '710488549074724';
    my $recipient_id;
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
    };

    subtest 'Chatbot | Get pending question' => sub {

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                category       => 'screening'
            }
        )
        ->status_is(200)
        ->json_has('/code')
        ->json_has('/text')
        ->json_has('/type')
        ->json_has('/extra_quick_replies')
        ->json_has('/multiple_choices')
        ->json_is('/code', 'SC1');

        # a triagem acaba caso a resposta seja 1 e deve vir a flag emergency_rerouting
        db_transaction{
            $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'SC1',
                    category       => 'screening',
                    answer_value   => '1'
                }
            )
            ->status_is(201)
            ->json_is('/emergency_rerouting', 1)
            ->json_is('/finished_quiz', 1);
        };

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'SC1',
                category       => 'screening',
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
                category       => 'screening'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'SC2');

        # Caso a resposta seja 2, deve ir direto para a SC3 e não ver a SC2a
        db_transaction{
            $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'SC2',
                    category       => 'screening',
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
                    category       => 'screening'
                }
            )
            ->status_is(200)
            ->json_is('/code', 'SC3');
        };

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'SC2',
                category       => 'screening',
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
                category       => 'screening'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'SC2a');

        # Caso a pessoa responda 2 não deve ter a SC2a
        db_transaction{
            $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'SC2a',
                    category       => 'screening',
                    answer_value   => '1'
                }
            )
            ->status_is(201)
            ->json_is('/go_to_appointment', 1)
            ->json_is('/finished_quiz', 1);
        };

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'SC2a',
                category       => 'screening',
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
                category       => 'screening'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'SC3');

        # a triagem acaba caso a resposta seja 1 e deve vir a flag go_to_appointment
        db_transaction{
            $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'SC3',
                    category       => 'screening',
                    answer_value   => '1'
                }
            )
            ->status_is(201)
            # ->json_is('/go_to_appointment', 1)
            ->json_is('/finished_quiz', 1);
        };

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'SC3',
                category       => 'screening',
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
                category       => 'screening'
            }
        )
        ->status_is(200)
        ->json_is('/code', 'SC4');

        # Na resposta da SC4, caso a resposta da SC1 tenha sido 2, haverá a flag suggest_wait_for_test
        db_transaction{
            my $answer = $schema->resultset('Answer')->search( { 'question.code' => 'SC1' }, { prefetch => 'question' } )->next;
            ok( $answer->update( { answer_value => '2' } ), 'update answer' );

            $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'SC4',
                    category       => 'screening',
                    answer_value   => '1'
                }
            )
            ->status_is(201)
            ->json_is('/suggest_wait_for_test', 1)
            ->json_is('/go_to_test', 1)
            ->json_is('/finished_quiz', 1);
        };

        db_transaction{
            $t->post_ok(
                '/api/chatbot/recipient/answer',
                form => {
                    security_token => $security_token,
                    fb_id          => $fb_id,
                    code           => 'SC4',
                    category       => 'screening',
                    answer_value   => '1'
                }
            )
            ->status_is(201)
            ->json_is('/suggest_wait_for_test', 0)
            ->json_is('/go_to_test', 1)
            ->json_is('/finished_quiz', 1);
        };

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'SC4',
                category       => 'screening',
                answer_value   => '2'
            }
        )
        ->status_is(201)
        ->json_is('/suggest_wait_for_test', 0)
        ->json_is('/go_to_test', 0)
        ->json_is('/finished_quiz', 1);
    };
};

done_testing();
