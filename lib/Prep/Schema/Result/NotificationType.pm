use utf8;
package Prep::Schema::Result::NotificationType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Prep::Schema::Result::NotificationType

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::PassphraseColumn>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");

=head1 TABLE: C<notification_type>

=cut

__PACKAGE__->table("notification_type");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<notification_type_name_key>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("notification_type_name_key", ["name"]);

=head1 RELATIONS

=head2 notification_queues

Type: has_many

Related object: L<Prep::Schema::Result::NotificationQueue>

=cut

__PACKAGE__->has_many(
  "notification_queues",
  "Prep::Schema::Result::NotificationQueue",
  { "foreign.type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2019-06-03 09:52:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/dfq/exib8B4A8T3+9UfeA


# You can replace this text with custom code or comments, and it will be preserved on regeneration

sub get_info {
    my ($self) = @_;

    my $name = $self->name;
    my ($text, $quick_replies);
    if ($name eq 'quiz_not_finished') {
        $text = 'Bb, vamos terminar seu QUIZ?';
        $quick_replies = [
            {
                content_type => 'text',
                title        => "Voltar para o início",
                payload      => 'greetings'
            },
            {
            content_type => 'text',
            title        => "Terminar quiz",
            payload      => 'beginQuiz'
            },
        ];
    }
    elsif ($name eq 'upcoming_appointment') {
        $text = 'Bafo!Tem uma consulta chegando';
        $quick_replies = [
            {
                content_type => 'text',
                title        => "Voltar para o início",
                payload      => 'greetings'
            }
        ];
    }
    elsif ($name eq 'fa_7_days') {
        $text = 'E ai, BB? Os humanos me informaram que você passou com o médico. Já começou a tomar os remédios?';
        $quick_replies = [
            {
                content_type => 'text',
                title        => 'Sim',
                payload      => 'go_to_A'
            },
            {
                content_type => 'text',
                title        => 'Não',
                payload      => 'go_to_D'
            },
        ];
    }
    elsif ($name eq 'fa_17_days') {
        $text = 'Oiii! Tô passando por aqui para saber de você! Tipo assim: se tá rolando de tomar os remédios, se tá lembrando direitinho, se não tá sentindo nada estranha ou se rolou alguma situação chata por causa da PrEP. E ai, tá tudo bem?';
        $quick_replies = [
            {
                content_type => 'text',
                title        => 'Sim, tá sucesso!',
                payload      => 'yes'
            },
            {
                content_type => 'text',
                title        => 'Não! ☹',
                payload      => 'followup'
            },
        ];
    }
    elsif ($name eq 'ra_15_days') {
        $text = 'Olá Bee, tudo bem? Tô passando por aqui para saber algumas coisinhas sobre como está seu seguimento em PrEP. Posso te fazer umas perguntinhas?';
        $quick_replies = [
            {
                content_type => 'text',
                title        => 'Sim',
                payload      => 'go_to_A'
            },
            {
                content_type => 'text',
                title        => 'Não',
                payload      => 'mainMenu'
            },
        ]
    }
    elsif ($name eq 'ra_45_days') {
        $text = 'Oiii! Tô passando por aqui para saber de você! Tipo assim: se tá rolando de tomar os remédios, se tá lembrando direitinho, se não tá sentindo nada estranha ou se rolou alguma situação chata por causa da PrEP. E ai, tá tudo bem?';
        $quick_replies = [
            {
                content_type => 'text',
                title        => 'Sim, tá sucesso!',
                payload      => 'yes'
            },
            {
                content_type => 'text',
                title        => 'Não! ☹',
                payload      => 'followup'
            },
        ]
    }
    elsif ($name eq '3_month_ra_45_days') {
        $text = 'Oiii! Tô passando por aqui para saber de você! Tipo assim: se tá rolando de tomar os remédios, se tá lembrando direitinho, se não tá sentindo nada estranha ou se rolou alguma situação chata por causa da PrEP. E ai, tá tudo bem?';
        $quick_replies = [
            {
                content_type => 'text',
                title        => 'Sim, tá sucesso!',
                payload      => 'yes'
            },
            {
                content_type => 'text',
                title        => 'Não! ☹',
                payload      => 'followup'
            },
        ]
    }
    elsif ($name eq 'no_appointment_after_7_days_quiz') {
        $text = 'Oi bee! ✌ Tás boua? Eu catei aki q tu se interessou pela pesquisa mas ñ conseguiu ou ñ quis agendar 1 encontro com a nossa ekipe 😐, mas vim aki de bunitahh 💅😎 te oferecer maneiras da gent continuar esse contatinho goxtosu, cata minhas opções de hj, lindee:';
        $quick_replies = [
            {
                content_type => 'text',
                title        => 'Entrar em contato',
                payload      => 'getContact'
            },
            {
                content_type => 'text',
                title        => 'Quero agendar',
                payload      => 'showDays'
            },
            {
                content_type => 'text',
                title        => 'Fale comigo',
                payload      => 'leavePhone'
            }
        ];
    }
    elsif ($name eq 'prep_reminder_before') {
        $text = 'Já tomou seus comprimidos?';
        $quick_replies = [
            {
                content_type => 'text',
                title        => 'Sim',
                payload      => 'notiAlarmeA_Sim'
            },
            {
                content_type => 'text',
                title        => 'Não',
                payload      => 'notiAlarmeA_Nao'
            }
        ];
    }
    elsif ($name eq 'prep_reminder_after') {
        $text = 'Oie! Já tomou seus comprimidos?';
        $quick_replies = [
            {
                content_type => 'text',
                title        => 'Sim',
                payload      => 'notiAlarmeB_Sim'
            },
            {
                content_type => 'text',
                title        => 'Não',
                payload      => 'notiAlarmeB_Nao'
            }
        ];
    }
    else {
        die 'missing dictionary for name=' . $name;
    }

    return {
        text          => $text,
        quick_replies => $quick_replies
    };
}

__PACKAGE__->meta->make_immutable;
1;
