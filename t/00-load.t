#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 1;

BEGIN {
    use FindBin;
    require_ok "$FindBin::Bin/../tagnotes";
}

diag "Testing TagNotes, Perl $], $^X";
