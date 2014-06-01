<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
   xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"   
   xmlns:cx="http://xmlcalabash.com/ns/extensions"
   xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
   xmlns:pxf="http://exproc.org/proposed/steps/file"
   xmlns:exf="http://exproc.org/standard/functions"
   xmlns:pxp="http://exproc.org/proposed/steps"
   xmlns:my="http://www.milowski.com/epub/steps"
   name="top">
   <p:input port="source"/>
   <p:input port="manifest" primary="false"/>   
   <p:input port="metadata" primary="false"/>   
   <p:option name="output-dir"/>
   <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

   <p:declare-step type="my:store-sequence">
      <p:input port="source" sequence="true" primary="true"/>
      <p:option name="indent" select="'false'"/>
      <p:for-each name="iteration">
         <cx:message>
            <p:with-option name="message" select="concat('Storing ',base-uri(.))"/>
         </cx:message>
         <p:store name="store">
            <p:with-option name="indent" select="$indent"/>
            <p:with-option name="href" select="base-uri(.)"/>
         </p:store>
      </p:for-each>
   </p:declare-step>
   
   <p:variable name="content-dir" select="concat($output-dir,'/content')"/>
   <p:variable name="epub" select="concat($output-dir,'.epub')"/>
   
   <p:group name="cleanup">
      <pxf:delete fail-on-error="false">
         <p:with-option name="href" select="$epub"/>
      </pxf:delete>
      <pxf:delete fail-on-error="false" recursive="true">
         <p:with-option name="href" select="$output-dir"/>
      </pxf:delete>
   </p:group>
   
   <p:group name="setup" cx:depends-on="cleanup">
      <cx:message>
         <p:input port="source"><p:empty/></p:input>
         <p:with-option name="message" select="concat('Output Directory: ',$output-dir)"/>
      </cx:message>
      <cx:message>
         <p:input port="source"><p:empty/></p:input>
         <p:with-option name="message" select="concat('Content Directory: ',$content-dir)"/>
      </cx:message>
      <pxf:mkdir>
         <p:with-option name="href" select="$output-dir"/>
      </pxf:mkdir>
      <pxf:mkdir>
         <p:with-option name="href" select="concat($output-dir,'/META-INF')"/>
      </pxf:mkdir>
      <p:store>
         <p:input port="source">
            <p:document href="container.xml"/>
         </p:input>
         <p:with-option name="href" select="concat($output-dir,'/META-INF/container.xml')"/>
      </p:store>
      <p:store method="text">
         <p:input port="source">
            <p:inline><text>application/epub+zip</text></p:inline>
         </p:input>
         <p:with-option name="href" select="concat($output-dir,'/mimetype')"/>
      </p:store>
      <pxf:mkdir>
         <p:with-option name="href" select="$content-dir"/>
      </pxf:mkdir>
   </p:group>
   
   <p:group name="build" cx:depends-on="setup">
      <p:xinclude name="slides">
         <p:input port="source">
            <p:pipe step="top" port="source"/>
         </p:input>
      </p:xinclude>
      
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Chunk and store content document.</p>
      </p:documentation>
      
      <p:xslt version="2.0" name="chunker">
         <p:input port="stylesheet"><p:document href="chunk-slides.xsl"/></p:input>
         <p:with-param name="output-dir" select="$content-dir"/>
      </p:xslt>
      <p:sink/>
      <my:store-sequence>
         <p:input port="source">
            <p:pipe step="chunker" port="secondary"/>
         </p:input>
      </my:store-sequence>

      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Generate Navigation</p>
      </p:documentation>
      
      <p:xslt version="2.0" name="nav">
         <p:input port="source"><p:pipe step="slides" port="result"/></p:input>
         <p:input port="stylesheet"><p:document href="navigation.xsl"/></p:input>
         <p:input port="parameters"><p:empty/></p:input>
      </p:xslt>
      <p:store>
         <p:with-option name="href" select="concat($content-dir,'/navigation.xhtml')"/>
      </p:store>
      
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Generate Packaging</p>
      </p:documentation>

      <p:xslt version="2.0" name="source-manifest">
         <p:input port="source">
            <p:pipe step="slides" port="result"/>
         </p:input>
         <p:input port="stylesheet"><p:document href="manifest.xsl"/></p:input>
         <p:input port="parameters"><p:empty/></p:input>
      </p:xslt>
      
      <p:xslt version="2.0" name="package">
         <p:input port="source">
            <p:pipe step="slides" port="result"/>
            <p:pipe step="source-manifest" port="result"/>
            <p:pipe step="top" port="manifest"/>
            <p:pipe step="top" port="metadata"/>
         </p:input>
         <p:input port="stylesheet"><p:document href="package.xsl"/></p:input>
         <p:input port="parameters"><p:empty/></p:input>
      </p:xslt>
      <p:store>
         <p:with-option name="href" select="concat($content-dir,'/content.opf')"/>
      </p:store>
      
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Copy Files</p>
      </p:documentation>
      
      <p:for-each>
         <p:iteration-source>
            <p:pipe step="source-manifest" port="result"/>
            <p:pipe step="top" port="manifest"/>
         </p:iteration-source>
         <p:viewport match="link">
            <p:output port="result">
               <p:pipe step="copied" port="result"/>
            </p:output>
            <p:variable name="source" select="resolve-uri(/link/@href,base-uri(/))"/>
            <p:variable name="target" select="concat($content-dir,'/',/link/@href)"/>
            <cx:message>
               <p:with-option name="message" select="concat('Copying ',$source,' to ',$target)"/>
            </cx:message>
            <pxf:copy name="copied">
               <p:with-option name="href" select="$source"/>
               <p:with-option name="target" select="$target"/>
            </pxf:copy>
         </p:viewport>
      </p:for-each>
      <p:sink/>
      
   </p:group>
   
   <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>Generate epub file</p>
   </p:documentation>
   
   <p:group cx:depends-on="build">
      <cx:message>
         <p:input port="source"><p:empty/></p:input>
         <p:with-option name="message" select="concat('Generating ',$epub)"/>
      </cx:message>
      <p:exec name="mimetype-only" command="zip" source-is-xml="false" result-is-xml="false">
         <p:input port="source"><p:empty/></p:input>
         <p:with-option name="cwd" select="$output-dir"/>
         <p:with-option name="args" select="concat('-0X ../',$epub,' mimetype')"/>
      </p:exec>
      <p:exec command="zip" source-is-xml="false" result-is-xml="false" cx:depends-on="mimetype-only">
         <p:input port="source"><p:empty/></p:input>
         <p:with-option name="cwd" select="$output-dir"/>
         <p:with-option name="args" select="concat('-rX9 ../',$epub,' META-INF content')"/>
      </p:exec>
      <p:sink/>
   </p:group>
   
</p:declare-step>