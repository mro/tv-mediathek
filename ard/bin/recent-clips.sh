#!/bin/sh
#
# Copyright (c) 2015, Marcus Rohrmoser mobile Software
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are permitted
# provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions
# and the following disclaimer.
#
# 2. The software must not be used for military or intelligence or related purposes nor
# anything that's in conflict with human rights as declared in http://www.un.org/en/documents/udhr/ .
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
# THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
cd "$(dirname "$0")/.."

# Check preliminaries
curl --version >/dev/null       || { echo "I need curl." && exit 1; }
xmllint --version 2> /dev/null  || { echo "I need xmllint (libxml2)." && exit 1; }
xsltproc --version > /dev/null  || { echo "I need xsltproc." && exit 1; }
# parallel --version > /dev/null  || { echo "I need parallel." && exit 1; }
shasum --version > /dev/null    || { echo "I need shasum." && exit 1; }

unescape_xml() {
  echo "$1" | sed -e 's/\&amp;/\&/g'
}
escape_xml() {
  echo "$1" | sed -e "s/\&/\&amp;/g;s/'/\&apos;/g"
}

day=0
if date -d '-5 day' '+%Y/%m/%d' >/dev/null 2>&1 ; then
  adjust="-d -${day} day"
else
  if date -v-5d '+%Y/%m/%d' >/dev/null 2>&1 ; then
    adjust="-v-${day}d"
  else
    echo "date command failed." && exit 1
  fi
fi
BASE_URL="http://www.ardmediathek.de"
CLIPS_URL="$BASE_URL/tv/sendungVerpasst?tag=$day"
subdir="./$(date "$adjust" '+%Y/%m/%d')"

{
  cat <<EOF
  <rdf:RDF
     xmlns:dc="http://purl.org/dc/elements/1.1/"
     xmlns:dct="http://purl.org/dc/terms/"
     xmlns:dctype="http://purl.org/dc/dcmitype/"
     xmlns:foaf="http://xmlns.com/foaf/0.1/"
     xmlns:freq="http://purl.org/cld/freq/"
     xmlns:iso639-1="http://lexvo.org/id/iso639-1/"
     xmlns:mime="http://purl.org/NET/mediatypes/"
     xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
     xmlns:rdfs="http://www.w3schools.com/RDF/rdf-schema.xml"
     xmlns:tl="http://purl.org/NET/c4dm/timeline.owl#"
     xmlns:xdt="http://www.w3.org/2005/xpath-datatypes#"
     xmlns:xsd="http://www.w3.org/2001/XMLSchema#">
EOF
  echo "xsltproc --html 'bin/$(basename "$0" .sh).xslt' '$CLIPS_URL'" 1>&2
  xsltproc --html "bin/$(basename "$0" .sh).xslt" "$CLIPS_URL" 2>/dev/null | while read time url_ title
  do
    self="$(escape_xml "$BASE_URL$url_")"
    # could be done parallel (1 HTTP request per loop)
    echo "<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->"
    echo "<dctype:MovingImage rdf:about='$self'>"
    echo "  <dct:title xml:language='deu'>$(escape_xml "$title")</dct:title>"
    echo "  <dct:date>$(date "$adjust" '+%Y-%m-%dT')$time:00</dct:date>"
    document_id="$(echo "$url_" | egrep -hoe 'documentId=[0-9]+' | cut -c 12-)"
    file_base="$subdir/$(echo "$time" | tr -d ':')-$document_id"

    url_series_part="$(echo "$url_" | cut -d / -f 3)"
    series_id="$(echo "$url_" | egrep -hoe 'bcastId=[0-9]+' | cut -c 9-)"
    url_series_html="http://www.ardmediathek.de/tv/$url_series_part/Sendung?documentId=$series_id&amp;bcastId=$series_id"
    url_series_rss="$url_series_html&amp;rss=true"
    echo "  <dct:isPartOf rdf:resource='$url_series_html'/>"
    echo "  <dct:isVersionOf rdf:resource='$file_base'/>"
    echo "</dctype:MovingImage>"

    echo "<dctype:Text rdf:about='$file_base'>"
    echo "  <dct:hasVersion rdf:resource='$self'/>"
    echo "</dctype:Text>"

    # fetch video version urls (quality)
    json_url="http://www.ardmediathek.de/play/media/$document_id"
    curl --silent --create-dirs --time-cond "$file_base.json" --output "$file_base.json" --url "$json_url"
    sh "bin/json2xml.sh" -r video < "$file_base.json" | xmllint --relaxng "bin/media-json.rng" --format --encode utf8 - > "$file_base.xml"
    # extract image + video urls
    xsltproc "bin/media-json.xslt" "$file_base.xml" | while read mime quality url
    do
      [ "image/jpeg" = "$mime" ] && [ "$image_url" = "" ] && image_url="$url" && {
        echo "<dctype:StillImage rdf:about='$image_url'>"
        echo "  <dct:isFormatOf rdf:resource='$file_base'/>"
        echo "  <dct:format rdf:resource='http://purl.org/NET/mediatypes/image/jpeg'/>"
        echo "</dctype:StillImage>"
      }
      [ "video/mp4"  = "$mime" ] && [ "$video_url" = "" ] && video_url="$url" && {
        echo "<dctype:MovingImage rdf:about='$video_url'>"
        echo "  <dct:isFormatOf rdf:resource='$file_base'/>"
        echo "  <dct:format rdf:resource='http://purl.org/NET/mediatypes/video/mp4'/>"
        echo "</dctype:MovingImage>"
      }
      [ "$image_url" != "" ] && [ "$video_url" != "" ] && break
    done
  done
  echo "</rdf:RDF>"
}
