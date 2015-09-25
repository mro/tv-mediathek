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

######################################################################
## Scrape ardmediathek.de for RSS feeds and build a OPML summary.
######################################################################

SETTINGS_FILE="bin/$(basename "$0" .sh).settings"
[ -f "$SETTINGS_FILE" ] || { echo "I need a $(pwd)/$SETTINGS_FILE" && exit 1; }
. "$SETTINGS_FILE"
[ "$OPML_URL" != "" ] || { echo "OPML_URL must be set in $(pwd)/$SETTINGS_FILE" && exit 1; }

DST="ardmediathek.de.opml"

# Check preliminaries
curl --version >/dev/null       || { echo "I need curl." && exit 1; }
xmllint --version 2> /dev/null  || { echo "I need xmllint (libxml2)." && exit 1; }
xsltproc --version > /dev/null  || { echo "I need xsltproc." && exit 1; }
shasum --version > /dev/null    || { echo "I need shasum." && exit 1; }

# ~24 Letters
# ~700 Series (~30 Series per Letter)
# ~17000 Episodes (~25 Episodes per Series)

[ "$TMP" != "" ] || TMP="."
RELAXNG_SCHEMA_URL='https://raw.githubusercontent.com/mro/opml-schema/hotfix/typo/schema.rng'
RELAXNG_SCHEMA="$TMP/opml.rng"
[ -f "$RELAXNG_SCHEMA" ] \
|| curl --location --remote-time --time-cond "$RELAXNG_SCHEMA" --output "$RELAXNG_SCHEMA" --url "$RELAXNG_SCHEMA_URL" \
|| { echo "Failed to download mandatory RelaxNG schema from $RELAXNG_SCHEMA_URL" && exit 1; }

unescape_xml() {
  echo "$1" | sed -e 's/\&amp;/\&/g'
}
escape_xml() {
  echo "$1" | sed -e "s/\&/\&amp;/g;s/'/\&apos;/g"
}

BASE_URL="http://www.ardmediathek.de/tv/sendungen-a-z?sendungsTyp=sendung"

{
  cat <<EOF
<opml version='2.0' xmlns:a='http://www.w3.org/2005/Atom'>
  <!-- 
    Lizenz: CC BY-SA 3.0 DE
  -->
  <!-- 
    <a:link rel='license'>http://creativecommons.org/licenses/by-sa/3.0/de/</a:link>
    <a:link rel='self'>$OPML_URL</a:link>
    <a:link rel='source'>$BASE_URL</a:link>
    <a:link rel='hub'>$PUBSUBHUBBUB</a:link>
    validates against https://raw.githubusercontent.com/mro/opml-schema/hotfix/typo/schema.rng
  -->
  <head>
    <title>ARD Mediathek RSS Feeds</title>
    <!-- <dateCreated/> see file timestamp -->
    <ownerId>http://purl.mro.name/mediathek</ownerId>
  </head>
  <body>
EOF

  for letter_url_ in $(curl --silent --url "$BASE_URL" | egrep -hoe 'href="/(radio|tv)/sendungen-a-z\?sendungsTyp=sendung&amp;buchstabe=[^"]+' | cut -c 7- | sort | uniq)
  do
    printf "%s" '*' 1>&2
    letter_url="http://www.ardmediathek.de$letter_url_"
    echo "  <outline text='Buchstabe $(echo "$letter_url_" | cut -c 53-)'>"
    echo "    <!-- $letter_url -->"

    xsltproc --html bin/series2opml.xslt "$(unescape_xml "$letter_url")" 2>/dev/null \
    | sed -e "s/\&/\&amp;/g;s/'/\&apos;/g" \
    | while read series_url_ title
    do
      printf "%s" '.' 1>&2
      series_url="http://www.ardmediathek.de$series_url_"
      echo "    <outline language='de' text='$title' type='rss' version='RSS2' htmlUrl='$series_url' xmlUrl='$series_url&amp;rss=true'/>"

      # reihe_url="http://www.ardmediathek.de$reihe_url_&amp;rss=true"
      # <a class="mediaLink" href="/tv/FilmMittwoch-im-Ersten/Meister-des-Todes-H%C3%B6rfassung-Video-tg/Das-Erste/Video?documentId=30734576&amp;bcastId=10318946">
      # </a>

  # Better get episode from RSS feed: &rss=true
  #     # TODO: extract not only episode url but also start time
  #     for episode_url_ in $(curl --silent --url "$series_url" | egrep -hoe 'href="/(radio|tv)/[^"]+\?documentId=[^"]+&amp;bcastId=[^"]+' | cut -c 7- | sed -e 's/\&amp;/\&/g' | sort | uniq)
  #     for episode_url in $(curl --silent --url "$series_url&rss=true" | egrep -hoe '<guid>[^<]+' | cut -c 7- | sed -e 's/\&amp;/\&/g' | sort | uniq)
  #     do
  #       echo "<!-- Episode: $episode_url -->"
  #       # extract documentid per episode or look for '/play/media/[^']+'
  #       # (json) http://www.ardmediathek.de/play/media/$documentid?devicetype=pc&features=
  #     done
    done
    echo "  </outline>"
  done

  cat <<EOF
  </body>
</opml>
EOF
} \
| xmllint --format --encode utf8 --relaxng "$RELAXNG_SCHEMA" --output "$DST~" - \
|| { echo "ouch" 1>&2 && exit 101; }

mv "$DST~" "$DST"
if shasum --check "$DST.sha"
then
  # if unchanged keep timestamp
  touch -r "$DST.sha" "$DST"
  echo unchanged
else
  shasum "$DST" > "$DST.sha"

#   echo "deploy & verify..."
#   rsync "$DST" "$DEPLOY_DST"
#   CONTENT_LENGTH=$(curl --location --head "$OPML_URL" | egrep -hoe '^Content-Length: [0-9]+' | cut -c 17-)
#   [ "$CONTENT_LENGTH" != "" ] || CONTENT_LENGTH=0
#   [ $(wc -c < "$DST") -eq $CONTENT_LENGTH ] || { echo "Content size mismatch: $(pwd)/$DST != $OPML_URL" && exit 1; }

  # http://blog.mro.name/2015/03/key-based-ftp-authentication/
  # lftp -u <username>,xx -e "put $DST ; quit" "$FTP"

  # https://indiewebcamp.com/How_to_publish_and_consume_PubSubHubbub
  [ "" = "$PUBSUBHUBBUB" ] || curl --url "$PUBSUBHUBBUB" \
    --data-urlencode "hub.mode=publish" \
    --data-urlencode "hub.url=$OPML_URL" \
    --location --output /dev/null \
    --write-out "POST $PUBSUBHUBBUB %{http_code}" 2>/dev/null
fi
