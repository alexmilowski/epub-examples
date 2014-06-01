<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
   xmlns:h="http://www.w3.org/1999/xhtml"
   >
   
   <xsl:template match="/">
      <manifest xml:base="{base-uri(.)}">
         <xsl:apply-templates select="h:html/h:body"/>
      </manifest>
   </xsl:template>
   
   <xsl:template match="h:body">
      <xsl:apply-templates/>
   </xsl:template>
   
   <xsl:template match="h:div[contains(@class,'slide')]">
      <xsl:apply-templates select=".//h:img"/>
   </xsl:template>
   
   <xsl:template match="h:img">
      <link href="{@src}">
         <xsl:choose>
            <xsl:when test="contains(@src,'.svg')">
               <xsl:attribute name="type">image/svg+xml</xsl:attribute>
            </xsl:when>
            <xsl:when test="contains(@src,'.png')">
               <xsl:attribute name="type">image/png</xsl:attribute>
            </xsl:when>
            <xsl:when test="contains(@src,'.jpg')">
               <xsl:attribute name="type">image/jpg</xsl:attribute>
            </xsl:when>
            <xsl:when test="contains(@src,'.gif')">
               <xsl:attribute name="type">image/gif</xsl:attribute>
            </xsl:when>
         </xsl:choose>
      </link>
   </xsl:template>
   
   <xsl:template match="*"/>   
</xsl:stylesheet>