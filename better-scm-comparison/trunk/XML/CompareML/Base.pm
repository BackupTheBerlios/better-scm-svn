package XML::CompareML::Base;

use strict;

use XML::LibXML;

use base qw(Class::Accessor);

__PACKAGE__->mk_accessors(qw(timestamp));

sub new
{
    my $class = shift;
    my $self = {};
    bless $self, $class;
    $self->_initialize(@_);
    return $self;
}

sub xml_node_contents_to_string
{
    my $self = shift;
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
    my $self = shift;
    my $impl_elem = shift;
    my ($name_elem) = $impl_elem->getChildrenByTagName("name");
    return $self->xml_node_contents_to_string($name_elem);
}

sub get_implementations
{
    my $self = shift;
    my $root_elem = $self->{root_elem};
    my ($meta_elem) = $root_elem->getChildrenByTagName("meta");
    my ($implementations_elem) = $meta_elem->getChildrenByTagName("implementations");
    my @impls_elems = $implementations_elem->getChildrenByTagName("impl");
    return [ map { +{'id' => $_->getAttribute("id"), 'name' => $self->_impl_get_name($_)} } @impls_elems ]
}

sub get_timestamp
{
    my $self = shift;
    my $root_elem = $self->{root_elem};
    my @nodes = $root_elem->findnodes("/comparison/meta/timestamp");
    if (@nodes)
    {
        return $self->xml_node_contents_to_string($nodes[0]);
    }
    else
    {
        return undef;
    }
}

sub _initialize
{
    my $self = shift;
    my %args = (@_);
    my $parser;
    my $dom;
    if ($args{input_filename})
    {
        $parser = XML::LibXML->new();
        $parser->validation(1);
        $dom = $parser->parse_file($args{input_filename});
    }
    else
    {
        die "input_filename must be specified!";
    }
    if ($args{output_handle})
    {
        $self->{o} = $args{output_handle};
    }
    else
    {
        die "output_handle must be specified!";
    }
    $self->{parser} = $parser;
    $self->{dom} = $dom;
    $self->{root_elem} = $dom->getDocumentElement();
}

sub process
{
    my $self = shift;

    $self->print_header();

    my $root_elem = $self->{root_elem};
    my ($contents_elem) = $root_elem->getChildrenByTagName("contents");
    my ($top_section_elem) = $contents_elem->getChildrenByTagName("section");

    my @impls = @{$self->get_implementations()};
    my %impls_to_indexes = (map { $impls[$_]->{'id'} => $_ } (0 .. $#impls));
    my %names = (map { $_->{'id'} => $_->{'name'} } @impls);

    $self->{impls} = \@impls;
    $self->{impls_to_indexes} = \%impls_to_indexes;
    $self->{impl_names} = \%names;
    $self->timestamp($self->get_timestamp());

    $self->{document_text} = "";
    $self->{toc_text} = "";

    $self->start_rendering();

    $self->render_section('elem' => $top_section_elem, 'depth' => 0,);

    $self->finish_rendering();

    print {*{$self->{o}}} $self->{document_text};
    
    $self->print_footer();
}

sub name
{
    my $self = shift;
    my $id = shift;
    return $self->{impl_names}->{$id};
}

sub sorter
{
    my $self = shift;
    my $impl = shift;

    my $indexes = $self->{impls_to_indexes};

    if (!exists($indexes->{$impl}))
    {
        die "Unknown system $impl";
    }
    return $indexes->{$impl};
}

sub out
{
    my $self = shift;
    $self->{document_text} .= join("", @_);
}

sub toc_out
{
    my $self = shift;
    $self->{toc_text} .= join("", @_);
}

sub render_section
{
    my $self = shift;
    my %args = (@_);
    my $section_elem = $args{elem};
    my $depth = $args{depth} || 0;

    my ($expl) = $section_elem->getChildrenByTagName("expl");
    my ($title) = $section_elem->getChildrenByTagName("title");
    my ($compare) = $section_elem->getChildrenByTagName("compare");
    my @sub_sections = $section_elem->getChildrenByTagName("section");

    my $title_string = $title->string_value();

    my $id = $section_elem->getAttribute("id");

    my @args = (
        'depth' => $depth,
        'id' => $id,
        'title_string' => $title_string,
        'expl' => $expl,
        'sub_sections' => \@sub_sections,
        );
        
    $self->render_section_start(
        @args
    );
    
    if ($compare)
    {
        $self->render_sys_table_start(@args);

        my @systems = ($compare->getChildrenByTagName("s"));
        my %kv = 
            (map 
                { $_->getAttribute("id") => $self->render_s_elem($_) } 
                @systems
            );
        my @keys_sorted = (sort { $self->sorter($a) <=> $self->sorter($b) } keys(%kv));
        foreach my $k (@keys_sorted)
        {
            $self->render_sys_table_row(
                'name' => $self->name($k),
                'desc' => $kv{$k},
            );
        }
        $self->render_sys_table_end();
    }

    foreach my $sub (@sub_sections)
    {
        $self->render_section(
            'elem' => $sub, 
            'depth' => ($depth+1)
            );
    }

    $self->render_section_end(
        'depth' => $depth,
        'id' => $id,
        'title_string' => $title_string,
        'expl' => $expl,
        'sub_sections' => \@sub_sections,
    );
}

1;
