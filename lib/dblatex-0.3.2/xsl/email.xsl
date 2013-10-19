<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!--############################################################################
    XSLT Stylesheet DocBook -> LaTeX 
    ############################################################################ -->

<xsl:template match="email">
  <xsl:text>\href{mailto:</xsl:text>
  <xsl:value-of select="."/>
  <xsl:text>}{</xsl:text>
  <xsl:apply-templates mode="slash.hyphen"/>
  <xsl:text>}</xsl:text>
</xsl:template>

</xsl:stylesheet>
