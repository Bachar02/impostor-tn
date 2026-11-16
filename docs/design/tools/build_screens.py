#!/usr/bin/env python3
"""Builds docs/design/reference/screens.html: full-screen compositions of the specified screens.

Design tooling only (not application code). Component styles, tokens and icons are taken
from the same sources as build_reference.py, so this page cannot drift from the component
reference.

  python docs/design/tools/build_screens.py            # HTML only
  python docs/design/tools/build_screens.py --png      # also renders + layout measurements

--png needs Google Chrome (set CHROME to its path if it is not in the default location).
It writes PNGs to reference/png/screens/ and measurements to reference/screens_metrics.json.
"""
import argparse, concurrent.futures, json, os, pathlib, re, shutil, subprocess, sys, tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import build_reference as ref  # noqa: E402  (tokens_css, icons, res, C, ROOT)

ROOT = ref.ROOT
OUT_HTML = os.path.join(ROOT, "reference", "screens.html")
OUT_PNG = os.path.join(ROOT, "reference", "png", "screens")
OUT_METRICS = os.path.join(ROOT, "reference", "screens_metrics.json")

# Screens rendered at every size, and the constrained ones rendered at the small sizes too.
SIZES_ALL = [(360, 720, 1.0)]
SIZES_CONSTRAINED = [(320, 568, 1.0), (320, 568, 1.5), (360, 720, 1.5)]
CONSTRAINED = ("ovl01_", "prv02_", "prv03_", "prv04_", "pub09_", "prv01_", "pub08_tally_12", "pub05_players_twelve", "pub01_home")
FULL_LENGTH = ("pub09_", "pub05_players_twelve", "pub02_howto", "prv03_vote_12_none", "pub08_tally_12")


def rgba(hex_color, alpha):
    r, g, b = [int(hex_color[i:i + 2], 16) for i in (1, 3, 5)]
    return "rgba(%d,%d,%d,%s)" % (r, g, b, alpha)


def extra_tokens_css():
    """Roles the component page does not need but the screens do: success colour and scrims."""
    pu, pr = ref.C["public"], ref.C["private"]
    return (".public{--ok:%s;--scrim:%s}\n.private{--ok:%s;--scrim:%s}\n" % (
        ref.res(pu["success"]), rgba(ref.res(pu["scrim"]["color"]), pu["scrim"]["alpha"]),
        ref.res(pr["success"]), rgba(ref.res(pr["scrim"]["color"]), pr["scrim"]["alpha"])))


def component_css():
    """Component rules copied verbatim from the component reference template."""
    src = open(os.path.join(ROOT, "reference", "index.template.html"), encoding="utf-8").read()
    start = src.index("/* ---------- themed stage ---------- */")
    return src[start:src.index("</style>")]


def build():
    html = open(os.path.join(ROOT, "reference", "screens.template.html"), encoding="utf-8").read()
    html = html.replace("/*__TOKENS_CSS__*/", ref.tokens_css() + extra_tokens_css())
    html = html.replace("/*__COMPONENT_CSS__*/", component_css())
    html = html.replace("__FONTS__", "../assets/fonts").replace("__LOGO__", "../assets/logo")
    html = html.replace("__ICONS_JSON__", json.dumps(ref.icons(), ensure_ascii=False))
    open(OUT_HTML, "w", encoding="utf-8", newline="\n").write(html)
    return re.findall(r"^ ([a-z0-9_]+):\(\)=>", html, re.M)


def chrome_path():
    cands = [os.environ.get("CHROME"), shutil.which("chrome"), shutil.which("google-chrome"),
             r"C:\Program Files\Google\Chrome\Application\chrome.exe", "/usr/bin/google-chrome",
             "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"]
    for c in cands:
        if c and os.path.exists(c):
            return c
    sys.exit("Chrome not found; set the CHROME environment variable.")


def run_chrome(chrome, profile, args, url):
    cmd = [chrome, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--no-first-run",
           "--user-data-dir=" + profile, "--virtual-time-budget=6000"] + args + [url]
    return subprocess.run(cmd, capture_output=True, timeout=120).stdout.decode("utf-8", "replace")


def shoot(job):
    chrome, sid, w, h, ts, full = job
    base = pathlib.Path(OUT_HTML).as_uri()
    url = "%s?s=%s&w=%d&h=%d&ts=%s&full=%d" % (base, sid, w, h, ts, 1 if full else 0)
    profile = tempfile.mkdtemp(prefix="tesskra_shot_")
    try:
        dom = run_chrome(chrome, profile, ["--window-size=%d,%d" % (max(w, 500), h), "--dump-dom"], url)
        m = re.search(r'<pre id="metrics">(.*?)</pre>', dom, re.S)
        if not m or not m.group(1).strip():
            return sid, None, "no metrics"
        metrics = json.loads(m.group(1).replace("&amp;", "&").replace("&lt;", "<").replace("&gt;", ">").replace("&quot;", '"'))
        height = metrics["deviceH"] if full else h
        suffix = "full" if full else "%dx%d%s" % (w, h, "" if ts == 1 else "_ts%d" % round(ts * 100))
        name = "%s__%s.png" % (sid, suffix)
        run_chrome(chrome, profile, ["--force-device-scale-factor=2", "--window-size=%d,%d" % (w, height),
                                     "--screenshot=" + os.path.join(OUT_PNG, name)], url)
        metrics["file"] = name
        metrics["full"] = bool(full)
        return sid, metrics, None
    finally:
        shutil.rmtree(profile, ignore_errors=True)


def render(screens):
    chrome = chrome_path()
    shutil.rmtree(OUT_PNG, ignore_errors=True)
    os.makedirs(OUT_PNG)
    jobs = []
    for sid in screens:
        sizes = list(SIZES_ALL)
        if sid.startswith(CONSTRAINED):
            sizes += SIZES_CONSTRAINED
        jobs += [(chrome, sid, w, h, ts, False) for w, h, ts in sizes]
        if sid.startswith(FULL_LENGTH):
            jobs.append((chrome, sid, 360, 720, 1.0, True))
    results, failed = [], []
    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
        for sid, metrics, err in pool.map(shoot, jobs):
            (results if metrics else failed).append(metrics or (sid, err))
    results.sort(key=lambda m: m["file"])
    json.dump(results, open(OUT_METRICS, "w", encoding="utf-8", newline="\n"), ensure_ascii=False, indent=1)
    print("rendered %d images, %d failed" % (len(results), len(failed)))
    for f in failed:
        print("  FAILED", f)


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--png", action="store_true")
    a = ap.parse_args()
    ids = build()
    print("built", OUT_HTML, "with", len(ids), "screen states")
    if a.png:
        render(ids)
