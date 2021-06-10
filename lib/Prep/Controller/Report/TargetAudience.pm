package Prep::Controller::Report::TargetAudience;
use Mojo::Base 'Prep::Controller';

use Prep::Utils;
use Prep::Logger;
use Moose;

has logger => (
    is      => 'rw',
    lazy    => 1,
    builder => '_build_logger',
);
sub _build_logger {&get_logger}

sub get {
    my $c = shift;

    my $city = $c->stash('city');

    my $logger = $c->logger;

    my $since = $c->stash('since');
    my $until = $c->stash('until');

    my $recipient_rs = $c->schema->resultset('Recipient')->search(
        {
            ($city ? ('me.city' => $city) : ()),
            'recipient_flag.is_target_audience' => 1,

            '-and' => [
                \[
                    "EXISTS (SELECT 1 FROM answer a, question q WHERE a.recipient_id = me.id AND q.code = 'A6' AND a.question_id = q.id AND a.created_at >= to_timestamp(?) AND a.created_at <= to_timestamp(?))",
                    $since, $until
                ]
            ]
        },
        {
            group_by => 'me.id',
            join     => [{'answers' => 'question'}, 'recipient_flag']
        }
    );

    my @metrics;

    $logger->debug("since_target_audience:$since");
    $logger->debug("until_target_audience:$until");

    my $recipient_count = $recipient_rs->count;
    push @metrics, {label => 'Contatos novos no período', value => $recipient_count};

    # Métricas de escolaridade
    my @scolarity_metrics;
    for (1 .. 4) {
        my ($label, $value);

        if ($_ == 1) {
            $label = 'Fundamental I';

            $value = $recipient_rs->search(
                {
                    'question.code'        => 'A4a',
                    'answers.answer_value' => {'-in' => ['1', '2', '3', '4']},
                    'answers.created_at'   => {'>='  => \"to_timestamp($since)", '<=' => \"to_timestamp($until)"}
                },
                {join => {'answers' => 'question'}}
            )->count;
        }
        elsif ($_ == 2) {
            $label = 'Fundamental II';

            $value = $recipient_rs->search(
                {
                    'question.code'        => 'A4a',
                    'answers.answer_value' => {'-in' => ['5', '6', '7', '8', '9']},
                    'answers.created_at'   => {'>='  => \"to_timestamp($since)", '<=' => \"to_timestamp($until)"}
                },
                {join => {'answers' => 'question'}}
            )->count;
        }
        elsif ($_ == 3) {
            $label = 'Ensino médio';

            $value = $recipient_rs->search(
                {
                    'question.code'        => 'A4',
                    'answers.answer_value' => '2',
                    'answers.created_at'   => {'>=' => \"to_timestamp($since)", '<=' => \"to_timestamp($until)"}
                },
                {join => {'answers' => 'question'}}
            )->count;
        }
        else {
            $label = 'Ensino superior';

            $value = $recipient_rs->search(
                {
                    'question.code'        => 'A4',
                    'answers.answer_value' => '3',
                    'answers.created_at'   => {'>=' => \"to_timestamp($since)", '<=' => \"to_timestamp($until)"}
                },
                {join => {'answers' => 'question'}}
            )->count;
        }

        push @scolarity_metrics, {label => $label, value => $value};
    }

    push @metrics, {sub_group => 'Por faixa de escolaridade', metrics => \@scolarity_metrics};

    # Métricas de cor/raça
    my @racial_metrics;
    for (1 .. 5) {
        my ($label, $value);

        if ($_ == 1) {
            $label = 'Branca';

            $value = $recipient_rs->search(
                {
                    'question.code'        => 'A5',
                    'answers.answer_value' => '1',
                    'answers.created_at'   => {'>=' => \"to_timestamp($since)", '<=' => \"to_timestamp($until)"}
                },
                {join => {'answers' => 'question'}}
            )->count;
        }
        elsif ($_ == 2) {
            $label = 'Preta';

            $value = $recipient_rs->search(
                {
                    'question.code'        => 'A5',
                    'answers.answer_value' => '2',
                    'answers.created_at'   => {'>=' => \"to_timestamp($since)", '<=' => \"to_timestamp($until)"}
                },
                {join => {'answers' => 'question'}}
            )->count;
        }
        elsif ($_ == 3) {
            $label = 'Amarela';

            $value = $recipient_rs->search(
                {
                    'question.code'        => 'A5',
                    'answers.answer_value' => '3',
                    'answers.created_at'   => {'>=' => \"to_timestamp($since)", '<=' => \"to_timestamp($until)"}
                },
                {join => {'answers' => 'question'}}
            )->count;
        }
        elsif ($_ == 4) {
            $label = 'Parda';

            $value = $recipient_rs->search(
                {
                    'question.code'        => 'A5',
                    'answers.answer_value' => '4',
                    'answers.created_at'   => {'>=' => \"to_timestamp($since)", '<=' => \"to_timestamp($until)"}
                },
                {join => {'answers' => 'question'}}
            )->count;
        }
        else {
            $label = 'Indígena';

            $value = $recipient_rs->search(
                {
                    'question.code'        => 'A5',
                    'answers.answer_value' => '5',
                    'answers.created_at'   => {'>=' => \"to_timestamp($since)", '<=' => \"to_timestamp($until)"}
                },
                {join => {'answers' => 'question'}}
            )->count;
        }

        push @racial_metrics, {label => $label, value => $value};
    }
    push @metrics, {sub_group => 'Por raça/cor', metrics => \@racial_metrics};

    # Métricas de interação.

    # Métricas sobre questionários
    my $started_recrutamento = $recipient_rs->search(
        {
            'question.code'      => 'B1',
            'answers.created_at' => {'>=' => \"to_timestamp($since)", '<=' => \"to_timestamp($until)"}
        },
        {join => {'answers' => 'question'}}
    )->count;
    push @metrics, {label => 'Iniciaram o questionário de recrutamento', value => $started_recrutamento};

    my $finished_recrutamento = $recipient_rs->search(
        {
            'question.code'      => 'B10',
            'answers.created_at' => {'>=' => \"to_timestamp($since)", '<=' => \"to_timestamp($until)"}
        },
        {join => {'answers' => 'question'}}
    )->count;
    push @metrics, {label => 'Finalizaram o questionário de recrutamento', value => $finished_recrutamento};

    # Métricas do TCLE
    my $term_signature_rs = $c->schema->resultset('TermSignature')->search(
        {'me.signed_at' => {'>=' => \"to_timestamp($since)", '<=' => \"to_timestamp($until)"}},
        {
            order_by => {'-desc' => 'me.signed_at'},
            group_by => 'me.recipient_id'
        }
    );

    my @tcle_metrics;
    for (1 .. 3) {
        my ($label, $value);

        if ($_ == 1) {
            $label = 'Aceitaram o TCLE';
            $value = $recipient_rs->search(
                {
                    '-and' => [
                        \['EXISTS (SELECT 1 FROM term_signature s WHERE s.recipient_id = me.id AND s.signed = true)'],
                    ]
                },
            )->count;
        }
        elsif ($_ == 2) {
            $label = 'Não aceitaram o TCLE';
            $value = $recipient_rs->search(
                {
                    '-and' => [
                        \['EXISTS (SELECT 1 FROM term_signature s WHERE s.recipient_id = me.id AND s.signed = false)'],
                    ]
                },
            )->count;
        }
        else {
            $label = 'Não responderam o TCLE';
            $value = $recipient_rs->search(
                {
                    '-and' => [
                        \['NOT EXISTS (SELECT 1 FROM term_signature s WHERE s.recipient_id = me.id)'],
                    ]
                },
                {join => {'answers' => 'question'}}
            );

            $value = $value->count;
        }

        push @tcle_metrics, {label => $label, value => $value};
    }
    push @metrics, {sub_group => 'Sobre o TCLE', metrics => \@tcle_metrics};

    my $eligible_for_research = $recipient_rs->search(
        {
            'recipient_flag.is_eligible_for_research' => 1,
            'question.code'                           => 'B10',
            'answers.created_at' => {'>=' => \"to_timestamp($since)", '<=' => \"to_timestamp($until)"}
        },
        {join => {'answers' => 'question'}}
    )->count;
    push @metrics, {label => 'Número de elegíveis', value => $eligible_for_research};

    my $created_appointment = $recipient_rs->search(
        {
            '-and' => [
                \[
                    'EXISTS (
                        SELECT
                            1
                        FROM appointment a
                        JOIN answer aa ON aa.recipient_id = a.recipient_id
                        JOIN question q ON aa.question_id = q.id
                        WHERE
                            a.recipient_id = me.id AND a.created_at BETWEEN to_timestamp(?) AND to_timestamp(?) AND
                            (q.code = ? AND aa.created_at BETWEEN to_timestamp(?) AND to_timestamp(?))
                    )',
                    $since, $until, 'A6', $since, $until
                ],
            ]
        }
    )->count;
    push @metrics, {label => 'Criaram agendamento', value => $created_appointment};

    my $total_appointments = $c->schema->resultset('Appointment')->search(
        {
            '-and' => [
                \[
                    'me.created_at BETWEEN to_timestamp(?) AND to_timestamp(?)',
                    $since, $until
                ]
            ]
        }
    )->count;
    push @metrics, {label => 'Agendamentos totais', value => $total_appointments};

    my $whatsapp_count = $recipient_rs->search({'me.phone' => \'IS NOT NULL'})->count;
    push @metrics, {label => 'Passaram WhatsApp', value => $whatsapp_count};

    my $instagram_count = $recipient_rs->search({'me.instagram' => \'IS NOT NULL'})->count;
    push @metrics, {label => 'Passaram Instagram', value => $instagram_count};

    # Métricas de contato
    # my @contact_metrics;
    # for (1 .. 2) {
    #     my ($label, $value);

    #     if ($_ == 1) {
    #         $label = 'Passaram WhatsApp';
    #         $value =;
    #     }
    #     else {
    #         $label = 'Passaram Instagram';
    #         $value = $recipient_rs->search(
    #             {
    #                 'me.instagram'  => \'IS NOT NULL',
    #                 'me.created_at' => {'>=' => \"to_timestamp($since)", '<=' => \"to_timestamp($until)"}
    #             }
    #         )->count;
    #     }
    #     push @contact_metrics, {label => $label, value => $value};
    # }
    # push @metrics, {sub_group => 'Passaram contato após bloco A', metrics => \@contact_metrics};

    return $c->render(
        status => 200,
        json   => {metrics => \@metrics}
    );
}

1;
