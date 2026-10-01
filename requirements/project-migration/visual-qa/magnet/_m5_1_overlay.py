"""M5-1: overlay / diff / mean RGB / visual matrix. Measurement only."""
from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageEnhance, ImageStat

DIR = Path(__file__).resolve().parent
SHOT = DIR / "screenshots"
DPR = 2.0

# Original field meter panel is 260×192, center = (0.28W, 0.30H) of full canvas.
# Widget finder only hit the "B =" text; this is source geometry.
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
    return {"r": m[0], "g": m[1], "b": m[2], "hex": "#{:02X}{:02X}{:02X}".format(*(int(round(v)) for v in m))}


def delta(orig: dict, fl: dict) -> dict:
    return {
        "dx": r1(fl["x"] - orig["x"]),
        "dy": r1(fl["y"] - orig["y"]),
        "dw": r1(fl["w"] - orig["w"]),
        "dh": r1(fl["h"] - orig["h"]),
        "dcx": r1(fl["cx"] - orig["cx"]),
        "dcy": r1(fl["cy"] - orig["cy"]),
    }


def row(component, priority, orig, fl, classification, notes, extra=None):
    d = delta(orig, fl)
    out = {
        "component": component,
        "priority": priority,
        "original_rect": rect_round(orig),
        "flutter_rect": rect_round(fl),
        "dx": d["dx"],
        "dy": d["dy"],
        "dw": d["dw"],
        "dh": d["dh"],
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

    orig_img = Image.open(SHOT / "original_default.png")
    flut_img = Image.open(SHOT / "flutter_default.png")
    orig_m = Image.open(SHOT / "original_field_meter.png")
    flut_m = Image.open(SHOT / "flutter_field_meter.png")

    # Window-aligned overlay / diff (same Pixel Tablet 2560×1600).
    overlay(orig_img, flut_img).save(SHOT / "overlay_default.png")
    diff_amp(orig_img, flut_img).save(SHOT / "diff_default.png")
    overlay(orig_m, flut_m).save(SHOT / "overlay_field_meter.png")
    diff_amp(orig_m, flut_m).save(SHOT / "diff_field_meter.png")

    # Canvas-normalized: scale Flutter center slot to original full canvas.
    orig_canvas = crop_logical(orig_img, od["canvas"])
    flut_canvas = crop_logical(flut_img, fd["canvas"])
    flut_canvas_scaled = flut_canvas.resize(orig_canvas.size, Image.Resampling.BILINEAR)
    overlay(orig_canvas, flut_canvas_scaled).save(SHOT / "overlay_canvas_normalized.png")
    diff_amp(orig_canvas, flut_canvas_scaled).save(SHOT / "diff_canvas_normalized.png")

    # Component crops (debug overflow stripes included — not a release visual).
    crop_logical(orig_img, od["controlPanel"]).save(SHOT / "original_control_panel.png")
    crop_logical(flut_img, fd["controlPanel"]).save(SHOT / "flutter_control_panel.png")
    crop_logical(orig_img, od["resetCircle"]).save(SHOT / "original_reset.png")
    crop_logical(flut_img, fd["resetCircle"]).save(SHOT / "flutter_reset.png")
    crop_logical(orig_img, od["compass"]).save(SHOT / "original_compass.png")
    crop_logical(flut_img, fd["compass"]).save(SHOT / "flutter_compass.png")
    crop_logical(orig_img, od["magnet"]).save(SHOT / "original_magnet.png")
    crop_logical(flut_img, fd["magnet"]).save(SHOT / "flutter_magnet.png")

    # Annotated overlay of both rect systems.
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
        "note": "Auxiliary only. Do not optimize these numbers. Debug overflow stripes are in-frame.",
        "png_size_px": {"original": list(orig_img.size), "flutter": list(flut_img.size)},
        "original_full_screen": mean_rgb(orig_img),
        "original_play_area": mean_rgb(orig_play),
        "flutter_full_screen": mean_rgb(flut_img),
        "flutter_play_area": mean_rgb(flut_play),
    }

    mapping = {
        "original_coordinate_system": {
            "origin": "window top-left = Scaffold body top-left",
            "canvas": "full window 1280×800 (no AppBar, no NineGrid)",
            "unit": "1 logical px = 1 MagneticField unit",
            "chrome": "none",
            "play_area": "canvas = window",
        },
        "flutter_center_slot_coordinate_system": {
            "origin_window": "window top-left includes AppBar",
            "appBar_h": 44.0,
            "nineGrid_body": {"x": 0.0, "y": 44.0, "w": 1280.0, "h": 756.0},
            "canvas_origin_in_window": {
                "x": r1(fd["canvas"]["x"]),
                "y": r1(fd["canvas"]["y"]),
            },
            "canvas_size": {
                "w": r1(fd["canvas"]["w"]),
                "h": r1(fd["canvas"]["h"]),
            },
            "unit": "1 canvas logical px = 1 MagneticField unit (unchanged formula)",
            "window_from_canvas_local": "window = canvas_origin + canvas_local",
        },
        "fraction_mapping": {
            "rule": "init positions use the same fractions of *current canvas*, not of the window",
            "magnet_center": "0.42W × 0.50H of canvas",
            "compass_center": "0.60W × 0.66H of canvas",
            "field_meter_center": "0.28W × 0.30H of canvas",
            "sizes_do_not_scale": [
                "magnet 500×128",
                "compass diameter 152",
                "field meter 260×192",
                "control panel width 230",
                "reset 52×52 (Flutter bottomRight clips height)",
            ],
        },
    }

    orig_meter = ORIG_FIELD_METER
    flut_meter = fm["fieldMeter"]

    rows = [
        row(
            "simulation canvas",
            "P0",
            od["canvas"],
            fd["canvas"],
            "[有意差异：NineGrid]",
            "Original canvas = full 1280×800. Flutter canvas = NineGrid center after AppBar 44. side=√0.7.",
        ),
        row(
            "magnet",
            "P0",
            od["magnet"],
            fd["magnet"],
            "[源码一致但布局不同]",
            "Hard size 500×128 unchanged (Δw=Δh=0). Center stays 0.42/0.50 of *canvas*, so window origin shifts. Do not change BarMagnetPainter.",
            extra={
                "flutter_canvas_local": rect_round(fd["magnet_canvasLocal"]),
                "original_as_canvas_local": rect_round(od["magnet"]),
            },
        ),
        row(
            "compass",
            "P0",
            od["compass"],
            fd["compass"],
            "[源码一致但布局不同]",
            "Hard size 152×152 unchanged. Center stays 0.60/0.66 of canvas. CompassPainter unmodified.",
            extra={"flutter_canvas_local": rect_round(fd["compass_canvasLocal"])},
        ),
        row(
            "control panel",
            "P1",
            od["controlPanel"],
            fd["controlPanel"],
            "[源码一致但布局不同]",
            "Same 230×298 and Positioned(top:12, right:12) relative to parent. Parent changed from full screen to center slot.",
            extra={"flutter_canvas_local": rect_round(fd["controlPanel_canvasLocal"])},
        ),
        row(
            "field meter",
            "P1",
            orig_meter,
            flut_meter,
            "[源码一致但布局不同]",
            "Same 260×192. Center 0.28/0.30 of canvas. Original rect is source geometry (finder hit B= text only).",
            extra={
                "original_text_finder": rect_round(om["fieldMeterText"]),
                "flutter_canvas_local": rect_round(fm["fieldMeter_canvasLocal"]),
            },
        ),
        row(
            "reset",
            "P1",
            od["resetCircle"],
            fd["resetCircle"],
            "[有意差异：NineGrid]",
            "Original Positioned(right:18, bottom:18) 52×52 on full Stack. Flutter NineGrid bottomRight + Center + padding 8. Measured height 45.7 because sideH≈61.7 < 52+16.",
        ),
        row(
            "appBar / chrome",
            "P1",
            {"x": 0, "y": 0, "w": 0, "h": 0, "cx": 0, "cy": 0},
            fd["appBar"],
            "[有意差异：NineGrid]",
            "Original has no AppBar. Flutter AppBar 1280×44 #1565C0 title 磁铁与罗盘. Capture is MaterialApp.home so leading back is absent (Home not wired).",
        ),
        row(
            "Flip Polarity button",
            "P2",
            od["flipPolarity"],
            fd["flipPolarity"],
            "[源码一致但布局不同]",
            "Same 208×48 inside the 230 panel. Window delta equals panel delta.",
        ),
        row(
            "slider",
            "P2",
            od["slider"],
            fd["slider"],
            "[已有问题：Legacy implementation]",
            "Both debug layouts overflowed by 55 pixels. Inner width 208, arrows 44, Slider min ~219. Do not fix in M5-1.",
        ),
        row(
            "label Strength",
            "P2",
            od["labelStrength"],
            fd["labelStrength"],
            "[源码一致但布局不同]",
            "Same 12px label inside panel; window position follows panel.",
        ),
        row(
            "label Bar Magnet",
            "P2",
            od["labelBarMagnet"],
            fd["labelBarMagnet"],
            "[源码一致但布局不同]",
            "Same 14px title inside panel.",
        ),
        row(
            "checkbox Magnetic Field (B)",
            "P2",
            od["checkbox_0"],
            fd["checkbox_0"],
            "[有意差异：Material]",
            "20×20 shrinkWrap both. Original ThemeData.dark() vs Flutter Material 3 light seed 0xFF1177AA.",
        ),
        row(
            "arrow buttons",
            "P2",
            od["btnArrowLeft"],
            fd["btnArrowLeft"],
            "[源码一致但布局不同]",
            "Source 22×22 InkWell boxes; measured icon 20×20. Follows panel.",
        ),
        row(
            "Earth",
            "P2",
            {"x": 0, "y": 0, "w": 0, "h": 0, "cx": 0, "cy": 0},
            {"x": 0, "y": 0, "w": 0, "h": 0, "cx": 0, "cy": 0},
            "[无法验证：missing earth.svg]",
            "Earth checkbox not tapped. No substitute asset generated. No screenshot.",
        ),
    ]

    matrix = {
        "phase": "M5-1 Magnet Visual Baseline",
        "date": "2026-08-31",
        "implementation_changes": 0,
        "environment": rects["environment"],
        "overflow": rects["overflow"],
        "earth": rects["earth"],
        "coordinate_mapping": mapping,
        "mean_rgb": rgb,
        "rows": rows,
        "locked_business": [
            "MagneticField.compute unmodified",
            "MagnetState unmodified",
            "CompassPainter unmodified",
            "reset semantics unmodified",
            "drag semantics unmodified",
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
