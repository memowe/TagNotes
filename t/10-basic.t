#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use File::Tempdir;
use UUID::Tiny ':std';

use_ok 'TagNotes';

sub write_file {
    my ($path, $content) = @_;
    open my $fh, '>', $path or die "Couldn't open '$path': $!\n";
    print $fh $content;
}

# prepare content
my $notes_dir   = File::Tempdir->new;
my $ndn         = $notes_dir->name;
my $n1_uuid     = create_uuid_as_string;
my $n2_uuid     = create_uuid_as_string;
my $n1_content  = <<'EOF';
sort: 1
foo: bar
---
baz
EOF
write_file("$ndn/note_$n1_uuid.md", $n1_content);
my $n2_content  = <<'EOF';
sort: 2
tags: foo, bar quux
---
# Hello world!
This is *text*
EOF
write_file("$ndn/note_$n2_uuid.md", $n2_content);

subtest 'Load notes' => sub {

    # load
    my $tagnotes    = TagNotes->new(notes_dir => $ndn);
    my ($n1, $n2)   = sort {$a->raw cmp $b->raw} @{$tagnotes->notes};

    subtest 'Inspect first note' => sub {
        isa_ok $n1 => 'TagNotes::Note';
        is $n1->path => "$ndn/note_$n1_uuid.md", 'Correct path';
        is $n1->raw => $n1_content, 'Correct raw content';
        is $n1->raw_header => "sort: 1\nfoo: bar\n", 'Correct raw header';
        is $n1->raw_body => "baz\n", 'Correct raw body';
        is_deeply $n1->get_meta_data => {sort => 1, foo => 'bar'},
            'Correct meta data';
        is_deeply $n1->get_tags => [], 'Correct tags';
        is $n1->get_html => "<p>baz</p>\n", 'Correct HTML';
    };

    subtest 'Inspect second note' => sub {
        isa_ok $n2 => 'TagNotes::Note';
        is $n2->path => "$ndn/note_$n2_uuid.md", 'Correct path';
        is $n2->raw => $n2_content, 'Correct raw content';
        is $n2->raw_header => "sort: 2\ntags: foo, bar quux\n",
            'Correct raw header';
        is $n2->raw_body => "# Hello world!\nThis is *text*\n",
            'Correct raw body';
        is_deeply $n2->get_meta_data => {sort => 2, tags => 'foo, bar quux'},
            'Correct meta data';
        is_deeply $n2->get_tags => ['foo', 'bar quux'], 'Correct tags';
        is $n2->get_html => <<'HTML', 'Correct HTML';
<h1>Hello world!</h1>

<p>This is <em>text</em></p>
HTML
    };
};

done_testing;
