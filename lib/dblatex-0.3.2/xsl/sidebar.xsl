<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<!-- The sidebar block must be a latex environment where verbatim
     stuff is correctly handled
  -->
<xsl:template match="sidebar">
  <xsl:text>&#10;&#10;\begin{sidebar}&#10;</xsl:text>
  <xsl:call-template name="label.id"/>
  <xsl:apply-templates select="title"/>
  <xsl:apply-templates select="*[not(self::title)]"/>
  <xsl:text>\end{sidebar}&#10;</xsl:text>
</xsl:template>

<xsl:template match="sidebar/title">
  <xsl:text>\textbf{</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>}&#10;&#10;</xsl:text>
</xsl:template>

</xsl:stylesheet>

