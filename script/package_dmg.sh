#!/usr/bin/env bash
set -euo pipefail

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
DMG_STAGING="$DIST_DIR/dmg-staging"
DMG_PATH="$DIST_DIR/ImageConvertAnything.dmg"

cd "$ROOT_DIR"
swift build -c release
BUILD_BINARY="$(swift build -c release --show-bin-path)/$EXECUTABLE_NAME"

rm -rf "$APP_BUNDLE" "$DMG_STAGING" "$DMG_PATH"
mkdir -p "$APP_MACOS" "$APP_RESOURCES" "$DMG_STAGING"
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

if command -v codesign >/dev/null 2>&1; then
  codesign --force --deep --sign - "$APP_BUNDLE" >/dev/null
fi

cp -R "$APP_BUNDLE" "$DMG_STAGING/"
ln -s /Applications "$DMG_STAGING/Applications"

hdiutil create \
  -volname "$DISPLAY_NAME" \
  -srcfolder "$DMG_STAGING" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

hdiutil verify "$DMG_PATH"

echo "Created $DMG_PATH"
