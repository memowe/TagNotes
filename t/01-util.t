#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

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

done_testing;
