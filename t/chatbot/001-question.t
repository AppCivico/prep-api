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
                    })
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

        ok(
            $question_map = $schema->resultset('QuestionMap')->create(
                {
                    map => to_json({
                        1  =>  'A1',
                        2  =>  'AC1',
                        3  =>  'AC2',
                        4  =>  'AC3',
                        5  =>  'AC4',
                        6  =>  'A2',
                        7  =>  'A3',
                        8  =>  'B1',
                        9  =>  'B1a',
                        10 =>  'B2',
                        11 =>  'B2a',
                        12 =>  'B2b',
                        13 =>  'B3',
                        14 =>  'B4',
                        15 =>  'B5',
                        16 =>  'B6',
                        17 =>  'B7'
                    })
                }
            ),
            'question map created'
        );

        # Criando as perguntas do AppCivico que não são importantes
        # para o resultado final
        for ( 1 .. 4 ) {
            ok(
                $question_rs->create(
                    {
                        code              => 'AC' . $_,
                        text              => 'Foobar?',
                        question_map_id   => $question_map->id,
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
                    question_map_id   => $question_map->id,
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
                        text              => 'Nos últimos doze meses, você teve relações sexuais com algum parceiro (homem ou mulher transexual ou travesti) que você considera fixo?',
                        type              => 'multiple_choice',
                        question_map_id   => $question_map->id,
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
						code              => 'B1a',
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
						)
					}
				)
			);

            ok(
                $question_rs->create(
                    {
                        code              => 'B2',
                        text              => 'Considerando só seus parceiros homens: nos últimos doze meses, quantos parceiros casuais você teve?',
                        type              => 'open_text',
                        question_map_id   => $question_map->id,
                        is_differentiator => 1
                    }
                )
            );

            ok(
				$question_rs->create(
					{
						code              => 'B2a',
						text              => 'Você sabe o resultado do teste de HIV desse seu parceiro fixo?',
						type              => 'multiple_choice',
						question_map_id   => $question_map->id,
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
						code              => 'B2b',
						text              => 'Você sabe o resultado do teste de HIV desse seu parceiro fixo?',
						type              => 'multiple_choice',
						question_map_id   => $question_map->id,
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
                        text              => 'Nos últimos doze meses, alguma vez você recebeu dinheiro, presentes ou favores para fazer sexo?',
                        type              => 'multiple_choice',
                        question_map_id   => $question_map->id,
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
						code              => 'B4',
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
						)
					}
				)
			);

			ok(
				$question_rs->create(
					{
						code              => 'B5',
						text              => 'Nos últimos doze meses, alguma vez você recebeu dinheiro, presentes ou favores para fazer sexo?',
						type              => 'multiple_choice',
						question_map_id   => $question_map->id,
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
								1 => "Sim, já ouvi falar",
								2 => "Não, nunca ouvi falar"
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
                        text              => 'Qual é a sua idade?',
                        type              => 'open_text',
                        question_map_id   => $question_map->id,
                        is_differentiator => 1,
                    }
                )
            );

            ok(
                $question_rs->create(
                    {
                        code              => 'A2',
                        text              => 'Nos últimos doze meses, você teve relações sexuais com homens ou com mulheres transexuais ou com travestis?',
                        type              => 'multiple_choice',
                        question_map_id   => $question_map->id,
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

    subtest 'Chatbot | Answers' => sub {

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'A1',
                answer_value   => '18'
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
        ->json_is('/code', 'AC1');

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

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'A2',
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
        ->json_is('/code', 'A3');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'A3',
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
        ->json_is('/code', 'B1a');

		$t->post_ok(
			'/api/chatbot/recipient/answer',
			form => {
				security_token => $security_token,
				fb_id          => $fb_id,
				code           => 'B1a',
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
        ->json_is('/code', 'B2a');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'B2a',
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
        ->json_is('/code', 'B2b');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'B2b',
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
        ->json_is('/code', 'B4');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'B4',
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
        ->json_is('/code', 'B5');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'B5',
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
        ->json_is('/code', 'B6');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'B6',
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
        ->json_is('/code', 'B7');

        $t->post_ok(
            '/api/chatbot/recipient/answer',
            form => {
                security_token => $security_token,
                fb_id          => $fb_id,
                code           => 'B7',
                answer_value   => '1'
            }
        )
        ->status_is(201)
        ->json_is('/finished_quiz', 1);

    };
};

done_testing();