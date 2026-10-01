"""P4-3 Chart Intro samples. Median 5x5. High var = AA / gradient edge.
Capture is 1280x800 @ DPR 1, so logical == pixel.
"""
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent
DIR = ROOT / "chart-intro"


def hx(rgb: tuple[int, int, int]) -> str:
    return "#{:02X}{:02X}{:02X}".format(*rgb)


def sample(im: Image.Image, x: int, y: int, r: int = 2) -> dict:
    x = max(r, min(im.width - r - 1, x))
    y = max(r, min(im.height - r - 1, y))
    pix = im.convert("RGB")
    cells = [
        pix.getpixel((x + dx, y + dy))
        for dy in range(-r, r + 1)
        for dx in range(-r, r + 1)
    ]
    med = tuple(sorted(c[i] for c in cells)[len(cells) // 2] for i in range(3))
    var = sum((c[i] - med[i]) ** 2 for c in cells for i in range(3)) / len(cells)
    return {
        "xy": [x, y],
        "rgb": list(med),
        "hex": hx(med),
        "var": round(var, 1),
        "edge_suspect": var > 400,
    }


def main() -> None:
    partial = Image.open(DIR / "flutter_chart_intro_c12_partial.png")
    zoom = Image.open(DIR / "flutter_chart_intro_c12_zoom.png")
    dialog = Image.open(DIR / "flutter_chart_intro_c12_dialog.png")
    out = {
        "note": "1280x800 DPR1 standalone Scaffold; AppBar is Theme chrome. Play body should be WHITE.",
        "fe69": "Chart Intro max 10 protons; Fe-69 does not exist on this screen.",
        "partial": {
            "size": [partial.width, partial.height],
            "samples": {
                "play_bg_left": sample(partial, 200, 400),
                "play_bg_mid": sample(partial, 400, 350),
                "play_bg_below_appbar": sample(partial, 80, 120),
                "appbar": sample(partial, 640, 28),
                "element_name": sample(partial, 52, 65),
                "radio_partial_selected": sample(partial, 1188, 434),
                "radio_zoom_unselected": sample(partial, 1210, 434),
                "accordion_area": sample(partial, 1228, 360),
                "periodic_area": sample(partial, 1228, 82),
                "reset_area": sample(partial, 1228, 678),
            },
        },
        "zoom": {
            "size": [zoom.width, zoom.height],
            "samples": {
                "play_bg_left": sample(zoom, 200, 400),
                "radio_partial_unselected": sample(zoom, 1188, 434),
                "radio_zoom_selected": sample(zoom, 1210, 434),
            },
        },
        "dialog": {
            "size": [dialog.width, dialog.height],
            "samples": {
                "play_behind_dialog": sample(dialog, 200, 400),
                "dialog_center": sample(dialog, 640, 400),
            },
        },
    }
    dest = ROOT / "p4_3_screenshot_samples.json"
    dest.write_text(json.dumps(out, indent=2), encoding="utf-8")
    print(dest)
    for name, block in out.items():
        if not isinstance(block, dict) or "samples" not in block:
            continue
        print("\n==", name)
        for k, v in block["samples"].items():
            flag = " EDGE?" if v["edge_suspect"] else ""
            print(f"  {k:28} {v['hex']} var={v['var']}{flag}")


if __name__ == "__main__":
    main()
