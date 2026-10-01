"""FINAL-VISUAL-REMEASURE: affine Flutter play → 1024×618. No lib changes."""
from __future__ import annotations

import json
from pathlib import Path

DIR = Path(__file__).resolve().parent
DECAY = DIR / "decay-first"
CHART = DIR / "chart-intro"

LAYOUT_W, LAYOUT_H = 1024.0, 618.0
FLUTTER_W, FLUTTER_H = 1280.0, 800.0
CHROME_H = 108.0
PLAY_H = FLUTTER_H - CHROME_H
SX = LAYOUT_W / FLUTTER_W
SY = LAYOUT_H / PLAY_H


def play_map(r: dict) -> dict:
    return {
        "x": round((r["x"]) * SX, 1),
        "y": round((r["y"] - CHROME_H) * SY, 1),
        "w": round(r["w"] * SX, 1),
        "h": round(r["h"] * SY, 1),
        "cx": round((r.get("cx", r["x"] + r["w"] / 2)) * SX, 1),
        "cy": round((r.get("cy", r["y"] + r["h"] / 2) - CHROME_H) * SY, 1),
    }


def dlt(o: dict, f: dict) -> dict:
    return {
        "dx": round(f["x"] - o["x"], 1),
        "dy": round(f["y"] - o["y"], 1),
        "dw": round(f["w"] - o["w"], 1),
        "dh": round(f["h"] - o["h"], 1),
        "dcx": round(f.get("cx", 0) - o.get("cx", o["x"] + o["w"] / 2), 1),
        "dcy": round(f.get("cy", 0) - o.get("cy", o["y"] + o["h"] / 2), 1),
    }


def row(screen, name, orig, mapped, cls, note=""):
    delta = dlt(orig, mapped) if orig and mapped else {}
    return {
        "screen": screen,
        "component": name,
        "original": orig,
        "flutter_mapped": mapped,
        **delta,
        "classification": cls,
        "note": note,
    }


def main() -> None:
    fe = json.loads((DECAY / "flutter_decay_fe69_rects.json").read_text(encoding="utf-8"))
    empty = json.loads((DECAY / "flutter_decay_empty_rects.json").read_text(encoding="utf-8"))
    r = fe["rects_logical"]
    e = empty["rects_logical"]
    m = {k: play_map(v) for k, v in r.items()}

    orig = {
        "play": {"x": 0, "y": 0, "w": 1024, "h": 618, "cx": 512, "cy": 309},
        "nucleus": {"x": 341.3, "y": 339.9, "w": 0, "h": 0, "cx": 341.3, "cy": 339.9},
        "generator": {"x": 161.3, "y": 513, "w": 360, "h": 90, "cx": 341.3, "cy": 558},
        "halfLife": {"x": 45, "y": 95, "w": 550, "h": 80, "cx": 320, "cy": 135},
        "counters": {"x": 687, "y": 15, "w": 140, "h": 50, "cx": 757, "cy": 40},
        "element": {"x": 250, "y": 193, "w": 140, "h": 24, "cx": 320, "cy": 205},
        "stability": {"x": 265, "y": 133, "w": 110, "h": 24, "cx": 320, "cy": 145},
        "symbol": {"x": 859, "y": 15, "w": 150, "h": 120, "cx": 934, "cy": 75},
        "decays": {"x": 687, "y": 145, "w": 322, "h": 360, "cx": 848, "cy": 325},
        "reset": {"x": 969, "y": 563, "w": 40, "h": 40, "cx": 989, "cy": 583},
        "ecloud": {"x": 687, "y": 575, "w": 180, "h": 28, "cx": 777, "cy": 589},
        "right": {"x": 687, "y": 15, "w": 322, "h": 490, "cx": 848, "cy": 260},
        "addProton": {"x": 0, "y": 0, "w": 28, "h": 24, "cx": 14, "cy": 12},
        "addPair": {"x": 0, "y": 0, "w": 42, "h": 24, "cx": 21, "cy": 12},
    }

    gen_bottom_orig = orig["generator"]["y"] + orig["generator"]["h"]
    gen_bottom_fl = m["nucleonCreators"]["y"] + m["nucleonCreators"]["h"]

    rows = [
        row("Decay", "play area", orig["play"], orig["play"], "[视觉已对齐]", "参考框"),
        row("Decay", "nucleus", orig["nucleus"], m["nucleusCenter"], "[视觉已对齐]",
            "Δcx=0 resolved；Δcy 来自 NineGrid 画布高，公式 canvasH×0.55 不重开"),
        row("Decay", "generator", orig["generator"], m["nucleonCreators"], "[视觉已对齐]",
            f"Δcx=0 resolved；bottom orig={gen_bottom_orig:.1f} fl={gen_bottom_fl:.1f}"),
        row("Decay", "Half-Life", orig["halfLife"], m["halfLifeInformation"], "[有意差异：NineGrid]",
            "拉满中心格；冻结中心 X 仍 320"),
        row("Decay", "counters", orig["counters"], m["protonCount"], "[有意差异：NineGrid]",
            "midRight 窄列；proton 行代表"),
        row("Decay", "Element", orig["element"], m["elementName"], "[视觉已对齐]",
            "cx=320 resolved（半衰期冻结中心，≠ atom 341.3）"),
        row("Decay", "Stability", orig["stability"], m["stability"], "[视觉已对齐]",
            "cx=320 与 Element 同 X"),
        row("Decay", "symbol", orig["symbol"], m["symbol"], "[有意差异：NineGrid]"),
        row("Decay", "Available Decays", orig["decays"], m["availableDecaysPanel"], "[有意差异：NineGrid]"),
        row("Decay", "Reset", orig["reset"], m["reset"], "[视觉近似]"),
        row("Decay", "Undo", None, None, "[有意差异：Material]",
            "Fe-69 无 Undo；出现时为 Icons.undo 非黄 ReturnButton"),
        row("Decay", "Electron Cloud", orig["ecloud"], m["electronCloudCheckbox"], "[有意差异：NineGrid]"),
        row("Decay", "right column", orig["right"], m["decayRightColumn"], "[有意差异：NineGrid]"),
        row("Decay", "addProton button", orig["addProton"], {
            "x": r["addProton"]["w"], "y": r["addProton"]["h"],
            "w": r["addProton"]["w"], "h": r["addProton"]["h"],
            "cx": r["addProton"]["w"] / 2, "cy": r["addProton"]["h"] / 2,
        }, "[视觉已对齐]", "逻辑 28×24 未变（P5-2 只换 Path）"),
        row("Decay", "addPair button", orig["addPair"], {
            "x": r["addPair"]["w"], "y": r["addPair"]["h"],
            "w": r["addPair"]["w"], "h": r["addPair"]["h"],
            "cx": r["addPair"]["w"] / 2, "cy": r["addPair"]["h"] / 2,
        }, "[视觉已对齐]", "逻辑 42×24 未变"),
    ]

    zoom = json.loads((CHART / "flutter_chart_intro_c12_zoom.json").read_text(encoding="utf-8"))
    partial = json.loads((CHART / "flutter_chart_intro_c12_partial.json").read_text(encoding="utf-8"))
    dialog = json.loads((CHART / "flutter_chart_intro_c12_dialog.json").read_text(encoding="utf-8"))
    z = zoom["rects_logical"]
    p = partial["rects_logical"]

    chart_rows = [
        {
            "screen": "Chart Intro",
            "component": "play / screen bg",
            "original": "WHITE",
            "flutter": "#FFFFFF",
            "classification": "[视觉已对齐]",
            "note": "C-12 取样 var=0；无原版 PNG",
        },
        {
            "screen": "Chart Intro",
            "component": "Shell / mini-atom / chart / periodic / symbol / element",
            "original": "绝对定位 1024×618",
            "flutter_raw": {k: z.get(k) for k in (
                "element", "chart", "periodicTable", "isotopeSymbol",
                "decayEquation", "decayButton", "fullChart", "partial", "zoom", "reset",
            )},
            "classification": "[有意差异：NineGrid]",
            "note": "右栏约 104.5 宽；无原版截图，不造叠图",
        },
        {
            "screen": "Chart Intro",
            "component": "Focused",
            "original": "fill 不变，窗外 0.65，框 1.5",
            "flutter": "同配方；无独立 Focused 整页 PNG（Zoom 帧含 focused 子图）",
            "classification": "[视觉已对齐]",
            "note": "源码几何；C-12 Zoom 有 chart 盒",
        },
        {
            "screen": "Chart Intro",
            "component": "Equation",
            "original": "minHeight 30 为下限",
            "flutter": z.get("decayEquation"),
            "classification": "[待确认]",
            "note": "C-12 稳定无箭。衰变核素 A/Z 列可 overflow 30（已知）",
        },
        {
            "screen": "Chart Intro",
            "component": "Radio Partial/Zoom",
            "original": "缩微核素图，fill #F1FAFE",
            "flutter": {"partial": p.get("partial"), "zoom": z.get("zoom")},
            "classification": "[有意差异：Material]",
            "note": "fill 已齐；图标是字",
        },
        {
            "screen": "Chart Intro",
            "component": "Full Chart dialog",
            "original": "INFO_DIALOG 无 fill（可能白）",
            "flutter": dialog.get("rects_logical", {}).get("fullChartTitle"),
            "classification": "[待确认]",
            "note": "底 #FFFEF4 未改；有 C-12 dialog PNG",
        },
    ]

    out = {
        "step": "FINAL-VISUAL-REMEASURE",
        "code_changed": False,
        "normalization": {
            "sx": SX,
            "sy": SY,
            "chrome_h": CHROME_H,
            "play": {"x": 0, "y": CHROME_H, "w": FLUTTER_W, "h": PLAY_H},
        },
        "p5_2_side_effects": {
            "generator_logical": r["nucleonCreators"],
            "addProton": r["addProton"],
            "addPair": r["addPair"],
            "empty_generator": e["nucleonCreators"],
            "parent_bounds_changed": False,
            "hit_area_box": "28×24 / 42×24 与 P2-5 相同",
        },
        "decay_rows": rows,
        "chart_rows": chart_rows,
    }
    dest = DIR / "final_remeasure_matrix.json"
    dest.write_text(json.dumps(out, indent=2, ensure_ascii=False), encoding="utf-8")
    print("sx", SX, "sy", SY)
    for row_i in rows:
        print(
            f"{row_i['component']:22} "
            f"dx={row_i.get('dx')} dy={row_i.get('dy')} "
            f"dw={row_i.get('dw')} dh={row_i.get('dh')} "
            f"dcx={row_i.get('dcx')} dcy={row_i.get('dcy')} "
            f"{row_i['classification']}"
        )
    print("wrote", dest)


if __name__ == "__main__":
    main()
