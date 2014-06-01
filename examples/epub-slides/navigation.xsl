<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
   xmlns:h="http://www.w3.org/1999/xhtml"
   xmlns="http://www.w3.org/1999/xhtml"
   xmlns:epub="http://www.idpf.org/2007/ops"
   exclude-result-prefixes="h">

<xsl:template name="slide-number">
   <xsl:text>S-</xsl:text>
   <xsl:number count="h:div[contains(@class,'slide') and not(contains(@class,'cover'))]" level="single" format="1"/>
</xsl:template>
   
<xsl:template match="/">
   <html>
      <head><title><xsl:value-of select="h:html/h:head/h:title"/></title></head>
      <body>
         <xsl:apply-templates select="h:html/h:head/h:title"/>
         <nav epub:type="toc">
            <h2>Table of Contents</h2>
            <ol>
               <li><a href="cover.xhtml">Cover</a></li>
               <xsl:apply-templates select="h:html/h:body"/>
            </ol>
         </nav>
      </body>
   </html>
</xsl:template>
   
<xsl:template match="h:head/h:title">
   <h1><xsl:apply-templates/></h1>
</xsl:template>
   
<xsl:template match="h:body">
   <xsl:apply-templates/>
</xsl:template>
   
<xsl:template match="h:div[contains(@class,'slide') and not(contains(@class,'cover'))]">
   <xsl:variable name="number">
      <xsl:call-template name="slide-number"/>
   </xsl:variable>
   <li><a href="slides.xhtml#{$number}"><xsl:apply-templates select="h:h1"/></a></li>
</xsl:template>
   
<xsl:template match="h:div/h:h1">
   <xsl:apply-templates/>
</xsl:template>
  
<xsl:template match="*"/>
   
</xsl:stylesheet>