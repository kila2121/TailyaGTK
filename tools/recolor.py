import colorsys
import re
import sys

ACCENT_SRC = (0x15, 0x53, 0x9E)
ACCENT_DST = (0x75, 0x54, 0xD1)
VIOLET_HUE = 258.0 / 360.0
GREY_POINTS = [(0, 0), (27, 18), (45, 24), (53, 30), (73, 42), (145, 138), (238, 255), (255, 255)]


def grey_map(g):
    for (x0, y0), (x1, y1) in zip(GREY_POINTS, GREY_POINTS[1:]):
        if x0 <= g <= x1:
            return round(y0 + (y1 - y0) * (g - x0) / (x1 - x0))
    return g


def to_rgb(h):
    h = h.lstrip("#")
    if len(h) == 3:
        h = "".join(c * 2 for c in h)
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))

def _rgba_repl(m):
    head = m.group(1)
    r, g, b = (int(m.group(i)) for i in (2, 3, 4))
    nr, ng, nb = recolor((r, g, b))
    tail = m.group(5) or ""
    return f"{head}({nr}, {ng}, {nb}{tail})"

def recolor(rgb):
    r, g, b = rgb
    if max(rgb) - min(rgb) <= 6:
        v = grey_map(round(sum(rgb) / 3))
        return (v, v, v)
    if rgb == ACCENT_SRC:
        return ACCENT_DST
    h, l, s = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
    if 0.52 <= h <= 0.72 and s > 0.25:
        src_l = colorsys.rgb_to_hls(*(c / 255 for c in ACCENT_SRC))[1]
        dst_l = colorsys.rgb_to_hls(*(c / 255 for c in ACCENT_DST))[1]
        l = min(max(l + (dst_l - src_l), 0.05), 0.95)
        s = min(s, 0.6)
        nr, ng, nb = colorsys.hls_to_rgb(VIOLET_HUE, l, s)
        return (round(nr * 255), round(ng * 255), round(nb * 255))
    return rgb


def main(src, dst, asset_base):
    text = open(src, encoding="utf-8").read()
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    text = re.sub(
        r"#([0-9a-fA-F]{6}|[0-9a-fA-F]{3})\b",
        lambda m: "#%02x%02x%02x" % recolor(to_rgb(m.group(1))),
        text,
    )
    text = re.sub(
        r"(rgba?)\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)([^)]*)\)",
        _rgba_repl,
        text,
    )   
    text = text.replace('url("assets/', 'url("' + asset_base)
    text = text.replace("url('assets/", "url('" + asset_base)
    text = re.sub(r"\n\s*\n+", "\n", text)
    open(dst, "w", encoding="utf-8").write(text)


main(sys.argv[1], sys.argv[2], sys.argv[3])
