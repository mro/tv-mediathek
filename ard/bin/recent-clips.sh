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
shasum --version > /dev/null    || { echo "I need shasum." && exit 1; }

CLIPS_URL="http://www.ardmediathek.de/tv/sendungVerpasst?tag=0"

xsltproc --html "bin/$(basename "$0" .sh).xslt" "$CLIPS_URL" 2>/dev/null
