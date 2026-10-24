#!/usr/bin/env bash
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.themes/TailyaGTK"
CFG="$HOME/.config/gtk-4.0"

mkdir -p "$DEST" "$CFG"
for item in gnome-shell gtk-3.0 gtk-4.0 index.theme; do
  rm -rf "$DEST/$item"
  cp -r "$SRC/$item" "$DEST/$item"
done

if [ -e "$CFG/gtk.css" ] && [ ! -L "$CFG/gtk.css" ]; then
  mv "$CFG/gtk.css" "$CFG/gtk.css.TailyaGTK-backup"
  echo "existing gtk-4.0/gtk.css saved as gtk.css.TailyaGTK-backup"
fi
ln -sf "$DEST/gtk-4.0/libadwaita.css" "$CFG/gtk.css"

if command -v flatpak >/dev/null 2>&1; then
  flatpak override --user --filesystem=xdg-config/gtk-4.0:ro --filesystem="$HOME/.themes:ro"
fi

if [ "${1:-}" = "--apply" ]; then
  gsettings set org.gnome.desktop.interface gtk-theme 'TailyaGTK'
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  gsettings set org.gnome.shell.extensions.user-theme name 'TailyaGTK' 2>/dev/null || echo "User Themes extension not found: pick the shell theme in GNOME Tweaks"
fi

echo "TailyaGTK installed to $DEST"
echo "Select it in GNOME Tweaks (Appearance), or run: ./install.sh --apply"
echo "Log out and back in so that libadwaita apps pick up the colors."
