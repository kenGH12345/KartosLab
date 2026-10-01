# VISUAL_LAYOUT_BASELINE — Charges and Fields (Final Visual Closure v2)

> Layout = **1024 × 618** Joist bounds · MVT scale = 128 px/m · Y inverted  
> A = PhET navbar (ORIGINAL only) — do not fix  
> B = simulation content · **B-P1 = 0**

## ToolboxLayout (ChargesAndFieldsToolboxPanel)

| Param | Source | Flutter |
|---|---|---|
| panel xMargin | 12 | 12 |
| panel yMargin | 10 | 10 |
| VBox spacing | 20 | 20 |
| voltmeter circle R | 10 | 10 |
| outline scale | 0.5×6/25 = 0.12 | 0.12 × 499px width |
| tape unspooled | 30 view px | 30 |
| tape baseScale | 0.8 | 0.8 |
| tape Node.scale (icon) | 0.8 | 0.8 |
| tape png | measuringTape.png 51×51 | same · content pad 0 |
| tape anchor | **rightBottom** = basePosition | same |
| tape crosshairs | base + tip · #E05F20 · size 5 · lw 2 | same |

## Voltmeter (active sensor)

| Param | Source | Flutter | Notes |
|---|---|---|---|
| Measurement point | crosshair center | same | tip = model position |
| Circle R | 18 | 18 | lineWidth 3 |
| Outline scale | 1.55×73.6/w | width = 114.08 | |
| Readout | decimalAdjust + " V" | same | |
| Circle fill | getElectricPotentialColor(V, 0.5) | CafPotentialColors.forCircle | |

## Voltage color field

| Param | Source | Flutter |
|---|---|---|
| Renderer truth | WebGL: 1 px · NEAREST；Canvas: 0.1 m + drawImage | dense `2/viewScale` m · NEAREST |
| Color | \|V\|/40 float lerp + alpha | CafPotentialColors.forField |
| Sample | skip d=0 | same |
| **Y orientation** | Canvas `sy < 0`（row0=minY → screen bottom） | Image row0 = **maxY**（top-first） |
| Model | Potential Model only | painter 不重算 V |

## Equipotential

| Param | Source | Flutter |
|---|---|---|
| Stroke | Path default ~1 · #32FF64 | strokeWidth 1 · butt/miter |
| Generation | ElectricPotentialLine.ts | ported model |
| Label | \|V\|<1 → toFixed(2) else toFixed(1) | absFixedVoltage |

## Component layout table

| Component | Original note | Flutter | Anchor | Delta |
|---|---|---|---|---|
| Tape toolbox icon | rightBottom + base/tip cross | same geometry | rightBottom | abs Y：A/FittedBox P2 |
| Voltage field | WebGL smooth glow | dense NEAREST | dest enlargedBounds | color match after Y-fix |
| Equipotential | thin green Path | same | MVT | overlap ~98% green px |

## Diff attribution (B content)

| State / crop | Verdict |
|---|---|
| tape geom | PASS / P2（壳+十字对齐；整帧位差 A） |
| voltage near charge | PASS（RGB 量级对齐） |
| equipotential center | PASS |
| 01 content_no_nav | mean ≈ 6.8（A 噪声） |
