import sys
import gi
gi.require_version("Gtk", "4.0")
from gi.repository import Gtk

Gtk.init_check()
errors = []
provider = Gtk.CssProvider()
provider.connect("parsing-error", lambda p, section, err: errors.append((section.to_string(), err.message)))
provider.load_from_path(sys.argv[1])
for where, msg in errors:
    print("PARSE ERROR", where, msg)
print("gtk4 lint:", sys.argv[1], "errors:", len(errors))
sys.exit(1 if errors else 0)
