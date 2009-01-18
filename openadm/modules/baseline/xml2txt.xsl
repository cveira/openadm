<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output encoding="ISO-8859-1" omit-xml-declaration ="yes"/>

<xsl:template match="/">
  <xsl:for-each select="/root/family">

+ FAMILY: <xsl:value-of select="@name"/>

     <xsl:for-each select="group">

  + GROUP: <xsl:value-of select="@name"/>

       <xsl:for-each select="category">

    + CATEGORY: <xsl:value-of select="@name"/>
        <xsl:for-each select="instance">
          <xsl:for-each select="property">
        + <xsl:value-of select="name"/> = <xsl:value-of select="value"/>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:for-each>

    </xsl:for-each>
  </xsl:for-each>
</xsl:template>

</xsl:stylesheet>