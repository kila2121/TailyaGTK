#!/usr/bin/env bash
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
OUT="/tmp/theme-shell-test"
VARIANT="dark"
SCHEME=""
D2D=""
CSS=""

while [ $# -gt 0 ]; do
  case "$1" in
    --out) OUT="$2"; shift 2 ;;
    --scheme) SCHEME="$2"; shift 2 ;;
    --variant) VARIANT="$2"; shift 2 ;;
    --d2d) D2D="$2"; shift 2 ;;
    --css) CSS="$2"; shift 2 ;;
    *) echo "unknown option: $1"; exit 2 ;;
  esac
done
case "$VARIANT" in
  dark) THEME_NAME="TailyaGTK"; SCHEME="${SCHEME:-prefer-dark}" ;;
  light) THEME_NAME="TailyaGTK-Light"; SCHEME="${SCHEME:-prefer-light}" ;;
  *) echo "variant must be dark or light"; exit 2 ;;
esac
CSS="${CSS:-$ROOT/themes/$THEME_NAME/gnome-shell/gnome-shell.css}"

for c in gnome-shell gdbus dbus-run-session python3; do
  command -v "$c" >/dev/null || { echo "missing: $c"; exit 2; }
done
python3 -c "import dbusmock" 2>/dev/null || { echo "missing: python3-dbusmock (pip install python-dbusmock)"; exit 2; }

if [ -z "$D2D" ]; then
  for d in "$HOME/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com" "/usr/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com"; do
    [ -d "$d" ] && D2D="$d" && break
  done
fi
[ -n "$D2D" ] || { echo "Dash to Dock not found, pass --d2d DIR"; exit 2; }

rm -rf "$OUT"; mkdir -p "$OUT/home" "$OUT/xdg"; chmod 700 "$OUT/xdg"
OUT="$(cd "$OUT" && pwd)"
D2D="$(cd "$D2D" && pwd)"
CSS="$(cd "$(dirname "$CSS")" && pwd)/$(basename "$CSS")"

export HOME="$OUT/home"
export XDG_RUNTIME_DIR="$OUT/xdg"
export XDG_CURRENT_DESKTOP=GNOME
export XDG_SESSION_TYPE=wayland
export LIBGL_ALWAYS_SOFTWARE=1
export NO_AT_BRIDGE=1

mkdir -p "$HOME/.themes/$THEME_NAME/gnome-shell" "$HOME/.local/share/gnome-shell/extensions"
ln -s "$CSS" "$HOME/.themes/$THEME_NAME/gnome-shell/gnome-shell.css"
ln -s "$D2D" "$HOME/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com"

export OUT HERE THEME_NAME SCHEME VARIANT
cd "$OUT"

dbus-run-session -- bash "$HERE/session.sh" > "$OUT/shell.log" 2>&1

python3 "$HERE/summary.py" "$OUT"
