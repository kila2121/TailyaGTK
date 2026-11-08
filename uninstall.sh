#!/usr/bin/env bash
set -euo pipefail
CFG="$HOME/.config/gtk-4.0"

if [ -L "$CFG/gtk.css" ]; then
  case "$(readlink "$CFG/gtk.css")" in
    "$HOME"/.themes/TailyaGTK*/gtk-4.0/libadwaita.css)
      rm "$CFG/gtk.css"
      if [ -e "$CFG/gtk.css.TailyaGTK-backup" ]; then
        mv "$CFG/gtk.css.TailyaGTK-backup" "$CFG/gtk.css"
      fi
      ;;
  esac
fi

rm -rf "$HOME/.themes/TailyaGTK" "$HOME/.themes/TailyaGTK-Light"

if command -v flatpak >/dev/null 2>&1; then
  flatpak override --user --nofilesystem=xdg-config/gtk-4.0 --nofilesystem="$HOME/.themes" || true
fi

echo "TailyaGTK removed. Switch the theme back in GNOME Tweaks."
