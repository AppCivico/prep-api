package Prep;
use Mojo::Base 'Mojolicious';

use Prep::Routes;
use Prep::Authentication;
use Prep::Authorization;
use Prep::Controller;
use Prep::SchemaConnected;

sub startup {
    my $self = shift;

    # Plugins.
    $self->plugin('Detach');
	$self->plugin('ParamLogger', filter => [qw(password)]);

    $self->plugin('SimpleAuthentication', {
        load_user     => sub { Prep::Authentication::load_user(@_)     },
        validate_user => sub { Prep::Authentication::validate_user(@_) },
    });

    $self->plugin(
        authorization => {
            has_priv    => sub { return Prep::Authorization->has_priv(@_)   },
            is_role     => sub { return Prep::Authorization->is_role(@_)    },
            user_privs  => sub { return Prep::Authorization->user_privs(@_) },
            user_role   => sub { return Prep::Authorization->user_role(@_)  },
            fail_render => Prep::Authorization->fail_render(),
        }
    );

    # Helpers.
    $self->helper(schema => sub { state $schema = Prep::SchemaConnected->get_schema(@_) });

    # Overwrite default helpers.
    $self->controller_class('Prep::Controller');
    $self->helper('reply.exception' => sub { Prep::Controller::reply_exception(@_) });
    $self->helper('reply.not_found' => sub { Prep::Controller::reply_not_found(@_) });

    # Router.
    Prep::Routes::register($self->routes);
}

1;
