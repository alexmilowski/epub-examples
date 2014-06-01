<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
   xmlns="http://www.idpf.org/2007/opf"
   xmlns:dc="http://purl.org/dc/elements/1.1/" 
   xmlns:dcterms="http://purl.org/dc/terms/"
   xmlns:h="http://www.w3.org/1999/xhtml"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   >
   
   <xsl:template match="/">
         <package version="3.0" unique-identifier="pub-id">
            <metadata>
               <xsl:apply-templates select="collection()/metadata/*" mode="copy"/>
               <xsl:variable name="modifiedTS" select="adjust-dateTime-to-timezone(current-dateTime(),xs:dayTimeDuration('PT0H')) "/>
               <xsl:variable name="modified" select="concat(substring-before(string($modifiedTS),'.'),'Z')"/>
               <meta property="dcterms:modified"><xsl:value-of select="$modified"/></meta>
               <xsl:apply-templates select="collection()/h:html" mode="metadata"/>
            </metadata>
            <manifest>
               <item id="navigation" media-type="application/xhtml+xml" href="navigation.xhtml" properties="nav"/>
               <item id="cover" media-type="application/xhtml+xml" href="cover.xhtml"/>
               <item id="slides" media-type="application/xhtml+xml" href="slides.xhtml" properties="svg mathml"/>
               <xsl:apply-templates select="collection()/manifest/link" mode="manifest"/>
            </manifest>
            <spine>
               <itemref idref="cover"/>
               <itemref idref="navigation"/>
               <itemref idref="slides"/>
            </spine>
         </package>
   </xsl:template>
   
   <xsl:template mode="copy" match="node()|@*">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()" mode="copy"/>
      </xsl:copy>
   </xsl:template>
   
   <xsl:template mode="manifest" match="link">
      <item id="id-{generate-id(.)}" href="{@href}" media-type="{@type}"/>
   </xsl:template>
   
   <xsl:template mode="metadata" match="h:html">
      <xsl:apply-templates mode="metadata" select="h:head"/>
   </xsl:template>
   
   <xsl:template mode="metadata" match="h:head">
      <xsl:apply-templates mode="metadata" select="h:title|h:meta"/>
      
   </xsl:template>
   
   <xsl:template mode="metadata" match="h:title">
      <dc:title><xsl:apply-templates/></dc:title>
   </xsl:template>
   
   <xsl:template mode="metadata" match="h:meta[@name='copyright']">
      <dc:rights><xsl:value-of select="@content"/></dc:rights>
   </xsl:template>
   
   <xsl:template mode="metadata" match="h:meta[@name='holder']">
      <meta property="dcterms:rightsHolder"><xsl:value-of select="@content"/></meta>
      <dc:contributor><xsl:value-of select="@content"/></dc:contributor>
   </xsl:template>
   
   <xsl:template mode="metadata" match="h:meta[@name='creator']">
      <dc:creator><xsl:value-of select="@content"/></dc:creator>
   </xsl:template>

   <xsl:template mode="metadata" match="h:meta[@name='pubdate']">
      <dc:date><xsl:value-of select="@content"/></dc:date>
   </xsl:template>
   
   <xsl:template mode="metadata" match="*"/>
         
</xsl:stylesheet>