"""Icon set v2: bold saturated tiles (no pale white), thick dark outline, bright symbol.
Each icon = coloured square tile with a vertical gradient + a chunky symbol on top.
Run: python tools/art/make_icons2.py  -> src/_assets/ic2_<name>.png (256x256)
"""
import os, subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
SVG_DIR = os.path.join(ROOT, "art", "svg2")
PNG_DIR = os.path.join(ROOT, "src", "_assets")
CLI = os.path.join(os.environ["LOCALAPPDATA"], "Programs", "ArtCraft", "VectorCraft", "vectorcraft-cli.exe")
os.makedirs(SVG_DIR, exist_ok=True)

OL = "#121530"
SW = 9

def shade(hexc, f):
    h = hexc.lstrip("#")
    r, g, b = int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)
    if f >= 0:
        r, g, b = r + (255 - r) * f, g + (255 - g) * f, b + (255 - b) * f
    else:
        r, g, b = r * (1 + f), g * (1 + f), b * (1 + f)
    return "#%02X%02X%02X" % (int(r), int(g), int(b))

def tile(color):
    top, mid, bot = shade(color, 0.35), color, shade(color, -0.4)
    d = (f'<defs><radialGradient id="g" cx="0.35" cy="0.25" r="0.95"><stop offset="0" stop-color="{top}"/>'
         f'<stop offset="0.55" stop-color="{mid}"/><stop offset="1" stop-color="{bot}"/></radialGradient>'
         f'<linearGradient id="gl" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#FFFFFF" stop-opacity="0.55"/>'
         f'<stop offset="1" stop-color="#FFFFFF" stop-opacity="0"/></linearGradient></defs>')
    d += f'<rect x="8" y="8" width="240" height="240" rx="30" fill="url(#g)" stroke="{OL}" stroke-width="10"/>'
    d += f'<rect x="17" y="17" width="222" height="222" rx="24" fill="none" stroke="{shade(color, 0.45)}" stroke-width="5" stroke-opacity="0.8"/>'
    # rays behind the symbol (clipped to the tile)
    d += '<defs><clipPath id="rc"><rect x="13" y="13" width="230" height="230" rx="26"/></clipPath></defs><g clip-path="url(#rc)">'
    for i in range(8):
        d += f'<path d="M128 128 L{128 + 200 * __import__("math").cos(i * 0.785):.0f} {128 + 200 * __import__("math").sin(i * 0.785):.0f} L{128 + 200 * __import__("math").cos(i * 0.785 + 0.2):.0f} {128 + 200 * __import__("math").sin(i * 0.785 + 0.2):.0f} Z" fill="#FFFFFF" fill-opacity="0.08"/>'
    d += '</g>'
    d += f'<rect x="22" y="22" width="212" height="96" rx="22" fill="url(#gl)"/>'
    return d

def R(x, y, w, h, rx, fill, sw=SW):
    s = f' stroke="{OL}" stroke-width="{sw}" stroke-linejoin="round"' if sw else ""
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" fill="{fill}"{s}/>'

def C(cx, cy, r, fill, sw=SW):
    s = f' stroke="{OL}" stroke-width="{sw}"' if sw else ""
    return f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{fill}"{s}/>'

def P(d, fill, sw=SW):
    s = f' stroke="{OL}" stroke-width="{sw}" stroke-linejoin="round" stroke-linecap="round"' if sw else ""
    return f'<path d="{d}" fill="{fill}"{s}/>'

def T(x, y, text, size, fill="#FFFFFF"):
    return (f'<text x="{x}" y="{y}" font-family="Arial Black, Arial" font-weight="900" font-size="{size}" '
            f'text-anchor="middle" fill="{fill}" stroke="{OL}" stroke-width="8" paint-order="stroke">{text}</text>')

def HL(x, y, w, h):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{min(w, h) // 2}" fill="#FFFFFF" fill-opacity="0.8"/>'

Y, G, B, PU, RD, OR, PK, CY, LIME = "#FFD21F", "#22E07A", "#2FA8FF", "#A35BFF", "#FF3B4E", "#FF8A1F", "#FF4FA8", "#18D6D0", "#B6FF3B"

def svg(body):
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">{body}</svg>'

ICONS = {}
import re as _re
def _shadow(body):
    # same shapes, solid dark, nudged down-right: a soft drop shadow
    sh = _re.sub(r'fill="(?!none)[^"]*"', 'fill="#0A0C20"', body)
    sh = _re.sub(r'stroke="[^"]*"', 'stroke="#0A0C20"', sh)
    return f'<g transform="translate(6,9)" opacity="0.35">{sh}</g>'

def icon(name, color):
    def deco(fn):
        def build():
            body = fn()
            # clip the shadow to the tile
            clip = '<clipPath id="c"><rect x="13" y="13" width="230" height="230" rx="26"/></clipPath>'
            return svg(tile(color) + f'<defs>{clip}</defs><g clip-path="url(#c)">{_shadow(body)}</g>' + body)
        ICONS[name] = build
        return fn
    return deco

# ---------- apps ----------
@icon("lab", PU)
def _():
    b = P("M106 40 h44 v52 l52 92 a18 18 0 0 1 -16 26 h-116 a18 18 0 0 1 -16 -26 l52 -92 z", "#7E3BE0")
    b += P("M80 148 h96 l24 42 a10 10 0 0 1 -9 14 h-126 a10 10 0 0 1 -9 -14 z", LIME, 0)
    b += P("M106 40 h44 v52 l52 92 a18 18 0 0 1 -16 26 h-116 a18 18 0 0 1 -16 -26 l52 -92 z", "none")
    b += R(94, 30, 68, 20, 6, Y)
    b += C(110, 178, 9, "#FFFFFF", 0) + C(140, 162, 6, "#FFFFFF", 0) + C(150, 186, 5, "#FFFFFF", 0)
    return b

@icon("parts", OR)
def _():
    b = R(58, 58, 140, 140, 12, "#2B2F55")
    b += R(86, 86, 84, 84, 8, Y)
    b += T(128, 145, "AI", 42, OL).replace(f'stroke="{OL}"', 'stroke="none"')
    for i in range(4):
        x = 76 + i * 32
        b += R(x - 6, 32, 12, 24, 3, "#C7CCE6", 6) + R(x - 6, 200, 12, 24, 3, "#C7CCE6", 6)
        y = 76 + i * 32
        b += R(32, y - 6, 24, 12, 3, "#C7CCE6", 6) + R(200, y - 6, 24, 12, 3, "#C7CCE6", 6)
    return b

@icon("team", B)
def _():
    b = C(92, 100, 34, "#FFC98A") + R(46, 140, 92, 74, 26, Y)
    b += C(166, 92, 38, "#E8A066") + R(116, 136, 102, 78, 28, PK)
    b += HL(78, 76, 18, 9) + HL(150, 66, 20, 9)
    return b

@icon("bank", G)
def _():
    b = P("M40 96 L128 40 L216 96 Z", Y)
    for x in (64, 112, 160):
        b += R(x, 104, 32, 82, 4, "#FFF3B0")
    b += R(40, 186, 176, 26, 4, Y) + R(52, 92, 152, 16, 3, "#E5A800", 0)
    b += C(128, 76, 12, G, 6)
    return b

@icon("social", PK)
def _():
    b = P("M44 54 h168 a18 18 0 0 1 18 18 v86 a18 18 0 0 1 -18 18 h-88 l-46 38 v-38 h-34 a18 18 0 0 1 -18 -18 v-86 a18 18 0 0 1 18 -18 z", "#FFFFFF")
    b += P("M128 150 l-34 -32 a20 20 0 0 1 34 -22 a20 20 0 0 1 34 22 z", RD, 7)
    return b

@icon("mail", RD)
def _():
    b = R(34, 66, 188, 130, 12, Y)
    b += P("M38 72 l90 70 l90 -70", "none", 10)
    b += P("M38 192 l64 -56 M218 192 l-64 -56", "none", 8)
    b += C(206, 64, 26, B, 8) + T(206, 75, "!", 34)
    return b

@icon("goals", Y)
def _():
    b = C(124, 136, 88, RD) + C(124, 136, 60, "#FFFFFF") + C(124, 136, 32, RD) + C(124, 136, 9, OL, 0)
    b += P("M128 132 l76 -76", "none", 11) + P("M196 40 l30 -6 l-6 30 l-22 4 z", G, 8)
    return b

@icon("company", CY)
def _():
    b = R(52, 38, 104, 184, 6, B) + R(152, 98, 60, 124, 6, PU)
    for row in range(5):
        for col in range(2):
            b += R(70 + col * 40, 56 + row * 30, 26, 18, 3, Y, 5)
    for row in range(3):
        b += R(168, 116 + row * 30, 28, 18, 3, Y, 5)
    b += R(36, 214, 184, 14, 3, "#2B2F55", 6)
    return b

@icon("shop", Y)
def _():
    b = P("M50 96 h156 l-14 112 h-128 z", OR)
    b += P("M92 96 v-22 a36 36 0 0 1 72 0 v22", "none", 12)
    b += T(128, 182, "R$", 62)
    b += HL(66, 108, 40, 10)
    return b

@icon("linkedin", "#1E7BFF")
def _():
    return T(128, 176, "in", 130)

@icon("cameras", "#4C5577")
def _():
    b = P("M40 80 l120 -26 l18 52 l-120 26 z", "#E7EBFF")
    b += C(70, 100, 14, RD, 6)
    b += R(150, 120, 22, 70, 4, "#C7CCE6") + R(116, 186, 90, 24, 4, "#C7CCE6")
    return b

@icon("web", "#1E7BFF")
def _():
    b = C(128, 128, 84, "#7FD3FF")
    b += P("M128 44 c-40 30 -40 138 0 168 M128 44 c40 30 40 138 0 168 M48 104 h160 M48 152 h160 M128 44 v168", "none", 8)
    b += C(128, 128, 84, "none")
    b += R(150, 150, 78, 56, 8, "#FFD21F") + T(189, 190, "www", 22, "#121530").replace('stroke="#121530"', 'stroke="none"')
    return b

@icon("gift", "#FF3B4E")
def _():
    b = R(46, 110, 164, 104, 8, "#FFD21F")
    b += R(36, 84, 184, 40, 8, "#FFE680")
    b += R(114, 84, 28, 130, 0, "#FF3B4E", 8)
    b += P("M128 84 c-20 -40 -64 -40 -60 -12 c4 20 40 14 60 12 z", "#FF3B4E", 8)
    b += P("M128 84 c20 -40 64 -40 60 -12 c-4 20 -40 14 -60 12 z", "#FF3B4E", 8)
    return b

@icon("gear", "#4C5577")
def _():
    import math
    b = ""
    for i in range(8):
        a = i * math.pi / 4
        x, y = 128 + 74 * math.cos(a), 128 + 74 * math.sin(a)
        b += f'<rect x="{x-17:.0f}" y="{y-17:.0f}" width="34" height="34" rx="6" fill="#C7CCE6" stroke="{OL}" stroke-width="8" transform="rotate({i*45} {x:.0f} {y:.0f})"/>'
    b += C(128, 128, 66, "#C7CCE6") + C(128, 128, 26, "#4C5577")
    return b

@icon("trophy", "#A35BFF")
def _():
    b = P("M84 50 h88 v50 a44 44 0 0 1 -88 0 z", "#FFD21F")
    b += P("M84 66 h-26 a26 26 0 0 0 30 40 M172 66 h26 a26 26 0 0 1 -30 40", "none", 10)
    b += R(116, 140, 24, 34, 0, "#E5A800") + R(84, 172, 88, 26, 6, "#FFD21F")
    b += T(128, 106, "1", 48, "#FFFFFF")
    return b

# ---------- shop items ----------
@icon("cash", G)
def _():
    b = ""
    for i, y in enumerate((150, 120, 90)):
        b += R(46, y, 164, 64, 10, "#8DF5A8")
        b += C(128, y + 32, 18, G, 6)
    b += T(128, 135, "$", 44)
    return b

@icon("vault", "#3A7D5A")
def _():
    b = R(42, 42, 172, 172, 14, "#C7CCE6") + C(128, 128, 54, "#8C93B8") + C(128, 128, 22, Y)
    for a in range(0, 360, 60):
        import math
        x, y = 128 + 54 * math.cos(math.radians(a)), 128 + 54 * math.sin(math.radians(a))
        b += P(f"M128 128 L{x:.0f} {y:.0f}", "none", 8)
    b += C(128, 128, 22, Y)
    return b

@icon("crown", PU)
def _():
    b = P("M40 186 l-6 -104 l52 44 l42 -72 l42 72 l52 -44 l-6 104 z", Y)
    b += R(40, 182, 176, 30, 6, "#E5A800")
    b += C(128, 150, 14, RD, 6) + C(80, 156, 10, CY, 6) + C(176, 156, 10, G, 6)
    return b

@icon("brain", PK)
def _():
    b = P("M128 52 c-40 -20 -86 6 -80 50 c-24 18 -18 62 14 70 c4 36 52 44 66 18 c14 26 62 18 66 -18 c32 -8 38 -52 14 -70 c6 -44 -40 -70 -80 -50 z", "#FFB3D6")
    b += P("M128 52 v136 M88 96 q20 10 40 0 M168 96 q-20 10 -40 0 M80 146 q24 -12 48 4 M176 146 q-24 -12 -48 4", "none", 8)
    return b

@icon("shield", B)
def _():
    b = P("M128 34 l84 30 v62 c0 52 -36 86 -84 102 c-48 -16 -84 -50 -84 -102 v-62 z", "#E9F2FF")
    b += P("M128 52 l66 24 v50 c0 40 -28 68 -66 82 z", B, 0)
    b += P("M128 34 l84 30 v62 c0 52 -36 86 -84 102 c-48 -16 -84 -50 -84 -102 v-62 z", "none")
    b += P("M92 128 l26 26 l48 -52", "none", 14)
    return b

@icon("gpu", OR)
def _():
    b = R(30, 70, 196, 112, 10, "#2B2F55")
    b += C(92, 126, 38, "#5A6290") + C(92, 126, 12, Y, 6)
    b += C(170, 126, 38, "#5A6290") + C(170, 126, 12, Y, 6)
    for i in range(6):
        b += R(54 + i * 26, 184, 14, 22, 2, Y, 6)
    b += R(30, 60, 196, 14, 4, G, 6)
    return b

@icon("clock", PK)
def _():
    b = C(128, 132, 84, "#FFFFFF") + C(128, 132, 70, Y, 0)
    b += P("M128 132 v-46 M128 132 l34 22", "none", 12) + C(128, 132, 9, OL, 0)
    b += T(196, 82, "x8", 40)
    return b

@icon("bolt", PU)
def _():
    return P("M146 28 l-72 112 h48 l-16 88 l78 -120 h-50 z", Y, 10)

@icon("fire", RD)
def _():
    b = P("M128 226 c-50 0 -78 -36 -70 -80 c6 -34 34 -50 36 -92 c30 20 46 48 42 76 c14 -10 20 -26 20 -40 c30 24 46 54 40 86 c-8 32 -30 50 -68 50 z", OR)
    b += P("M128 222 c-24 0 -36 -18 -32 -38 c4 -16 16 -26 22 -44 c24 16 38 36 36 56 c-2 16 -10 26 -26 26 z", Y, 7)
    return b

# ---------- model kinds ----------
@icon("chat", CY)
def _():
    b = P("M40 60 h176 a16 16 0 0 1 16 16 v84 a16 16 0 0 1 -16 16 h-90 l-44 36 v-36 h-42 a16 16 0 0 1 -16 -16 v-84 a16 16 0 0 1 16 -16 z", "#FFFFFF")
    b += C(88, 118, 13, B) + C(128, 118, 13, B) + C(168, 118, 13, B)
    return b

@icon("code", G)
def _():
    b = R(32, 52, 192, 152, 10, "#1D2142")
    b += P("M92 96 l-30 32 l30 32 M164 96 l30 32 l-30 32", "none", 12).replace(OL, LIME)
    b += P("M138 86 l-20 84", "none", 10).replace(OL, Y)
    return b

@icon("image", PK)
def _():
    b = R(34, 50, 188, 156, 10, "#7FD3FF")
    b += P("M38 200 l60 -70 l40 44 l26 -26 l54 52 z", G)
    b += C(170, 92, 20, Y)
    return b

@icon("voice", OR)
def _():
    b = R(98, 34, 60, 110, 30, "#FFFFFF")
    b += P("M70 120 a58 58 0 0 0 116 0", "none", 11)
    b += P("M128 178 v34 M96 214 h64", "none", 11)
    b += R(112, 60, 32, 12, 6, OR, 0) + R(112, 84, 32, 12, 6, OR, 0)
    return b

@icon("music", PU)
def _():
    b = P("M100 176 v-118 l92 -22 v118", "none", 12)
    b += P("M100 70 l92 -22 v28 l-92 22 z", Y, 8)
    b += C(80, 180, 26, Y) + C(172, 158, 26, Y)
    return b

@icon("video", RD)
def _():
    b = R(30, 70, 140, 116, 12, "#FFFFFF")
    b += P("M170 106 l56 -30 v104 l-56 -30 z", Y)
    b += P("M84 98 l46 30 l-46 30 z", RD, 7)
    return b

@icon("cube", CY)
def _():
    b = P("M128 34 l86 48 v96 l-86 48 l-86 -48 v-96 z", Y)
    b += P("M128 130 l86 -48 v96 l-86 48 z", OR)
    b += P("M128 130 l-86 -48 v96 l86 48 z", "#FFE680")
    b += P("M128 34 l86 48 l-86 48 l-86 -48 z", "none")
    return b

@icon("robot", Y)
def _():
    b = R(54, 72, 148, 120, 22, "#C7CCE6")
    b += C(98, 126, 20, B) + C(158, 126, 20, B) + C(98, 126, 7, "#FFFFFF", 0) + C(158, 126, 7, "#FFFFFF", 0)
    b += R(96, 160, 64, 14, 6, "#2B2F55", 6)
    b += P("M128 72 v-26", "none", 9) + C(128, 40, 12, RD)
    b += R(34, 112, 20, 36, 6, "#8C93B8") + R(202, 112, 20, 36, 6, "#8C93B8")
    return b

if __name__ == "__main__":
    import sys
    only = set(sys.argv[1:])
    for name, fn in ICONS.items():
        if only and name not in only:
            continue
        sp = os.path.join(SVG_DIR, name + ".svg")
        pp = os.path.join(PNG_DIR, "ic2_" + name + ".png")
        with open(sp, "w", encoding="utf-8") as f:
            f.write(fn())
        res = subprocess.run([CLI, "convert", sp, pp], capture_output=True, text=True)
        print(name, "ok" if os.path.exists(pp) else ("FAILED " + (res.stderr or res.stdout)[:200]))
