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
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="../../../../assets/2015/tv-mediathek.rdf"
  xmlns:a="http://www.w3.org/2005/Atom"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dct="http://purl.org/dc/terms/"
    xmlns:dctype="http://purl.org/dc/dcmitype/"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:freq="http://purl.org/cld/freq/"
    xmlns:iso639-3="http://lexvo.org/id/iso639-3/"
    xmlns:mime="http://purl.org/NET/mediatypes/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3schools.com/RDF/rdf-schema.xml"
    xmlns:tl="http://purl.org/NET/c4dm/timeline.owl#"
    xmlns:xdt="http://www.w3.org/2005/xpath-datatypes#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#">
  <xsl:output method="xml" indent="yes" media-type="text/xml"/>
  
  <xsl:template match="/">
    <rdf:RDF>     
      <xsl:apply-templates select="a:entry"/>
    </rdf:RDF>      
  </xsl:template>

  <xsl:template match="a:entry">
    <dctype:Text rdf:about='http://www.ardmediathek.de/tv/Filme-im-Ersten/S%C3%BC%C3%9Fer-September/Das-Erste/Video?documentId=30777652&amp;bcastId=1933898'>
      <dct:format rdf:resource='http://purl.org/NET/mediatypes/text/html'/>
      <dct:isFormatOf rdf:resource=''/>
      <dct:language rdf:resource='http://lexvo.org/id/iso639-3/deu'/>
    </dctype:Text>
    <dctype:Text rdf:about=''>
      <dct:title>Süßer September</dct:title>
      <dct:date>2015-09-25T20:15:00</dct:date>
      <dct:hasFormat rdf:resource='http://www.ardmediathek.de/tv/Filme-im-Ersten/S%C3%BC%C3%9Fer-September/Das-Erste/Video?documentId=30777652&amp;bcastId=1933898'/>
      <dct:isPartOf rdf:resource='http://www.ardmediathek.de/tv/Filme-im-Ersten/Sendung?documentId=1933898&amp;bcastId=1933898'/>
    </dctype:Text>
    <rdf:Description rdf:about=''>
      <dct:hasFormat rdf:resource='http://www.ardmediathek.de/image/00/30/77/76/64/1547339463/16x9/960'/>
    </rdf:Description>
    <dctype:StillImage rdf:about='http://www.ardmediathek.de/image/00/30/77/76/64/1547339463/16x9/960'>
      <dct:isFormatOf rdf:resource=''/>
      <dct:format rdf:resource='http://purl.org/NET/mediatypes/image/jpeg'/>
    </dctype:StillImage>
    <rdf:Description rdf:about=''>
      <dct:hasFormat rdf:resource='http://mvideos.daserste.de/videoportal/Film/c_560000/567034/format662735.mp4'/>
    </rdf:Description>
    <dctype:MovingImage rdf:about='http://mvideos.daserste.de/videoportal/Film/c_560000/567034/format662735.mp4'>
      <dct:language rdf:resource='http://lexvo.org/id/iso639-3/deu'/>
      <dct:isFormatOf rdf:resource=''/>
      <dct:format rdf:resource='http://purl.org/NET/mediatypes/video/mp4'/>
    </dctype:MovingImage>   
  </xsl:template>
</xsl:stylesheet>
