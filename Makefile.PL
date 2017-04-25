use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    VERSION         => '0.01',
    NAME            => 'TagNotes',
    ABSTRACT        => 'A simple filesystem-based note app using Markdown',
    AUTHOR          => 'Mirko Westermeier <mirko@westermeier.de>',
    LICENSE         => 'mit',
    META_MERGE      => {resources => {
        repository  => 'https://github.com/memowe/TagNotes',
        bugtracker  => 'https://github.com/memowe/TagNotes/issues',
    }},
    PREREQ_PM       => {
        'Mo'                => '0.40',
        'Mojolicious'       => '7.30',
        'Text::Markdown'    => '1.000031',
    },
    TEST_REQUIRES   => {
        'File::Tempdir' => '0.02',
    },
    test => {TESTS => 't/*.t'},
);
