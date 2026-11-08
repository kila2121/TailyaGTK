#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
command -v sassc >/dev/null || { echo "sassc is required (sudo apt install sassc)"; exit 1; }
command -v gresource >/dev/null || { echo "gresource is required (sudo apt install libglib2.0-bin)"; exit 1; }

GTK3_LIB="$(ldconfig -p | awk '/libgtk-3\.so\.0/ {print $NF; exit}')"
GTK4_LIB="$(ldconfig -p | awk '/libgtk-4\.so\.1/ {print $NF; exit}')"
[ -n "$GTK3_LIB" ] || { echo "libgtk-3 not found (sudo apt install libgtk-3-0)"; exit 1; }
[ -n "$GTK4_LIB" ] || { echo "libgtk-4 not found (sudo apt install libgtk-4-1)"; exit 1; }

mkdir -p build

build_variant() {
  local variant="$1" name="$2" gtk3_base="$3" gtk4_base="$4"
  local out="themes/$name" tmp="build/$variant"
  mkdir -p "$out/gtk-3.0" "$out/gtk-4.0" "$out/gnome-shell" "$tmp"

  sed "s/@NAME@/$name/g; s/@VARIANT@/$variant/g" src/index.theme.in > "$out/index.theme"

  for part in gtk3 gtk4 shell; do
    printf "@import 'palettes/%s';\n@import '%s';\n" "$variant" "$part" > "$tmp/entry-$part.scss"
    sassc -t expanded -I src "$tmp/entry-$part.scss" "$tmp/$part-overrides.css"
  done

  gresource extract "$GTK3_LIB" "/org/gtk/libgtk/theme/Adwaita/$gtk3_base" > "$tmp/gtk3-base.css"
  python3 tools/recolor.py "$tmp/gtk3-base.css" "$tmp/gtk3-base.recolored.css" "resource:///org/gtk/libgtk/theme/Adwaita/assets/" "$variant"
  cat "$tmp/gtk3-base.recolored.css" "$tmp/gtk3-overrides.css" > "$out/gtk-3.0/gtk.css"

  gresource extract "$GTK4_LIB" "/org/gtk/libgtk/theme/Default/$gtk4_base" > "$tmp/gtk4-base.css"
  python3 tools/recolor.py "$tmp/gtk4-base.css" "$tmp/gtk4-base.recolored.css" "resource:///org/gtk/libgtk/theme/Default/assets/" "$variant"
  cp "$tmp/gtk4-overrides.css" "$out/gtk-4.0/libadwaita.css"
  cat "$tmp/gtk4-base.recolored.css" "$tmp/gtk4-overrides.css" > "$out/gtk-4.0/gtk.css"

  cp "$tmp/shell-overrides.css" "$out/gnome-shell/gnome-shell.css"

  rm -f "$out/gtk-3.0/gtk-dark.css" "$out/gtk-4.0/gtk-dark.css"
  if [ "$variant" = "dark" ]; then
    printf '@import url("gtk.css");\n' > "$out/gtk-3.0/gtk-dark.css"
    printf '@import url("gtk.css");\n' > "$out/gtk-4.0/gtk-dark.css"
  fi
  echo "built $out"
}

build_variant dark TailyaGTK gtk-contained-dark.css Default-dark.css
build_variant light TailyaGTK-Light gtk-contained.css Default-light.css
