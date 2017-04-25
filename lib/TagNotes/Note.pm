package TagNotes::Note;
use Mo qw(required builder);

use Text::Markdown 'markdown';
use Mojo::DOM;
use Mojo::Util 'trim';

has path        => (required => 1);
has uuid        => (builder => '_extract_uuid');
has raw         => (builder => 'read');
has raw_header  => (builder => 'read');
has raw_body    => (builder => 'read');

sub _extract_uuid {
    my $self = shift;
    return unless $self->path =~ /note_([0-9a-f-]+)\.md$/;
    return $1;
}

sub read {
    my $self = shift;

    # slurp from file
    open my $fh, '<', $self->path
        or die "Couldn't open '" . $self->path . "': $!\n";
    my $raw = do {local $/; <$fh>};

    # split via the first '------' line
    my ($header, $body) = split /^-+\R/m => $raw, 2;

    # set attributes
    $self->raw($raw);
    $self->raw_header($header);
    $self->raw_body($body);
    return $raw;
}

sub get_meta_data {
    my $self = shift;

    # iterate header definition lines
    my %meta;
    my $rh = $self->raw_header;
    $meta{$1} = $2 while $rh =~ /^([^:]+): *(.+)$/mg;

    # done
    return \%meta;
}

sub get_tags {
    return [split /,\s*/ => shift->get_meta_data->{tags} // ''];
}

sub get_html {
    return markdown shift->raw_body;
}

sub get_name {
    my $self = shift;

    # prepare
    my $dom = Mojo::DOM->new($self->get_html);

    # try to find a headline
    my $h1 = $dom->at('h1');
    return trim $h1->all_text if defined $h1;

    # no headline: all text
    return trim $dom->all_text;
}

1;
__END__
