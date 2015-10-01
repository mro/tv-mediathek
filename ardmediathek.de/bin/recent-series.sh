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

day=0 ; [ "$DAY" = "" ] || day=$(($DAY+0))
BASE_URL="http://www.ardmediathek.de"
CACHE="cache"
TMP="tmp"
PUB="pub"

###########################################################################
## fetch list of all broadcasting stations
###########################################################################
echo "xsltproc --stringparam base_url '/tv/sendungVerpasst?tag=$day' --html 'bin/$(basename "$0" .sh).sender.xslt' '$BASE_URL/tv/sendungVerpasst?tag=$day'" 1>&2
xsltproc --stringparam base_url "/tv/sendungVerpasst?tag=$day" --html "bin/$(basename "$0" .sh).sender.xslt" "$BASE_URL/tv/sendungVerpasst?tag=$day" 2>/dev/null \
| while read clips_url_ sender_name
do
  #########################################################################
  ## fetch urls of recent clips
  CLIPS_URL="${BASE_URL}$clips_url_"
  echo "$sender_name: $ xsltproc --html 'bin/$(basename "$0" .sh).xslt' '$CLIPS_URL'" 1>&2
  xsltproc --html "bin/$(basename "$0" .sh).xslt" "$CLIPS_URL" 2>/dev/null | while read time_ url_ title
  do
    [ "${time_}" != "" ] || { echo "$$time_ is unset. How can this be? '${time_} $url_ $title'" && exit 101; }
    [ "$url_" != "" ] || { echo "$$url_ is unset. How can this be? '${time_} $url_ $title'" && exit 101; }
    echo "$url_" | egrep -hoe "bcastId=[0-9]+"
  done
done
