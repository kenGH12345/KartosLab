# ANDROID_ZH_CJK_REPORT

> PHASE 8 · Pixel Tablet emulator-5554 · Android 15 / API 35 · density 320 · landscape

## Verdict

**PASS** (P2 only: Material Back tooltip English)

## Evidence

| Check | Result | Evidence |
|---|---|---|
| App title CJK | PASS | `01_home.png` / cold-start `05_cold_start_no_impeller.png` — 「Kratos 仿真实验室」 |
| Category headers | PASS | 「物理」「化学」「力学」 |
| Card titles / subtitles | PASS | Full mechanics + chemistry grids Chinese |
| Scientific symbols | PASS | χ² on 曲线拟合; pH retained; N/S poles; units µm / K / kg/m³ in sim screens |
| Overflow / clipping | PASS | Long titles e.g. 「万有引力实验室：基础」 fit cards |
| Missing glyphs / tofu | PASS | None observed |
| Narrow / density | PASS | density=320 tablet landscape; no collapse |

## P2

- System `BackButton` accessibility tooltip remains English `"Back"` (Flutter Material default). User-facing titles/labels Chinese.
