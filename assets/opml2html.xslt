<?xml version="1.0" encoding="UTF-8"?>
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


  http://www.w3.org/TR/xslt/
-->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

  <xsl:output
    method="html"
    indent="yes"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"/>

  <xsl:template match="/">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="opml"/>
    </html>
  </xsl:template>

  <xsl:template match="opml">
    <head>
      <meta content="text/html; charset=utf-8" http-equiv="content-type"/>
      <!-- https://developer.apple.com/library/IOS/documentation/AppleApplications/Reference/SafariWebContent/UsingtheViewport/UsingtheViewport.html#//apple_ref/doc/uid/TP40006509-SW26 -->
      <!-- http://maddesigns.de/meta-viewport-1817.html -->
      <!-- meta name="viewport" content="width=device-width"/ -->
      <!-- http://www.quirksmode.org/blog/archives/2013/10/initialscale1_m.html -->
      <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
      <!-- meta name="viewport" content="width=400"/ -->
      <link href="../assets/style.css" rel="stylesheet" type="text/css"/>

      <link rel='license'>http://creativecommons.org/licenses/by-sa/3.0/de/</link>
      <link rel='via' href='index.opml'/>

      <title><xsl:value-of select="head/title"/></title>
      <style type="text/css">
/*&lt;![CDATA[<![CDATA[*/
body {
  background-color: #EAEAEC;
}
li.ghost {
  color: #AAA;
}
/*]]>]]&gt;*/
        </style>
    </head>
    <body>
      <h1 id="top"><xsl:value-of select="head/title"/></h1>

      <p>
        <img src="../../assets/atomenabled.svg" alt="AtomEnabled Logo"/>
        <a href="https://de.wikipedia.org/wiki/Atom_%28Format%29">Wikipedia: Atom (Format)</a>
      </p>

      <h2 id="license">Lizenz</h2>
  <p><a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/de/"><img style=
  "border-width:0" src="http://mirrors.creativecommons.org/presskit/buttons/88x31/svg/by-sa.svg"
  alt="Creative Commons Lizenzvertrag" /></a><br />
  "<span rel="dct:type" property="dct:title" href="http://purl.org/dc/dcmitype/Text" xmlns:dct=
  "http://purl.org/dc/terms/">Mediathek Meta Maschine Feeds</span>" von <a rel="cc:attributionURL"
  property="cc:attributionName" href=
  "http://linkeddata.mro.name/open/tv/mediathek/ardmediathek.de/feeds/index.opml" xmlns:cc=
  "http://creativecommons.org/ns#">Marcus Rohrmoser</a> ist lizenziert unter einer <a rel="license"
  href="http://creativecommons.org/licenses/by-sa/3.0/de/">Creative Commons Namensnennung -
  Weitergabe unter gleichen Bedingungen 3.0 Deutschland Lizenz</a>.</p>

      <h2 id="sources">Quellen</h2>

      <ul id="sourcelist">
        <li>Original Daten von: <a href="http://www.ardmediathek.de/tv/sendungVerpasst">
        ARD Mediathek</a></li>

        <li>GitHub: <a href="https://github.com/mro/tv-mediathek">https://github.com/mro/tv-mediathek</a></li>

        <li>Schrift: <a href="http://moorstation.org/typoasis/blackletter/htm/deutsche_druck.htm">Deutsche
        Druckschrift</a>, 1888 von <a href="http://www.typografie.info/3/page/Personen/wiki.html/_/heinz-k%C3%B6nig-r422">Heinz
        König</a> für <a href="https://en.wikipedia.org/wiki/Genzsch_%26_Heyse,_A.G.">Genzsch &amp;
        Heyse</a> (1922), Initialen nach Zeichnungen von <a href="https://de.wikipedia.org/wiki/Eduard_Ege">Eduard Ege</a>
        </li>
      </ul>

      <h2 id="feeds">Feeds</h2>

      <xsl:for-each select="body/outline">
        <h3 class="letter"><xsl:value-of select="@text"/></h3>
        <ul id="feedlist">
          <xsl:for-each select="outline[@type='rss' and @version='atom']">
            <xsl:variable name="_id" select="concat('feed_', substring-after(@htmlUrl, 'bcastId='))"/>
            <li class="feed" id="{$_id}">
              <xsl:if test="not(@xmlUrl)">
                <xsl:attribute name="class">feed ghost</xsl:attribute>
              </xsl:if>
              <span class="title"><xsl:value-of select="@text"/></span><xsl:text> </xsl:text>
              <xsl:if test="@xmlUrl">
                <a class="atom" href="{@xmlUrl}">atom (<span class="counter"><xsl:value-of select="@title"/></span>)</a><xsl:text> </xsl:text>
              </xsl:if>
              <a class="html" href="{@htmlUrl}">html</a><xsl:text> </xsl:text>
              <a class="anchor" href="#{$_id}">¶</a><xsl:text> </xsl:text>
            </li>
          </xsl:for-each>
        </ul>
      </xsl:for-each>
    </body>
  </xsl:template>

</xsl:stylesheet>
