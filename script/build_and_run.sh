#!/usr/bin/env bash
set -euo pipefail

ROOMLET_MODE="${1:-run}"
case "$ROOMLET_MODE" in
  run|--build-only|--debug|--logs|--telemetry|--verify) ;;
  *) echo "usage: $0 [--build-only|--debug|--logs|--telemetry|--verify]" >&2; exit 2 ;;
esac
ROOMLET_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOMLET_ROOT"
if [[ -f "$HOME/.codex/storage-policy.md" ]]; then
  ROOMLET_GUARD="$HOME/Library/Application Support/LocalStorageGuard/storage_guard.py"
  [[ -f "$ROOMLET_GUARD" ]] || { echo "The workspace Storage Guard is unavailable." >&2; exit 1; }
  python3 "$ROOMLET_GUARD" preflight --need-gib 4
fi

if pgrep -x Roomlet >/dev/null; then
  if [[ "$ROOMLET_MODE" == --build-only ]]; then
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

swift build --product Roomlet
ROOMLET_BINARY="$(swift build --show-bin-path)/Roomlet"
"$ROOMLET_ROOT/script/package_app.sh" "$ROOMLET_BINARY"
ROOMLET_APP="$ROOMLET_ROOT/dist/Roomlet.app"
case "$ROOMLET_MODE" in
  --build-only) echo "Build-only finished; the app was not launched." ;;
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
