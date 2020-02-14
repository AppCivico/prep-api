package WebService::AssistenteCivico;
use common::sense;
use MooseX::Singleton;

use JSON::MaybeXS;
use Furl;
use Try::Tiny::Retry;
use Prep::Utils qw(is_test);
use Prep::Logger;

has 'ua' => ( is => 'rw', lazy => 1, builder => '_build_ua' );
has logger => (
    is      => 'rw',
    lazy    => 1,
    builder => '_build_logger',
);

sub _build_ua { Furl->new() }
sub _build_logger { &get_logger }

sub get_metrics {
    my ($self, %opts) = @_;

    my $logger = $self->logger;

    my $since = $opts{since};
    my $until = $opts{until};

    my $url = 'https://dapi-assistente.appcivico.com' . '/api/metrics';

    $url .= '?chatbot_id=' . '226';
    $url .= '&security_token=' . 'prep-dev';
    $url .= '&since=' . $since if $since;
    $url .= '&until=' . $until if $until;


    $logger->info("url: $url");
    if (is_test()) {
        return {
            most_used_intents => [
                "saude",
                "foobar",
                "mobilidade_urbana",
                "default fallback intent"
            ],
            most_used_intents_target_audience => [
                "saude",
                "mobilidade_urbana",
                "default fallback intent"
            ],
            recipients_with_fallback_intent => 3,
            recipients_with_intent          => 10
        };
    }
    else {
        my $res;
        eval {
            retry {
                $res = $self->ua->get(
                    $url,
                    [],
                    {
                        chatbot_id     => $ENV{ASSISTENTE_CIVICO_CHATBOT_ID},
                        security_token => $ENV{ASSISTENTE_CIVICO_METRICS_SECURITY_TOKEN},

                        ($since ? (since => $since) : ()),
                        ($until ? (until => $until) : ()),
                    }
                );

                die $res->decoded_content unless $res->is_success;

                my $response = decode_json( $res->decoded_content );
            }
            retry_if { shift() < 3 } catch { die $_; };
        };
        die $@ if $@;

        return decode_json( $res->decoded_content );
    }
}

1;
