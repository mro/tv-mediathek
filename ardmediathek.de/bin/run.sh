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

SETTINGS_FILE="../run.config"
[ -f "$SETTINGS_FILE" ] || { echo "I need a $(pwd)/$SETTINGS_FILE" && exit 1; }
. "$SETTINGS_FILE"

# Check preliminaries
curl --version >/dev/null       || { echo "I need curl" && exit 1; }
which xargs >/dev/null          || { echo "I need xargs" && exit 1; }
ruby --version >/dev/null       || { echo "I need ruby 1.8.7 or higher" && exit 1; }
# lftp --version >/dev/null       || { echo "I need lftp" && exit 1; }

# cleanup a bit:
grep -l "&amp;amp;" pub/series/*/feed.atom | head -n 5 | xargs rm

# download (cache) RSS candidates
url_pattern='http://www.ardmediathek.de/export/rss/id={}'
# url_pattern='http://www.ardmediathek.de/tv/Tatort/Sendung?documentId={}&rss=true'
sh bin/recent-series.sh \
  | sort \
  | uniq \
  | egrep -hoe "bcastId=[0-9]+" \
  | sort -n \
  | cut -c 9- \
  | xargs -I{} -P 15 -n 1 -- curl --create-dirs --silent --output 'cache/series/{}/feed.rss' "$url_pattern"
# find changed ones and run them through bin/atom.rb
# New feeds are picked up on 2nd run. That's IMO acceptable.
shasum --check cache/series.rss.sha \
  | grep "/feed.rss: FAILED" \
  | egrep -hoe "^cache/series/[0-9]+/feed.rss" \
  | sort -n \
  | uniq \
  | xargs -P 8 -n 1 -- ruby bin/atom.rb
shasum cache/series/*/feed.rss > cache/series.rss.sha

sh bin/create-series-opml.sh

## deploy from ../run.config
deploy

shasum --check cache/feeds.sha \
  | grep "/feed.atom: FAILED" \
  | egrep -hoe "^pub/series/[0-9]+/feed.atom" \
  | sort -n \
  | uniq \
  | xargs -P 15 -I{} -n 1 -- echo "notify pubsubhubbbub {}"
shasum pub/*/*/feed.atom > cache/feeds.sha

echo "done. $(date)"
