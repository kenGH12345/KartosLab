"""P5-2 micro-geometry samples. Median 5x5. High var = AA / edge."""
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent


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


def L(x: float, y: float) -> tuple[int, int]:
    return int(x * 2), int(y * 2)


def main() -> None:
    fe = Image.open(ROOT / "decay-first" / "flutter_decay_fe69.png")
    empty = Image.open(ROOT / "decay-first" / "flutter_decay_empty.png")
    dialog = Image.open(ROOT / "chart-intro" / "flutter_chart_intro_c12_dialog.png")
    zoom = Image.open(ROOT / "chart-intro" / "flutter_chart_intro_c12_zoom.png")
    out = {
        "fe69_dpr2": {
            "size": [fe.width, fe.height],
            "samples": {
                "add_proton_center": sample(fe, *L(231.7, 742)),
                "add_proton_bg": sample(fe, *L(222, 742)),
                "add_pair_left": sample(fe, *L(416, 742)),
                "add_pair_right": sample(fe, *L(437, 742)),
                "add_neutron_center": sample(fe, *L(621.7, 742)),
                "less_stable_arrow": sample(fe, *L(130, 270)),
                "more_stable_arrow": sample(fe, *L(1140, 270)),
            },
        },
        "empty_dpr2": {
            "size": [empty.width, empty.height],
            "samples": {
                "add_pair_left": sample(empty, *L(416, 742)),
                "add_pair_right": sample(empty, *L(437, 742)),
            },
        },
        "c12_dialog_dpr1": {
            "size": [dialog.width, dialog.height],
            "samples": {
                "play_bg": sample(dialog, 200, 400),
                "dialog_close_guess": sample(dialog, 1240, 80),
            },
        },
        "c12_zoom_dpr1": {
            "size": [zoom.width, zoom.height],
            "note": "C-12 is stable: no in-cell decay arrow (correct).",
            "samples": {
                "play_bg": sample(zoom, 200, 400),
            },
        },
    }
    dest = ROOT / "p5_2_screenshot_samples.json"
    dest.write_text(json.dumps(out, indent=2), encoding="utf-8")
    print(dest)
    for name, block in out.items():
        if "samples" not in block:
            continue
        print("\n==", name)
        for k, v in block["samples"].items():
            flag = " EDGE?" if v["edge_suspect"] else ""
            print(f"  {k:24} {v['hex']} var={v['var']}{flag}")


if __name__ == "__main__":
    main()
