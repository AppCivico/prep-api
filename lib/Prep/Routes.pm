package Prep::Routes;
use strict;
use warnings;

sub register {
    my $r = shift;

    my $api = $r->route('/api');

    # Register.
    my $register = $api->route('/register');
	$register->post('/recipient')->to('register-recipient#post');
	$register->post('/admin')->to('register-admin#post');

    # Login.
    my $login = $api->route('/login');
    $login->post('/')->to('login#post');

    # Login::ForgotPassword
    my $forgot_password = $login->route('/forgot_password');
    $forgot_password->post('/')->to('login-forgot_password#post');

    # Login::Reset
    my $reset = $forgot_password->route('/reset');
    $reset->post('/:token')->to('login-reset#post');

}

1;
