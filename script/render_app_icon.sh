#!/usr/bin/env bash
set -euo pipefail

ROOMLET_ICON_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
command -v python3 >/dev/null || { echo "Python 3 is required to export this editable artwork." >&2; exit 1; }
exec python3 "$ROOMLET_ICON_ROOT/script/render_app_icon.py" "$@"
