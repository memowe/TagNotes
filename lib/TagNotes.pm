package TagNotes;
use Mo qw(required builder);

use TagNotes::Note;

has notes_dir   => (required => 1);
has notes       => (is => 'ro', builder => 'read_notes');

sub read_notes {
    my $self = shift;

    # prepare notes dir reading
    opendir my $ndh, $self->notes_dir
        or die "Couldn't open '" . $self->notes_dir . "': $!\n";
    my @notes;

    # build note objects
    for my $entry (map {$self->notes_dir . "/$_"} readdir $ndh) {
        next unless -e -r -f $entry and $entry =~ /note_[0-9a-f-]+\.md$/;
        push @notes, TagNotes::Note->new(path => $entry)
    }

    # done
    $self->notes(\@notes);
    return $self->notes;
}

1;
__END__
