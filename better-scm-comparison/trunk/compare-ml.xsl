<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"
 doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
 doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
 />

<xsl:key name="impl" match="/comparison/meta/implementations/impl" use="@id"/>

<xsl:template match="/comparison">
 <html xmlns="http://www.w3.org/1999/xhtml">
 <head>
  <title><xsl:value-of select="contents/section[@id='main']/title"/></title>
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
  <xsl:apply-templates select="contents"/>
 </body>
 <!--http://rafb.net/paste/results/lTurEi25.html-->
 </html>
</xsl:template>

<xsl:template match="contents">
 <xsl:apply-templates select="section"/>
</xsl:template>

<xsl:template match="section">
 <xsl:element name="h{count(ancestor-or-self::section)}">
 <a id="{@id}"></a>
 <xsl:value-of select="title"/>
 </xsl:element>
 <xsl:apply-templates select="expl"/>
 <xsl:if test="@id = 'main'">
 <ul class="toc">
  <xsl:apply-templates select="section" mode="toc"/>
 </ul>
 </xsl:if>
 <xsl:apply-templates select="section"/>
 <xsl:apply-templates select="compare"/>
</xsl:template>

<xsl:template match="section" mode="toc">
 <li>
 <a href="#{@id}"><xsl:value-of select="title"/></a>
 <xsl:if test="section">
  <ul>
  <xsl:apply-templates select="section" mode="toc"/>
  </ul>
 </xsl:if>
 </li>
</xsl:template>

<xsl:template match="expl">
 <p class="expl">
 <xsl:value-of select="."/>
 </p>
</xsl:template>

<xsl:template match="compare">
 <table class="compare">
 <xsl:apply-templates select="s"/>
 </table>
</xsl:template>

  <xsl:template match="s">
 <tr>
 <td class="sys"><xsl:value-of select="key('impl', @id)/name"/></td>
 <td class="desc"><xsl:value-of select="."/></td>
 </tr>
</xsl:template>

</xsl:stylesheet>
