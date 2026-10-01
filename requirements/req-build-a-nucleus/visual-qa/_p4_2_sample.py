"""P4-2 post-fix samples. Median 5x5. High var = AA / gradient edge."""
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent
DIR = ROOT / "decay-first"


def hx(rgb: tuple[int, int, int]) -> str:
    return "#{:02X}{:02X}{:02X}".format(*rgb)


def sample(im: Image.Image, x: int, y: int, r: int = 2) -> dict:
    x = max(r, min(im.width - r - 1, x))
    y = max(r, min(im.height - r - 1, y))
    pix = im.convert("RGB")
    cells = [pix.getpixel((x + dx, y + dy)) for dy in range(-r, r + 1) for dx in range(-r, r + 1)]
    med = tuple(sorted(c[i] for c in cells)[len(cells) // 2] for i in range(3))
    var = sum((c[i] - med[i]) ** 2 for c in cells for i in range(3)) / len(cells)
    return {"xy": [x, y], "rgb": list(med), "hex": hx(med), "var": round(var, 1), "edge_suspect": var > 400}


def L(x: float, y: float) -> tuple[int, int]:
    return int(x * 2), int(y * 2)


def main() -> None:
    fl = Image.open(DIR / "flutter_decay_fe69.png")
    empty = Image.open(DIR / "flutter_decay_empty.png")
    orig = Image.open(DIR / "original_decay_screen1.png")
    out = {
        "flutter_fe69": {
            "size": [fl.width, fl.height],
            "samples": {
                "play_bg_left": sample(fl, *L(80, 300)),
                "play_bg_center_away": sample(fl, *L(200, 250)),
                "canvas_left_of_nucleus": sample(fl, *L(280, 543)),
                "electron_cloud": sample(fl, *L(500, 543)),
                "nucleus_center": sample(fl, *L(427, 543)),
                "available_decays_panel": sample(fl, *L(1228, 250)),
                "decay_alpha_disabled": sample(fl, *L(1228, 297)),
                "half_life_pointer": sample(fl, *L(640, 208)),
                "appbar": sample(fl, *L(640, 28)),
            },
        },
        "flutter_empty": {
            "size": [empty.width, empty.height],
            "samples": {
                "play_bg": sample(empty, *L(200, 300)),
                "canvas": sample(empty, *L(427, 543)),
            },
        },
        "original_fe69": {
            "size": [orig.width, orig.height],
            "samples": {
                "page_bg": sample(orig, 80, 280),
                "available_decays_panel": sample(orig, 880, 280),
            },
        },
    }
    dest = ROOT / "p4_2_screenshot_samples.json"
    dest.write_text(json.dumps(out, indent=2), encoding="utf-8")
    print(dest)
    for name, block in out.items():
        print("\n==", name)
        for k, v in block["samples"].items():
            flag = " EDGE?" if v["edge_suspect"] else ""
            print(f"  {k:28} {v['hex']} var={v['var']}{flag}")


if __name__ == "__main__":
    main()
