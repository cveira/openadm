<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output encoding="ISO-8859-1" omit-xml-declaration ="yes"/>

<xsl:template match="/">
  <xsl:for-each select="/root/family">

  <h1>Family: <xsl:value-of select="@name"/></h1>

    <xsl:for-each select="group">
      <blockquote>
        <h2>GROUP: <xsl:value-of select="@name"/></h2>

        <xsl:for-each select="category">
          <blockquote>
            <h3>CATEGORY: <xsl:value-of select="@name"/></h3>
            <xsl:for-each select="instance">
              <blockquote>
                <xsl:for-each select="property">
                  <p><b><xsl:value-of select="name"/></b> = <xsl:value-of select="value"/></p>
                </xsl:for-each>
              </blockquote>
            </xsl:for-each>
          </blockquote>
        </xsl:for-each>
      </blockquote>
    </xsl:for-each>
  </xsl:for-each>
</xsl:template>

</xsl:stylesheet>