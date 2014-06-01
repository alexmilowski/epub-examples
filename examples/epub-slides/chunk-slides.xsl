<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
   xmlns:h="http://www.w3.org/1999/xhtml"
   xmlns="http://www.w3.org/1999/xhtml"
   exclude-result-prefixes="h">
   
<xsl:param name="output-dir"/>
   
<xsl:template name="slide-number">
   <xsl:text>S-</xsl:text>
   <xsl:number count="h:div[contains(@class,'slide') and not(contains(@class,'cover'))]" level="single" format="1"/>
</xsl:template>

<xsl:template match="/">
   <xsl:result-document href="{$output-dir}/cover.xhtml">
      <html>
         <xsl:apply-templates select="h:html/h:head"/>
         <body>
         <xsl:apply-templates select="h:html/h:body" mode="cover"/>
         </body>
      </html>
   </xsl:result-document>
   <xsl:result-document href="{$output-dir}/slides.xhtml">
      <html>
         <xsl:apply-templates select="h:html/h:head"/>
         <body>
         <xsl:apply-templates select="h:html/h:body"/>
         </body>
      </html>
   </xsl:result-document>
</xsl:template>
   
<xsl:template match="h:head">
   <head>
      <title><xsl:value-of select="h:title"/></title>
      <link rel="stylesheet" type="text/css" href="slides.css"/>
   </head>
</xsl:template>
   
<xsl:template mode="cover" match="h:body">
   <xsl:apply-templates select="h:div[contains(@class,'cover')]"/>
</xsl:template>
   
<xsl:template match="h:body">
   <xsl:apply-templates select="h:div[contains(@class,'slide') and not(contains(@class,'cover'))]"/>
</xsl:template>
   
<xsl:template match="h:div">
   <xsl:copy>
      <xsl:attribute name="id"><xsl:call-template name="slide-number"/></xsl:attribute>
      <xsl:apply-templates select="@*|node()" mode="copy"/>
   </xsl:copy>
</xsl:template>

<xsl:template mode="copy" match="@*|node()">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="copy"/>
   </xsl:copy>   
</xsl:template>
  
</xsl:stylesheet>