#!/usr/bin/perl -w

use strict;

use XML::LibXML;

use XML::LibXML::Common qw(:w3c);

use ScmCompare qw(xml_node_contents_to_string);

my $parser = XML::LibXML->new();

$parser->validation(1);

my $dom = $parser->parse_file("./scm-comparison.xml");

my $root_elem = $dom->getDocumentElement();
my ($contents_elem) = $root_elem->getChildrenByTagName("contents");
my ($top_section_elem) = $contents_elem->getChildrenByTagName("section");

if (! -e "docbook")
{
    mkdir("docbook");
}
open O, ">docbook/scm-comparison.xml";
print O <<"EOF";
<?xml version="1.0" encoding="iso-8859-1"?>
<!DOCTYPE article PUBLIC "-//OASIS//DTD DocBook XML V4.1.2//EN"
"/usr/share/sgml/docbook/xml-dtd-4.1.2/docbookx.dtd"[
]>
<article>

EOF

my @impls = @{ScmCompare::get_implementations($root_elem)};
my %impls_to_indexes = (map { $impls[$_]->{'id'} => $_ } (0 .. $#impls));

my %names = (map { $_->{'id'} => $_->{'name'} } @impls);

sub name
{
    my $id = shift;
    return $names{$id};
}

sub sorter
{
    my $impl = shift;

    if (!exists($impls_to_indexes{$impl}))
    {
        die "Unknown system $impl";
    }
    return $impls_to_indexes{$impl};
}

sub html_to_docbook
{
    my $parent_node = shift;
    my $not_first = shift;
    my @child_nodes = $parent_node->childNodes();
    my $ret = "";

    foreach my $node (@child_nodes)
    {
        if ($node->nodeType() == ELEMENT_NODE())
        {            
            if ($node->nodeName() eq "a")
            {
                $ret .= "<ulink url=\"" . $node->getAttribute("href") . "\">";
            }
            else
            {
                my @attrs = $node->attributes();
                $ret .= "<" . $node->nodeName() . " " . join(" ", map { "$_=\"".$node->getAttribute($_)."\""} @attrs) . ">";
            }
            $ret .= html_to_docbook($node, 1);

            if ($node->nodeName() eq "a")
            {
                $ret .= "</ulink>";
            }
            else
            {
                $ret .= "</" . $node->nodeName() . ">";
            }
        }
        else
        {
            $ret .= $node->toString();
        }
    }
    # Remove leading and trailing space.
    if (1)
    {
        $ret =~ s!^\s+!!mg;
        $ret =~ s/\s+$//mg;
    }
    return $ret;
    
}

my $document_text = "";

sub out
{
    $document_text .= join("", @_);
}

sub render_section
{
    my $section_elem = shift;
    my $depth = shift || 0;

    my ($expl) = $section_elem->getChildrenByTagName("expl");
    my ($title) = $section_elem->getChildrenByTagName("title");
    my ($compare) = $section_elem->getChildrenByTagName("compare");

    my $title_string = $title->string_value();

    my $id = $section_elem->getAttribute("id");
    
    my $d = $depth+1;
    if ($depth)
    {
        out("<section id=\"$id\">\n");
    }

    out("<title>$title_string</title>\n");

    if ($expl)
    {
        out("<para>\n" . xml_node_contents_to_string($expl) . "\n</para>\n");
    }

    if ($compare)
    {
        out("<table frame=\"all\">\n");
        out("<title>Comparison - $title_string</title>\n");
        out("<tgroup cols=\"2\" align=\"left\" colsep=\"1\" rowsep=\"1\">\n");
        out("<colspec colname=\"system\" />\n");
        out("<colspec colname=\"description\" />\n");
        out("<thead>\n<row>\n<entry><emphasis>System</emphasis></entry>\n" .
            "<entry><emphasis>Description</emphasis></entry>\n" .
            "</row>\n</thead>\n");
        out("<tbody>\n");
        my @systems = ($compare->getChildrenByTagName("s"));
        my %kv = (map { $_->getAttribute("id") => html_to_docbook($_) } @systems);
        my @keys_sorted = (sort { sorter($a) <=> sorter($b) } keys(%kv));
        foreach my $k (@keys_sorted)
        {
            out("<row>\n<entry>" . name($k) . "</entry>\n" .
                "<entry>\n" . $kv{$k} . "\n</entry>\n</row>\n");
        }
        out("</tbody>\n</tgroup>\n</table>\n");
    }

    my @sub_sections = $section_elem->getChildrenByTagName("section");

    foreach my $sub (@sub_sections)
    {
        &render_section($sub, $depth+1);
    }

    if ($depth)
    {
        out("</section>\n");
    }    
}

&render_section($top_section_elem);

print O $document_text;

print O "</article>\n";

