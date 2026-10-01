"""Decay 首屏：原版截图量测 + 与 Flutter 叠图 / 差异图。

原版 PNG：1024×672（PhET LAYOUT_BOUNDS 1024×618 + joist 底栏 ≈54）。
Flutter PNG：Pixel Tablet 2560×1600 @ DPR 2 → 逻辑 1280×800。
"""
from __future__ import annotations

import json
import os
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageEnhance, ImageStat

DIR = Path(__file__).resolve().parent
ORIG = DIR / "original_decay_screen1.png"
ORIG_TABS = DIR / "original_decay_tabs.png"
FLUTTER_EMPTY = DIR / "flutter_decay_empty.png"
FLUTTER_FE = DIR / "flutter_decay_fe69.png"
FE_JSON = DIR / "flutter_decay_fe69_rects.json"
EMPTY_JSON = DIR / "flutter_decay_empty_rects.json"

# 原版设计坐标（LAYOUT_BOUNDS 1024×618，截图 y=0 对齐 play area 顶）
LAYOUT_W, LAYOUT_H = 1024, 618
NAV_H = 54  # 672-618
ATOM_CX = LAYOUT_W / 3
ATOM_CY = LAYOUT_H * 0.55
HL_LEFT = 15 + 30
HL_Y = 15 + 80
PANEL_RIGHT = LAYOUT_W - 15
PANEL_TOP = 15
RESET_RIGHT = LAYOUT_W - 15
RESET_BOTTOM = LAYOUT_H - 15
CREATOR_CX = ATOM_CX
CREATOR_BOTTOM = LAYOUT_H - 15
HL_WIDTH = 550


def load(p: Path) -> Image.Image:
    return Image.open(p).convert("RGB")


def row_luma(im: Image.Image, y: int) -> float:
    w, _ = im.size
    sl = im.crop((0, y, w, y + 1))
    return ImageStat.Stat(sl).mean[0] * 0.299 + ImageStat.Stat(sl).mean[1] * 0.587 + ImageStat.Stat(sl).mean[2] * 0.114


def find_black_footer(im: Image.Image) -> int:
    w, h = im.size
    for y in range(h - 1, h // 2, -1):
        if row_luma(im, y) > 40:
            return y + 1
    return h


def bbox_where(im: Image.Image, pred) -> tuple[int, int, int, int] | None:
    px = im.load()
    w, h = im.size
    minx, miny, maxx, maxy = w, h, -1, -1
    for y in range(h):
        for x in range(w):
            if pred(px[x, y]):
                if x < minx:
                    minx = x
                if y < miny:
                    miny = y
                if x > maxx:
                    maxx = x
                if y > maxy:
                    maxy = y
    if maxx < 0:
        return None
    return minx, miny, maxx - minx + 1, maxy - miny + 1


def is_near_black(c, maxv=35):
    return c[0] <= maxv and c[1] <= maxv and c[2] <= maxv


def is_orange_reset(c):
    r, g, b = c
    return r > 200 and 80 < g < 180 and b < 80 and r - g > 40


def is_panel_gray(c):
    r, g, b = c
    if max(r, g, b) - min(r, g, b) > 18:
        return False
    return 200 <= r <= 235


def is_nucleus_warm(c):
    r, g, b = c
    return r > 160 and g > 60 and b < 90 and r > g


def measure_original(im: Image.Image) -> dict:
    w, h = im.size
    footer_y = find_black_footer(im)
    play_h = footer_y
    footer = {"x": 0, "y": footer_y, "w": w, "h": h - footer_y, "cx": w / 2, "cy": (footer_y + h) / 2}

    # 右栏：从右侧找灰面板
    px = im.load()
    right_xs = []
    for y in range(20, min(play_h - 20, 500)):
        for x in range(w - 8, w // 2, -1):
            if is_panel_gray(px[x, y]):
                right_xs.append(x)
                break
    panel_right = max(right_xs) if right_xs else w - 15
    panel_left_candidates = []
    for y in range(20, 220):
        seen = False
        for x in range(w - 20, w // 2, -1):
            if is_panel_gray(px[x, y]):
                seen = True
            elif seen:
                panel_left_candidates.append(x + 1)
                break
    panel_left = int(sum(panel_left_candidates) / len(panel_left_candidates)) if panel_left_candidates else 820

    reset = bbox_where(im, is_orange_reset)

    # 核：play 区左中暖色
    nuc = None
    minx, miny, maxx, maxy = w, play_h, -1, -1
    for y in range(120, play_h - 80):
        for x in range(80, int(w * 0.62)):
            if is_nucleus_warm(px[x, y]):
                if x < minx:
                    minx = x
                if y < miny:
                    miny = y
                if x > maxx:
                    maxx = x
                if y > maxy:
                    maxy = y
    if maxx >= 0:
        nuc = {
            "x": minx,
            "y": miny,
            "w": maxx - minx + 1,
            "h": maxy - miny + 1,
            "cx": (minx + maxx) / 2,
            "cy": (miny + maxy) / 2,
        }

    design = {
        "page": {"x": 0, "y": 0, "w": w, "h": h, "cx": w / 2, "cy": h / 2},
        "playArea": {"x": 0, "y": 0, "w": LAYOUT_W, "h": LAYOUT_H, "cx": LAYOUT_W / 2, "cy": LAYOUT_H / 2},
        "footerNav": footer,
        "nucleusCenter_design": {"x": ATOM_CX, "y": ATOM_CY, "w": 0, "h": 0, "cx": ATOM_CX, "cy": ATOM_CY},
        "halfLife_design": {
            "x": HL_LEFT,
            "y": HL_Y,
            "w": HL_WIDTH,
            "h": 80,
            "cx": HL_LEFT + HL_WIDTH / 2,
            "cy": HL_Y + 40,
        },
        "rightPanel_measured": {
            "x": panel_left,
            "y": PANEL_TOP,
            "w": panel_right - panel_left,
            "h": 420,
            "cx": (panel_left + panel_right) / 2,
            "cy": PANEL_TOP + 210,
        },
        "reset_design": {
            "x": RESET_RIGHT - 40,
            "y": RESET_BOTTOM - 40,
            "w": 40,
            "h": 40,
            "cx": RESET_RIGHT - 20,
            "cy": RESET_BOTTOM - 20,
        },
        "generator_design": {
            "x": CREATOR_CX - 180,
            "y": CREATOR_BOTTOM - 90,
            "w": 360,
            "h": 90,
            "cx": CREATOR_CX,
            "cy": CREATOR_BOTTOM - 45,
        },
    }
    if reset:
        x, y, rw, rh = reset
        design["reset_measured"] = {"x": x, "y": y, "w": rw, "h": rh, "cx": x + rw / 2, "cy": y + rh / 2}
    if nuc:
        design["nucleus_measured"] = nuc
    design["meta"] = {
        "source": ORIG.name,
        "pixels": {"w": w, "h": h},
        "layoutBounds": {"w": LAYOUT_W, "h": LAYOUT_H},
        "navBarH": h - footer_y,
        "note": "截图像素 = 设计坐标（1 CSS px）。底栏为 joist，不在 LAYOUT_BOUNDS 内。",
    }
    return design


def scale_rect(r: dict, sx: float, sy: float) -> dict:
    return {
        "x": r["x"] * sx,
        "y": r["y"] * sy,
        "w": r["w"] * sx,
        "h": r["h"] * sy,
        "cx": r.get("cx", r["x"] + r["w"] / 2) * sx,
        "cy": r.get("cy", r["y"] + r["h"] / 2) * sy,
    }


def delta(a: dict | None, b: dict | None) -> dict | None:
    if not a or not b:
        return None
    return {
        "dx": round(b["x"] - a["x"], 1),
        "dy": round(b["y"] - a["y"], 1),
        "dw": round(b["w"] - a["w"], 1),
        "dh": round(b["h"] - a["h"], 1),
        "dcx": round(b.get("cx", 0) - a.get("cx", 0), 1),
        "dcy": round(b.get("cy", 0) - a.get("cy", 0), 1),
    }


def overlay_pair(a: Image.Image, b: Image.Image, size: tuple[int, int], out_overlay: Path, out_diff: Path) -> dict:
    aa = a.resize(size, Image.Resampling.LANCZOS)
    bb = b.resize(size, Image.Resampling.LANCZOS)
    ov = Image.blend(aa, bb, 0.5)
    ov.save(out_overlay)
    diff = ImageChops.difference(aa, bb)
    # 增强差异便于看
    boost = ImageEnhance.Brightness(diff).enhance(3.0)
    boost.save(out_diff)
    stat = ImageStat.Stat(diff)
    mean = sum(stat.mean) / 3
    return {"mean_abs_rgb": round(mean, 2), "size": {"w": size[0], "h": size[1]}}


def main() -> None:
    orig = load(ORIG)
    orig_meas = measure_original(orig)
    (DIR / "original_decay_rects.json").write_text(
        json.dumps(orig_meas, indent=2), encoding="utf-8"
    )

    report = {
        "viewports": {
            "original": {"w": orig.size[0], "h": orig.size[1], "dpr": 1, "note": "PhET 官网/运行截图 1024×672"},
            "flutter_target": {
                "label": "Pixel Tablet landscape",
                "physical": {"w": 2560, "h": 1600},
                "logical": {"w": 1280, "h": 800},
                "dpr": 2.0,
            },
        },
        "original_measured": orig_meas,
        "overlays": {},
        "normalized_1280x800": {},
    }

    sx, sy = 1280 / orig.size[0], 800 / orig.size[1]
    report["scale_orig_to_tablet"] = {"sx": sx, "sy": sy}

    if FLUTTER_EMPTY.exists():
        fe = load(FLUTTER_EMPTY)
        report["overlays"]["full_empty_vs_original"] = overlay_pair(
            orig,
            fe,
            (1280, 800),
            DIR / "overlay_50_empty.png",
            DIR / "diff_empty.png",
        )
    if FLUTTER_FE.exists():
        ff = load(FLUTTER_FE)
        report["overlays"]["full_fe69_vs_original"] = overlay_pair(
            orig,
            ff,
            (1280, 800),
            DIR / "overlay_50_fe69.png",
            DIR / "diff_fe69.png",
        )
        # play area：原版去底栏 vs Flutter 去 AppBar（用 JSON）
        if FE_JSON.exists():
            fj = json.loads(FE_JSON.read_text(encoding="utf-8"))
            report["flutter_fe69_rects_logical"] = fj
            app = fj["rects_logical"].get("appBar")
            tab = fj["rects_logical"].get("tabBar")
            chrome_h = 0
            if app:
                chrome_h = max(chrome_h, app["y"] + app["h"])
            if tab:
                chrome_h = max(chrome_h, tab["y"] + tab["h"])
            # Flutter 图是 2560×1600，逻辑×2
            crop_y = int(chrome_h * 2)
            play_f = ff.crop((0, crop_y, ff.size[0], ff.size[1]))
            play_o = orig.crop((0, 0, orig.size[0], orig_meas["footerNav"]["y"]))
            report["overlays"]["play_fe69_vs_original"] = overlay_pair(
                play_o,
                play_f,
                (1024, 618),
                DIR / "overlay_50_play.png",
                DIR / "diff_play.png",
            )
            report["flutter_chrome_h_logical"] = chrome_h

    (DIR / "decay_first_diff_report.json").write_text(
        json.dumps(report, indent=2), encoding="utf-8"
    )
    print(json.dumps({k: report[k] for k in ("viewports", "overlays", "flutter_chrome_h_logical") if k in report}, indent=2))
    print("wrote", DIR / "decay_first_diff_report.json")


if __name__ == "__main__":
    main()
