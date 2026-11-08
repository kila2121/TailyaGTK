#!/usr/bin/env bash
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
CFG="$HOME/.config/gtk-4.0"

usage() { echo "usage: $0 [dark|light|both] [--apply]"; exit 2; }

find_theme() {
  for base in "$SRC/themes" "$SRC"; do
    if [ -f "$base/$1/index.theme" ]; then echo "$base/$1"; return 0; fi
  done
  return 1
}

choice=""
apply=0
for arg in "$@"; do
  case "$arg" in
    dark|light|both) choice="$arg" ;;
    --apply) apply=1 ;;
    *) usage ;;
  esac
done

has_dark=0; has_light=0
find_theme TailyaGTK >/dev/null && has_dark=1
find_theme TailyaGTK-Light >/dev/null && has_light=1
if [ -z "$choice" ]; then
  if [ "$has_dark" -eq 1 ]; then choice=dark; elif [ "$has_light" -eq 1 ]; then choice=light; else echo "no theme found next to install.sh"; exit 1; fi
fi

install_theme() {
  local name="$1" dir
  dir="$(find_theme "$name")" || { echo "$name is not included in this package"; exit 1; }
  mkdir -p "$HOME/.themes"
  rm -rf "$HOME/.themes/$name"
  cp -r "$dir" "$HOME/.themes/$name"
  echo "installed $name to $HOME/.themes/$name"
}

case "$choice" in
  dark) names=(TailyaGTK); primary=TailyaGTK; scheme=prefer-dark ;;
  light) names=(TailyaGTK-Light); primary=TailyaGTK-Light; scheme=prefer-light ;;
  both) names=(TailyaGTK TailyaGTK-Light); primary=TailyaGTK; scheme=prefer-dark ;;
esac

for n in "${names[@]}"; do install_theme "$n"; done

mkdir -p "$CFG"
if [ -e "$CFG/gtk.css" ] && [ ! -L "$CFG/gtk.css" ]; then
  mv "$CFG/gtk.css" "$CFG/gtk.css.TailyaGTK-backup"
  echo "existing gtk-4.0/gtk.css saved as gtk.css.TailyaGTK-backup"
fi
ln -sf "$HOME/.themes/$primary/gtk-4.0/libadwaita.css" "$CFG/gtk.css"

if command -v flatpak >/dev/null 2>&1; then
  flatpak override --user --filesystem=xdg-config/gtk-4.0:ro --filesystem="$HOME/.themes:ro"
fi

if [ "$apply" -eq 1 ]; then
  gsettings set org.gnome.desktop.interface gtk-theme "$primary"
  gsettings set org.gnome.desktop.interface color-scheme "$scheme"
  gsettings set org.gnome.shell.extensions.user-theme name "$primary" 2>/dev/null || echo "User Themes extension not found: pick the shell theme in GNOME Tweaks"
fi

echo "active variant for libadwaita apps: $primary"
echo "Select it in GNOME Tweaks (Appearance), or run: $0 $choice --apply"
echo "Log out and back in so that libadwaita apps pick up the colors."
