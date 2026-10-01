# FINAL_VISUAL_QA — Molecules and Light

Post–Home Integration visual status.

## Severity

| Level | Count | Notes |
|-------|-------|-------|
| P0 | **0** | Launch / core objects / controls OK |
| P1 | **0** | Spectrum complete; layout intact after AppBar |
| P2 | residual | VERSION_DELTA only (see below) |

## Checklist (Home entry path)

| Scene | Status |
|-------|--------|
| Initial (IR / OFF / CO) | PASS |
| Microwave / Infrared / Visible / Ultraviolet | PASS |
| CO N₂ O₂ CO₂ CH₄ H₂O NO₂ O₃ | PASS |
| Playing / Slow / Pause / Step / Reset | PASS |
| Spectrum Dialog (adaptive height under AppBar) | PASS |
| Home card (化学 / 光与分子) | PASS |

## Home chrome vs sim artwork

- Home card uses `Icons.flare_rounded` — catalog convention only
- Simulation interior still uses PhET micro PNGs + CustomPainter — **Substituted = 0**

## Viewport fill

Design space stays **768×504**. The stage is no longer pinned top-left. `Positioned.fill` + `FittedBox(BoxFit.contain, Alignment.center)` scales it to the available body so the observation window, selectors, and controls occupy the window together.

## AppBar impact

Thin 44 px production AppBar added for Back navigation. Spectrum dialog height adapts to remaining viewport (no overflow).

## Remaining VERSION_DELTA (P2)

- Per-molecule vibration mode fine detail
- VisibleColor LUT vs approximate rainbow
- Superscript tick typography (`10^n` ASCII)

These are **not** regressions from Home integration.
