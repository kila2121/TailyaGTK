#!/usr/bin/env bash
set -euo pipefail
DEST="$HOME/.themes/TailyaGTK"
CFG="$HOME/.config/gtk-4.0"

if [ -L "$CFG/gtk.css" ] && [ "$(readlink "$CFG/gtk.css")" = "$DEST/gtk-4.0/libadwaita.css" ]; then
  rm "$CFG/gtk.css"
  if [ -e "$CFG/gtk.css.TailyaGTK-backup" ]; then
    mv "$CFG/gtk.css.TailyaGTK-backup" "$CFG/gtk.css"
  fi
fi

rm -rf "$DEST"

if command -v flatpak >/dev/null 2>&1; then
  flatpak override --user --nofilesystem=xdg-config/gtk-4.0 --nofilesystem="$HOME/.themes" || true
fi

echo "TailyaGTK removed. Switch the theme back in GNOME Tweaks."
