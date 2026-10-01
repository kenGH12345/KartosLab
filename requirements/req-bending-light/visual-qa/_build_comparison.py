"""Build same-size side-by-side and 50/50 overlays. Not a product artifact."""
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFont, ImageStat

root = Path(__file__).resolve().parent
official = root / "official"
flutter = root / "flutter"
out = root / "comparison"
out.mkdir(parents=True, exist_ok=True)

pairs = [
    ("OFFICIAL_INTRO.png", "FLUTTER_INTRO.png", "INTRO"),
    ("OFFICIAL_MORE_TOOLS.png", "FLUTTER_MORE_TOOLS.png", "MORE_TOOLS"),
    ("OFFICIAL_PRISMS.png", "FLUTTER_PRISMS.png", "PRISMS"),
    ("OFFICIAL_WHITE_LIGHT.png", "FLUTTER_WHITE_LIGHT.png", "WHITE_LIGHT"),
    ("OFFICIAL_GRAPH.png", "FLUTTER_GRAPH.png", "GRAPH"),
    ("OFFICIAL_SENSORS.png", "FLUTTER_SENSORS.png", "SENSORS"),
]


# Flutter demo: Material AppBar is 56px. Official joist navbar starts at y=569.
APP_BAR = 56
NAV_TOP = 569
STAGE = (834, 504)


def stage(im, kind):
    w, h = im.size
    if kind == "flutter":
        body_h = h - APP_BAR
        scale = body_h / STAGE[1]
        sw = STAGE[0] * scale
        left = (w - sw) / 2
        box = (round(left), APP_BAR, round(left + sw), h)
    else:
        avail = NAV_TOP
        scale = avail / STAGE[1]
        sw = STAGE[0] * scale
        left = (w - sw) / 2
        box = (round(left), 0, round(left + sw), avail)
    return im.crop(box).resize(STAGE, Image.Resampling.LANCZOS)


for off_name, flu_name, stem in pairs:
    a = stage(Image.open(official / off_name).convert("RGBA"), "official")
    b = stage(Image.open(flutter / flu_name).convert("RGBA"), "flutter")
    side = Image.new("RGBA", (a.width + b.width, a.height), (0, 0, 0, 255))
    side.paste(a, (0, 0))
    side.paste(b, (a.width, 0))
    side.save(out / f"{stem}_SIDE_BY_SIDE.png")
    Image.blend(a, b, 0.5).save(out / f"{stem}_OVERLAY.png")
    diff = ImageChops.difference(a.convert("RGB"), b.convert("RGB"))
    print(stem, "stage", a.size, "mean_abs", [round(x, 2) for x in ImageStat.Stat(diff).mean])

print("wrote", out)
