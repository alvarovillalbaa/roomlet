#!/usr/bin/env bash
set -euo pipefail

ROOMLET_MODE="${1:-run}"
case "$ROOMLET_MODE" in
  run|--build-only|--build-preview|--debug|--logs|--telemetry|--verify) ;;
  *) echo "usage: $0 [--build-only|--build-preview|--debug|--logs|--telemetry|--verify]" >&2; exit 2 ;;
esac
if [[ "$ROOMLET_MODE" == --build-preview && "$#" != 1 ]]; then
  echo "--build-preview accepts no other arguments." >&2
  exit 2
fi
ROOMLET_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOMLET_ROOT"
if [[ "$ROOMLET_MODE" == --build-preview ]]; then
  ROOMLET_BUILD_FLAGS=(--configuration release --build-system native --disable-local-rpath)
  if [[ -n "${ROOMLET_SWIFTPM_CACHE:-}" ]]; then
    if [[ "$ROOMLET_SWIFTPM_CACHE" != /* || ! -d "$ROOMLET_SWIFTPM_CACHE" || -L "$ROOMLET_SWIFTPM_CACHE" ]]; then
      echo "ROOMLET_SWIFTPM_CACHE must be an existing absolute directory, not a symlink." >&2
      exit 1
    fi
    ROOMLET_BUILD_FLAGS+=(--cache-path "$ROOMLET_SWIFTPM_CACHE")
  fi
  if [[ -L "$ROOMLET_ROOT/dist" || ( -e "$ROOMLET_ROOT/dist" && ! -d "$ROOMLET_ROOT/dist" ) ]]; then
    echo "Refusing an unsafe preview output directory." >&2
    exit 1
  fi
  for ROOMLET_OUTPUT in "$ROOMLET_ROOT/dist/Roomlet-0.1.0-macos-universal.zip" "$ROOMLET_ROOT/dist/Roomlet-0.1.0-macos-universal.zip.sha256"; do
    if [[ -e "$ROOMLET_OUTPUT" || -L "$ROOMLET_OUTPUT" ]]; then
      echo "Preview output already exists; nothing was replaced: $ROOMLET_OUTPUT" >&2
      exit 1
    fi
  done
fi
if [[ -f "$HOME/.codex/storage-policy.md" ]]; then
  ROOMLET_GUARD="$HOME/Library/Application Support/LocalStorageGuard/storage_guard.py"
  [[ -f "$ROOMLET_GUARD" ]] || { echo "The workspace Storage Guard is unavailable." >&2; exit 1; }
  python3 "$ROOMLET_GUARD" preflight --need-gib 4
fi

if pgrep -x Roomlet >/dev/null; then
  if [[ "$ROOMLET_MODE" == --build-only || "$ROOMLET_MODE" == --build-preview ]]; then
    echo "Close Roomlet before replacing its app bundle. Existing work was left alone." >&2
    exit 1
  fi
  /usr/bin/osascript -e 'tell application id "com.alvarovillalbaa.Roomlet" to quit'
  for ROOMLET_ATTEMPT in {1..20}; do
    pgrep -x Roomlet >/dev/null || break
    sleep 0.25
  done
  if pgrep -x Roomlet >/dev/null; then
    echo "Roomlet stayed open. Finish or stop its current operation and quit before rebuilding." >&2
    exit 1
  fi
fi

if [[ "$ROOMLET_MODE" == --build-preview ]]; then
  swift build --product Roomlet "${ROOMLET_BUILD_FLAGS[@]}" --arch arm64 --scratch-path "$ROOMLET_ROOT/.build/preview-arm64"
  ROOMLET_ARM64_BINARY="$(swift build "${ROOMLET_BUILD_FLAGS[@]}" --arch arm64 --scratch-path "$ROOMLET_ROOT/.build/preview-arm64" --show-bin-path)/Roomlet"
  swift build --product Roomlet "${ROOMLET_BUILD_FLAGS[@]}" --arch x86_64 --scratch-path "$ROOMLET_ROOT/.build/preview-x86_64"
  ROOMLET_X86_64_BINARY="$(swift build "${ROOMLET_BUILD_FLAGS[@]}" --arch x86_64 --scratch-path "$ROOMLET_ROOT/.build/preview-x86_64" --show-bin-path)/Roomlet"
  ROOMLET_UNIVERSAL_STAGE="$(mktemp -d "$ROOMLET_ROOT/.build/.roomlet-universal.XXXXXX")"
  trap 'rm -rf "$ROOMLET_UNIVERSAL_STAGE"' EXIT
  /usr/bin/lipo -create "$ROOMLET_ARM64_BINARY" "$ROOMLET_X86_64_BINARY" -output "$ROOMLET_UNIVERSAL_STAGE/Roomlet"
  chmod +x "$ROOMLET_UNIVERSAL_STAGE/Roomlet"
  "$ROOMLET_ROOT/script/package_app.sh" "$ROOMLET_UNIVERSAL_STAGE/Roomlet" --preview
else
  swift build --product Roomlet
  ROOMLET_BINARY="$(swift build --show-bin-path)/Roomlet"
  "$ROOMLET_ROOT/script/package_app.sh" "$ROOMLET_BINARY"
fi
ROOMLET_APP="$ROOMLET_ROOT/dist/Roomlet.app"
case "$ROOMLET_MODE" in
  --build-only) echo "Build-only finished; the app was not launched." ;;
  --build-preview) echo "Built a locally ad-hoc signed universal preview: $ROOMLET_ROOT/dist/Roomlet-0.1.0-macos-universal.zip" ;;
  --debug) lldb -- "$ROOMLET_APP/Contents/MacOS/Roomlet" ;;
  --logs)
    /usr/bin/open -n "$ROOMLET_APP"
    /usr/bin/log stream --info --style compact --predicate 'process == "Roomlet"'
    ;;
  --telemetry)
    /usr/bin/open -n "$ROOMLET_APP"
    /usr/bin/log stream --info --style compact --predicate 'subsystem == "com.alvarovillalbaa.Roomlet"'
    ;;
  --verify)
    /usr/bin/open -n "$ROOMLET_APP"
    sleep 1
    pgrep -x Roomlet >/dev/null
    ;;
  run) /usr/bin/open -n "$ROOMLET_APP" ;;
esac
