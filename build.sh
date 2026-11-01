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

gresource extract "$GTK3_LIB" /org/gtk/libgtk/theme/Adwaita/gtk-contained-dark.css > build/gtk3-base.css
python3 tools/recolor.py build/gtk3-base.css build/gtk3-base.recolored.css "resource:///org/gtk/libgtk/theme/Adwaita/assets/"
sassc -t expanded -I src src/gtk3.scss build/gtk3-overrides.css
cat build/gtk3-base.recolored.css build/gtk3-overrides.css > gtk-3.0/gtk.css
printf '@import url("gtk.css");\n' > gtk-3.0/gtk-dark.css

gresource extract "$GTK4_LIB" /org/gtk/libgtk/theme/Default/Default-dark.css > build/gtk4-base.css
python3 tools/recolor.py build/gtk4-base.css build/gtk4-base.recolored.css "resource:///org/gtk/libgtk/theme/Default/assets/"
sassc -t expanded -I src src/gtk4.scss build/gtk4-overrides.css
cp build/gtk4-overrides.css gtk-4.0/libadwaita.css
cat build/gtk4-base.recolored.css build/gtk4-overrides.css > gtk-4.0/gtk.css
printf '@import url("gtk.css");\n' > gtk-4.0/gtk-dark.css

echo "built gtk-3.0/gtk.css, gtk-4.0/gtk.css, gtk-4.0/libadwaita.css"
