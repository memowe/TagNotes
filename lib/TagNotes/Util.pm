package TagNotes::Util;

use strict;
use warnings;

use Exporter 'import';

our @EXPORT_OK = qw(shorten trim);

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

1;
__END__
