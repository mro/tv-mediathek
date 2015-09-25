<?xml version="1.0" encoding="UTF-8"?>
<!--
  Turn broadcast xml into html, used client-side, by the browser.

  Supposed to be either
  - linked to (ln -s) from stations/<name>/app/broadcast2html.xslt
  - xsl:import-ed from a custom stations/<name>/app/broadcast2html.xslt,
  - automatically rewritten to from stations/<name>/app/broadcast2html.xslt
  so each station can provide a custom skin but uses the generic one as a fallback.

  See stations/dlf/app/broadcast2html.xslt for an example for xsl:import.

 Copyright (c) 2013-2015 Marcus Rohrmoser, http://purl.mro.name/radio-pi

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 associated documentation files (the "Software"), to deal in the Software without restriction,
 including without limitation the rights to use, copy, modify, merge, publish, distribute,
 sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or
 substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
 NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
 OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 MIT License http://opensource.org/licenses/MIT
 
 
 http://www.w3.org/TR/xslt/
-->
<xsl:stylesheet
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:rec="../../../../../assets/2013/radio-pi.rdf"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:dctype="http://purl.org/dc/dcmitype/"
  xmlns:foaf="http://xmlns.com/foaf/0.1/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="rec"
  version="1.0">

  <!-- replace linefeeds with <br> tags -->
  <xsl:template name="linefeed2br">
    <xsl:param name="string" select="''"/>
    <xsl:param name="pattern" select="'&#10;'"/>
    <xsl:choose>
      <xsl:when test="contains($string, $pattern)">
        <xsl:value-of select="substring-before($string, $pattern)"/><br class="br"/><xsl:comment> Why do we see 2 br on Safari and output/@method=html here? http://purl.mro.name/safari-xslt-br-bug </xsl:comment>
        <xsl:call-template name="linefeed2br">
          <xsl:with-param name="string" select="substring-after($string, $pattern)"/>
          <xsl:with-param name="pattern" select="$pattern"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:output
    method="html"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"/>

  <!-- load external additional xml documents -->
  <xsl:variable name="station_about_rdf" select="document('../about.rdf')"/>
  <xsl:variable name="now_fellows_xml" select="document('../../../../app/now.lua')"/>

  <xsl:template name="broadcast_station_source">
    <a id="via" class="via" href="{rec:meta[@name='DC.source']/@content}" rel="via">Sendung</a>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template name="station_rdf_name">
    <xsl:variable name="station_rdf0" select="$station_about_rdf/rdf:RDF/foaf:Document[ '' = @rdf:about ]"/>
    <xsl:variable name="station_rdf1" select="$station_about_rdf/rdf:RDF/*[ $station_rdf0/foaf:primaryTopic/@rdf:resource = @rdf:about ]"/>
    <xsl:variable name="station_rdf" select="$station_about_rdf/rdf:RDF/rdf:Description">
      <!-- currently there's only 1 rdf:Description, all others are of different dctype -->
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$station_rdf">
        <a title="{$station_rdf/foaf:name} Programm" href="{$station_rdf/../dctype:Text/@rdf:about}">
          <img alt="Senderlogo {$station_rdf/foaf:name}" src="{$station_rdf/foaf:logo/@rdf:resource}" style="height:30px" class="border"/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <span title="No station RDF found at ../../../about.rdf" style="color:red;font-weight:bolder">!</span>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template name="station_rdf_stream">
    <xsl:variable name="stream_rdf" select="$station_about_rdf/rdf:RDF/dctype:Sound[@rdf:about]"/>
    <xsl:choose>
      <xsl:when test="$stream_rdf">
        <a style="color:green" class="location" title="{$stream_rdf/@rdf:about}" href="{$stream_rdf/@rdf:about}">Live Stream</a>
      </xsl:when>
      <xsl:otherwise>
        <!-- keep the fallback to jquery + GET station.cfg for now: -->
        <a id="stream" style="display:none">Live Stream</a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/rec:broadcast">
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="{rec:meta[@name='DC.language']/@content}">
      <head>
        <meta content="text/html; charset=utf-8" http-equiv="content-type"/>
        <!-- https://developer.apple.com/library/IOS/documentation/AppleApplications/Reference/SafariWebContent/UsingtheViewport/UsingtheViewport.html#//apple_ref/doc/uid/TP40006509-SW26 -->
        <!-- http://maddesigns.de/meta-viewport-1817.html -->
        <!-- meta name="viewport" content="width=device-width"/ -->
        <!-- http://www.quirksmode.org/blog/archives/2013/10/initialscale1_m.html -->
        <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
        <!-- meta name="viewport" content="width=400"/ -->
        <link href="../../../../../assets/favicon-32x32.png" rel="shortcut icon" type="image/png" />
        <link href="../../../../../assets/favicon-512x512.png" rel="apple-touch-icon" type="image/png" />
        <link href="../../../app/style.css" rel="stylesheet" type="text/css"/>
        <title>
          <xsl:value-of select="rec:meta[@name='DC.title']/@content"/>
        </title>
        <link href="{rec:meta[@name='DC.source']/@content}" rel="via"/>
        <link href="../../../../../app/prev.lua" rel="prev"/>
        <link href="../../../../../app/next.lua" rel="next"/>
        <link href="index.html" rel="parent"/>
        <!-- link href='../../../../../enclosures/app/schedule.lua?uri=referer' rel='edit-media'/ -->
        <xsl:for-each select="rec:meta">
          <meta content="{@content}" name="{@name}"/>
        </xsl:for-each>
      </head>
      <body id="broadcast" class="vevent">
        <noscript><p>JavaScript ist aus, es geht zwar (fast) alles auch ohne, aber mit ist's <b>schöner</b>. (Datumsformatierung, Aufnahmen wieder stornieren, Tagesübersicht, RDF Urls in der Fußzeile)</p></noscript>
        <ul id="whatsonnow" class="buttongroup">
          <xsl:for-each select="$now_fellows_xml/*/rec:broadcast">
            <xsl:variable name="fellow_station_name" select="substring-before(rec:meta[@name='DC.identifier']/@content, '/')"/> 
            <li><a href="../../../../{rec:meta[@name='DC.identifier']/@content}">
              <span class="station"><xsl:value-of select="$fellow_station_name"/></span>
              <br class='br'/>
              <span class="broadcast"><xsl:value-of select="rec:meta[@name='DC.title']/@content"/></span>
            </a></li>
          </xsl:for-each>
        </ul>
        <ul id="navigation" class="buttongroup" title="Navigation">
          <li><a id="prev_week" href="../../../../../app/now.lua?t=P-7D" title="Woche vorher">&lt;&lt;&lt;</a></li>
          <li><a id="yesterday" href="../../../../../app/now.lua?t=P-1D" title="Tag vorher">&lt;&lt;</a></li>
          <li><a href="../../../../../app/prev.lua" rel="prev" title="Sendung vorher">&lt;</a></li>
          <li class="now"><a href="../../../now">aktuell</a></li>
          <li><a href="../../../../../app/next.lua" rel="next" title="Sendung nachher">&gt;</a></li>
          <li><a id="tomorrow" href="../../../../../app/now.lua?t=P1D" title="Tag nachher">&gt;&gt;</a></li>
          <li><a id="next_week" href="../../../../../app/now.lua?t=P7D" title="Woche nachher">&gt;&gt;&gt;</a></li>
        </ul>
        <div class="summary">
          <h2 id="series">
            <xsl:value-of select="rec:meta[@name='DC.title.series']/@content"/>
          </h2><xsl:text> </xsl:text>
          <h1 id="title">
            <xsl:value-of select="rec:meta[@name='DC.title']/@content"/>
          </h1>
        </div>
          <h2 id="summary">
            <xsl:value-of select="rec:meta[@name='DC.title.episode']/@content"/>
          </h2>
        <p>
          <xsl:call-template name="broadcast_station_source"/>
          <xsl:call-template name="station_rdf_name"/>
          <xsl:call-template name="station_rdf_stream"/>
        </p>
        <h3 id="date">
          <span id="dtstart" class="dtstart" title="{rec:meta[@name='DC.format.timestart']/@content}"><xsl:value-of select="translate(rec:meta[@name='DC.format.timestart']/@content, 'T', ' ')"/></span>
          bis
          <span id="dtend" class="dtend" title="{rec:meta[@name='DC.format.timeend']/@content}"><xsl:value-of select="substring-after(rec:meta[@name='DC.format.timeend']/@content, 'T')"/></span>
        </h3>
        <p class="image">
          <img alt="Bild zur Sendung" id="image" class="border animated fadeInRotate" src="{rec:meta[@name='DC.image']/@content}"/>
        </p>
        <div id="content" class="description border">
          <p>
          <xsl:call-template name="linefeed2br">
            <xsl:with-param name="string" select="rec:meta[@name='DC.description']/@content"/>
          </xsl:call-template>
          </p>
        </div>
        <h3>Podcast</h3>
        <p id="podcasts" class="podcasts">keiner</p>
        <form id="ad_hoc" method="post" action="../../../../../enclosures/app/ad_hoc.cgi">
          <fieldset>
          <input id="ad_hoc_action" type="hidden" name="add" value="referer"/>
          <input id="ad_hoc_submit" type="submit" value="Aufnehmen"/>
          </fieldset>
        </form>
        <p id="enclosure">
          <!-- audio controls="controls" style="display:none">Doesn't play well with auth...<source type="audio/mpeg" /></audio -->
          <a id="enclosure_link">mp3</a></p>
        <hr/>
        <ul id="allday" class="nobullet" style="display:none"><li>Dummy</li></ul>
        <p><a href=".">Verzeichnis Index</a></p>
        <hr/>
        <p id="footer">
          <!--
          <a style="display:none" href="http://validator.w3.org/check?uri=referer">
          <img alt="Valid XHTML 1.0 Strict" height="31" src="http://www.w3.org/Icons/valid-xhtml10-blue.png" width="88"/>
          </a>
          <a style="display:none" href="http://jigsaw.w3.org/css-validator/check/referer?profile=css3&amp;usermedium=screen&amp;warning=2&amp;vextwarning=false&amp;lang=de">
          <img alt="CSS ist valide!" src="http://jigsaw.w3.org/css-validator/images/vcss-blue" style="border:0;width:88px;height:31px"/>
          </a>
          -->
          Powered by <a href="http://purl.mro.name/radio-pi">github.com/mro/radio-pi</a><br class="br"/>
          <a href="http://www.w3.org/RDF/">RDF</a>:<br class="br"/>
          <tt>$ <a href="http://librdf.org/raptor/rapper.html">rapper</a> -i grddl -o turtle '<span class="canonical-url url">&lt;url from address bar&gt;</span>'</tt><br class="br"/>
          <tt>$ <a href="http://librdf.org/raptor/rapper.html">rapper</a> -i grddl -o rdfxml-abbrev '<span class="canonical-url">&lt;url from address bar&gt;</span>'</tt><br class="br"/>
          <tt>$ <a href="http://xmlsoft.org/XSLT/xsltproc.html">xsltproc</a> --stringparam canonical_url '<span class="canonical-url">&lt;url from address bar&gt;</span>' '<span class="base-url">&lt;url from address bar&gt;/../../../../../..</span>/assets/2013/broadcast2rdf.xslt' '<span class="canonical-url">&lt;url from address bar&gt;</span>.xml'</tt>
        </p>
        <script type="text/javascript" src="../../../../../assets/jquery-2.0.0.min.js"/>
        <script type="text/javascript" src="../../../../../assets/moment.min.js"/><!-- http://momentjs.com/ -->
        <script type="text/javascript" src="../../../../../assets/lang/de.js"/><!-- https://github.com/timrwood/moment/blob/develop/min/lang/de.js -->
        <script type="text/javascript" src="../../../../../assets/broadcast2html.js" />
      </body>
    </html>
  </xsl:template>

  <xsl:template match="/rec:broadcasts">
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="{rec:meta[@name='DC.language']/@content}">
      <head>
        <meta content="text/html; charset=utf-8" http-equiv="content-type"/>
        <!-- https://developer.apple.com/library/IOS/documentation/AppleApplications/Reference/SafariWebContent/UsingtheViewport/UsingtheViewport.html#//apple_ref/doc/uid/TP40006509-SW26 -->
        <!-- http://maddesigns.de/meta-viewport-1817.html -->
        <!-- meta name="viewport" content="width=device-width"/ -->
        <!-- http://www.quirksmode.org/blog/archives/2013/10/initialscale1_m.html -->
        <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
        <!-- meta name="viewport" content="width=400"/ -->
        <link href="../../../../../assets/favicon-32x32.png" rel="shortcut icon" type="image/png" />
        <link href="../../../../../assets/favicon-512x512.png" rel="apple-touch-icon" type="image/png" />
        <link href="../../../app/style.css" rel="stylesheet" type="text/css"/>
        <link rel="profile" href="http://microformats.org/profile/hcalendar"/>
      </head>
      <body>
        <noscript><p>JavaScript ist aus, es geht zwar (fast) alles auch ohne, aber mit ist's <b>schöner</b>. (Zeitgleiche Sendungen anderer Sender, Datumsformatierung, Aufnahmen wieder stornieren, Tagesübersicht, RDF Url)</p></noscript>
        <h1 title="{@date}"><xsl:value-of select="@date"/></h1>
        <ol style='list-style-type: none;'>
          <xsl:for-each select="rec:broadcast">
            <xsl:variable name="rowid" select="translate(substring(rec:meta[@name='DC.format.timestart']/@content, 11, 6), ':', '_')"/>
            <xsl:variable name="duration_minutes" select="number(rec:meta[@name='DC.format.duration']/@content) div 60"/>
            <li class="broadcast vevent" id="{$rowid}">
              <a class="dtstart" href="#{$rowid}" title="{rec:meta[@name='DC.format.timestart']/@content}"><xsl:value-of select="substring(rec:meta[@name='DC.format.timestart']/@content, 12, 5)"/></a>
              <span class="dtend" title="{rec:meta[@name='DC.format.timeend']/@content}"/>
              <xsl:text> </xsl:text>
              <a class="url" href="../../../../{rec:meta[@name='DC.identifier']/@content}">.</a>
              <xsl:text> </xsl:text>
              <span class="duration" title="PT{$duration_minutes}M"><xsl:value-of select="$duration_minutes"/>"</span>
              <xsl:text> </xsl:text>
              <span class="title summary" title="{rec:meta[@name='DC.description']/@content}"><xsl:value-of select="rec:meta[@name='DC.title']/@content"/></span>
              <span class="description" style="display:none"><xsl:value-of select="rec:meta[@name='DC.description']/@content"/></span>
            </li>
          </xsl:for-each>
        </ol>
        <p><a href=".">Verzeichnis Index</a></p>
        <hr/>
        <p id="footer">
          <!--
          <a style="display:none" href="http://validator.w3.org/check?uri=referer">
          <img alt="Valid XHTML 1.0 Strict" height="31" src="http://www.w3.org/Icons/valid-xhtml10-blue.png" width="88"/>
          </a>
          <a style="display:none" href="http://jigsaw.w3.org/css-validator/check/referer?profile=css3&amp;usermedium=screen&amp;warning=2&amp;vextwarning=false&amp;lang=de">
          <img alt="CSS ist valide!" src="http://jigsaw.w3.org/css-validator/images/vcss-blue" style="border:0;width:88px;height:31px"/>
          </a>
          -->
          Powered by <a href="http://purl.mro.name/radio-pi/">github.com/mro/radio-pi</a><br class="br"/>
          <a href="http://www.w3.org/RDF/">RDF</a>:<br class="br"/>
          <tt>$ <a href="http://librdf.org/raptor/rapper.html">rapper</a> -i grddl -o turtle '<span class="canonical-url">&lt;url from address bar&gt;</span>'</tt><br class="br"/>
          <tt>$ <a href="http://librdf.org/raptor/rapper.html">rapper</a> -i grddl -o rdfxml-abbrev '<span class="canonical-url">&lt;url from address bar&gt;</span>'</tt><br class="br"/>
          <tt>$ <a href="http://xmlsoft.org/XSLT/xsltproc.html">xsltproc</a> --stringparam canonical_url '<span class="canonical-url">&lt;url from address bar&gt;</span>' '<span class="base-url">&lt;url from address bar&gt;/../../../../../..</span>/assets/2013/broadcast2rdf.xslt' '<span class="canonical-url">&lt;url from address bar&gt;</span>.xml'</tt>
        </p>
        <script type="text/javascript" src="../../../../../assets/jquery-2.0.0.min.js"/>
        <script type="text/javascript" src="../../../../../assets/broadcast2html.early.js" />
        <script type="text/javascript" src="../../../../../assets/moment.min.js"/><!-- http://momentjs.com/ -->
        <script type="text/javascript" src="../../../../../assets/lang/de.js"/><!-- https://github.com/timrwood/moment/blob/develop/min/lang/de.js -->
        <script type="text/javascript" src="../../../../../assets/broadcast2html.js" />
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
