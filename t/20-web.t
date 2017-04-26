#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Mojo;
use TagNotes::Util qw(write_file shorten);
use File::Tempdir;
use UUID::Tiny ':std';
use Mojo::DOM;

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

quux
EOF
write_file("$ndn/note_$n1_uuid.md", $n1_content);
my $n2_content  = <<'EOF';
sort: 2
tags: foo, bar quux
---
# Hello world!
This is *text*
and it is long and it is long and it is long and it is long and it is long
and it is long and it is long and it is long and it is long and it is long
EOF
write_file("$ndn/note_$n2_uuid.md", $n2_content);

# prepare tester
$ENV{TAGNOTES_NOTES_DIR} = $notes_dir->name;
use FindBin '$Bin';
require "$Bin/../tagnotes";
my $t = Test::Mojo->new;

# access note objects
my ($n1, $n2) = map {$t->app->tagnotes->get_note($_)} $n1_uuid, $n2_uuid;

subtest 'Note listing' => sub {

    $t->get_ok('/')->status_is(200)->text_is(title => 'TagNotes - Notes');
    $t->element_count_is('.notes .note' => 2);
    $t->text_is('.note:first-child .caption h2' => '');
    $t->text_is('.note:first-child .caption p' => $n1->get_body_text);
    $t->text_is('.note:nth-child(2) .caption h2' => $n2->get_name);
    $t->text_is('.note:nth-child(2) .caption p' =>
        shorten($n2->get_body_text, 150));

    my $l1 = $t->tx->res->dom->at('.note:first-child .caption');
    is $l1->children('h2')->first->text => '', 'Correct headline in first link';
    is $l1->attr('href') => $t->app->url_for(note => {uuid => $n1->uuid}),
        'Correct URL in first link';

    my $l2 = $t->tx->res->dom->at('.note:nth-child(2) .caption');
    is $l2->children('h2')->first->text => $n2->get_name,
        'Correct headline in second link';
    is $l2->attr('href') => $t->app->url_for(note => {uuid => $n2->uuid}),
        'Correct URL in second link';
};

subtest 'First note' => sub {
    $t->get_ok("/note/$n1_uuid")->status_is(200);
    $t->text_is(title => 'TagNotes - ');
    is $t->tx->res->dom->at('.main')->children->map('to_string')->join(' ') =>
        $n1->get_html, 'Correct HTML';
};

subtest 'Second note' => sub {
    $t->get_ok("/note/$n2_uuid")->status_is(200);
    $t->text_is(title => 'TagNotes - ' . $n2->get_name);
    is $t->tx->res->dom->at('.main')->children->map('to_string')->join(' ') =>
        $n2->get_html, 'Correct HTML';
};

done_testing;
