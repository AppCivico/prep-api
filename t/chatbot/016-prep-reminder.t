use common::sense;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Prep::Test;
use Prep::Worker::PrepReminder;

use JSON;

my $t      = test_instance;
my $schema = $t->app->schema;

use DDP;

db_transaction {
    my $security_token = $ENV{CHATBOT_SECURITY_TOKEN};

    ok my $category_rs     = $schema->resultset('Category');
    ok my $question_map_rs = $schema->resultset('QuestionMap');
    ok my $question_rs     = $schema->resultset('Question');
    ok my $answer_rs       = $schema->resultset('Answer');

    my $fb_id = '111111';

    my $recipient;
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

        my $recipient_id = $t->tx->res->json->{id};
        $recipient    = $schema->resultset('Recipient')->find($recipient_id);

    };

    subtest 'Set up reminder' => sub {
        my $notification_queue_rs = $schema->resultset('NotificationQueue');

        my $res = $t->put_ok(
            '/api/chatbot/recipient',
            form => {
                security_token       => $security_token,
                fb_id                => $fb_id,
                prep_reminder_before => 1,
                prep_reminder_before_interval => '15:00:00'
            }
        )
        ->status_is(400)
        ->tx->res->json;

        ok $recipient->recipient_flag->update( { is_prep => 1 } );

        ok !defined $recipient->prep_reminder;

        $res = $t->put_ok(
            '/api/chatbot/recipient',
            form => {
                security_token       => $security_token,
                fb_id                => $fb_id,
                prep_reminder_before => 1,
                prep_reminder_before_interval => '17:00:00'
            }
        )
        ->status_is(200)
        ->json_has('/id')
        ->tx->res->json;

        ok my $prep_reminder = $recipient->prep_reminder;

        is $prep_reminder->reminder_before, 1;
        is $prep_reminder->reminder_after, 0;

        is $prep_reminder->reminder_before_interval, '17:00:00';

        is $notification_queue_rs->count, 0;

        ok my $worker = Prep::Worker::PrepReminder->new(
            schema      => $schema,
            logger      => $t->app->log,
            max_process => 1,
        );

        # TODO Será que o alarme deveria sempre valer só para o próximo dia? Será que não deveria validar se tem um horario minimo e dependendo marcar para o dia atual?
        my @queue = $worker->_queue_rs;
        is @queue, 0;

        ok $prep_reminder->update( { reminder_temporal_wait_until => \"NOW() - INTERVAL '10 MINUTES'" } );
        ok $prep_reminder->discard_changes;

        @queue = $worker->_queue_rs;
        is @queue, 1;

        ok $worker->run_once();

        @queue = $worker->_queue_rs;
        is @queue, 0;
        is $notification_queue_rs->count, 1;

        ok my $notification = $notification_queue_rs->next;
        is $notification->type_id, 9, 'before';
        is $notification->prep_reminder_id, $prep_reminder->id;

        # Cancelando alarme
        $res = $t->put_ok(
            '/api/chatbot/recipient',
            form => {
                security_token       => $security_token,
                fb_id                => $fb_id,
                cancel_prep_reminder => 1
            }
        )
        ->status_is(200)
        ->json_has('/id')
        ->tx->res->json;

        ok $prep_reminder->discard_changes;
        is $prep_reminder->reminder_before, 0;
        is $prep_reminder->reminder_after, 0;

        # Ao cancelar o alarme, é cancelada qualquer notificação na fila.
        is $notification_queue_rs->count, 0;

        # Setup alarme pós.
        $res = $t->put_ok(
            '/api/chatbot/recipient',
            form => {
                security_token       => $security_token,
                fb_id                => $fb_id,
                prep_reminder_before => 1,
                prep_reminder_before_interval => '15:46:39.286572',
                prep_reminder_after => 1,
            }
        )
        ->status_is(400)
        ->tx->res->json;

        $res = $t->put_ok(
            '/api/chatbot/recipient',
            form => {
                security_token       => $security_token,
                fb_id                => $fb_id,
                prep_reminder_after => 1,
            }
        )
        ->status_is(400)
        ->tx->res->json;

        @queue = $worker->_queue_rs;
        is @queue, 0;

        $res = $t->put_ok(
            '/api/chatbot/recipient',
            form => {
                security_token       => $security_token,
                fb_id                => $fb_id,
                prep_reminder_after => 1,
                prep_reminder_after_interval => '18:00:00',
            }
        )
        ->status_is(200)
        ->tx->res->json;

        ok $prep_reminder->discard_changes;

        is $prep_reminder->reminder_before, 0;
        is $prep_reminder->reminder_after, 1;

        is $prep_reminder->reminder_before_interval, undef;
        is $prep_reminder->reminder_after_interval, '18:00:00';

        is $notification_queue_rs->count, 0;

        ok $prep_reminder->update( { reminder_temporal_wait_until => \"NOW() - INTERVAL '10 MINUTES'" } );
        ok $prep_reminder->discard_changes;

        @queue = $worker->_queue_rs;
        is @queue, 1;

        ok $worker->run_once;

        @queue = $worker->_queue_rs;
        is @queue, 0;

        is $notification_queue_rs->count, 1;

        db_transaction{
            # Inserindo mais duas notificações para testar trava de 3 notificações por hora.
            for (1 .. 2) {
                my $wait_until;
                if ($_ == 1) {
                    $wait_until = \"NOW() + interval '10 minutes'";
                }
                else {
                    $wait_until = \"NOW() + interval '20 minutes'";
                }

                ok $notification_queue_rs->create(
                    {
                        recipient_id     => $recipient->id,
                        prep_reminder_id => $prep_reminder->id,
                        type_id          => 10,
                        wait_until       => $wait_until
                    }
                );
            }

            ok $prep_reminder->update( { reminder_temporal_wait_until => \"NOW() - INTERVAL '10 MINUTES'" } );
            ok $prep_reminder->discard_changes;

            @queue = $worker->_queue_rs;
            is @queue, 1;

            ok my $wait_until = $prep_reminder->reminder_temporal_wait_until->datetime;

            ok $worker->run_once;
            ok $wait_until ne $prep_reminder->discard_changes->reminder_temporal_wait_until->datetime;
        };

        my $date = DateTime->now;
        $date    = $date->subtract( days => '15' );

        is $notification_queue_rs->count, 1;

        db_transaction{
            $res = $t->put_ok(
            '/api/chatbot/recipient',
                form => {
                    security_token       => $security_token,
                    fb_id                => $fb_id,
                    prep_reminder_running_out => 1,
                    prep_reminder_running_out_date => DateTime->now->ymd,
                    prep_reminder_running_out_count => '1',
                }
            )
            ->status_is(200)
            ->tx->res->json;
        };

        db_transaction{
            is $schema->resultset('NotificationQueue')->count, 1;

            $res = $t->put_ok(
                '/api/chatbot/recipient',
                form => {
                    security_token       => $security_token,
                    fb_id                => $fb_id,
                    prep_reminder_running_out => 1,
                    prep_reminder_running_out_date => DateTime->now->subtract(days => 30)->ymd,
                    prep_reminder_running_out_count => '1',
                }
            )
            ->status_is(200)
            ->tx->res->json;

            ok defined $res->{running_out_date};
            ok defined $res->{running_out_wait_until};

            is $schema->resultset('NotificationQueue')->count, 1;
        };

        $res = $t->put_ok(
            '/api/chatbot/recipient',
            form => {
                security_token       => $security_token,
                fb_id                => $fb_id,
                prep_reminder_running_out => 1,
                prep_reminder_running_out_date => $date->ymd,
                prep_reminder_running_out_count => '2',
            }
        )
        ->status_is(200)
        ->tx->res->json;

        $date = $date->add( days => '5' );

        $res = $t->put_ok(
            '/api/chatbot/recipient',
            form => {
                security_token       => $security_token,
                fb_id                => $fb_id,
                prep_reminder_running_out_date => '2020-03-01',
                prep_reminder_running_out_count => '1',
            }
        )
        ->status_is(200)
        ->tx->res->json;

    };

};

done_testing();
