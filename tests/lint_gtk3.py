import sys
import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk

Gtk.init_check()
errors = []
provider = Gtk.CssProvider()
provider.connect("parsing-error", lambda p, section, err: errors.append((section.get_file().get_path() if section.get_file() else "?", section.get_start_line() + 1, err.message)))
provider.load_from_path(sys.argv[1])
for where, line, msg in errors:
    print("PARSE ERROR", where, line, msg)
print("gtk3 lint:", sys.argv[1], "errors:", len(errors))
sys.exit(1 if errors else 0)
