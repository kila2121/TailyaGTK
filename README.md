<div align="center">

# TailyaGTK

**A glassmorphism theme for GNOME — Shell, GTK 3, GTK 4 and libadwaita.**

The same translucent, purple-accented look as [Tailya](https://github.com/kila2121/Tailya.git), now extended to every application on your desktop.

**English** · [Русский](README.ru.md)

![GNOME Shell 45+](https://img.shields.io/badge/GNOME%20Shell-45%2B-4a86cf?logo=gnome&logoColor=white)
![GTK 3.24+](https://img.shields.io/badge/GTK-3.24%2B-7554d1)
![GTK 4 + libadwaita](https://img.shields.io/badge/GTK%204%20%2B%20libadwaita-1.5%2B-7554d1)
![License: MIT](https://img.shields.io/badge/license-MIT-7554d1)

</div>

---

Popup menus, Quick Settings and the calendar get a semi-transparent dark surface with a soft drop shadow. Calendar days turn into rounded pills. Notifications have proper 16 px corners. The muted purple accent that marks a checked quick toggle in the Shell is the same purple you see in Firefox, GIMP, GNOME Files and Settings — because TailyaGTK styles all three theming systems from a single palette.

> **TailyaGTK covers three separate systems** — GNOME Shell, GTK 3, and GTK 4 with libadwaita. Each is applied through a different mechanism. `./install.sh --apply` handles all three in one command; if you install manually, read the sections below carefully.

---

## What it changes

**GNOME Shell** — top panel menus, Quick Settings, calendar, notifications, dock:

- **Glass surfaces** — popup menus, Quick Settings and the calendar use a translucent dark background with a soft shadow.
- **Dashboard and overview** — dash buttons and overview tiles lose their boxes; the dash keeps a subtle glass panel.
- **Calendar** — hovered and current days become rounded pills; labels and navigation arrows get a consistent, readable style.
- **Notifications** — 16 px rounded corners, a soft shadow and carefully stepped text opacity.
- **Purple accent** — checked quick toggles, slider levels and switches share one muted purple (`rgb(117, 84, 209)`).
- **Smooth motion** — 150 ms transitions on hover, focus and press states.

**GTK 3 and plain GTK 4 applications** — Firefox, GIMP, older apps, plain GTK 4 apps:

- **Pill-shaped controls** — buttons, entries, spinbuttons and linked button groups get a generous rounded radius.
- **Frosted headerbars** — headerbars lose their gradient and drop to a flat, slightly darker surface.
- **Purple accent everywhere** — suggested-action buttons, focus rings, selections, sliders and progress bars use the same purple as the Shell.
- **Rounded menus and popovers** — 14–16 px corners across menus, tooltips and popovers.

**libadwaita applications** — Files, Settings, Text Editor, Console:

- **Recolored accent** — every `@define-color` that Adwaita exposes (`accent_bg_color`, `accent_color`, `accent_fg_color`, and their hover/active states) is set to the TailyaGTK palette.
- **Recolored sidebars, cards, dialogs and popovers** — background tones matched to the GTK 3 and Shell surfaces, so the whole desktop reads as one theme.

The theme is pure CSS. No extensions beyond User Themes, no scripts at runtime. The installer only copies files and creates one symlink.

## What's in the box

| Folder | What it styles |
| --- | --- |
| `gnome-shell/` | top panel menus, quick settings, calendar, notifications, dialogs, dock |
| `gtk-4.0/libadwaita.css` | libadwaita apps (Files, Settings, Text Editor, …) |
| `gtk-4.0/gtk.css` | plain GTK 4 apps that do not use libadwaita |
| `gtk-3.0/` | GTK 3 apps (Firefox, GIMP, older apps) |
| `src/` | SCSS sources the GTK stylesheets are generated from |
| `tools/recolor.py` | recolors the stock Adwaita CSS to the TailyaGTK palette |
| `build.sh` | generates `gtk-3.0/gtk.css` and `gtk-4.0/gtk.css` |
| `install.sh` / `uninstall.sh` | installs the theme and links `libadwaita.css` |

## Requirements

| Requirement | Details |
| --- | --- |
| GNOME Shell | 45 or newer (tested on 48) |
| GTK | 3.24 or newer, 4.14 or newer |
| User Themes | [extension](https://extensions.gnome.org/extension/19/user-themes/), enabled — needed for the Shell part |
| GNOME Tweaks | optional, but the easiest way to pick a Shell theme |

## Installation

**1. Clone or copy the theme.**

From an archive:

```bash
mkdir -p ~/.themes
tar -xf tailya-gtk.tar.gz -C ~/.themes
```

From the project folder:

```bash
mkdir -p ~/.themes
cp -r /path/to/TailyaGTK ~/.themes/
```

For all users:

```bash
sudo tar -xf tailya-gtk.tar.gz -C /usr/share/themes
```

Replace `tailya-gtk.tar.gz` and `/path/to/TailyaGTK` with the actual names. GNOME also reads themes from `~/.local/share/themes/`, so either home location works.

**2. Run the installer.**

```bash
cd ~/.themes/TailyaGTK
./install.sh --apply
```

That copies the theme into `~/.themes/TailyaGTK`, links `libadwaita.css` to `~/.config/gtk-4.0/gtk.css`, and selects the theme and dark color scheme with `gsettings`. If you prefer to do it by hand, the three steps the script performs are:

```bash
ln -sf ~/.themes/TailyaGTK/gtk-4.0/libadwaita.css ~/.config/gtk-4.0/gtk.css
gsettings set org.gnome.desktop.interface gtk-theme 'TailyaGTK'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
```

If `flatpak` is installed, the installer also grants Flatpak apps read access to `~/.themes` and `~/.config/gtk-4.0`.

**3. Select the Shell theme.**

Install and enable the **User Themes** extension, then open **GNOME Tweaks → Appearance** and choose **TailyaGTK** under **Shell**. If GNOME Tweaks is not installed, install it from your distribution's package manager.

**4. Log out and back in.**

libadwaita reads `~/.config/gtk-4.0/gtk.css` at application start — a full logout/login guarantees every running app picks up the new colors. On X11 you can also press `Alt+F2`, type `r`, press `Enter` to reload the Shell only.

## Why two GTK 4 files

Plain GTK 4 applications read the active GTK theme from `~/.themes/TailyaGTK/gtk-4.0/gtk.css`. libadwaita applications do not: they ignore the selected GTK theme and only read `~/.config/gtk-4.0/gtk.css`. The installer creates a symlink there. So the theme ships two GTK 4 stylesheets: a complete one for plain GTK 4, and a short one that only redefines the color palette for libadwaita.

## Customization

**Shell styles** live in [`gnome-shell/gnome-shell.css`](gnome-shell/gnome-shell.css). The purple accent appears in three shades — replace all three to keep it consistent:

```css
rgb(117, 84, 209)  /* normal  */
rgb(135, 105, 222) /* hover   */
rgb(100, 70, 190)  /* pressed */
```

**Panel transparency.** Glass surfaces use `rgba(30, 30, 30, 0.5)`. Lower the alpha for more transparency, raise it for a more solid panel.

After editing Shell CSS, reload with `Alt+F2` → `r` on X11, or log out and back in on Wayland.

**GTK styles** are generated from a single palette. To recolor the entire theme — Shell excluded — edit one file and rebuild:

```bash
nano src/_palette.scss      # change $accent, $window-bg, $radius-s, etc.
./build.sh
./install.sh --apply
```

> **One gotcha:** the source accent color of Adwaita (`#15539e`) and the destination accent color (`#7554d1`) are also hard-coded in `tools/recolor.py` as `ACCENT_SRC` and `ACCENT_DST`. If you change `$accent` in `_palette.scss`, also update `ACCENT_DST` in `recolor.py` — otherwise the base CSS gets recolored to the old accent and the overrides paint on top with the new one, producing a two-tone result.

## Building from source

The GTK 3 and plain GTK 4 stylesheets are *generated*, not hand-edited. The pipeline takes the stock Adwaita CSS that is already compiled into `libgtk-3.so` and `libgtk-4.so`, recolors it, and appends the overrides from `src/`. The Shell stylesheet is hand-written and is not part of the build.

For each of GTK 3 and GTK 4, `build.sh` does four steps:

**1. Extract the stock Adwaita CSS from the installed GTK library.**

```bash
gresource extract "$GTK3_LIB" /org/gtk/libgtk/theme/Adwaita/gtk-contained-dark.css > build/gtk3-base.css
```

This yields the full Adwaita stylesheet — thousands of lines that style every widget GTK knows about.

**2. Recolor it with the TailyaGTK palette.**

```bash
python3 tools/recolor.py build/gtk3-base.css build/gtk3-base.recolored.css "resource:///org/gtk/libgtk/theme/Adwaita/assets/"
```

`recolor.py` walks the CSS, replaces Adwaita's blue accent (`#15539e`) with the TailyaGTK purple (`#7554d1`), remaps grey tones by a gradient, and rewrites `url("assets/…")` so that image assets load from GTK's resources instead of a folder that does not exist.

**3. Compile the SCSS overrides.**

```bash
sassc -t expanded -I src src/gtk3.scss build/gtk3-overrides.css
```

`src/gtk3.scss` and `src/gtk4.scss` import the palette and shape partials, emit `@define-color` statements, and are compiled into plain CSS.

**4. Concatenate base and overrides.**

```bash
cat build/gtk3-base.recolored.css build/gtk3-overrides.css > gtk-3.0/gtk.css
```

Order matters: base first, overrides second. When two selectors have the same specificity, the later rule wins — which is how the pill-shaped buttons from `src/_gtk3-shape.scss` override the square ones from Adwaita.

GTK 4 runs the same four steps with `src/gtk4.scss`, plus one extra: the compiled overrides are also copied to `gtk-4.0/libadwaita.css`, so the installer can symlink them to `~/.config/gtk-4.0/gtk.css`.

### Dependencies

```bash
sudo apt install sassc libglib2.0-bin libgtk-3-0 libgtk-4-1
```

- `sassc` — SCSS compiler
- `libglib2.0-bin` — provides `gresource`
- `libgtk-3-0`, `libgtk-4-1` — the libraries `build.sh` extracts Adwaita from

For the test suite:

```bash
sudo apt install xvfb imagemagick python3-gi libadwaita-1-0 gir1.2-adw-1
```

### Test

```bash
./tests/run_tests.sh
```

The suite runs three checks:

- **CSS parse check** — `lint_gtk3.py` and `lint_gtk4.py` load the generated stylesheets through the real GTK parsers and report any syntax errors. Fast way to catch a typo in a partial before installing.
- **Screenshots** — `preview_gtk3.py` and `preview_gtk4.py` open windows with typical widgets (buttons, entries, switches, menus, lists), render them under `xvfb`, and save PNGs to `/tmp/tailya-test/` for visual diffing.
- **libadwaita coverage** — `preview_gtk4.py` exercises `Adw.ApplicationWindow`, `Adw.HeaderBar`, `Adw.ToolbarView` and `Adw.ActionRow`, which are the widgets whose colors come from the `@define-color` blocks in `src/gtk4.scss`.

### Files you should not edit

These are generated. Any change will be overwritten the next time you run `./build.sh`:

- `gtk-3.0/gtk.css`, `gtk-3.0/gtk-dark.css`
- `gtk-4.0/gtk.css`, `gtk-4.0/gtk-dark.css`, `gtk-4.0/libadwaita.css`
- everything under `build/`

To change how a widget looks, edit `src/_gtk3-shape.scss` or `src/_gtk4-shape.scss`. To change the Shell, edit `gnome-shell/gnome-shell.css` — it is hand-written and not part of the build.

## Compatibility

| Stack | Status |
| --- | --- |
| GTK 3.24.41 | ✅ Tested (screenshots) |
| GTK 4.14 + libadwaita 1.5 | ✅ Tested (screenshots) |
| libadwaita 1.6 / 1.7 (GNOME 47 / 48) | ⚠️ Selectors and color mechanism checked against the libadwaita 1.7 source |
| GNOME Shell 48 | ✅ Daily setup (Debian 13) |
| GNOME Shell 43–47 | ⚠️ Expected to work, not tested |
| GNOME Shell 49+ | ❌ Not tested |

Dark only — there is no light variant. Unknown selectors are ignored by GTK and Shell, so a different version at worst shows stock styling.

## Troubleshooting

**The Shell theme doesn't appear in the list.**
Make sure the path is exactly `~/.themes/TailyaGTK/gnome-shell/gnome-shell.css`, restart GNOME Tweaks, and check that User Themes is enabled.

**The Shell theme is selected but nothing changes.**
On Wayland, Shell themes are applied at login — log out and back in. On X11, reload with `Alt+F2` → `r`.

**GTK applications still look default.**
Check that `gsettings get org.gnome.desktop.interface gtk-theme` returns `'TailyaGTK'`. Then fully quit and reopen the app — GTK themes are read at application start.

**libadwaita apps (Files, Settings, Text Editor) look default.**
Check that `~/.config/gtk-4.0/gtk.css` is a symlink to `~/.themes/TailyaGTK/gtk-4.0/libadwaita.css`. Then fully quit and reopen the app.

**Some elements look unstyled.**
GNOME 47+ may have renamed or added selectors. Include your GNOME version and a screenshot — or tweak the CSS yourself.

**The login screen still looks default.**
That's expected: GDM uses its own theme and does not load themes from `~/.themes`.

## Uninstall

```bash
./uninstall.sh
```

This removes `~/.themes/TailyaGTK`, restores any previous `~/.config/gtk-4.0/gtk.css` from `gtk.css.glassy-backup`, and revokes the Flatpak overrides. Then switch the theme back in GNOME Tweaks.

## Credits

- GNOME Shell stylesheet started as a modification of [kila2121/Tailya](https://github.com/kila2121/Tailya.git) (MIT).

## License

[MIT](LICENSE) © 2026 kila2121. GTK stylesheets derived from Adwaita: LGPL-2.1-or-later.

---

<div align="center">

Made for people who like their desktop a little more translucent.

[Русская версия](README.ru.md)

</div>