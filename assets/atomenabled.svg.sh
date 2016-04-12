#!/bin/sh
cd "$(dirname "$0")"
# 
# http://stackoverflow.com/a/15072127
# 

inkscape=/Applications/Inkscape.app/Contents/Resources/bin/inkscape

$inkscape --help >/dev/null 2>&1  || { echo "Inkscape is not installed." && exit 1; }
optipng -help >/dev/null 2>&1     || { echo "optipng is not installed." && exit 1; }
sips --help >/dev/null 2>&1       || { echo "sips is not installed. https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/sips.1.html" && exit 1; }

src="$(pwd)/atomenabled-dev.svg"
dst_dir="$(pwd)"

prefix=$dst_dir/atomenabled
OPTS="--export-background=white --without-gui --export-area-page"
# OPTS="$OPTS --export-id-only"

dst=${prefix}-210x80.png
$inkscape --export-width=210 --export-height=80 --export-png=$dst $OPTS --file="$src"

dst=${prefix}-100x100.png
$inkscape --export-width=100 --export-height=100 --export-area=0:0:81:81 --export-png=$dst $OPTS --file="$src"

sips --setProperty description 'AtomEnabled.org Logo' \
  --setProperty copyright https://github.com/mro/tv-mediathek/blob/master/assets/atomenabled.svg \
  "$dst_dir"/*.png
optipng -o 7 "$dst_dir"/*.png

# crate a clean, stripped down SVG

dst=${prefix}.svg
cp "$src" "$dst"
# http://stackoverflow.com/a/10492912
$inkscape "$dst" \
  --select=graphics0 --verb=EditDelete \
  --select=graphics0 --verb=EditDelete \
  --select=graphics1 --verb=EditDelete \
  --select=graphics2 --verb=EditDelete \
  --select=helper0   --verb=EditDelete \
  --select=helper1   --verb=EditDelete \
  --select=text1     --verb=EditDelete \
  --select=bitmap0   --verb=EditDelete \
  --verb=FileVacuum  --verb=FileSave \
  --verb=FileClose   --verb=FileQuit
$inkscape --without-gui --vacuum-defs --export-plain-svg="$dst" --file="$dst"
