#!/usr/bin/env bash
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-/tmp/TailyaGTK-test}"
mkdir -p "$OUT/cfg/gtk-4.0" "$OUT/data/themes"
status=0

xvfb-run -a python3 "$ROOT/tests/lint_gtk4.py" "$ROOT/gtk-4.0/gtk.css" || status=1
xvfb-run -a python3 "$ROOT/tests/lint_gtk4.py" "$ROOT/gtk-4.0/libadwaita.css" || status=1
xvfb-run -a python3 "$ROOT/tests/lint_gtk3.py" "$ROOT/gtk-3.0/gtk.css" || status=1

rm -rf "$OUT/data/themes/TailyaGTK"; ln -s "$ROOT" "$OUT/data/themes/TailyaGTK"
shot() {
  local name="$1"; shift
  xvfb-run -a -s "-screen 0 1100x720x24" bash -c "
    export GDK_BACKEND=x11 GSK_RENDERER=cairo LIBGL_ALWAYS_SOFTWARE=1 NO_AT_BRIDGE=1 $*
    \$PYTHON_CMD &
    pid=\$!
    sleep 2.4
    import -window root '$OUT/$name.png'
    wait \$pid
  "
}

rm -f "$OUT/cfg/gtk-4.0/gtk.css"
PYTHON_CMD="python3 $ROOT/tests/preview_gtk4.py" XDG_CONFIG_HOME="$OUT/cfg-empty" shot gtk4-baseline "XDG_CONFIG_HOME=$OUT/cfg-empty"
ln -s "$ROOT/gtk-4.0/libadwaita.css" "$OUT/cfg/gtk-4.0/gtk.css"
PYTHON_CMD="python3 $ROOT/tests/preview_gtk4.py" shot gtk4-TailyaGTK "XDG_CONFIG_HOME=$OUT/cfg"
PYTHON_CMD="python3 $ROOT/tests/preview_gtk4.py" shot gtk4-TailyaGTK-popover "XDG_CONFIG_HOME=$OUT/cfg TailyaGTK_POPOVER=1"
PYTHON_CMD="python3 $ROOT/tests/preview_gtk3.py" shot gtk3-baseline "GTK_THEME=Adwaita:dark"
PYTHON_CMD="python3 $ROOT/tests/preview_gtk3.py" shot gtk3-TailyaGTK "XDG_DATA_HOME=$OUT/data GTK_THEME=TailyaGTK:dark"
PYTHON_CMD="python3 $ROOT/tests/preview_gtk4_plain.py" shot gtk4-plain "XDG_DATA_HOME=$OUT/data XDG_CONFIG_HOME=$OUT/cfg-empty GTK_THEME=TailyaGTK:dark"
ls -l "$OUT"/*.png
exit $status
