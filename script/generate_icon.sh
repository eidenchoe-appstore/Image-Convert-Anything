#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_PATH="${1:-$ROOT_DIR/dist/AppIcon.icns}"
ICON_PACKAGE="$ROOT_DIR/app_icon.icon"
ICTOOL="/Applications/Icon Composer.app/Contents/Executables/ictool"

if [[ ! -d "$ICON_PACKAGE" ]]; then
  echo "missing app_icon.icon" >&2
  exit 1
fi

if [[ ! -x "$ICTOOL" ]]; then
  echo "missing Icon Composer ictool: $ICTOOL" >&2
  exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

ICONSET="$TMP_DIR/AppIcon.iconset"
mkdir -p "$ICONSET" "$(dirname "$OUTPUT_PATH")"

render_icon() {
  local points="$1"
  local scale="$2"
  local output="$3"

  "$ICTOOL" "$ICON_PACKAGE" \
    --export-image \
    --output-file "$output" \
    --platform macOS \
    --rendition Default \
    --width "$points" \
    --height "$points" \
    --scale "$scale" >/dev/null
}

render_icon 16 1 "$ICONSET/icon_16x16.png"
render_icon 16 2 "$ICONSET/icon_16x16@2x.png"
render_icon 32 1 "$ICONSET/icon_32x32.png"
render_icon 32 2 "$ICONSET/icon_32x32@2x.png"
render_icon 128 1 "$ICONSET/icon_128x128.png"
render_icon 128 2 "$ICONSET/icon_128x128@2x.png"
render_icon 256 1 "$ICONSET/icon_256x256.png"
render_icon 256 2 "$ICONSET/icon_256x256@2x.png"
render_icon 512 1 "$ICONSET/icon_512x512.png"
render_icon 512 2 "$ICONSET/icon_512x512@2x.png"

iconutil -c icns "$ICONSET" -o "$OUTPUT_PATH"
echo "$OUTPUT_PATH"
