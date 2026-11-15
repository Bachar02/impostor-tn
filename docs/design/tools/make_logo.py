#!/usr/bin/env python3
"""Regenerates the logo, stamp and app-icon SVGs with text converted to outlines.

Design tooling only (not application code). Requires: fonttools, uharfbuzz.
Run from the repository root:  python3 docs/design/tools/make_logo.py
Change WORDMARK below when the Arabic product name is approved, then re-run.
"""
import io, os
import uharfbuzz as hb
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen

ROOT = os.path.join(os.path.dirname(__file__), "..")
FONT = os.path.join(ROOT, "assets/fonts/NotoKufiArabic[wght].ttf")
OUT = os.path.join(ROOT, "assets/logo")
WORDMARK = "إمبوستور"  # PROVISIONAL spelling, needs Derja review

INK, PAPER, RAISED, STAMP, MUSTARD = "#1B2A4A", "#F3EBDD", "#FFFDF7", "#C92D22", "#E9A820"


def load(wght):
    """In-memory static instance used only to extract outlines; never redistributed."""
    f = instancer.instantiateVariableFont(TTFont(FONT), {"wght": wght})
    buf = io.BytesIO(); f.save(buf)
    return f, buf.getvalue()


def outline(text, wght=900, direction="rtl", script="arab", lang="ar"):
    """Returns (svg path data in font units with y pointing down, advance, ascent, descent)."""
    f, data = load(wght)
    font = hb.Font(hb.Face(data))
    b = hb.Buffer(); b.add_str(text)
    b.direction, b.script, b.language = direction, script, lang
    hb.shape(font, b)
    gs, order = f.getGlyphSet(), f.getGlyphOrder()
    x, parts = 0, []
    for info, pos in zip(b.glyph_infos, b.glyph_positions):
        pen = SVGPathPen(gs)
        gs[order[info.codepoint]].draw(TransformPen(pen, (1, 0, 0, -1, x + pos.x_offset, -pos.y_offset)))
        parts.append(pen.getCommands()); x += pos.x_advance
    hhea = f["hhea"]
    return " ".join(p for p in parts if p), x, hhea.ascent, -hhea.descent


def bbox(d, f_units=None):
    from fontTools.svgLib.path import parse_path
    from fontTools.pens.boundsPen import ControlBoundsPen
    p = ControlBoundsPen(None); parse_path(d, p); return p.bounds


def placed(d, x, y, height, fill):
    """Scale the outline so its ink box is `height` tall with top-left corner at (x, y)."""
    x0, y0, x1, y1 = bbox(d)
    s = height / (y1 - y0)
    return f'<path fill="{fill}" transform="translate({x - x0 * s:.2f} {y - y0 * s:.2f}) scale({s:.5f})" d="{d}"/>', (x1 - x0) * s


def write(name, body, w, h):
    with open(os.path.join(OUT, name), "w", encoding="utf-8") as fh:
        fh.write(f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">{body}</svg>\n')


def main():
    os.makedirs(OUT, exist_ok=True)
    word, *_ = outline(WORDMARK)
    tn, *_ = outline("TN", direction="ltr", script="latn", lang="en")
    q, *_ = outline("؟")

    # 1. Wordmark, ink and paper versions
    for name, col in (("wordmark_ar_ink.svg", INK), ("wordmark_ar_paper.svg", PAPER)):
        p, wd = placed(word, 0, 0, 120, col)
        write(name, p, round(wd), 120)

    # 2. TN stamp (round ring, rotated in use, not in the file)
    p, wd = placed(tn, 0, 0, 34, STAMP)
    p, _ = placed(tn, (96 - wd) / 2, 31, 34, STAMP)
    write("stamp_tn.svg", f'<circle cx="48" cy="48" r="44" fill="none" stroke="{STAMP}" stroke-width="5"/>'
          f'<circle cx="48" cy="48" r="36" fill="none" stroke="{STAMP}" stroke-width="1.5"/>{p}', 96, 96)

    # 3. Ticket lockup for the home screen (paper theme)
    p, wd = placed(word, 0, 0, 62, INK)
    W, H = 320, 190
    p, _ = placed(word, W - 28 - wd, 44, 62, INK)
    lock = (f'<rect x="10" y="10" width="{W-14}" height="{H-14}" rx="20" fill="{INK}"/>'
            f'<rect x="4" y="4" width="{W-14}" height="{H-14}" rx="20" fill="{RAISED}" stroke="{INK}" stroke-width="2.5"/>'
            f'{p}'
            f'<path d="M24 136H{W-30}" stroke="{INK}" stroke-width="2.5" stroke-dasharray="8 6"/>'
            f'<circle cx="4" cy="136" r="11" fill="{PAPER}" stroke="{INK}" stroke-width="2.5"/>'
            f'<circle cx="{W-10}" cy="136" r="11" fill="{PAPER}" stroke="{INK}" stroke-width="2.5"/>'
            f'<rect x="-10" y="120" width="13" height="32" fill="{PAPER}"/>'
            f'<rect x="{W-9}" y="120" width="20" height="32" fill="{PAPER}"/>')
    write("logo_ticket_lockup.svg", lock, W, H)

    # 4. Android adaptive icon: 108x108 layers, artwork inside the 66x66 safe zone
    write("app_icon_background.svg", f'<rect width="108" height="108" fill="{MUSTARD}"/>', 108, 108)
    qp, qw = placed(q, 0, 0, 30, STAMP)
    qp, _ = placed(q, 54 - qw / 2, 33, 30, STAMP)
    fg = (f'<g transform="rotate(-8 54 54)">'
          f'<rect x="34" y="27" width="46" height="60" rx="8" fill="{INK}"/>'
          f'<rect x="31" y="24" width="46" height="60" rx="8" fill="{RAISED}" stroke="{INK}" stroke-width="3"/>'
          f'{qp}'
          f'<path d="M37 70H71" stroke="{INK}" stroke-width="2.5" stroke-dasharray="4 3.5"/>'
          f'<path d="M40 77H68" stroke="{INK}" stroke-width="2.5" stroke-linecap="round"/>'
          f'</g>')
    write("app_icon_foreground.svg", fg, 108, 108)
    write("app_icon_preview.svg",
          f'<clipPath id="m"><rect width="108" height="108" rx="26"/></clipPath><g clip-path="url(#m)">'
          f'<rect width="108" height="108" fill="{MUSTARD}"/>{fg}</g>', 108, 108)
    # Monochrome layer for Android 13 themed icons
    mono = fg.replace(RAISED, "none").replace(STAMP, "#000000").replace(INK, "#000000").replace(
        f'<rect x="34" y="27" width="46" height="60" rx="8" fill="#000000"/>', "")
    write("app_icon_monochrome.svg", mono, 108, 108)


if __name__ == "__main__":
    main()
