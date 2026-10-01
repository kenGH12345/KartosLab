# PHASE_3_VISUAL_MATRIX — Molecules and Light

Viewport: **768 × 504** (source `MicroScreenView` layoutBounds) — unchanged from Phase 2.

## Screenshot checklist (manual / golden targets)

| Scene | Focus |
|-------|-------|
| Initial | IR selected, emitter OFF, CO, spectrum closed |
| Microwave / Infrared / Visible / Ultraviolet | Source PNGs + selected chrome |
| CO N₂ O₂ CO₂ CH₄ H₂O NO₂ O₃ | Selector order + geometry |
| Playing / Slow / Pause / Step | Time control chips |
| Reset | Returns to initial |
| Spectrum Dialog | Full strip + arrows + chirp + Close |

## Light sources

| Light | Asset | Order (low→high energy) |
|-------|-------|-------------------------|
| Microwave | `microwaveSource.png` | 1 |
| Infrared | `infraredSource.png` | 2 |
| Visible | `flashlight.png` | 3 |
| Ultraviolet | `uvSource.png` | 4 |

Arrow caption: **Higher Energy →** (source arrow points right under buttons).

## Molecules

Selector order (source `MoleculeSelectionPanel`): CO → N₂ → O₂ → CO₂ → **CH₄** → H₂O → NO₂ → O₃.

Geometry from Phase 1 offsets; vibration remains simplified radial stretch (**P2** vs source per-molecule `setVibration`).

## Spectrum dialog

| Element | Status |
|---------|--------|
| Title Light Spectrum | PASS |
| Frequency arrow (cyan) | PASS |
| Strip + bands + visible rainbow | PASS |
| Wavelength arrow (magenta) | PASS |
| Chirp wave | PASS |
| Close | PASS |
| Simulation underlay preserved | PASS |

## Severity rollup

| Severity | Count | Notes |
|----------|-------|-------|
| P0 | **0** | — |
| P1 | **0** | Spectrum gap closed |
| P2 | several | vibration modes, superscript ticks, VisibleColor LUT, dialog chrome |

## Assets

Substituted = **0**. Spectrum is CustomPainter; light/photon PNGs from PhET micro mipmaps.
