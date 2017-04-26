package TagNotes::Util;

use strict;
use warnings;

use Exporter 'import';

our @EXPORT_OK = qw(read_file shorten trim write_file);

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
