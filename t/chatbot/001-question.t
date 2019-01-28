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
            $first_question = $question_rs->create(
                {
                    code              => 'Z1',
                    text              => 'Foobar?',
                    type              => 'multiple_choice',
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

        ok(
            $question_map = $schema->resultset('QuestionMap')->create(
                {
                    map => to_json({
                        1 => 'Z1',
                        2 => 'U4',
                        3 => 'Y5',
                    })
                }
            ),
            'question map created'
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
                fb_id          => $fb_id
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
                fb_id          => $fb_id
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
                answer_value   => '1'
            }
        )
        ->status_is(201);

        # A pergunta esperada agora é a U4
        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id
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
        ->json_is('/count_more', 2)
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
                answer_value   => '1'
            }
        )
        ->status_is(201);

        # A pergunta esperada agora é a última Y5
        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id
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
                answer_value   => 'FOObar'
            }
        )
        ->status_is(201);

        # Não deve vir nenhuma pergunta e o has_more deve ser 0
        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id
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

        # Criando as perguntas do AppCivico que não são importantes
        # para o resultado final
        for ( 1 .. 4 ) {
            ok(
                $question_rs->create(
                    {
                        code              => 'AC' . $_,
                        text              => 'Foobar?',
                        type              => 'multiple_choice',
                        is_differentiator => 0,
                        multiple_choices  => to_json({ 1 => 'foo', 2 => 'bar' })
                    }
                )
            );
        }

        # A única pergunta que fazemos que importa é a AC5
        ok(
            $question_rs->create(
                {
                    code              => 'AC5',
                    text              => 'Deseja participar?',
                    type              => 'multiple_choice',
                    is_differentiator => 0,
                    multiple_choices  => to_json({ 1 => 'sim', 2 => 'não' })
                }
            )
        );

        # Perguntas da parte B
        subtest 'Creating B section questions' => sub {
            ok(
                $question_rs->create(
                    {
                        code              => 'B1',
                        text              => 'Quando você fez seu último teste de HIV?',
                        type              => 'multiple_choice',
                        is_differentiator => 1,
                        multiple_choices  => to_json(
                            {
                                1 => "Nunca fiz",
                                2 => "Há menos de 6 meses",
                                3 => "Há mais de 6 meses"
                            }
                        )
                    }
                )
            );

            ok(
                $question_rs->create(
                    {
                        code              => 'B2',
                        text              => 'Nos últimos seis meses, você teve algum corrimento, ferida, verruga ou bolhas no pênis ou no ânus?',
                        type              => 'multiple_choice',
                        is_differentiator => 1,
                        multiple_choices  => to_json(
                            {
                                1 => "Sim",
                                2 => "Não"
                            }
                        )
                    }
                )
            );

            ok(
                $question_rs->create(
                    {
                        code              => 'B3',
                        text              => 'Nos últimos seis meses, você usou a PEP - profilaxia pós-exposição sexual ao HIV?',
                        type              => 'multiple_choice',
                        is_differentiator => 1,
                        multiple_choices  => to_json(
                            {
                                1 => "Sim",
                                2 => "Não"
                            }
                        )
                    }
                )
            );
        };

        # Perguntas da parte C
        subtest 'Creating C section questions' => sub {
            ok(
                $question_rs->create(
                    {
                        code              => 'C1',
                        text              => 'Nos últimos seis meses, você teve relações sexuais com algum parceiro que você considera fixo?',
                        type              => 'multiple_choice',
                        is_differentiator => 1,
                        multiple_choices  => to_json(
                            {
                                1 => "Sim",
                                2 => "Não"
                            }
                        )
                    }
                )
            );

            ok(
                $question_rs->create(
                    {
                        code              => 'C2',
                        text              => 'Você sabe o resultado do teste de HIV de seu parceiro fixo?',
                        type              => 'multiple_choice',
                        is_differentiator => 1,
                        multiple_choices  => to_json(
                            {
                                1 => "Sim, é negativo",
                                2 => "Sim, é positivo",
                                3 => "Não sei"
                            }
                        )
                    }
                )
            );

            ok(
                $question_rs->create(
                    {
                        code              => 'C3',
                        text              => 'Nos últimos seis meses, quantos parceiros casuais você teve?',
                        type              => 'multiple_choice',
                        is_differentiator => 1,
                        multiple_choices  => to_json(
                            {
                                1 => "De 1 a 5",
                                2 => "Entre 5 e 10",
                                3 => "Mais de 10",
                                4 => "Nenhum"
                            }
                        )
                    }
                )
            );

            ok(
                $question_rs->create(
                    {
                        code              => 'C4',
                        text              => 'Nos últimos seis meses, você fez sexo anal sem camisinha com algum(ns) de seus parceiros casuais?',
                        type              => 'multiple_choice',
                        is_differentiator => 1,
                        multiple_choices  => to_json(
                            {
                                1 => "Sim",
                                2 => "Não"
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
                        code              => 'A1',
                        text              => 'Qual é o seu nome completo?',
                        type              => 'open_text',
                        is_differentiator => 1,
                    }
                )
            );

            ok(
                $question_rs->create(
                    {
                        code              => 'A2',
                        text              => 'Qual a sua data de nascimento?',
                        type              => 'open_text',
                        is_differentiator => 1
                    }
                )
            );

            ok(
                $question_rs->create(
                    {
                        code              => 'A3',
                        text              => 'Qual é o seu CPF?',
                        type              => 'open_text',
                        is_differentiator => 1
                    }
                )
            );

            ok(
                $question_rs->create(
                    {
                        code              => 'A4',
                        text              => 'Como você define sua cor?',
                        type              => 'multiple_choice',
                        is_differentiator => 1,
                        multiple_choices  => to_json(
                            {
                                1 => "Branca",
                                2 => "Preta",
                                3 => "Amarela",
                                4 => "Parda",
                                5 => "Indígena"
                            }
                        )
                    }
                )
            );
        };

        ok(
            $question_map = $schema->resultset('QuestionMap')->create(
                {
                    map => to_json({
                        1  =>  'AC1',
                        2  =>  'AC2',
                        3  =>  'AC3',
                        4  =>  'AC4',
                        5  =>  'B1',
                        6  =>  'B2',
                        7  =>  'B3',
                        8  =>  'C1',
                        9  =>  'C2',
                        10 =>  'C3',
                        11 =>  'C4',
                        12 =>  'AC5',
                        13 =>  'A1',
                        14 =>  'A2',
                        15 =>  'A3',
                        16 =>  'A4'
                    })
                }
            ),
            'question map created'
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

    subtest 'Chatbot | Answers' => sub {

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'AC1',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id
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
                code           => 'AC3',
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
                code           => 'AC4',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id
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
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id
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
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id
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
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id
            }
        )
        ->status_is(200)
        ->json_is('/code', 'C1');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'C1',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id
            }
        )
        ->status_is(200)
        ->json_is('/code', 'C2');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'C2',
                answer_value   => '2'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id
            }
        )
        ->status_is(200)
        ->json_is('/code', 'C3');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'C3',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id
            }
        )
        ->status_is(200)
        ->json_is('/code', 'C4');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'C4',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id
            }
        )
        ->status_is(200)
		->json_has('/is_eligible_for_research')
		->json_has('/is_part_of_research')
		->json_is('/is_eligible_for_research', 1)
		->json_is('/code', 'AC5');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'AC5',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id
            }
        )
        ->status_is(200)
        ->json_is('/code', 'A1');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'A1',
                answer_value   => 'Foobar'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id
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
                answer_value   => '1998-05-11'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id
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
                answer_value   => '40371892597'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 0);

        $t->get_ok(
            '/api/chatbot/recipient/pending-question',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id
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
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 1);

    };
};

done_testing();