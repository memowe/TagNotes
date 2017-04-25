use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    VERSION     => '0.01',
    NAME        => 'TagNotes',
    ABSTRACT    => 'A simple filesystem-based note app using Markdown',
    AUTHOR      => 'Mirko Westermeier <mirko@westermeier.de>',
    LICENSE     => 'mit',
    PREREQ_PM   => {
        'Mojolicious'   => '7.30',
    },
    META_MERGE  => {resources => {
        repository  => 'https://github.com/memowe/TagNotes',
        bugtracker  => 'https://github.com/memowe/TagNotes/issues',
    }},
    test => {TESTS => 't/*.t'},
);
