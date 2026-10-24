import gi
gi.require_version("Gtk", "4.0")
from gi.repository import Gtk, GLib

app = Gtk.Application(application_id="org.TailyaGTK.Plain4")

def activate(a):
    win = Gtk.ApplicationWindow(application=a, title="Plain GTK4")
    win.set_default_size(640, 300)
    box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12, margin_top=16, margin_bottom=16, margin_start=16, margin_end=16)
    row = Gtk.Box(spacing=8)
    row.append(Gtk.Button(label="Normal"))
    s = Gtk.Button(label="Suggested"); s.add_css_class("suggested-action"); row.append(s)
    row.append(Gtk.Entry(placeholder_text="Entry", hexpand=True))
    row.append(Gtk.Switch(active=True))
    box.append(row)
    box.append(Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 1))
    box.append(Gtk.Label(label="Plain GTK4 label"))
    win.set_child(box)
    win.present()
    GLib.timeout_add(3000, a.quit)

app.connect("activate", activate)
app.run()
