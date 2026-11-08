#!/usr/bin/env bash
set -euo pipefail

ROOMLET_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOMLET_BINARY="${1:?usage: package_app.sh /path/to/built/Roomlet [--preview]}"
ROOMLET_PACKAGE_MODE="${2:-}"
if [[ "$#" -gt 2 || ( -n "$ROOMLET_PACKAGE_MODE" && "$ROOMLET_PACKAGE_MODE" != --preview ) ]]; then
  echo "usage: package_app.sh /path/to/built/Roomlet [--preview]" >&2
  exit 2
fi
[[ -f "$ROOMLET_BINARY" && -x "$ROOMLET_BINARY" ]] || { echo "A built Roomlet executable is required." >&2; exit 1; }
ROOMLET_DIST="$ROOMLET_ROOT/dist"
ROOMLET_APP="$ROOMLET_DIST/Roomlet.app"
ROOMLET_PREVIEW_NAME="Roomlet-0.1.0-macos-universal.zip"
ROOMLET_PREVIEW_COMPLETE=0
if [[ "$ROOMLET_PACKAGE_MODE" == --preview ]]; then
  command -v python3 >/dev/null || { echo "Preview packaging requires Python 3's standard library." >&2; exit 1; }
  if pgrep -x Roomlet >/dev/null; then
    echo "Close Roomlet before replacing its app bundle. Existing work was left alone." >&2
    exit 1
  fi
  if [[ -e "$ROOMLET_DIST" && ! -d "$ROOMLET_DIST" ]]; then
    echo "Refusing an unsafe preview output directory." >&2
    exit 1
  fi
  for ROOMLET_OUTPUT in "$ROOMLET_DIST/$ROOMLET_PREVIEW_NAME" "$ROOMLET_DIST/$ROOMLET_PREVIEW_NAME.sha256"; do
    if [[ -e "$ROOMLET_OUTPUT" || -L "$ROOMLET_OUTPUT" ]]; then
      echo "Preview output already exists; nothing was replaced: $ROOMLET_OUTPUT" >&2
      exit 1
    fi
  done
fi
if [[ -L "$ROOMLET_DIST" || -L "$ROOMLET_APP" ]]; then
  echo "Refusing a symlinked app output path." >&2
  exit 1
fi
mkdir -p "$ROOMLET_DIST"
if [[ -e "$ROOMLET_APP" ]]; then
  [[ -f "$ROOMLET_APP/Contents/Resources/.roomlet-generated" || -f "$ROOMLET_APP/Contents/.roomlet-generated" ]] || { echo "The existing output is not a Roomlet-generated bundle. Move it aside first." >&2; exit 1; }
  ROOMLET_OLD_ID="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$ROOMLET_APP/Contents/Info.plist")"
  [[ "$ROOMLET_OLD_ID" == com.alvarovillalbaa.Roomlet ]] || { echo "The existing output belongs to another app." >&2; exit 1; }
fi
ROOMLET_STAGE="$(mktemp -d "$ROOMLET_DIST/.roomlet-stage.XXXXXX")"
cleanup_roomlet_stage() {
  if [[ "$ROOMLET_PACKAGE_MODE" == --preview && "$ROOMLET_PREVIEW_COMPLETE" == 0 ]]; then
    python3 - "$ROOMLET_STAGE" "$ROOMLET_DIST" "$ROOMLET_PREVIEW_NAME" <<'PY'
from pathlib import Path
import stat
import sys

stage, output = map(Path, sys.argv[1:3])
for name in (sys.argv[3], sys.argv[3] + ".sha256"):
    source, target = stage / name, output / name
    try:
        left, right = source.lstat(), target.lstat()
    except FileNotFoundError:
        continue
    if (stat.S_ISREG(left.st_mode) and stat.S_ISREG(right.st_mode)
            and (left.st_dev, left.st_ino) == (right.st_dev, right.st_ino)):
        target.unlink()
PY
    if [[ -d "$ROOMLET_STAGE/previous.app" ]]; then
      if [[ ! -e "$ROOMLET_APP" && ! -L "$ROOMLET_APP" ]]; then
        mv -n "$ROOMLET_STAGE/previous.app" "$ROOMLET_APP"
      fi
      if [[ -d "$ROOMLET_STAGE/previous.app" ]]; then
        echo "Previous app preserved for recovery: $ROOMLET_STAGE/previous.app" >&2
        return
      fi
    fi
  fi
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
if [[ "$ROOMLET_PACKAGE_MODE" == --preview ]]; then
  cp "$ROOMLET_ROOT/LICENSE" "$ROOMLET_STAGE/Roomlet.app/Contents/Resources/LICENSE.txt"
  cp "$ROOMLET_ROOT/docs/preview-setup.md" "$ROOMLET_STAGE/Roomlet.app/Contents/Resources/PREVIEW.md"
fi
printf 'Roomlet generated build output\n' > "$ROOMLET_STAGE/Roomlet.app/Contents/Resources/.roomlet-generated"
chmod +x "$ROOMLET_STAGE/Roomlet.app/Contents/MacOS/Roomlet"
/usr/bin/plutil -lint "$ROOMLET_STAGE/Roomlet.app/Contents/Info.plist"
# Local artifact signing uses no developer account or network; it is not notarization.
/usr/bin/codesign --force --sign - --entitlements "$ROOMLET_ROOT/Resources/Roomlet.entitlements" "$ROOMLET_STAGE/Roomlet.app"
/usr/bin/codesign --verify --strict "$ROOMLET_STAGE/Roomlet.app"
if [[ "$ROOMLET_PACKAGE_MODE" == --preview ]]; then
  [[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$ROOMLET_STAGE/Roomlet.app/Contents/Info.plist")" == 0.1.0 ]] || { echo "Preview archive version does not match its bundle." >&2; exit 1; }
  python3 - "$ROOMLET_STAGE/Roomlet.app" <<'PY'
from pathlib import Path
import stat
import sys

app = Path(sys.argv[1])
total = 0
for count, path in enumerate(app.rglob("*"), 1):
    if count > 512:
        raise SystemExit("Preview bundle exceeds 512 entries.")
    mode = path.lstat().st_mode
    if stat.S_ISREG(mode):
        total += path.stat().st_size
    elif not stat.S_ISDIR(mode):
        raise SystemExit("Preview bundle contains a nonregular entry.")
    if total > 32 * 1024 * 1024:
        raise SystemExit("Preview bundle exceeds 32 MiB.")
PY
  /usr/bin/ditto -c -k --rsrc --extattr --sequesterRsrc --keepParent "$ROOMLET_STAGE/Roomlet.app" "$ROOMLET_STAGE/$ROOMLET_PREVIEW_NAME"
  python3 - "$ROOMLET_STAGE" "$ROOMLET_DIST" "$ROOMLET_PREVIEW_NAME" <<'PY'
import hashlib
import os
from pathlib import Path, PurePosixPath
import stat
import sys
import zipfile

stage, output = map(Path, sys.argv[1:3])
name = sys.argv[3]
archive = stage / name
if archive.stat().st_size > 8 * 1024 * 1024:
    raise SystemExit("Preview ZIP exceeds 8 MiB.")
with zipfile.ZipFile(archive) as package:
    entries = package.infolist()
    if len(entries) > 512 or sum(row.file_size for row in entries) > 32 * 1024 * 1024:
        raise SystemExit("Preview ZIP exceeds its expansion budget.")
    seen = set()
    for row in entries:
        path = PurePosixPath(row.filename)
        mode = row.external_attr >> 16
        if (row.filename in seen or path.is_absolute() or ".." in path.parts
                or not path.parts or path.parts[0] not in ("Roomlet.app", "__MACOSX")
                or row.filename != path.as_posix() + ("/" if row.is_dir() else "")
                or "\\" in row.filename or any(ord(char) < 32 or ord(char) == 127 for char in row.filename)
                or row.flag_bits & 1 or not (stat.S_ISREG(mode) or stat.S_ISDIR(mode))):
            raise SystemExit("Preview ZIP contains an unsafe entry.")
        seen.add(row.filename)
        data = package.read(row)
        if path.parts[0] == "__MACOSX":
            parts = path.parts[1:]
            if not parts and row.is_dir():
                continue
            if not parts:
                raise SystemExit("Preview ZIP metadata has no bundle owner.")
            if row.is_dir():
                owner_parts = parts
            elif parts[-1].startswith("._") and len(parts[-1]) > 2:
                owner_parts = (*parts[:-1], parts[-1][2:])
                if data[:8] != b"\x00\x05\x16\x07\x00\x02\x00\x00":
                    raise SystemExit("Preview ZIP metadata is not AppleDouble.")
            else:
                raise SystemExit("Preview ZIP metadata has an unsupported name.")
            if not owner_parts or owner_parts[0] != "Roomlet.app":
                raise SystemExit("Preview ZIP metadata has no bundle owner.")
            owner = stage.joinpath(*owner_parts)
            if not owner.exists() or owner.is_symlink():
                raise SystemExit("Preview ZIP metadata refers to an unknown entry.")
checksum = hashlib.sha256(archive.read_bytes()).hexdigest()
with (stage / (name + ".sha256")).open("x", encoding="ascii") as destination:
    destination.write(checksum + "  " + name + "\n")
published = []
try:
    for leaf in (name, name + ".sha256"):
        source, target = stage / leaf, output / leaf
        os.link(source, target, follow_symlinks=False)
        published.append((target, source.stat()))
except BaseException:
    for target, owned in reversed(published):
        current = target.lstat()
        if (current.st_dev, current.st_ino) == (owned.st_dev, owned.st_ino):
            target.unlink()
    raise
PY
fi
if [[ -e "$ROOMLET_APP" ]]; then mv "$ROOMLET_APP" "$ROOMLET_STAGE/previous.app"; fi
mv "$ROOMLET_STAGE/Roomlet.app" "$ROOMLET_APP"
if [[ "$ROOMLET_PACKAGE_MODE" == --preview ]]; then ROOMLET_PREVIEW_COMPLETE=1; fi
echo "Packaged local app: $ROOMLET_APP"
