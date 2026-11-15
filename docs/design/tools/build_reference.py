#!/usr/bin/env python3
"""Builds docs/design/reference/index.html (and optional PNG renders) from the tokens.

Design tooling only (not application code).
  python3 docs/design/tools/build_reference.py            # HTML only
  python3 docs/design/tools/build_reference.py --png      # also PNG renders (needs playwright + Chrome)
  python3 docs/design/tools/build_reference.py --fonts assets/fonts --out /tmp/site/index.html
"""
import argparse, glob, json, os, re

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
tok = lambda n: json.load(open(os.path.join(ROOT, "tokens", n + ".json"), encoding="utf-8"))
C, T, A = tok("colors"), tok("typography"), tok("animations")


def res(v):
    """Resolve '{palette.ink}' style references."""
    while isinstance(v, str) and v.startswith("{"):
        g, k = v.strip("{}").split(".")
        v = C[g][k]
    return v


def lum(h):
    r, g, b = [int(h[i:i + 2], 16) / 255 for i in (1, 3, 5)]
    f = lambda c: c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4
    return 0.2126 * f(r) + 0.7152 * f(g) + 0.0722 * f(b)


def contrast(a, b):
    la, lb = sorted((lum(a), lum(b)), reverse=True)
    return round((la + 0.05) / (lb + 0.05), 2)


def tokens_css():
    pu, pr, ro = C["public"], C["private"], C["role"]
    g = lambda d, k: res(d[k])
    pub = {"bg": g(pu, "background"), "surface": g(pu, "surface"), "sunken": g(pu, "surfaceSunken"), "text": g(pu, "textPrimary"),
           "text2": g(pu, "textSecondary"), "text-disabled": g(pu, "textDisabled"), "border": g(pu, "border"), "border-strong": g(pu, "border"),
           "primary": g(pu, "primary"), "primary-pressed": g(pu, "primaryPressed"), "on-primary": g(pu, "onPrimary"),
           "accent": g(pu, "accent"), "on-accent": g(pu, "onAccent"), "error-text": g(pu, "errorText"), "focus": g(pu, "focusRing"),
           "shadow": g(pu, "shadow"), "ticket": g(pu, "surface"), "on-ticket": g(pu, "textPrimary"),
           "btn-shadow": "4px 4px 0 " + g(pu, "shadow"), "btn-press": "translate(4px,4px)", "ticket-shadow": "6px 6px 0 " + g(pu, "shadow")}
    prv = {"bg": g(pr, "background"), "surface": g(pr, "surface"), "sunken": g(pr, "surface"), "text": g(pr, "textPrimary"),
           "text2": g(pr, "textSecondary"), "text-disabled": g(pr, "textDisabled"), "border": g(pr, "border"), "border-strong": g(pr, "borderStrong"),
           "primary": g(pr, "primary"), "primary-pressed": g(pr, "primaryPressed"), "on-primary": g(pr, "onPrimary"),
           "accent": g(pr, "primary"), "on-accent": g(pr, "onPrimary"), "error-text": g(pr, "error"), "focus": g(pr, "focusRing"),
           "shadow": g(pr, "shadow"), "ticket": g(pr, "ticket"), "on-ticket": g(pr, "onTicket"),
           "btn-shadow": "none", "btn-press": "translateY(2px)", "ticket-shadow": "0 6px 0 " + g(pr, "shadow")}
    css = ":root{--pub-bg:%s;--role-civ:%s;--role-imp:%s}\n" % (pub["bg"], res(ro["civilian"]), res(ro["impostor"]))
    for cls, d in ((".public", pub), (".private", prv)):
        css += cls + "{" + ";".join("--%s:%s" % kv for kv in d.items()) + "}\n"
    return css


def swatches():
    out = []
    for theme in ("public", "private", "role"):
        bg = res(C["public" if theme == "role" else theme]["background"])
        items = []
        for k, v in C[theme].items():
            if k.startswith("$") or isinstance(v, dict):
                continue
            h = res(v)
            items.append('<div class="sw"><i style="background:%s"></i><b>%s.%s</b><span>%s · %s:1 on bg</span></div>' % (h, theme, k, h, contrast(h, bg)))
        out.append('<div class="cell"><b>%s</b><div class="row" style="gap:10px">%s</div></div>' % (theme, "".join(items)))
    return "".join(out)


def type_rows():
    rows = ["<tr><th>Token</th><th>Spec</th><th>Sample</th><th>Use</th></tr>"]
    sample = "شكون الإمبوستور؟ ڨازوز 4–12"
    for k, s in T["styles"].items():
        size = min(s["fontSize"], 44)
        rows.append('<tr><td><b>%s</b></td><td>%s %s<br>%s / %s</td><td dir="rtl" style="text-align:right;font-family:%s;font-weight:%s;font-size:%spx;line-height:%s;white-space:nowrap">%s</td><td>%s</td></tr>' % (
            k, s["fontFamily"], s["fontWeight"], s["fontSize"], s["lineHeight"], s["fontFamily"], s["fontWeight"], size, s["lineHeight"], sample if s["fontSize"] < 60 else "بريك", s.get("use", "")))
    return "".join(rows)


def icons():
    d = {}
    for f in sorted(glob.glob(os.path.join(ROOT, "assets/icons/ic_*.svg"))):
        d[os.path.basename(f)[3:-4]] = open(f, encoding="utf-8").read().strip()
    return d


def build(fonts, out):
    html = open(os.path.join(ROOT, "reference/index.template.html"), encoding="utf-8").read()
    ic = icons()
    html = html.replace("/*__TOKENS_CSS__*/", tokens_css()).replace("__FONTS__", fonts)
    html = html.replace("__SWATCHES__", swatches()).replace("__TYPE_ROWS__", type_rows())
    html = re.sub(r"__ICS:(\w+)__", lambda m: '<span class="ic s">%s</span>' % ic[m.group(1)], html)
    html = re.sub(r"__IC:(\w+)__", lambda m: '<span class="ic">%s</span>' % ic[m.group(1)], html)
    html = html.replace("__ICONS_JSON__", json.dumps(ic, ensure_ascii=False))
    open(out, "w", encoding="utf-8").write(html)
    return out


def render_png(html_path):
    from playwright.sync_api import sync_playwright
    outdir = os.path.join(ROOT, "reference/png"); os.makedirs(outdir, exist_ok=True)
    with sync_playwright() as p:
        b = p.chromium.launch(executable_path=os.environ.get("CHROME", "/usr/bin/google-chrome"), args=["--no-sandbox"])
        pg = b.new_page(viewport={"width": 1228, "height": 900}, device_scale_factor=2)
        pg.goto("file://" + html_path); pg.evaluate("document.fonts.ready"); pg.wait_for_timeout(400)
        for el in pg.query_selector_all("section[data-shot]"):
            el.screenshot(path=os.path.join(outdir, el.get_attribute("data-shot") + ".png"))
        # demo states at exact 360x720
        ph = pg.query_selector("#phone")
        steps = [("09_demo_setup_paper", None), ("10_demo_handoff", "handoff"), ("11_demo_sealed", "sealed"), ("12_demo_revealed", "revealed")]
        for name, go in steps:
            if go:
                pg.click("#phone [data-go=%s]" % go); pg.wait_for_timeout(1000)
            ph.screenshot(path=os.path.join(outdir, name + ".png"))
        b.close()


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--fonts", default="../assets/fonts")
    ap.add_argument("--out", default=os.path.join(ROOT, "reference/index.html"))
    ap.add_argument("--png", action="store_true")
    a = ap.parse_args()
    path = build(a.fonts, a.out)
    if a.png:
        render_png(os.path.abspath(path))
    print("built", path)
