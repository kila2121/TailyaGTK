#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cp -r "$ROOT/." "$TMP/"
(cd "$TMP" && ./build.sh >/dev/null)

fail=0
stale() { echo "STALE: $1"; fail=1; }

for pair in "dark:TailyaGTK" "light:TailyaGTK-Light"; do
  variant="${pair%%:*}"
  name="${pair##*:}"
  for f in gnome-shell/gnome-shell.css gtk-4.0/libadwaita.css index.theme; do
    cmp -s "$TMP/themes/$name/$f" "$ROOT/themes/$name/$f" || stale "themes/$name/$f"
  done
  for entry in "gtk3-overrides.css:gtk-3.0/gtk.css" "gtk4-overrides.css:gtk-4.0/gtk.css"; do
    built="$TMP/build/$variant/${entry%%:*}"
    committed="$ROOT/themes/$name/${entry##*:}"
    lines="$(wc -l < "$built")"
    tail -n "$lines" "$committed" | cmp -s - "$built" || stale "themes/$name/${entry##*:}"
  done
done

if [ "$fail" -eq 0 ]; then
  echo "generated CSS is up to date"
else
  echo "run ./build.sh and commit the result"
fi
exit "$fail"
