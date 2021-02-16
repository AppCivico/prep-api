package Prep::Logger;
use strict;
use warnings;

use DateTime;
use IO::Handle;
use Log::Log4perl qw(:easy);
use Prep::Utils qw(is_test);
use Mojo::Util qw(monkey_patch);

monkey_patch 'Log::Log4perl::Logger', context => sub { return $_[0] };

my $test_is_folder;
if (@ARGV) {
    $test_is_folder = $ARGV[-1] eq 't' || $ARGV[-1] eq 't/' || $ARGV[-1] eq './t' || $ARGV[-1] eq './t/';
}

if ( $ENV{PREP_API_LOG_DIR} ) {
    if ( -d $ENV{PREP_API_LOG_DIR} ) {
        my $date_now = DateTime->now->ymd('-');

        # vai ter q rever isso, quando é mojo..
        my $app_type = $0 =~ /\.psgi/ ? 'api' : &_extract_basename($0);

        my $log_file = $app_type eq 'api' ? "api.$date_now.$$" : "$app_type.$date_now";

        $ENV{PREP_API_LOG_DIR} = $ENV{PREP_API_LOG_DIR} . "/$log_file.log";
        print STDERR "Redirecting STDERR/STDOUT to $ENV{PREP_API_LOG_DIR}\n";
        close(STDERR);
        close(STDOUT);
        autoflush STDERR 1;
        autoflush STDOUT 1;
        open( STDERR, '>>', $ENV{PREP_API_LOG_DIR} ) or die 'cannot redirect STDERR';
        open( STDOUT, '>>', $ENV{PREP_API_LOG_DIR} ) or die 'cannot redirect STDOUT';

    }
    else {
        print STDERR "PREP_API_LOG_DIR is not a dir\n";
    }
}
else {
    print STDERR "PREP_API_LOG_DIR not configured\n";
}

Log::Log4perl->easy_init(
    {
        level  => $DEBUG,
        layout => ( is_test() && $test_is_folder ? '' : '[%d{dd/MM/yyyy HH:mm:ss.SSS}] [%P] [%p] %m{indent=1}%n' ),
        ( $ENV{PREP_API_LOG_DIR} ? ( file => '>>' . $ENV{PREP_API_LOG_DIR} ) : () ),
        'utf8'    => 1,
        autoflush => 1,

    }
);

our @ISA = qw(Exporter);

our @EXPORT = qw(log_info log_fatal log_error get_logger);

my $logger = get_logger;

# logs
sub log_info {
    my (@texts) = @_;
    $logger->info( join ' ', @texts );
}

sub log_error {
    my (@texts) = @_;
    $logger->error( join ' ', @texts );
}

sub log_fatal {
    my (@texts) = @_;
    $logger->fatal( join ' ', @texts );
}

sub _extract_basename {
    my ($path) = @_;
    my ($part) = $path =~ /.+(?:\/(.+))$/;
    return lc($part);
}

1;
