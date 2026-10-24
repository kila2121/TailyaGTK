import os
import sys
import gi
gi.require_version("Gtk", "4.0")
gi.require_version("Adw", "1")
from gi.repository import Gtk, Adw, GLib

OUT = sys.argv[1] if len(sys.argv) > 1 else "/tmp/preview4.png"

class App(Adw.Application):
    def __init__(self):
        super().__init__(application_id="org.TailyaGTK.Preview4")
        self.connect("activate", self.on_activate)

    def on_activate(self, app):
        Adw.StyleManager.get_default().set_color_scheme(Adw.ColorScheme.FORCE_DARK)
        win = Adw.ApplicationWindow(application=app)
        win.set_default_size(980, 640)
        view = Adw.ToolbarView()
        header = Adw.HeaderBar()
        header.pack_start(Gtk.Button(label="Open"))
        header.pack_end(Gtk.Button(icon_name="open-menu-symbolic"))
        self.menu_btn = Gtk.MenuButton(label="Menu")
        pop = Gtk.Popover()
        pbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        for t in ("New window", "Preferences", "About"):
            b = Gtk.Button(label=t)
            b.add_css_class("flat")
            pbox.append(b)
        pop.set_child(pbox)
        self.menu_btn.set_popover(pop)
        header.pack_end(self.menu_btn)
        view.add_top_bar(header)

        root = Gtk.Box()
        side = Gtk.ListBox()
        side.add_css_class("navigation-sidebar")
        side.set_size_request(200, -1)
        for t in ("Overview", "Files", "Network", "Appearance"):
            side.append(Gtk.Label(label=t, xalign=0, margin_top=8, margin_bottom=8, margin_start=8))
        side.select_row(side.get_row_at_index(1))
        root.append(side)

        main = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=14, margin_top=18, margin_bottom=18, margin_start=18, margin_end=18, hexpand=True)

        row1 = Gtk.Box(spacing=10)
        row1.append(Gtk.Button(label="Normal"))
        s = Gtk.Button(label="Suggested"); s.add_css_class("suggested-action"); row1.append(s)
        d = Gtk.Button(label="Destructive"); d.add_css_class("destructive-action"); row1.append(d)
        f = Gtk.Button(label="Flat"); f.add_css_class("flat"); row1.append(f)
        linked = Gtk.Box(); linked.add_css_class("linked")
        for t in ("One", "Two", "Three"):
            linked.append(Gtk.Button(label=t))
        row1.append(linked)
        c = Gtk.Button(icon_name="list-add-symbolic"); c.add_css_class("circular"); row1.append(c)
        main.append(row1)

        row2 = Gtk.Box(spacing=10)
        e = Gtk.Entry(placeholder_text="Entry", hexpand=True); row2.append(e)
        row2.append(Gtk.SearchEntry(placeholder_text="Search"))
        row2.append(Gtk.SpinButton.new_with_range(0, 100, 1))
        row2.append(Gtk.Switch(active=True, valign=Gtk.Align.CENTER))
        row2.append(Gtk.CheckButton(label="Check", active=True))
        row2.append(Gtk.DropDown.new_from_strings(["Alpha", "Beta", "Gamma"]))
        main.append(row2)

        sc = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 1); sc.set_value(40); main.append(sc)
        pb = Gtk.ProgressBar(fraction=0.6); main.append(pb)

        lst = Gtk.ListBox(); lst.add_css_class("boxed-list"); lst.set_selection_mode(Gtk.SelectionMode.NONE)
        for t, sub in (("First row", "Subtitle text"), ("Second row", "Another subtitle")):
            r = Adw.ActionRow(title=t, subtitle=sub)
            r.add_suffix(Gtk.Switch(valign=Gtk.Align.CENTER, active=(t == "First row")))
            lst.append(r)
        main.append(lst)

        card = Gtk.Label(label="A card with some text", margin_top=14, margin_bottom=14); card.add_css_class("card"); main.append(card)
        dim = Gtk.Label(label="Dim label", xalign=0); dim.add_css_class("dim-label"); main.append(dim)
        main.append(Gtk.LinkButton(uri="https://example.org", label="Link button"))

        root.append(main)
        view.set_content(root)
        win.set_content(view)
        win.present()
        if os.environ.get("TailyaGTK_POPOVER"):
            GLib.timeout_add(1200, lambda: (self.menu_btn.popup(), False)[1])
        GLib.timeout_add(3000, self.quit)

App().run()
