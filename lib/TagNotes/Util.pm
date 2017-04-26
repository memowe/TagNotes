package TagNotes::Util;
use Mojo::Base 'Mojolicious::Plugin';

# This file has a traditional exporter interface (exports functions)
# and works also as a Mojolicious::Plugin which registers these functions
# as helpers in the web app

use strict;
use warnings;

use Exporter 'import';

our @EXPORT_OK = qw(read_file shorten trim write_file);

sub register {
    my ($self, $app, $conf) = @_;

    # inject exportable functions as helpers
    for my $fn (@EXPORT_OK) {
        no strict 'refs';
        $app->helper($fn => sub {shift; *{$fn}->(@_)});
    }
}

sub read_file {
    my $path = shift;
    open my $fh, '<', $path or die "Couldn't open '$path': $!\n";
    return do {local $/; <$fh>};
}

sub shorten {
    my ($str, $max_length) = @_;
    $max_length //= 160;

    # nothing to do
    return $str if length $str <= $max_length;

    # shorten
    return substr($str, 0, $max_length - 3) . '...';
}

sub trim {
    my $str = shift;

    # delete whitespace from start and beginning
    $str =~ s/^\s+//;
    $str =~ s/\s+$//;

    # simplify whitespace inbetween
    $str =~ s/\s\s+/ /g;

    # done
    return $str;
}

sub write_file {
    my ($path, $content) = @_;
    open my $fh, '>', $path or die "Couldn't open '$path': $!\n";
    print $fh $content;
}

1;
__END__
