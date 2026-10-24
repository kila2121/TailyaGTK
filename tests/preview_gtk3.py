import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, GLib

win = Gtk.Window(title="TailyaGTK GTK3")
win.set_default_size(900, 560)
hb = Gtk.HeaderBar(title="TailyaGTK GTK3", show_close_button=True)
hb.pack_start(Gtk.Button(label="Open"))
win.set_titlebar(hb)

box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=14, margin=18)
row1 = Gtk.Box(spacing=10)
row1.pack_start(Gtk.Button(label="Normal"), False, False, 0)
s = Gtk.Button(label="Suggested"); s.get_style_context().add_class("suggested-action"); row1.pack_start(s, False, False, 0)
d = Gtk.Button(label="Destructive"); d.get_style_context().add_class("destructive-action"); row1.pack_start(d, False, False, 0)
f = Gtk.Button(label="Flat"); f.get_style_context().add_class("flat"); row1.pack_start(f, False, False, 0)
linked = Gtk.Box(); linked.get_style_context().add_class("linked")
for t in ("One", "Two", "Three"):
    linked.pack_start(Gtk.Button(label=t), False, False, 0)
row1.pack_start(linked, False, False, 0)
row1.pack_start(Gtk.Button(label="Disabled", sensitive=False), False, False, 0)
box.pack_start(row1, False, False, 0)

row2 = Gtk.Box(spacing=10)
row2.pack_start(Gtk.Entry(placeholder_text="Entry"), True, True, 0)
row2.pack_start(Gtk.SearchEntry(), False, False, 0)
row2.pack_start(Gtk.SpinButton.new_with_range(0, 100, 1), False, False, 0)
row2.pack_start(Gtk.Switch(active=True), False, False, 0)
row2.pack_start(Gtk.CheckButton(label="Check", active=True), False, False, 0)
combo = Gtk.ComboBoxText(); [combo.append_text(t) for t in ("Alpha", "Beta")]; combo.set_active(0)
row2.pack_start(combo, False, False, 0)
box.pack_start(row2, False, False, 0)

box.pack_start(Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 1), False, False, 0)
box.pack_start(Gtk.ProgressBar(fraction=0.6), False, False, 0)

lst = Gtk.ListBox()
for t in ("First row", "Second row", "Third row"):
    lst.add(Gtk.Label(label=t, xalign=0, margin=10))
lst.select_row(lst.get_row_at_index(1))
sc_ = None
box.pack_start(lst, False, False, 0)

tv = Gtk.TextView(); tv.get_buffer().set_text("Text view\nsecond line")
tv.set_size_request(-1, 70)
box.pack_start(tv, False, False, 0)

nb = Gtk.Notebook(); nb.append_page(Gtk.Label(label="Page one"), Gtk.Label(label="Tab one")); nb.append_page(Gtk.Label(label="Page two"), Gtk.Label(label="Tab two"))
box.pack_start(nb, True, True, 0)

win.add(box)
win.connect("destroy", Gtk.main_quit)
win.show_all()
GLib.timeout_add(3000, Gtk.main_quit)
Gtk.main()
