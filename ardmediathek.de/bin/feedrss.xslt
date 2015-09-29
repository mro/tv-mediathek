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
<!--

  http://www.w3.org/TR/xslt/

  Add <item><enclosure> tags.

  $ xsltproc bin/feedrss.xslt http://www.ardmediathek.de/export/rss/id=1458

  http://linkeddata.mro.name/open/tv/mediathek/ardmediathek.de/mp4url.php?htmlurl=
  
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
  
  <xsl:param name="prefix">http://linkeddata.mro.name/open/tv/mediathek/ardmediathek.de/mp4url.php?quality=3&amp;htmlurl=</xsl:param>

  <xsl:template match="item[link]">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
      <enclosure type="video/mp4" length="100000000" url="{$prefix}{link}"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
