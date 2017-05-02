package TagNotes;
use Mo qw(required default build);

use TagNotes::Note;

has notes_dir       => (required => 1);
has _note           => {}; # {uuid => Note}
has _notes_by_tag   => {}; # {tag => {uuid => Note}}

sub BUILD {
    my $self = shift;

    # prepare notes dir reading
    opendir my $ndh, $self->notes_dir
        or die "Couldn't open '" . $self->notes_dir . "': $!\n";
    my %note;

    # import notes
    for my $entry (map {$self->notes_dir . "/$_"} readdir $ndh) {
        next unless -e -r -f $entry and $entry =~ /note_[0-9a-f-]+\.md$/;

        # create
        my $note = TagNotes::Note->new(path => $entry);
        $self->_note->{$note->uuid} = $note;

        # build tag index
        $self->_notes_by_tag->{$_}{$note->uuid} = $note
            for @{$note->get_tags};
    }
}

sub get_note {
    my ($self, $uuid) = @_;
    return $self->_note->{$uuid};
}

sub get_all_notes {
    my $self = shift;
    return [values %{$self->_note}];
}

sub get_tag_notes {
    my ($self, $tag) = @_;
    return [values %{$self->_notes_by_tag->{$tag} // {}}];
}

sub get_all_tags {
    my $self = shift;
    return [sort keys %{$self->_notes_by_tag // {}}];
}

# tag cloud {tag => note count} (for a given list)
sub get_tag_cloud {
    my ($self, $tags) = @_;

    # no tags: get all tags
    $tags //= $self->get_all_tags;

    # transform {uuid => note} to uuid count
    my %notes_per_tag;
    for my $tag (@$tags) {
        $notes_per_tag{$tag} = @{$self->get_tag_notes($tag)};
    }

    # done
    return \%notes_per_tag;
}

# loads tags of notes which have the given tag
sub get_related_tags {
    my ($self, $tag) = @_;

    # iterate related notes
    my %tags;
    for my $note (@{$self->get_tag_notes($tag)}) {
        $tags{$_} = 1 for @{$note->get_tags};
    }

    # done
    return [sort keys %tags];
}

1;
__END__
