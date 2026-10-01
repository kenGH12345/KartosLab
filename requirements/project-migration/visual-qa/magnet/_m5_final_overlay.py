"""M5-FINAL: overlay / diff / mean RGB / FINAL_VISUAL_MATRIX. Measurement only."""
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageEnhance, ImageStat

ROOT = Path(__file__).resolve().parent
DIR = ROOT / "final"
SHOT = DIR / "screenshots"
DPR = 2.0

ORIG_FIELD_METER = {
    "x": 358.4 - 260 / 2,
    "y": 240.0 - 192 / 2,
    "w": 260.0,
    "h": 192.0,
    "cx": 358.4,
    "cy": 240.0,
    "source": "phet SimulationPage: w=260 h=192 center=(0.28W, 0.30H)",
}


def r1(v: float) -> float:
    return round(float(v), 1)


def rect_round(r: dict) -> dict:
    return {k: r1(v) if isinstance(v, (int, float)) else v for k, v in r.items()}


def logical_to_px(r: dict) -> tuple[int, int, int, int]:
    x = int(round(r["x"] * DPR))
    y = int(round(r["y"] * DPR))
    w = max(1, int(round(r["w"] * DPR)))
    h = max(1, int(round(r["h"] * DPR)))
    return x, y, w, h


def crop_logical(im: Image.Image, r: dict) -> Image.Image:
    x, y, w, h = logical_to_px(r)
    return im.crop((x, y, min(im.width, x + w), min(im.height, y + h)))


def mean_rgb(im: Image.Image) -> dict:
    rgb = im.convert("RGB")
    st = ImageStat.Stat(rgb)
    m = [round(v, 2) for v in st.mean]
    return {
        "r": m[0],
        "g": m[1],
        "b": m[2],
        "hex": "#{:02X}{:02X}{:02X}".format(*(int(round(v)) for v in m)),
    }


def delta(orig: dict, fl: dict) -> dict:
    return {
        "dx": r1(fl["x"] - orig["x"]),
        "dy": r1(fl["y"] - orig["y"]),
        "dw": r1(fl["w"] - orig["w"]),
        "dh": r1(fl["h"] - orig["h"]),
        "dcx": r1(fl["cx"] - orig["cx"]),
        "dcy": r1(fl["cy"] - orig["cy"]),
    }


def row(component, orig, fl, classification, notes, extra=None):
    d = delta(orig, fl)
    out = {
        "component": component,
        "original_rect": rect_round(orig),
        "flutter_rect": rect_round(fl),
        "dx": d["dx"],
        "dy": d["dy"],
        "dw": d["dw"],
        "dh": d["dh"],
        "dcx": d["dcx"],
        "dcy": d["dcy"],
        "classification": classification,
        "notes": notes,
    }
    if extra:
        out.update(extra)
    return out


def overlay(a: Image.Image, b: Image.Image, alpha: float = 0.5) -> Image.Image:
    a = a.convert("RGB").resize(b.size, Image.Resampling.BILINEAR)
    b = b.convert("RGB")
    return Image.blend(a, b, alpha)


def diff_amp(a: Image.Image, b: Image.Image) -> Image.Image:
    a = a.convert("RGB").resize(b.size, Image.Resampling.BILINEAR)
    b = b.convert("RGB")
    d = ImageChops.difference(a, b)
    return ImageEnhance.Brightness(d).enhance(3.0)


def draw_rect(im: Image.Image, r: dict, color, label: str) -> None:
    x, y, w, h = logical_to_px(r)
    dr = ImageDraw.Draw(im)
    dr.rectangle([x, y, x + w - 1, y + h - 1], outline=color, width=3)
    dr.text((x + 4, y + 4), label, fill=color)


def main() -> None:
    rects = json.loads((DIR / "rects.json").read_text(encoding="utf-8"))
    od = rects["rects"]["original_default"]
    fd = rects["rects"]["flutter_default"]
    om = rects["rects"]["original_field_meter"]
    fm = rects["rects"]["flutter_field_meter"]
    moved = rects["rects"]["flutter_magnet_moved"]

    orig_img = Image.open(SHOT / "original_default.png")
    flut_img = Image.open(SHOT / "flutter_default.png")
    orig_m = Image.open(SHOT / "original_field_meter.png")
    flut_m = Image.open(SHOT / "flutter_field_meter.png")
    flut_moved = Image.open(SHOT / "flutter_magnet_moved.png")

    overlay(orig_img, flut_img).save(SHOT / "overlay_default.png")
    diff_amp(orig_img, flut_img).save(SHOT / "diff_default.png")
    overlay(orig_m, flut_m).save(SHOT / "overlay_field_meter.png")
    diff_amp(orig_m, flut_m).save(SHOT / "diff_field_meter.png")

    orig_canvas = crop_logical(orig_img, od["canvas"])
    flut_canvas = crop_logical(flut_img, fd["canvas"])
    flut_canvas_scaled = flut_canvas.resize(orig_canvas.size, Image.Resampling.BILINEAR)
    overlay(orig_canvas, flut_canvas_scaled).save(SHOT / "overlay_canvas_normalized.png")
    diff_amp(orig_canvas, flut_canvas_scaled).save(SHOT / "diff_canvas_normalized.png")

    crop_logical(orig_img, od["controlPanel"]).save(SHOT / "original_control_panel.png")
    crop_logical(flut_img, fd["controlPanel"]).save(SHOT / "flutter_control_panel.png")
    crop_logical(orig_img, od["resetCircle"]).save(SHOT / "original_reset.png")
    crop_logical(flut_img, fd["resetCircle"]).save(SHOT / "flutter_reset.png")
    crop_logical(orig_img, od["compass"]).save(SHOT / "original_compass.png")
    crop_logical(flut_img, fd["compass"]).save(SHOT / "flutter_compass.png")
    crop_logical(orig_img, od["magnet"]).save(SHOT / "original_magnet.png")
    crop_logical(flut_img, fd["magnet"]).save(SHOT / "flutter_magnet.png")
    flut_moved.save(SHOT / "flutter_magnet_moved.png")  # already captured

    annotated = overlay(orig_img, flut_img)
    draw_rect(annotated, od["canvas"], (255, 80, 80), "orig canvas")
    draw_rect(annotated, fd["canvas"], (80, 180, 255), "fl canvas")
    draw_rect(annotated, od["magnet"], (255, 160, 0), "orig magnet")
    draw_rect(annotated, fd["magnet"], (0, 220, 180), "fl magnet")
    draw_rect(annotated, od["compass"], (255, 160, 0), "orig compass")
    draw_rect(annotated, fd["compass"], (0, 220, 180), "fl compass")
    draw_rect(annotated, od["controlPanel"], (255, 80, 200), "orig panel")
    draw_rect(annotated, fd["controlPanel"], (180, 80, 255), "fl panel")
    draw_rect(annotated, od["resetCircle"], (255, 200, 0), "orig reset")
    draw_rect(annotated, fd["resetCircle"], (255, 255, 0), "fl reset")
    annotated.save(SHOT / "overlay_annotated_rects.png")

    orig_play = crop_logical(orig_img, od["canvas"])
    flut_play = crop_logical(flut_img, fd["canvas"])
    rgb = {
        "note": "Auxiliary only. Do not optimize these numbers. Debug original overflow stripes may be in-frame.",
        "png_size_px": {"original": list(orig_img.size), "flutter": list(flut_img.size)},
        "original_full_screen": mean_rgb(orig_img),
        "original_play_area": mean_rgb(orig_play),
        "flutter_full_screen": mean_rgb(flut_img),
        "flutter_play_area": mean_rgb(flut_play),
    }

    orig_meter = ORIG_FIELD_METER
    flut_meter = fm["fieldMeter"]

    rows = [
        row(
            "simulation canvas",
            od["canvas"],
            fd["canvas"],
            "SOURCE-ALIGNED / LAYOUT-DIFFERENT",
            "Original canvas = full window. Flutter = NineGrid center after AppBar 44. Engineering chrome.",
        ),
        row(
            "magnet",
            od["magnet"],
            fd["magnet"],
            "VISUALLY ALIGNED",
            "Window center (0.42W, 0.50H). Size 500×128. Δx=Δy=Δw=Δh=0.",
            extra={"flutter_canvas_local": rect_round(fd["magnet_canvasLocal"])},
        ),
        row(
            "compass",
            od["compass"],
            fd["compass"],
            "VISUALLY ALIGNED",
            "Window center (0.60W, 0.66H). Size 152×152. Vector vs magnet (230.4, 128).",
            extra={"flutter_canvas_local": rect_round(fd["compass_canvasLocal"])},
        ),
        row(
            "field meter",
            orig_meter,
            flut_meter,
            "VISUALLY ALIGNED",
            "Window center (0.28W, 0.30H). Size 260×192. Magnet−Meter (179.2, 160). Finder on original hits B= text; rect is source geometry.",
            extra={
                "original_text_finder": rect_round(om["fieldMeterText"]),
                "flutter_canvas_local": rect_round(fm["fieldMeter_canvasLocal"]),
            },
        ),
        row(
            "control panel",
            od["controlPanel"],
            fd["controlPanel"],
            "SOURCE-ALIGNED / LAYOUT-DIFFERENT",
            "Same 230×298 and canvas-local top:12 right:12. Window origin follows NineGrid center.",
            extra={"flutter_canvas_local": rect_round(fd["controlPanel_canvasLocal"])},
        ),
        row(
            "reset",
            od["resetCircle"],
            fd["resetCircle"],
            "SOURCE-ALIGNED / LAYOUT-DIFFERENT",
            "Circle 52×52 restored. Slot remains NineGrid.bottomRight. right inset 18; bottom inset limited by side cell (~9.7). Δy≈+8.3 vs full-window bottom:18.",
        ),
        row(
            "appBar / chrome",
            {"x": 0, "y": 0, "w": 0, "h": 0, "cx": 0, "cy": 0},
            fd["appBar"],
            "SOURCE-ALIGNED / LAYOUT-DIFFERENT",
            "Original SimulationPage has no AppBar. Flutter AppBar 1280×44 #1565C0. Home not wired; leading back absent in this capture.",
        ),
        row(
            "Flip Polarity button",
            od["flipPolarity"],
            fd["flipPolarity"],
            "VISUALLY ALIGNED",
            "Same 208×48. Window delta equals panel delta (follows canvas origin).",
        ),
        row(
            "slider",
            od["slider"],
            fd["slider"],
            "VISUALLY ALIGNED",
            "Both 164×14. Flutter overflow 0 after M5-3 FittedBox. Original still overflowed by 55px (Legacy A).",
        ),
        row(
            "label Magnetic Field (B)",
            od["labelMagneticField"],
            fd["labelMagneticField"],
            "SOURCE-ALIGNED / LAYOUT-DIFFERENT",
            "FittedBox scaleDown: 184×14.7 vs original 238.5×19 (overflow). Intentional engineering adaptation.",
        ),
        row(
            "label Bar Magnet",
            od["labelBarMagnet"],
            fd["labelBarMagnet"],
            "VISUALLY ALIGNED",
            "Same 142.5×20. Window position follows panel.",
        ),
        row(
            "checkbox Magnetic Field (B)",
            od["checkbox_0"],
            fd["checkbox_0"],
            "MATERIAL DIFFERENCE",
            "20×20 shrinkWrap both. Original ThemeData.dark() vs Flutter Material 3 light.",
        ),
        row(
            "arrow buttons",
            od["btnArrowLeft"],
            fd["btnArrowLeft"],
            "VISUALLY ALIGNED",
            "22×22 source; measured icon follows panel.",
        ),
        row(
            "AppBar title font",
            {"x": 0, "y": 0, "w": 0, "h": 0, "cx": 0, "cy": 0},
            fd.get("labelAppBarTitle", {"x": 0, "y": 0, "w": 0, "h": 0, "cx": 0, "cy": 0}),
            "FONT DIFFERENCE",
            "CJK title 磁铁与罗盘 uses platform fallback (e.g. Microsoft YaHei). Latin panel/magnet labels unspecified → Roboto both sides.",
        ),
        row(
            "Earth",
            {"x": 0, "y": 0, "w": 0, "h": 0, "cx": 0, "cy": 0},
            {"x": 0, "y": 0, "w": 0, "h": 0, "cx": 0, "cy": 0},
            "BLOCKED",
            "BLOCKED: missing earth.svg. Checkbox not tapped. No substitute asset.",
        ),
        row(
            "magnet moved (Flutter only)",
            fd["magnet"],
            moved["magnet"],
            "VISUALLY ALIGNED",
            "Drag Offset(-140, 70) from body. Center 537.6,400 → 397.6,470. Drag semantics unchanged.",
        ),
    ]

    matrix = {
        "phase": "M5-FINAL Magnet Visual QA",
        "date": "2026-08-31",
        "implementation_changes": 0,
        "environment": rects["environment"],
        "overflow": {
            "original": rects["overflow"]["original"],
            "flutter": rects["overflow"]["flutter"],
            "note": "Original still overflowed by 55px (Legacy A). Flutter 0 after M5-3.",
        },
        "earth": {
            "status": "BLOCKED: missing earth.svg",
            "tapped": False,
            "asset": "assets/earth.svg",
        },
        "electromagnet": "BLOCKED",
        "mean_rgb": rgb,
        "rows": rows,
        "locked_business": [
            "MagneticField.compute unmodified",
            "MagnetState unmodified",
            "CompassPainter unmodified",
            "reset semantics unmodified",
            "drag semantics unmodified",
            "Home not wired",
            "Legacy not deleted",
        ],
    }
    (DIR / "matrix.json").write_text(
        json.dumps(matrix, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    (DIR / "mean_rgb.json").write_text(
        json.dumps(rgb, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    print("wrote", DIR / "matrix.json")
    print("rgb", json.dumps(rgb, indent=2))


if __name__ == "__main__":
    main()
