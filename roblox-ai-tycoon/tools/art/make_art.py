"""Draws the game's UI art as SVG (blocky, thick outlines, one consistent style).
Then converts to PNG with VectorCraft:  vectorcraft-cli convert in.svg out.png
Output PNGs go to src/_assets so the dev web server can serve them for upload to Roblox.

Style rules (keep every asset consistent):
  - outline: #1C2440, 10px on 256 icons
  - flat fills + one darker shade on the lower/right side + one small white highlight
  - chunky rounded-square shapes (rx 18-28), no gradients except the title sky
"""
import os, subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
SVG_DIR = os.path.join(ROOT, "art", "svg")
PNG_DIR = os.path.join(ROOT, "src", "_assets")
CLI = os.path.join(os.environ["LOCALAPPDATA"], "Programs", "ArtCraft", "VectorCraft", "vectorcraft-cli.exe")
os.makedirs(SVG_DIR, exist_ok=True)
os.makedirs(PNG_DIR, exist_ok=True)

OL = "#1C2440"   # outline
SW = 10          # stroke width on 256 canvas

def svg(w, h, body):
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">{body}</svg>'

def r(x, y, w, h, rx, fill, stroke=True, sw=SW):
    s = f' stroke="{OL}" stroke-width="{sw}" stroke-linejoin="round"' if stroke else ""
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" fill="{fill}"{s}/>'

def c(cx, cy, rad, fill, stroke=True, sw=SW):
    s = f' stroke="{OL}" stroke-width="{sw}"' if stroke else ""
    return f'<circle cx="{cx}" cy="{cy}" r="{rad}" fill="{fill}"{s}/>'

def path(d, fill, stroke=True, sw=SW):
    s = f' stroke="{OL}" stroke-width="{sw}" stroke-linejoin="round" stroke-linecap="round"' if stroke else ""
    return f'<path d="{d}" fill="{fill}"{s}/>'

def hl(x, y, w, h, rx=6):  # small white highlight
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" fill="#FFFFFF" fill-opacity="0.75"/>'

# ---------- 9-slice button: white so the game can tint it with ImageColor3 ----------
def button():
    b = r(8, 8, 240, 112, 26, "#FFFFFF", sw=8)
    b += f'<rect x="12" y="84" width="232" height="32" rx="18" fill="#C9D3E6"/>'      # bottom bevel (tints darker)
    b += r(8, 8, 240, 112, 26, "none", sw=8)
    b += f'<rect x="28" y="20" width="200" height="14" rx="7" fill="#FFFFFF" fill-opacity="0.9"/>'  # shine
    return svg(256, 128, b)

def panel():
    b = r(6, 6, 244, 244, 28, "#FFFFFF", sw=8)
    b += f'<rect x="10" y="214" width="236" height="32" rx="22" fill="#D7E2F2"/>'
    b += r(6, 6, 244, 244, 28, "none", sw=8)
    return svg(256, 256, b)

# ---------- icons 256x256 ----------
def icon_lab():
    b = path("M104 30 h48 v62 l58 104 a22 22 0 0 1 -20 32 h-124 a22 22 0 0 1 -20 -32 l58 -104 z", "#EAF6FF")
    b += path("M74 150 h108 l26 46 a14 14 0 0 1 -12 20 h-136 a14 14 0 0 1 -12 -20 z", "#3DDC84", sw=0)
    b += path("M104 30 h48 v62 l58 104 a22 22 0 0 1 -20 32 h-124 a22 22 0 0 1 -20 -32 l58 -104 z", "none")
    b += r(92, 22, 72, 22, 8, "#B9C6DA")
    b += c(110, 180, 9, "#FFFFFF", stroke=False) + c(140, 196, 6, "#FFFFFF", stroke=False)
    return svg(256, 256, b)

def icon_parts():
    b = r(24, 64, 208, 128, 18, "#3A4566")
    b += r(24, 166, 208, 26, 10, "#2A3350", stroke=False)
    b += c(92, 128, 42, "#7C8BB3") + c(92, 128, 14, OL, stroke=False)
    for i in range(4):
        b += r(150, 86 + i * 22, 64, 12, 5, "#3DDC84", stroke=False)
    for i in range(7):
        b += r(48 + i * 24, 192, 14, 26, 3, "#FFC21A")
    b += hl(40, 76, 60, 10)
    return svg(256, 256, b)

def icon_team():
    b = c(88, 96, 38, "#FFD27A") + r(40, 140, 96, 84, 30, "#2D8CFF")
    b += c(168, 104, 34, "#E8A86B") + r(124, 146, 90, 78, 28, "#A15CFF")
    b += hl(70, 72, 20, 10, 5) + hl(150, 82, 18, 9, 5)
    return svg(256, 256, b)

def icon_bank():
    b = ""
    for i, y in enumerate((168, 134, 100)):
        b += r(52, y, 152, 44, 20, "#FFC21A")
        b += r(56, y + 28, 144, 12, 6, "#E59A00", stroke=False)
    b += c(128, 72, 46, "#FFD84D") + path("M128 46 v52 M112 60 h26 a10 10 0 0 1 0 20 h-20 a10 10 0 0 0 0 20 h26", "none", sw=8)
    b += hl(98, 46, 22, 10, 5)
    return svg(256, 256, b)

def icon_social():
    b = path("M40 52 h176 a20 20 0 0 1 20 20 v96 a20 20 0 0 1 -20 20 h-96 l-44 36 v-36 h-36 a20 20 0 0 1 -20 -20 v-96 a20 20 0 0 1 20 -20 z", "#2D8CFF")
    b += c(88, 120, 14, "#FFFFFF") + c(128, 120, 14, "#FFFFFF") + c(168, 120, 14, "#FFFFFF")
    b += hl(54, 64, 70, 10)
    return svg(256, 256, b)

def icon_mail():
    b = r(28, 60, 200, 140, 22, "#FFFFFF")
    b += path("M34 72 l94 72 l94 -72", "none", sw=10)
    b += r(176, 40, 52, 52, 26, "#FF4D5E")
    b += path("M202 54 v20", "none", sw=8) + c(202, 82, 3, "#FFFFFF", stroke=False)
    return svg(256, 256, b)

def icon_goals():
    b = c(128, 136, 92, "#FF4D5E") + c(128, 136, 62, "#FFFFFF") + c(128, 136, 32, "#FF4D5E") + c(128, 136, 8, OL, stroke=False)
    b += path("M132 132 l70 -70", "none", sw=10) + path("M196 46 l26 -4 l-4 26 l-20 2 z", "#3DDC84", sw=8)
    return svg(256, 256, b)

def icon_company():
    b = r(56, 40, 144, 192, 16, "#7FB3FF")
    b += r(60, 196, 136, 32, 10, "#5A8FE0", stroke=False)
    for row in range(4):
        for col in range(3):
            b += r(78 + col * 36, 62 + row * 34, 24, 22, 5, "#FFF2B3", sw=6)
    b += r(108, 196, 40, 36, 6, "#3A4566", sw=6)
    b += hl(70, 52, 40, 8, 4)
    return svg(256, 256, b)

# ---------- title background 1920x1080: blocky city, soft sky ----------
def title_bg():
    import random
    random.seed(7)
    b = '<defs><linearGradient id="sky" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#6FB7FF"/><stop offset="1" stop-color="#C8E6FF"/></linearGradient></defs>'
    b += '<rect width="1920" height="1080" fill="url(#sky)"/>'
    for cx, cy, s in ((260, 180, 1.0), (1500, 140, 1.3), (980, 260, 0.8), (1780, 330, 0.7)):
        w = 220 * s
        b += f'<g fill="#FFFFFF" fill-opacity="0.95"><rect x="{cx}" y="{cy}" width="{w}" height="{50*s}" rx="{20*s}"/><rect x="{cx+40*s}" y="{cy-34*s}" width="{w*0.55}" height="{50*s}" rx="{20*s}"/></g>'
    # back row of buildings
    x = -20
    while x < 1920:
        w = random.choice((120, 150, 180))
        h = random.randint(260, 520)
        b += f'<rect x="{x}" y="{1080-h-120}" width="{w}" height="{h+120}" rx="10" fill="#8FB4E8" stroke="{OL}" stroke-opacity="0.25" stroke-width="6"/>'
        x += w + 18
    # front row with windows
    x = -40
    pal = ["#2D8CFF", "#3DDC84", "#FFC21A", "#FF6B7A", "#A15CFF", "#22C3D6"]
    i = 0
    while x < 1920:
        w = random.choice((170, 200, 240))
        h = random.randint(200, 380)
        col = pal[i % len(pal)]
        y = 1080 - h - 90
        b += f'<rect x="{x}" y="{y}" width="{w}" height="{h+90}" rx="16" fill="{col}" stroke="{OL}" stroke-width="10"/>'
        for wy in range(y + 30, 1080 - 120, 56):
            for wx in range(x + 24, x + w - 40, 50):
                b += f'<rect x="{wx}" y="{wy}" width="30" height="30" rx="6" fill="#FFF6C9" stroke="{OL}" stroke-width="5"/>'
        x += w + 26
        i += 1
    b += f'<rect x="-10" y="990" width="1940" height="100" fill="#3A4566" stroke="{OL}" stroke-width="10"/>'
    for sx in range(0, 1920, 120):
        b += f'<rect x="{sx+30}" y="1030" width="60" height="12" rx="6" fill="#FFC21A"/>'
    return svg(1920, 1080, b)

# ---------- stud tile (Roblox brick pattern), white with low alpha: overlay on any colour ----------
def studs():
    b = '<rect x="10" y="10" width="44" height="44" rx="3" fill="none" stroke="#FFFFFF" stroke-opacity="0.10" stroke-width="5"/>'
    b += '<rect x="20" y="20" width="24" height="24" rx="2" fill="#000000" fill-opacity="0.10"/>'
    return svg(64, 64, b)

ASSETS = {
    "ui_studs": studs,
    "ui_button": button, "ui_panel": panel,
    "icon_lab": icon_lab, "icon_parts": icon_parts, "icon_team": icon_team, "icon_bank": icon_bank,
    "icon_social": icon_social, "icon_mail": icon_mail, "icon_goals": icon_goals, "icon_company": icon_company,
    "title_bg": title_bg,
}

if __name__ == "__main__":
    for name, fn in ASSETS.items():
        sp = os.path.join(SVG_DIR, name + ".svg")
        pp = os.path.join(PNG_DIR, name + ".png")
        with open(sp, "w", encoding="utf-8") as f:
            f.write(fn())
        res = subprocess.run([CLI, "convert", sp, pp], capture_output=True, text=True)
        ok = os.path.exists(pp)
        print(name, "ok" if ok else ("FAILED " + (res.stderr or res.stdout)[:200]))
