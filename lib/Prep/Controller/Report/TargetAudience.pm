package Prep::Controller::Report::TargetAudience;
use Mojo::Base 'Prep::Controller';

use Prep::Utils;
use WebService::AssistenteCivico;
use Prep::Logger;
use Moose;

has logger => (
    is      => 'rw',
    lazy    => 1,
    builder => '_build_logger',
);
sub _build_logger { &get_logger }

sub get {
    my $c = shift;

    my $city = $c->stash('city');

    my $logger = $c->logger;

    my $since = $c->stash('since');
    my $until = $c->stash('until');

    my $recipient_rs = $c->schema->resultset('Recipient')->search(
        {
            ( $city ? ( { 'me.city' => $city } ) : ( ) ),
            'recipient_flag.is_target_audience' => 1
        },
        { join => 'recipient_flag' }
    );

    my @metrics;

    # Métricas de escolaridade
    my @scolarity_metrics;
    for ( 1 .. 4 ) {
        my ($label, $value);

        if ($_ == 1) {
            $label = 'Fundamental I';

            $value = $recipient_rs->search(
                {
                    'question.code'        => 'A4a',
                    'answers.answer_value' => { '-in' => ['1', '2', '3', '4'] }
                },
                { join => { 'answers' => 'question' } }
            )->count;
        }
        elsif ($_ == 2) {
            $label = 'Fundamental II';

            $value = $recipient_rs->search(
                {
                    'question.code'        => 'A4a',
                    'answers.answer_value' => { '-in' => ['5', '6', '7', '8', '9'] }
                },
                { join => { 'answers' => 'question' } }
            )->count;
        }
        elsif ($_ == 3) {
            $label = 'Ensino médio';

            $value = $recipient_rs->search(
                {
                    'question.code'        => 'A4',
                    'answers.answer_value' => '2'
                },
                { join => { 'answers' => 'question' } }
            )->count;
        }
        else {
            $label = 'Ensino superior';

            $value = $recipient_rs->search(
                {
                    'question.code'        => 'A4',
                    'answers.answer_value' => '3'
                },
                { join => { 'answers' => 'question' } }
            )->count;
        }

        push @scolarity_metrics, { label => $label, value => $value };
    }

    push @metrics, { sub_group => 'Por faixa de escolaridade', metrics => \@scolarity_metrics };

    # Métricas de cor/raça
    my @racial_metrics;
    for ( 1 .. 5 ) {
        my ($label, $value);

        if ($_ == 1) {
            $label = 'Branca';

            $value = $recipient_rs->search(
                {
                    'question.code'        => 'A5',
                    'answers.answer_value' => '1'
                },
                { join => { 'answers' => 'question' } }
            )->count;
        }
        elsif ($_ == 2) {
            $label = 'Preta';

            $value = $recipient_rs->search(
                {
                    'question.code'        => 'A5',
                    'answers.answer_value' => '2'
                },
                { join => { 'answers' => 'question' } }
            )->count;
        }
        elsif ($_ == 3) {
            $label = 'Amarela';

            $value = $recipient_rs->search(
                {
                    'question.code'        => 'A5',
                    'answers.answer_value' => '3'
                },
                { join => { 'answers' => 'question' } }
            )->count;
        }
        elsif ($_ == 4) {
            $label = 'Parda';

            $value = $recipient_rs->search(
                {
                    'question.code'        => 'A5',
                    'answers.answer_value' => '4'
                },
                { join => { 'answers' => 'question' } }
            )->count;
        }
        else {
            $label = 'Indígena';

            $value = $recipient_rs->search(
                {
                    'question.code'        => 'A5',
                    'answers.answer_value' => '5'
                },
                { join => { 'answers' => 'question' } }
            )->count;
        }

        push @racial_metrics, { label => $label, value => $value };
    }
    push @metrics, { sub_group => 'Por raça/cor', metrics => \@racial_metrics };

    # Métricas de interação.

    # Métricas sobre questionários
    my $started_publico_interesse = $recipient_rs->search(
        { 'question.code' => 'A1' },
        { join => { 'answers' => 'question' } }
    )->count;
    push @metrics, { label => 'Iniciaram o questionário de público de interesse', value => $started_publico_interesse };

    my $finished_publico_interesse = $recipient_rs->search(
        { 'recipient_flag.finished_publico_interesse' => 1 }
    )->count;
    push @metrics, { label => 'Finalizaram o questionário de público de interesse', value => $finished_publico_interesse };

    my $started_recrutamento = $recipient_rs->search(
        { 'question.code' => 'B1' },
        { join => { 'answers' => 'question' } }
    )->count;
    push @metrics, { label => 'Iniciaram o questionário de recrutamento', value => $started_recrutamento };

    my $finished_recrutamento = $recipient_rs->search(
        { 'question.code' => 'B10' },
        { join => { 'answers' => 'question' } }
    )->count;
    push @metrics, { label => 'Finalizaram o questionário de recrutamento', value => $finished_recrutamento };

    # Métricas do TCLE
    my $term_signature_rs = $c->schema->resultset('TermSignature')->search(
        undef,
        {
            order_by => { '-desc' => 'me.signed_at' },
            group_by => 'me.recipient_id'
        }
    );

    my @tcle_metrics;
    for (1 .. 3) {
        my ($label, $value);

        if ($_ == 1) {
            $label = 'Aceitaram o TCLE';
            $value = $recipient_rs->search( { 'recipient_flag.signed_term' => 1 } )->count;
        }
        elsif ($_ == 2) {
            $label = 'Não aceitaram o TCLE';
            $value = $term_signature_rs->search( { 'me.signed' => 0 } )->count;
        }
        else {
            $label = 'Não responderam o TCLE';
            $value = $recipient_rs->search(
                {
                    '-and' => [
                        \[ 'NOT EXISTS (SELECT 1 FROM term_signature)' ]
                    ]
                }
            )->count;
        }

        push @tcle_metrics, {label => $label, value => $value};
    }
    push @metrics, { sub_group => 'Sobre o TCLE', metrics => \@tcle_metrics };

    my $eligible_for_research = $recipient_rs->search(
        { 'recipient_flag.is_eligible_for_research' => 1 }
    )->count;
    push @metrics, { label => 'Número de elegíveis', value => $eligible_for_research };

    my $created_appointment = $recipient_rs->search(
        { '-and' => [ \['EXISTS (SELECT 1 FROM appointment)'] ] }
    )->count;
    push @metrics, { label => 'Agendaram', value => $created_appointment };

    # Métricas de contato
    my @contact_metrics;
    for (1 .. 2) {
        my ($label, $value);

        if ($_ == 1) {
            $label = 'Passaram WhatsApp';
            $value = $recipient_rs->search( { 'me.phone' => \'IS NOT NULL' } )->count;
        }
        else {
            $label = 'Passaram Instagram';
            $value = $recipient_rs->search( { 'me.instagram' => \'IS NOT NULL' } )->count;
        }
        push @contact_metrics, {label => $label, value => $value};
    }
    push @metrics, { sub_group => 'Passaram contato após bloco A', metrics => \@contact_metrics };

    return $c->render(
        status => 200,
        json   => {
            metrics => \@metrics
        }
    );
}

1;
