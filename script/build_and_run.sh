#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-run}"
EXECUTABLE_NAME="ImgConvertAnything"
DISPLAY_NAME="Image Convert Anything"
BUNDLE_ID="com.eiden.ImgConvertAnything"
MIN_SYSTEM_VERSION="14.0"
APP_VERSION="1.1.0"
BUILD_NUMBER="3"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
APP_BUNDLE="$DIST_DIR/$DISPLAY_NAME.app"
APP_CONTENTS="$APP_BUNDLE/Contents"
APP_MACOS="$APP_CONTENTS/MacOS"
APP_RESOURCES="$APP_CONTENTS/Resources"
APP_BINARY="$APP_MACOS/$EXECUTABLE_NAME"
INFO_PLIST="$APP_CONTENTS/Info.plist"
ICON_SOURCE="$ROOT_DIR/icon.png"
ICON_FILE="$APP_RESOURCES/AppIcon.icns"

pkill -x "$EXECUTABLE_NAME" >/dev/null 2>&1 || true

cd "$ROOT_DIR"
swift build
BUILD_BINARY="$(swift build --show-bin-path)/$EXECUTABLE_NAME"

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_MACOS" "$APP_RESOURCES"
cp "$BUILD_BINARY" "$APP_BINARY"
chmod +x "$APP_BINARY"

install_icon() {
  if [[ ! -f "$ICON_SOURCE" ]]; then
    return
  fi

  local tmp_dir iconset base_png
  tmp_dir="$(mktemp -d)"
  iconset="$tmp_dir/AppIcon.iconset"
  base_png="$tmp_dir/AppIcon-1024.png"
  mkdir -p "$iconset"

  sips --resampleHeightWidthMax 1024 "$ICON_SOURCE" --out "$base_png" >/dev/null
  sips --padToHeightWidth 1024 1024 --padColor 000000 "$base_png" --out "$base_png" >/dev/null 2>&1

  sips -z 16 16 "$base_png" --out "$iconset/icon_16x16.png" >/dev/null
  sips -z 32 32 "$base_png" --out "$iconset/icon_16x16@2x.png" >/dev/null
  sips -z 32 32 "$base_png" --out "$iconset/icon_32x32.png" >/dev/null
  sips -z 64 64 "$base_png" --out "$iconset/icon_32x32@2x.png" >/dev/null
  sips -z 128 128 "$base_png" --out "$iconset/icon_128x128.png" >/dev/null
  sips -z 256 256 "$base_png" --out "$iconset/icon_128x128@2x.png" >/dev/null
  sips -z 256 256 "$base_png" --out "$iconset/icon_256x256.png" >/dev/null
  sips -z 512 512 "$base_png" --out "$iconset/icon_256x256@2x.png" >/dev/null
  sips -z 512 512 "$base_png" --out "$iconset/icon_512x512.png" >/dev/null
  cp "$base_png" "$iconset/icon_512x512@2x.png"

  iconutil -c icns "$iconset" -o "$ICON_FILE"
  rm -rf "$tmp_dir"
}

install_icon

cat >"$INFO_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleDisplayName</key>
  <string>$DISPLAY_NAME</string>
  <key>CFBundleExecutable</key>
  <string>$EXECUTABLE_NAME</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleName</key>
  <string>$DISPLAY_NAME</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>$APP_VERSION</string>
  <key>CFBundleVersion</key>
  <string>$BUILD_NUMBER</string>
  <key>LSApplicationCategoryType</key>
  <string>public.app-category.photography</string>
  <key>LSMinimumSystemVersion</key>
  <string>$MIN_SYSTEM_VERSION</string>
  <key>NSHighResolutionCapable</key>
  <true/>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
</dict>
</plist>
PLIST

open_app() {
  /usr/bin/open -n "$APP_BUNDLE"
}

case "$MODE" in
  run)
    open_app
    ;;
  --debug|debug)
    lldb -- "$APP_BINARY"
    ;;
  --logs|logs)
    open_app
    /usr/bin/log stream --info --style compact --predicate "process == \"$EXECUTABLE_NAME\""
    ;;
  --telemetry|telemetry)
    open_app
    /usr/bin/log stream --info --style compact --predicate "subsystem == \"$BUNDLE_ID\""
    ;;
  --verify|verify)
    open_app
    sleep 2
    pgrep -x "$EXECUTABLE_NAME" >/dev/null
    ;;
  *)
    echo "usage: $0 [run|--debug|--logs|--telemetry|--verify]" >&2
    exit 2
    ;;
esac
