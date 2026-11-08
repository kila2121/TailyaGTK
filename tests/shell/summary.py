import glob
import json
import os
import re
import sys

out = sys.argv[1]
fail = 0
print("scenario            labels surfaces issues")
for path in sorted(glob.glob(os.path.join(out, "audit-*.json"))):
    r = json.load(open(path))
    n = len(r["issues"])
    fail += n
    print("%-19s %6d %8d %6d" % (r["name"], r["labels"], r["surfaces"], n))
    for i in r["issues"][:8]:
        if i["kind"] == "low-contrast":
            print("    low contrast %.2f  %-12r %s fg=%s bg=%s" % (i["ratio"], i["text"], i["actor"], i["fg"], i["bg"]))
        else:
            print("    %s (lum %.2f)  %s bg=%s" % (i["kind"].replace("-", " "), i["lum"], i["actor"], i["bg"]))

expected = {"quick-settings", "calendar", "notification", "dock-menu", "end-session"}
got = {os.path.basename(p)[6:-5] for p in glob.glob(os.path.join(out, "audit-*.json"))}
missing = sorted(expected - got)
if missing:
    print("MISSING scenarios (could not be audited): " + ", ".join(missing))
    fail += len(missing)

log = open(os.path.join(out, "shell.log"), errors="replace").read()
css_errors = [l for l in log.splitlines() if re.search(r"stylesheet|css", l, re.I) and re.search(r"fail|error|warn", l, re.I)]
if css_errors:
    print("CSS problems in shell log:")
    for l in css_errors[:10]:
        print("   " + l.strip()[:200])
    fail += len(css_errors)

print("screenshots: " + ", ".join(sorted(os.path.basename(p) for p in glob.glob(os.path.join(out, "*.png")))))
print("RESULT: " + ("FAIL" if fail else "PASS"))
sys.exit(1 if fail else 0)
