# PHASE 2 — VIEWPORT REPORT

| Item | Value | Evidence |
| ---- | ----- | -------- |
| Layout width | **1024** | Joist `ScreenView.DEFAULT_LAYOUT_BOUNDS` (WOAS does not override) |
| Layout height | **618** | same |
| Play fill | `#FFFFB7` | `WOASColors.backgroundColorProperty` |
| MVT origin | (150, 265) | `VIEW_ORIGIN_X/Y` |
| MVT scale | 1.25 | `SCALE_FROM_ORIGINAL` |
| Bead X span | 150 → 900 | 61 beads × gap 10 × 1.25 |
| Flutter fit | `FittedBox` contain into parent | device scaling only |

```text
Source viewport = Flutter logical viewport (1024×618)
```
