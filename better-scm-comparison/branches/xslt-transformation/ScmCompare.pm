package ScmCompare;

use strict;

my @impls = 
(
    {
        'id' => "cvs",
        'name' => "CVS",
    },
    {
        'id' => "aegis",
        'name' => "Aegis",
    },
    {
        'id' => "arch",
        'name' => "Arch",
    },
    {
        'id' => "bitkeeper",
        'name' => "BitKeeper", 
    },
    {
        'id' => "cmsynergy",
        'name' => "CMSynergy",
    },
    {
        'id' => "co-op",
        'name' => "Co-Op",
    },
    {
        'id' => "monotone",
        'name' => "Monotone",
    },
    {
        'id' => "opencm",
        'name' => "OpenCM",
    },
    {
        'id' => "perforce",
        'name' => "Perforce",
    },
    {
        'id' => "subversion",
        'name' => "Subversion",
    },
    {
        'id' => "svk",
        'name' => "svk",
    },
    {
        'id' => "vesta",
        'name' => "Vesta",
    },
    {
        'id' => "vss",
        'name' => "Visual SourceSafe",
    },
);

sub get_implementations
{
    return \@impls;
}

1;


