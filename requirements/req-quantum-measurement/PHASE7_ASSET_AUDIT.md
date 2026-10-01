# PHASE7_ASSET_AUDIT

| Asset | Source | Flutter Path | Actual Usage | Substituted | Status |
| --- | --- | --- | --- | --- | --- |
| classicalCoinHeads.svg | `images/classicalCoinHeads.svg` | `assets/simulations/quantum_measurement/images/classicalCoinHeads.svg` | Classical coin face | 0 | PASS |
| classicalCoinTails.svg | `images/classicalCoinTails.svg` | `.../classicalCoinTails.svg` | Classical coin face | 0 | PASS |
| greenPhoton.png | `images/greenPhoton_png.ts` (50×50 PNG) | `.../greenPhoton.png` (decoded 3674 B) | PhotonRenderer, display Ø=10, scale 0.2 | 0 | PASS |
| spinScreenIcon.png | `images/spinScreenIcon_png.ts` | `.../spinScreenIcon.png` (7008 B) | Home/tab later; asset present | 0 | PASS (unused until Home) |

Programmatic (not substitution): Bloch sphere, SG, laser/PBS, 10k canvas, dividers, quantum coins.

**Assets substituted = 0** for runtime-used images.

SVG: original viewBox preserved (copied from PhET). PNG: intrinsic 50×50 photon; display size from `TARGET_PHOTON_VIEW_RADIUS=5`.
