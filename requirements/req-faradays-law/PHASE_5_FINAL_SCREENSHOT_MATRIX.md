# PHASE 5 — FINAL SCREENSHOT MATRIX · Faraday's Law

Comparison protocol: same logical viewport **834×504**, Model state arranged, Flutter PNG under `visual-qa/screenshots/`. Oracle = local PhET source constants + user/source screenshots (`phet sourses/.../assets/faradays-law-screenshot*.png`).

Not pixel-golden gated (anti-alias / font). Severity per observable mismatch.

| # | State | Viewport | Flutter capture | Comparison target | Difference | Severity |
| --- | --- | --- | --- | --- | --- | --- |
| A | Initial: magnet (647,200) NS, 1 coil, field OFF, voltmeter OFF, bulb off, arrows ON | 834×504 | `A_initial.png` | Phase 0 initial + `faradays-law-screenshot.png` | Layout/colors match; label glyphs soft in headless capture | P2-FONT |
| B | Magnet left / at coil / right (widget matrix) | 834×504 | state tests (no extra PNG) | source drag positions | Host center tracks model ±40px pad | PASS |
| C1 | 1 coil | 834×504 | (default in A) | source single coil | four-loop only | PASS |
| C2 | 2 coil | 834×504 | `C_two_coil.png` | source dual coil | top 2 + bottom 4 mipmaps; radio selected | PASS |
| D | SN polarity | 834×504 | `D_polarity_SN.png` | source flip | Blue/red halves swap; no mirrored text via scaleX | PASS |
| E | Field lines ON | 834×504 | `E_field_lines_ON.png` | source ellipses | Nested ellipses + arrows; tangent micro-delta | P2-03 |
| F | Voltmeter ON, needle ~0 | 834×504 | `F_voltmeter_ON.png` | source VoltmeterNode | Body/gauge/wires present; shade simplified | P2-02 |
| G | Bulb bright via \|V\| | 834×504 | (H_combined halo) | BulbNode | Halo from Model; base align micro | P2-05 |
| H1 | 2 coil + field ON + voltmeter ON + SN + magnet displaced + V≠0 | 834×504 | `H_combined.png` | combined source look | Z-order sandwich OK; structure match | PASS |
| H2 | Reset → initial | 834×504 | `H_reset_initial.png` | initial | Matches A defaults (VD-02 voltage 0) | PASS |

## Captures on disk

```
requirements/req-faradays-law/visual-qa/screenshots/
  A_initial.png
  C_two_coil.png
  D_polarity_SN.png
  E_field_lines_ON.png
  F_voltmeter_ON.png
  H_combined.png
  H_reset_initial.png
```

Generator: `test/faradays_law/visual/visual_qa_screenshot_capture_test.dart`

## Interaction visual states (widget)

| Control | OFF/1-coil/NS | ON/2-coil/SN | After Reset |
| --- | --- | --- | --- |
| Voltmeter checkbox | unchecked | checked | unchecked |
| Field Lines checkbox | unchecked | checked | unchecked |
| Coil radio | single selected | double selected | single |
| Flip | NS magnet | SN magnet | NS |
| Reset All | — | — | full initial |

No stuck pressed/hover observed in widget tests.
