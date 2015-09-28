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

day=0 ; [ "$DAY" = "" ] || day=$(($DAY+0))
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

echo "xsltproc --stringparam base_url '/tv/sendungVerpasst?tag=$day' --html 'bin/$(basename "$0" .sh).sender.xslt' '$BASE_URL/tv/sendungVerpasst?tag=$day'" 1>&2
xsltproc --stringparam base_url "/tv/sendungVerpasst?tag=$day" --html "bin/$(basename "$0" .sh).sender.xslt" "$BASE_URL/tv/sendungVerpasst?tag=$day" 2>/dev/null \
| while read clips_url_ sender_name
do
  CLIPS_URL="${BASE_URL}$clips_url_"
  subdir="$sender_name/$(date "$adjust" '+%Y/%m/%d')"
  mkdir -p "$subdir" 2>/dev/null

  echo "$sender_name: $ xsltproc --html 'bin/$(basename "$0" .sh).xslt' '$CLIPS_URL'" 1>&2
  xsltproc --html "bin/$(basename "$0" .sh).xslt" "$CLIPS_URL" 2>/dev/null | while read time_ url_ title
  do
    [ "${time_}" != "" ] || { echo "$$time_ is unset. How can this be? '${time_} $url_ $title'" && exit 101; }
    [ "$url_" != "" ] || { echo "$$url_ is unset. How can this be? '${time_} $url_ $title'" && exit 101; }
    self="$(escape_xml "${BASE_URL}${url_}")"
    document_id="$(echo "$url_" | egrep -hoe 'documentId=[0-9]+' | cut -c 12-)"
    [ "$document_id" != "" ] || { echo "$$document_id is unset. How can this be? '$url_'" && exit 101; }

    file_base="$subdir/$(echo "${time_}" | tr -d ':')00-$document_id"
    file_base_url=""

    {
      # could be done parallel (1 HTTP request per loop)

      # fetch video version urls (quality)
      json_url="http://www.ardmediathek.de/play/media/$document_id"
      curl --silent --time-cond "$file_base.json" --output "$file_base.json" --url "$json_url"
      sh "bin/json2xml.sh" -r video < "$file_base.json" > "$file_base.xml" || {
        echo "This is bad!" 1>&2
        exit 111
      }
      xmllint --relaxng "bin/media-json.rng" --format --encode utf-8 --output "$file_base.xml~" "$file_base.xml" 2>/dev/null || {
        echo "FAILURE: $file_base.xml from '$json_url' invalid." 1>&2
        exit 112
      }
      mv "$file_base.xml~" "$file_base.xml"

      timestamp="$(date "$adjust" "+%Y-%m-%dT${time_}:00%z" | sed -e 's/..$/:\0/g')"

      url_series_part="$(echo "$url_" | cut -d / -f 3)"
      series_id="$(echo "$url_" | egrep -hoe 'bcastId=[0-9]+' | cut -c 9-)"
      url_series_html="http://www.ardmediathek.de/tv/$url_series_part/Sendung?documentId=$series_id&amp;bcastId=$series_id"
      url_series_rss="$url_series_html&amp;rss=true"

      # iTunes Podcast http://www.apple.com/de/itunes/podcasts/specs.html#duration
      # Yahoo! Media   https://web.archive.org/web/20090415204940/http://search.yahoo.com/mrss/
      # OPML           http://www.opml.org/spec2

      # the following uses tl:durationInt instead itunes:duration because the
      # latter crashes http://validator.w3.org/feed/check.cgi?url=https%3A%2F%2Fweb.archive.org%2Fweb%2F20150927180152%2Fhttp%3A%2F%2Flinkeddata.mro.name%2Fdemo.atom
      # see https://groups.google.com/forum/#!forum/feedvalidator-users

      cat <<EOF
<?xml version="1.0" encoding="utf-8"?>
<!-- ?xml-stylesheet type="text/xsl" href="../../../../assets/entry2html.xslt"? -->
<!-- unorthodox relative default namespace to enable http://www.w3.org/TR/grddl-tests/#sq2 without a central server -->
<a:entry xmlns="../../../../../assets/2015/tv-mediathek.rdf"
  xmlns:a="http://www.w3.org/2005/Atom"
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:tl="http://purl.org/NET/c4dm/timeline.owl#"
  xml:lang="de">
  <a:author><a:name>$sender_name</a:name></a:author>
  <a:link rel="via" type="text/html" href="$(escape_xml "$CLIPS_URL")"/>
  <a:link rel="alternate" type="text/html" href="$self"/>

  <a:title>$(escape_xml "$title")</a:title>
  <a:category scheme="http://www.ardmediathek.de/tv/$url_series_part/Sendung?" term="documentId=$series_id"/>
  <a:id>tag:ardmediathek.de,2015:documentId=$document_id</a:id>
  <a:updated>${timestamp}</a:updated>
  <a:published>${timestamp}</a:published>

  $(xsltproc "bin/media-json.xslt" "$file_base.xml" | grep -v "a:entry" | uniq)
</a:entry>
<!-- validate: http://validator.w3.org/feed/ -->
<!-- RDF: rapper -i grddl -o turtle <...> -->
EOF
      rm "$file_base.json" "$file_base.xml"
    } > "$file_base.atom"
    xmllint --nowarning --format --encode utf-8 --output "$file_base.atom~" "$file_base.atom" || {
      echo "FAILURE: $file_base.atom not well-formed"
      continue
    }
    mv "$file_base.atom~" "$file_base.atom"

    if [ -f "$file_base.atom.sha" ] && shasum --check "$file_base.atom.sha" 1>/dev/null 2>&1
    then
      printf '.'
      # if unchanged keep timestamp
      touch -r "$file_base.atom.sha" "$file_base.atom"
    else
      printf '+'
      shasum "$file_base.atom" > "$file_base.atom.sha"
      # deploy in case
    fi
  done
  echo ""
done
