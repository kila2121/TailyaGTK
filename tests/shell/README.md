# Shell theme test

Starts a headless GNOME Shell with Dash to Dock and your `gnome-shell/gnome-shell.css`,
opens five typical surfaces and audits every visible label and surface.

| Scenario | What is opened |
| --- | --- |
| quick-settings | quick settings menu |
| calendar | date menu with calendar and notification list |
| notification | a critical notification banner with action buttons |
| dock-menu | app menu in the dock with the "All Windows" submenu |
| end-session | the shutdown dialog |

Checks:

- **low contrast**: text against its effective background (all semi-transparent layers composited over a dark backdrop) below 3:1
- **light surface**: a widget with a background that is light (luminance above 0.35)
- **CSS errors**: an `Error parsing stylesheet` line in the shell log (one syntax error disables the whole file)

Scrollbar handles are ignored. Screenshots and per-scenario JSON reports are written to the output directory.

## Run

```
sudo apt install gnome-shell mutter gnome-shell-extensions gnome-calculator python3-pip
pip install --break-system-packages python-dbusmock
./tests/shell/run.sh --variant dark
./tests/shell/run.sh --variant light
```

Options: `--out DIR`, `--variant dark|light` (picks `themes/TailyaGTK` or `themes/TailyaGTK-Light` and the matching color scheme), `--scheme prefer-dark|prefer-light|default`, `--d2d DIR` (Dash to Dock location,
found automatically in `~/.local/share/gnome-shell/extensions`), `--css FILE`.

Run both variants: with `prefer-light` the shell uses its light base stylesheet, which is where unstyled
popups show up as white blocks. A fake systemd-logind is started automatically, no root or display is needed.

Limits: the container image provides GNOME Shell 46, and menus that depend on hardware (Wi-Fi, Bluetooth,
power profiles) are not present, so quick settings contain a single toggle.
