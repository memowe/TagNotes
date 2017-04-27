#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use TagNotes::Util 'write_file';
use File::Tempdir;
use UUID::Tiny ':std';

use_ok 'TagNotes';

# prepare content
my $notes_dir   = File::Tempdir->new;
my $ndn         = $notes_dir->name;
my $n1_uuid     = create_uuid_as_string;
my $n2_uuid     = create_uuid_as_string;
my $n1_content  = <<'EOF';
sort: 1
tags: baz
foo: bar
---
baz

quux
EOF
write_file("$ndn/note_$n1_uuid.md", $n1_content);
my $n2_content  = <<'EOF';
sort: 2
tags: foo, bar quux, baz
---
# Hello world!
This is *text*
EOF
write_file("$ndn/note_$n2_uuid.md", $n2_content);

subtest 'Load notes' => sub {

    # load
    my $tagnotes    = TagNotes->new(notes_dir => $ndn);
    my ($n1, $n2)   = sort {$a->raw cmp $b->raw} @{$tagnotes->get_all_notes};
    is $tagnotes->get_note($n1_uuid) => $n1, 'First note found';
    is $tagnotes->get_note($n2_uuid) => $n2, 'Second note found';

    subtest 'Inspect first note' => sub {
        isa_ok $n1 => 'TagNotes::Note';
        is $n1->uuid => $n1_uuid, 'Correct UUID';
        is $n1->path => "$ndn/note_$n1_uuid.md", 'Correct path';
        is $n1->raw => $n1_content, 'Correct raw content';
        is $n1->raw_header => "sort: 1\ntags: baz\nfoo: bar\n",
            'Correct raw header';
        is $n1->raw_body => "baz\n\nquux\n", 'Correct raw body';
        is_deeply $n1->get_meta_data =>
            {sort => 1, foo => 'bar', tags => 'baz'}, 'Correct meta data';
        is_deeply $n1->get_tags => ['baz'], 'Correct tags';
        is $n1->get_html => "<p>baz</p> <p>quux</p>", 'Correct HTML';
        is $n1->get_name => undef, 'No name';
        is $n1->get_body_text => "baz quux", 'Correct body text';
    };

    subtest 'Inspect second note' => sub {
        isa_ok $n2 => 'TagNotes::Note';
        is $n2->uuid => $n2_uuid, 'Correct UUID';
        is $n2->path => "$ndn/note_$n2_uuid.md", 'Correct path';
        is $n2->raw => $n2_content, 'Correct raw content';
        is $n2->raw_header => "sort: 2\ntags: foo, bar quux, baz\n",
            'Correct raw header';
        is $n2->raw_body => "# Hello world!\nThis is *text*\n",
            'Correct raw body';
        is_deeply $n2->get_meta_data =>
            {sort => 2, tags => 'foo, bar quux, baz'}, 'Correct meta data';
        is_deeply $n2->get_tags => ['bar quux','baz', 'foo'], 'Correct tags';
        is $n2->get_html =>
            '<h1>Hello world!</h1> <p>This is <em>text</em></p>',
            'Correct HTML';
        is $n2->get_name => 'Hello world!', 'Correct name';
        is $n2->get_body_text => 'This is text', 'Correct body text';
    };

    subtest 'Tag index' => sub {
        is_deeply $tagnotes->get_tag_notes('foo') => [$n2], 'Correct foo notes';
        my $baz_notes = $tagnotes->get_tag_notes('baz');
        my @baz_notes = sort {$a->raw cmp $b->raw} @$baz_notes;
        is_deeply \@baz_notes => [$n1, $n2], 'Correct baz notes';
        is_deeply $tagnotes->get_tag_notes('bar') => [], 'No bar notes';
    };
};

done_testing;
