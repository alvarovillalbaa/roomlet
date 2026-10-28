#!/usr/bin/env bash
set -euo pipefail

ROOMLET_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOMLET_BINARY="${1:?usage: package_app.sh /path/to/built/Roomlet}"
[[ -f "$ROOMLET_BINARY" && -x "$ROOMLET_BINARY" ]] || { echo "A built Roomlet executable is required." >&2; exit 1; }
ROOMLET_DIST="$ROOMLET_ROOT/dist"
ROOMLET_APP="$ROOMLET_DIST/Roomlet.app"
if [[ -L "$ROOMLET_DIST" || -L "$ROOMLET_APP" ]]; then
  echo "Refusing a symlinked app output path." >&2
  exit 1
fi
mkdir -p "$ROOMLET_DIST"
if [[ -e "$ROOMLET_APP" ]]; then
  [[ -f "$ROOMLET_APP/Contents/.roomlet-generated" ]] || { echo "The existing output is not a Roomlet-generated bundle. Move it aside first." >&2; exit 1; }
  ROOMLET_OLD_ID="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$ROOMLET_APP/Contents/Info.plist")"
  [[ "$ROOMLET_OLD_ID" == com.alvarovillalbaa.Roomlet ]] || { echo "The existing output belongs to another app." >&2; exit 1; }
fi
ROOMLET_STAGE="$(mktemp -d "$ROOMLET_DIST/.roomlet-stage.XXXXXX")"
cleanup_roomlet_stage() {
  if [[ ! -e "$ROOMLET_APP" && -d "$ROOMLET_STAGE/previous.app" ]]; then
    mv "$ROOMLET_STAGE/previous.app" "$ROOMLET_APP"
  fi
  rm -rf "$ROOMLET_STAGE"
}
trap cleanup_roomlet_stage EXIT
mkdir -p "$ROOMLET_STAGE/Roomlet.app/Contents/MacOS"
mkdir -p "$ROOMLET_STAGE/Roomlet.app/Contents/Resources"
cp "$ROOMLET_BINARY" "$ROOMLET_STAGE/Roomlet.app/Contents/MacOS/Roomlet"
cp "$ROOMLET_ROOT/Resources/Info.plist" "$ROOMLET_STAGE/Roomlet.app/Contents/Info.plist"
cp "$ROOMLET_ROOT/Resources/AppIcon.icns" "$ROOMLET_STAGE/Roomlet.app/Contents/Resources/AppIcon.icns"
printf 'Roomlet generated build output\n' > "$ROOMLET_STAGE/Roomlet.app/Contents/.roomlet-generated"
chmod +x "$ROOMLET_STAGE/Roomlet.app/Contents/MacOS/Roomlet"
/usr/bin/plutil -lint "$ROOMLET_STAGE/Roomlet.app/Contents/Info.plist"
# Local artifact signing uses no developer account or network; it is not notarization.
/usr/bin/codesign --force --sign - --entitlements "$ROOMLET_ROOT/Resources/Roomlet.entitlements" "$ROOMLET_STAGE/Roomlet.app"
/usr/bin/codesign --verify --strict "$ROOMLET_STAGE/Roomlet.app"
if [[ -e "$ROOMLET_APP" ]]; then mv "$ROOMLET_APP" "$ROOMLET_STAGE/previous.app"; fi
mv "$ROOMLET_STAGE/Roomlet.app" "$ROOMLET_APP"
echo "Packaged local app: $ROOMLET_APP"
