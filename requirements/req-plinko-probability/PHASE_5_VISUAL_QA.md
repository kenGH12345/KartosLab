# PHASE 5 — Visual QA · Plinko Probability

> 日期：2026-09-16  
> Behavior Reference：**local 1.2.0-dev.6**  
> Visual Reference：**published latest**（本地 unbuilt HTML 不可独立运行）

## Renderer probe

| metric | value |
|---|---|
| canvas | 2 |
| svg | 5 |
| Ready | `phet.joist.sim.currentScreenProperty.value.model` |
| Forbidden | `waitForSelector('canvas')` alone |

## Matrix

21 states × ORIGINAL + FLUTTER + DIFF（见 `visual-qa/`）

Tools:

- `tool/probe_plinko_probability.js`
- `tool/capture_plinko_probability_original.js`
- `tool/recapture_plinko_lab_geometry.js`
- `tool/diff_plinko_visual_qa.py`（全帧）
- `tool/diff_plinko_content_crop.py`（**内容区 crop · 排除 navbar**）
- `test/plinko_probability/visual_qa/plinko_visual_qa_capture_test.dart`

## Capture alignment（本轮）

- ORIGINAL navbar ≈ y=737 @ 1280×800（高 63px）
- FLUTTER：内容 letterbox 至 1280×737 + 底部黑条 + `ClipRect`；`FontLoader(Arial)`
- Content-crop：两侧裁到 navbar_top 后同尺寸 Diff → **归因 B 类**

## Diff summary

### Full-frame（含 A/navbar）

Intro ~27 · Lab ~44–46（navbar + shell 权重大，**不作通过标准**）

### Content-crop（B 类）

| band | mean_abs_diff | notes |
|---|---|---|
| Intro initial/reset | ~23.9 | radio 竖排后 panel 区改善 |
| Intro with balls | ~24–26 | |
| Intro counterMode | ~33.2 | histogram 区仍高 |
| Lab | ~33–38 | hist / NumberControl 主导 |

区域 avg（21 states）：

| region | avg mean_abs |
|---|---|
| cylinders_hist | ~56 |
| board_pegs | ~35 |
| bottom_chrome | ~43 |
| right_panel | ~23 |
| hopper_mode | ~19 |

## Diff Attribution

### A — KARTOSLAB global shell（不改）

- `KratosTabbedScreen` top bar vs PhET navbar/home icons（capture 已 letterbox 底部 navbar 对齐）
- App chrome padding / safe area

### B — Plinko content（须清 P1）

| Item | Status | Notes |
|---|---|---|
| Peg grid count / spacing | **PASS (model)** | GaltonBoard 已测 |
| Peg rotation angle | **PASS (code)** | `-(π/4)+p·(π/2)` |
| Peg shadow | **PARTIAL** | 多 stop 径向渐变；非 toImage 位图 |
| Board triangle + hopper | **PARTIAL** | 比例接近；阴影/渐变仍偏 |
| Cylinder perspective | **PARTIAL** | 5-stop + darker/brighter；椭圆描边仍粗 |
| Counter ↔ Cylinder | **PASS (behavior)** | |
| Path trajectory | **PASS (model)** | Bernoulli 预采样 |
| Ball shaded sphere | **PASS** | |
| Intro ×1/×10/×100 竖排 | **improved** | VerticalAqua 布局 |
| Lab hopperMode 竖排 | **improved** | 无 Panel 框；半径/间距仍偏 |
| Lab PegControls white panel | **improved** | fill=white；NumberControl 未齐 |
| Lab histogram axes Bin/Count | **P1** | 标签有；刻度/缩放 vs ORIGINAL 仍偏 |
| Statistics chrome | **improved** | 去粉头；折叠钮未齐 |
| Intro ×All vs ×100 | **A/B note** | published=`×All`；local=`×`+maxBallsIntro |

## Major Geometry Gate

| Gate | Result |
|---|---|
| Peg Grid | improved |
| Cylinder | improved（仍 P1） |
| Counter / Histogram | improved（仍 P1） |
| Board | improved |
| Balls | PASS |
| Path | PASS logic |
| Controls | improved（竖排 radio） |
| Statistics | improved chrome |
| Probability Ideal | PASS |

## Visual Gate verdict

**NOT READY** — Final B-P1 v2 后 content-crop overall ~29.5；`board_pegs` 改善，但 Histogram / NumberControl packing / Cylinder 仍有 B-P1。

禁止 Home 接入。
