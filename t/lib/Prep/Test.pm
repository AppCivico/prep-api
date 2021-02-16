package Prep::Test;

use Test::More;
use Test::Mojo;
use Data::Printer;

use Mojo::Util qw(monkey_patch);

our ($calendar_event_get, $calendar_event_post, $event_deletion_response);

monkey_patch 'Test::Mojo', or_die => sub {
    my $t = shift;

    if (!$t->success()) {
        my (undef, $file, $line) = caller;

        p $t->tx->res->to_string;
        BAIL_OUT("Fail at line $line in $file.");
    }
};


sub import {
    strict->import;
    warnings->import;

    no strict 'refs';

    my $caller = caller;

    while (my ($name, $symbol) = each %{__PACKAGE__ . '::'}) {
        next if $name eq 'BEGIN';
        next if $name eq 'import';
        next unless *{$symbol}{CODE};

        my $imported = $caller . '::' . $name;
        *{$imported} = \*{$symbol};
    }
}

my $t = Test::Mojo->new('Prep');

sub test_instance { $t }

sub get_schema { app()->schema }

sub app { $t->app }

sub db_transaction (&) {
    my ($code) = @_;

    my $schema = get_schema;
    eval {
        $schema->txn_do(
            sub {
                $code->();
                die 'rollback';
            }
        );
    };
    die $@ unless $@ =~ m{rollback};
}

sub api_auth_as {
    my (%args) = @_;

    if (exists $args{user_id}) {
        my $user_id = $args{user_id};

        my $schema = get_schema;
        my $user = $schema->resultset('User')->find($user_id);

        my $user_session = $user->new_session();

        $t->ua->on(start => sub {
            my ($ua, $tx) = @_;
            $tx->req->headers->header('X-API-Key' => $user_session->{api_key});
        });
    }
    elsif (exists $args{nobody}) {
        $t->ua->on(start => sub {
            my ($ua, $tx) = @_;
            $tx->req->headers->remove('X-API-Key');
        });
    }
    else {
        die __PACKAGE__ . ": invalid params for 'api_auth_as'";
    }

    return $user_session;
}

sub setup_calendar_event_get {
    $calendar_event_get = {
        "kind" => "calendar#events",
        "etag" => "p3349f9cgu63e00g",
        "summary" => "prep_dev",
        "description" => "Agenda de dev do prep",
        "updated" => "2019-01-24T16 =>54 =>57.709Z",
        "timeZone" => "America/Sao_Paulo",
        "accessRole" => "owner",
        "defaultReminders" => [],
        "nextSyncToken" => "CMiXpZDxhuACEMiXpZDxhuACGAU=",
        "items" => [
            {
                "kind" => "calendar#event",
                "etag" => "3096697795418000",
                "id" => "fakeevent2",
                "status" => "confirmed",
                "htmlLink" => "https://www.google.com/calendar/event?eid=ZmFrZWV2ZW50MiBlb2tvZS5jb21fbzEzZTZjNDZoYXRtZ2VkODBvdm5zOGxlNmNAZw",
                "created" => "2019-01-24T16:54:57.000Z",
                "updated" => "2019-01-24T16:54:57.709Z",
                "description" => "\n\nvoucher : AAAAAAAA\n,\n\nagendamento_chatbot : 1\n,\n\nNos últimos doze meses, você teve relações sexuais com algum parceiro (homem ou mulher transexual ou travesti) que você considera fixo? : Sim\n,\n\nConsiderando só seus parceiros homens: nos últimos doze meses, quantos parceiros casuais você teve? : 3\n,\n\nNos últimos doze meses, alguma vez você recebeu dinheiro, presentes ou favores para fazer sexo? : Sim\n,\n\nEstá rolando uma pesquisa bafônica com o pessoal da USP (Universidade de São Paulo) para te acompanhar nesse nessa lacração doida que você vive. Que tal?\\n\\nAqui você pode ler um artigo completo do professor da USP explicando sobre a pesquisa. : Não tenho interesse\n\n\n",
                "creator" => {
                    "email" => "lucas.ansei@appcivico.com",
                    "displayName" => "Lucas Ansei"
                },
                "organizer" => {
                    "email" => "eokoe.com_o13e6c46hatmged80ovns8le6c@group.calendar.google.com",
                    "displayName" => "prep_dev",
                    "self" => true
                },
                "start" => {
                    "dateTime" => "2019-01-25T14:00:00-02:00",
                    "timeZone" => "America/Sao_Paulo"
                },
                "end" => {
                    "dateTime" => "2019-01-25T15:00:00-02:00",
                    "timeZone" => "America/Sao_Paulo"
                },
                "iCalUID" => "fakeevent2@google.com",
                "sequence" => 0,
                "reminders" => {
                    "useDefault" => true
                }
            },
            {
                "kind" => "calendar#event",
                "etag" => "3096697795418000",
                "id" => "fakeevent2",
                "status" => "confirmed",
                "htmlLink" => "https://www.google.com/calendar/event?eid=ZmFrZWV2ZW50MiBlb2tvZS5jb21fbzEzZTZjNDZoYXRtZ2VkODBvdm5zOGxlNmNAZw",
                "created" => "2019-01-24T16:54:57.000Z",
                "updated" => "2019-01-24T16:54:57.709Z",
                "description" => "\n\nvoucher : 1573221416102831\n,\n\n\nNos últimos doze meses, você teve relações sexuais com algum parceiro (homem ou mulher transexual ou travesti) que você considera fixo? : Sim\n,\n\nConsiderando só seus parceiros homens: nos últimos doze meses, quantos parceiros casuais você teve? : 3\n,\n\nNos últimos doze meses, alguma vez você recebeu dinheiro, presentes ou favores para fazer sexo? : Sim\n,\n\nEstá rolando uma pesquisa bafônica com o pessoal da USP (Universidade de São Paulo) para te acompanhar nesse nessa lacração doida que você vive. Que tal?\\n\\nAqui você pode ler um artigo completo do professor da USP explicando sobre a pesquisa. : Não tenho interesse\n\n\n",
                "creator" => {
                    "email" => "lucas.ansei@appcivico.com",
                    "displayName" => "Lucas Ansei"
                },
                "organizer" => {
                    "email" => "eokoe.com_o13e6c46hatmged80ovns8le6c@group.calendar.google.com",
                    "displayName" => "prep_dev",
                    "self" => true
                },
                "start" => {
                    "dateTime" => "2019-01-25T15:30:00-02:00",
                    "timeZone" => "America/Sao_Paulo"
                },
                "end" => {
                    "dateTime" => "2019-01-25T16:00:00-02:00",
                    "timeZone" => "America/Sao_Paulo"
                },
                "iCalUID" => "fakeevent2@google.com",
                "sequence" => 0,
                "reminders" => {
                    "useDefault" => true
                }
            },
            {
                "kind" => "calendar#event",
                "etag" => "3096697795418000",
                "id" => "fakeevent3",
                "status" => "confirmed",
                "htmlLink" => "https://www.google.com/calendar/event?eid=ZmFrZWV2ZW50MiBlb2tvZS5jb21fbzEzZTZjNDZoYXRtZ2VkODBvdm5zOGxlNmNAZw",
                "created" => "2019-01-24T16:54:57.000Z",
                "updated" => "2019-01-24T16:54:57.709Z",
                "description" => "\n\ndeletado: 1\n,\n\n\nappointment_id: 56\n,\n\n\nagendamento_chatbot: 1\n,\n\n\nvoucher : 1573221416102831\n,\n\n\nNos últimos doze meses, você teve relações sexuais com algum parceiro (homem ou mulher transexual ou travesti) que você considera fixo? : Sim\n,\n\nConsiderando só seus parceiros homens: nos últimos doze meses, quantos parceiros casuais você teve? : 3\n,\n\nNos últimos doze meses, alguma vez você recebeu dinheiro, presentes ou favores para fazer sexo? : Sim\n,\n\nEstá rolando uma pesquisa bafônica com o pessoal da USP (Universidade de São Paulo) para te acompanhar nesse nessa lacração doida que você vive. Que tal?\\n\\nAqui você pode ler um artigo completo do professor da USP explicando sobre a pesquisa. : Não tenho interesse\n\n\n",
                "creator" => {
                    "email" => "lucas.ansei@appcivico.com",
                    "displayName" => "Lucas Ansei"
                },
                "organizer" => {
                    "email" => "eokoe.com_o13e6c46hatmged80ovns8le6c@group.calendar.google.com",
                    "displayName" => "prep_dev",
                    "self" => true
                },
                "start" => {
                    "dateTime" => "2019-01-25T16:30:00-02:00",
                    "timeZone" => "America/Sao_Paulo"
                },
                "end" => {
                    "dateTime" => "2019-01-25T17:00:00-02:00",
                    "timeZone" => "America/Sao_Paulo"
                },
                "iCalUID" => "fakeevent3@google.com",
                "sequence" => 0,
                "reminders" => {
                    "useDefault" => true
                }
            }
        ]
    }
}

sub setup_calendar_event_post {
    $calendar_event_post = {
        "kind" => "calendar#event",
        "etag" => "3096697795418000",
        "id" => "fakeevent2",
        "status" => "confirmed",
        "htmlLink" => "https =>//www.google.com/calendar/event?eid=ZmFrZWV2ZW50MiBlb2tvZS5jb21fbzEzZTZjNDZoYXRtZ2VkODBvdm5zOGxlNmNAZw",
        "created" => "2019-01-24T16 =>54 =>57.000Z",
        "updated" => "2019-01-24T16 =>54 =>57.709Z",
        "description" => "foobar",
        "creator" => {
            "email" => "lucas.ansei@appcivico.com",
            "displayName" => "Lucas Ansei"
        },
        "organizer" => {
            "email" => "eokoe.com_o13e6c46hatmged80ovns8le6c@group.calendar.google.com",
            "displayName" => "prep_dev",
            "self" => true
        },
        "start" => {
            "dateTime" => "2019-01-25T14 =>00 =>00-02 =>00",
            "timeZone" => "America/Sao_Paulo"
        },
        "end" => {
            "dateTime" => "2019-01-25T15 =>00 =>00-02 =>00",
            "timeZone" => "America/Sao_Paulo"
        },
        "iCalUID" => "fakeevent2@google.com",
        "sequence" => 0,
        "reminders" => {
            "useDefault" => true
        }
    }
}

sub setup_calendar_event_delete {
    $event_deletion_response = {}
}

1;