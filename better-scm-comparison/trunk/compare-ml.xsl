<?xml version="1.0" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- 
Initiating match-template.
-->
<xsl:template match="/">
<xsl:apply-templates/>
</xsl:template>    

<xsl:template match="comparison">
<html>
<head>
<title>Comparison</title>
<style type="text/css">
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
</style>
</head>
<body>
<ul>
<xsl:apply-templates select="//comparison/contents/section">
<xsl:with-param name="toc" value="1" />
</xsl:apply-templates>
</ul>
<!--
<xsl:apply-templates select="//comparison/contents/section" />
-->
</body>http://rafb.net/paste/results/lTurEi25.html
</html>
</xsl:template>

<xsl:template match="section">
<xsl:param name="toc" />
<xsl:choose>
<xsl:when test="$toc = '1'">
<li>
<a href="hoola">
<!--<xsl:attribute name="href" select="@id" />
<xsl:value-of select="title" /> -->
</a>
<xsl:if test="section">
<ul>
<xsl:apply-templates select="section">
<xsl:with-param name="toc" value="1" />
</xsl:apply-templates>
</ul>
</xsl:if>
</li>
</xsl:when>
<xsl:otherwise>
<xsl:element name="h{count(ancestor-or-self::section)}"><xsl:value-of select="title" /></xsl:element>
<xsl:apply-templates select="expl" />
<xsl:apply-templates select="section" />
<xsl:if test="compare"> 
<table class="compare">
<xsl:apply-templates select="compare" />
</table>
</xsl:if>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="expl">
<p class="expl">
<xsl:value-of select="." />
</p>
</xsl:template>

<xsl:template match="s">
<tr>
<xsl:variable name="curid" select="@id" />
<td class="sys"><xsl:value-of select="//comparison/meta/implementations/impl[@id=$curid]/name" /></td>
<td class="desc"><xsl:value-of select="." /></td>
</tr>
</xsl:template>

<xsl:template match="compare">
<xsl:apply-templates select="//comparison/meta/implementations/impl">
<xsl:with-param name="curcomp" select="." />
</xsl:apply-templates>
</xsl:template>

<xsl:template match="impl">
<xsl:param name="curcomp" />
<xsl:variable name="curid" select="@id" />
<xsl:apply-templates select="$curcomp/s[@id=$curid]" />
</xsl:template>

</xsl:stylesheet>
