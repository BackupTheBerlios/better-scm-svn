package ScmCompare;

use strict;

use XML::LibXML;

require Exporter;

use vars qw(@ISA @EXPORT_OK);
@ISA=qw(Exporter);

@EXPORT_OK = qw(xml_node_contents_to_string);

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

sub xml_node_contents_to_string
{
    my $node = shift;
    my @child_nodes = $node->childNodes();
    my $ret = join("", map { $_->toString() } @child_nodes);
    # Remove leading and trailing space.
    $ret =~ s!^\s+!!mg;
    $ret =~ s/\s+$//mg;
    return $ret;
}

sub _impl_get_name
{
    my $impl_elem = shift;
    my ($name_elem) = $impl_elem->getChildrenByTagName("name");
    return xml_node_contents_to_string($name_elem);
}
sub get_implementations
{
    my $root_elem = shift;
    my ($meta_elem) = $root_elem->getChildrenByTagName("meta");
    my ($implementations_elem) = $meta_elem->getChildrenByTagName("implementations");
    my @impls_elems = $implementations_elem->getChildrenByTagName("impl");
    return [ map { +{'id' => $_->getAttribute("id"), 'name' => _impl_get_name($_)} } @impls_elems ]
}

1;


