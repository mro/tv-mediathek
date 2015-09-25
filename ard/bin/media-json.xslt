<?xml version="1.0"?>
<!--
  Copyright (c) 2015, Marcus Rohrmoser mobile Software
  All rights reserved.
 
  Redistribution and use in source and binary forms, with or without modification, are permitted
  provided that the following conditions are met:
 
  1. Redistributions of source code must retain the above copyright notice, this list of conditions
  and the following disclaimer.
 
  2. The software must not be used for military or intelligence or related purposes nor
  anything that's in conflict with human rights as declared in http://www.un.org/en/documents/udhr/ .
 
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
  IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
  THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--> 
<!-- http://www.w3.org/TR/xslt/

	$ xmllint - -relaxng bin/media-json.rng "..." | xsltproc - -html bin/media-json.xslt -
  
  return image and video urls (descending quality)
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text"/>
  <xsl:template match="/">
    <xsl:for-each select="video/_previewImage">
      <xsl:text>image/jpeg 3 </xsl:text>
      <xsl:value-of select="normalize-space(.)"/>
      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
    <xsl:for-each select="video/_mediaArray/_mediaStreamArray">
      <xsl:sort select="_quality" data-type="number" order="descending"/>
      <xsl:for-each select="_stream">
        <xsl:text>video/mp4 </xsl:text>
        <xsl:value-of select="normalize-space(../_quality)"/><xsl:text> </xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:text>&#10;</xsl:text>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
