#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use File::Temp 'tempfile';

subtest 'read_file' => sub {
    use_ok 'TagNotes::Util', 'read_file';

    # prepare
    my $file    = File::Temp->new;
    my $fn      = $file->filename;

    # roundtrip
    open my $fh, '>', $fn or die "Couldn't open '$fn': $!\n";
    print $fh 'foo';
    close $fh; # make sure writing is done
    is read_file($fn) => 'foo', 'Correct file content';
};

subtest 'shorten' => sub {
    use_ok 'TagNotes::Util', 'shorten';
    is shorten('1234567890', 6) => '123...', 'Shortened to 6';
    is shorten('1234567890', 10) => '1234567890', 'Did nothing (exact length)';
    is shorten('1234567890', 15) => '1234567890', 'Did nothing (too long)';
    is shorten('s' x 500) => shorten('s' x 500, 160), 'Correct default length';
};

subtest 'trim' => sub {
    use_ok 'TagNotes::Util', 'trim';
    is trim("  \n foo\n  \nbar ") => 'foo bar', 'Trimmed correctly';
};

subtest 'write_file' => sub {
    use_ok 'TagNotes::Util', 'write_file';

    # prepare
    my $file    = File::Temp->new;
    my $fn      = $file->filename;

    # roundtrip
    write_file($fn, 'foo');
    open my $fh, '<', $fn or die "Couldn't open '$fn': $!\n";
    is do {local $/; <$fh>} => 'foo', 'Correct file content';
};

done_testing;
