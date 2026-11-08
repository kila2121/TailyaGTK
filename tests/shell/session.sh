#!/usr/bin/env bash
SYSADDR=$(dbus-daemon --session --fork --print-address --nopidfile)
export DBUS_SYSTEM_BUS_ADDRESS="$SYSADDR"
python3 -m dbusmock --system -t logind > "$OUT/mock.log" 2>&1 &
sleep 2
gdbus call --address "$SYSADDR" --dest org.freedesktop.login1 --object-path /org/freedesktop/login1 \
  --method org.freedesktop.DBus.Mock.AddSession "c1" "seat0" "$(id -u)" "$(id -un)" true > /dev/null 2>&1
export XDG_SESSION_ID=c1

gsettings set org.gnome.desktop.interface color-scheme "$SCHEME"
gsettings set org.gnome.shell disable-user-extensions false
gsettings set org.gnome.shell enabled-extensions "['user-theme@gnome-shell-extensions.gcampax.github.com', 'dash-to-dock@micxgx.gmail.com']"
gsettings set org.gnome.shell.extensions.user-theme name "$THEME_NAME"

ev() {
  local f="$HERE/js/$1.js"
  sed -e "s#@@OUT@@#$OUT#g" -e "s#@@NAME@@#${2:-x}#g" -e "s#@@VARIANT@@#$VARIANT#g" "$f" > "$OUT/cur.js"
  gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell \
    --method org.gnome.Shell.Eval "$(cat "$OUT/cur.js")" 2>&1 | tee -a "$OUT/steps.log" | head -c 300
  echo
}
shot() {
  gdbus call --session --dest org.gnome.Shell.Screenshot --object-path /org/gnome/Shell/Screenshot \
    --method org.gnome.Shell.Screenshot.Screenshot false false "$OUT/$1.png" > /dev/null 2>&1
}
step() { echo "== $1" | tee -a "$OUT/steps.log"; }

driver() {
  for i in $(seq 1 40); do
    r=$(gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell --method org.gnome.Shell.Eval "$(cat "$HERE/js/ready.js")" 2>/dev/null)
    case "$r" in *ready*) break ;; esac
    sleep 1
  done
  sleep 4

  W=$(ls "$XDG_RUNTIME_DIR" | grep -m1 '^wayland-[0-9]*$')
  if command -v gnome-calculator >/dev/null; then
    WAYLAND_DISPLAY=$W GDK_BACKEND=wayland gnome-calculator > "$OUT/app.log" 2>&1 &
    for i in $(seq 1 20); do
      r=$(gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell --method org.gnome.Shell.Eval "$(cat "$HERE/js/count-windows.js")" 2>/dev/null)
      case "$r" in *'"0"'*) sleep 1 ;; *) break ;; esac
    done
    sleep 2
  fi

  step quick-settings; ev qs-open; sleep 1; shot quick-settings; ev audit quick-settings; ev qs-close; sleep 1
  step calendar; ev date-open; sleep 1; shot calendar; ev audit calendar; ev date-close; sleep 1

  step notification
  gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications \
    --method org.freedesktop.Notifications.Notify "Test" 0 "" "Notification title" "Notification body text that is long enough to wrap onto a second line" \
    "['default', 'Open', 'reply', 'Reply']" "{'urgency': <byte 2>}" 0 > /dev/null 2>&1
  sleep 2; ev banner; ev audit notification; shot notification

  step dock-menu
  ev dock-menu-open; sleep 1; ev dock-submenu-open; sleep 2; shot dock-menu; ev audit dock-menu; ev dock-menu-close; sleep 1

  step end-session
  gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/SessionManager/EndSessionDialog \
    --method org.gnome.SessionManager.EndSessionDialog.Open 1 0 60 "[]" > /dev/null 2>&1
  sleep 2; ev modal-root; shot end-session; ev audit end-session

  sleep 1
  pkill -TERM gnome-shell
}

driver > "$OUT/driver.log" 2>&1 &
timeout 120 gnome-shell --headless --wayland --virtual-monitor 1280x800 --unsafe-mode 2>&1
