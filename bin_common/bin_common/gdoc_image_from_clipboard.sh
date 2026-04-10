#!/bin/bash

set -euo pipefail

output="${1:-clipboard_image.png}"

# Google Docs copies images as HTML with an embedded base64 data URI.
# Extract the base64 payload from the HTML clipboard and decode it.
osascript -e 'the clipboard as «class HTML»' \
    | sed 's/«data HTML//;s/»//' \
    | xxd -r -p \
    | sed -n 's/.*data:image\/[a-z]*;base64,\([^"]*\).*/\1/p' \
    | base64 -D -o "$output"

echo "$output"
