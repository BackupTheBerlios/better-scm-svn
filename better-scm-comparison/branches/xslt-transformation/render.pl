#!/usr/bin/perl -w

use strict;

use XML::LibXML;

use ScmCompare qw(xml_node_contents_to_string);

my $parser = XML::LibXML->new();

$parser->validation(1);

my $dom = $parser->parse_file("./scm-comparison.xml");

my $stylesheet_url = undef;

my ($style, $style_link);
if ($stylesheet_url)
{
    $style = "<link rel=\"stylesheet\" href=\"$stylesheet_url\" />";
}
else
{
    $style = <<'EOF';
<style type="text/css">
<!--
h2 { background-color : #98FB98; /* PaleGreen */ }
h3 { background-color : #FFA500; /* Orange */ }
table.compare 
{ 
    margin-left : 1em; 
    margin-right : 1em; 
    width: 90%;
    max-width : 40em;
}
.compare td 
{ 
    border-color : black; border-style : solid ; border-width : thin;
    vertical-align : top;
    padding : 0.2em;
}
ul.toc
{
    list-style-type : none ; padding-left : 0em;
}
.toc ul
{
    list-style-type : none ; 
    padding-left : 0em; 
    margin-left : 2em;
}
.expl
{
    border-style : solid ; border-width : thin;
    background-color : #E6E6FA; /* Lavender */
    border-color : black;
    padding : 0.3em;
}
:link:hover { background-color : yellow }
-->
</style>
EOF

}
my $root_elem = $dom->getDocumentElement();

my ($contents_elem) = $root_elem->getChildrenByTagName("contents");
my ($top_section_elem) = $contents_elem->getChildrenByTagName("section");
open O, ">comparison.html";
print O <<"EOF";
<?xml version="1.0" encoding="iso-8859-1"?>
<!DOCTYPE html
     PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="he" lang="he">
<head>
<meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
<title>Version Control Systems Comparison</title>
$style
</head>
<body>
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

my $document_text = "";
my $toc_text = "";

sub out
{
    $document_text .= join("", @_);
}

$toc_text = "<ul class=\"toc\">\n";

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
    out("<h$d><a name=\"$id\" id=\"$id\">$title_string</a></h$d>\n");

    if ($expl)
    {
        out("<p class=\"expl\">\n" . xml_node_contents_to_string($expl) . "\n</p>\n");
    }

    if ($depth == 0)
    {
        out("<<<TOC>>>\n");
    }    

    if ($compare)
    {
        out("<table class=\"compare\">\n");
        my @systems = ($compare->getChildrenByTagName("s"));
        my %kv = 
            (map 
                { $_->getAttribute("id") => xml_node_contents_to_string($_) } 
                @systems
            );
        my @keys_sorted = (sort { sorter($a) <=> sorter($b) } keys(%kv));
        foreach my $k (@keys_sorted)
        {
            out("<tr>\n<td class=\"sys\">" . name($k) . "</td>\n" .
                "<td class=\"desc\">\n" . $kv{$k} . "\n</td>\n</tr>\n");
        }
        out("</table>\n");
    }

    my @sub_sections = $section_elem->getChildrenByTagName("section");

    $toc_text .= "<li><a href=\"#$id\">$title_string</a>";

    if (@sub_sections)
    {
        $toc_text .= "\n<ul>\n";
    }
    foreach my $sub (@sub_sections)
    {
        &render_section($sub, $depth+1);
    }

    if (@sub_sections)
    {
        $toc_text .= "\n</ul>\n";
    }
    $toc_text .= "</li>\n"
}

&render_section($top_section_elem);

$toc_text .= "</ul>\n";

$document_text =~ s!<<<TOC>>>!$toc_text!;

print O $document_text;

print O "\n</body>\n</html>\n";

