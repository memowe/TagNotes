package TagNotes::Note;
use Mo qw(required build builder);

use Text::Markdown 'markdown';
use Mojo::DOM;
use TagNotes::Util 'trim';

has path        => (required => 1);
has uuid        => (builder => '_extract_uuid');
has raw         => (is => 'ro');
has raw_header  => (is => 'ro');
has raw_body    => (is => 'ro');

sub _extract_uuid {
    my $self = shift;
    return unless $self->path =~ /note_([0-9a-f-]+)\.md$/;
    return $1;
}

sub BUILD {
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
    return trim markdown shift->raw_body;
}

sub get_name {
    my $self = shift;

    # try to find a headline
    my $dom = Mojo::DOM->new($self->get_html);
    my $h1  = $dom->at('h1');
    return trim $h1->all_text if defined $h1;

    # no headline: nothing
    return;
}

sub get_body_text {
    my $self = shift;

    # remove ehe headline, if any
    my $dom = Mojo::DOM->new($self->get_html);
    my $h1  = $dom->at('h1');
    $h1->remove if defined $h1;

    # remaining text
    return trim $dom->all_text;
}

1;
__END__
