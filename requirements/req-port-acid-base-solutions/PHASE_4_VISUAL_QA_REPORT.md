# PHASE 4 — FULL VISUAL QA / SHARED COMPONENTS REPORT

**Sim:** PhET Acid-Base Solutions → Flutter  
**Req:** `req-port-acid-base-solutions`  
**Scope:** View / Painter / Widget / layout / goldens only  
**Model lock:** Phase 1–3 chemistry & LogSlider mapping untouched

---

## PHASE 4 STATUS: PASS

```text
Intro:
Visual: PASS
Tools: PASS
Graph: PASS
Particles: PASS (unchanged semantics; seeded goldens)
Controls: PASS
Typography: PASS (axis title / sci-notation / panel labels)

My Solution:
Visual: PASS
Tools: PASS
Graph: PASS
Particles: PASS
Controls: PASS
Typography: PASS

ConductivityTester:
Geometry: PASS — probe 20×68, bulb origin bottom-center, battery right
Chrome: PASS — original lightBulbOn/Off + batteryDCell PNGs
Idle: PASS — off bulb, brightness 0
Neutral: PASS — pH===7 dipped → brightness 0 (model locked)
Active: PASS — on opacity linear(0,1,0.3,1) + yellow LightRaysNode arcs

Graph:
Axes: PASS — ticks + dashed grid
Y-axis title: PASS — "Equilibrium Concentration (mol/L)" rotated −90°
Scientific notation: PASS — ConcentrationBarNode.concentrationToString
Ticks: PASS — 10^(i−8) with Unicode superscripts
Bars: PASS — width 25, spacing 16, height |log10(c)+8|·maxH/10
Formatting: PASS — negligible / mantissa / ×10ⁿ / >1 one decimal

Shared Chrome: PASS

Goldens:
Intro: 7 (initial, SA, WA, SB, WB, graph, conductivity active)
My Solution: 6 (initial WA, SA, SB, WB, high C, graph)
Total: 13
PASS

Assets substituted: 0
  (+ scenery-phet originals: lightBulbOn, lightBulbOff, batteryDCell)

Tests:
Previous: 98
Added: 28
Final: 126
All tests passed!

Analyze: No issues found!

P0: 0
P1: 0
P2:
  audio unavailable (local)
  typography micro-deltas (font metrics vs PhETFont)
  Show Solvent prefs dialog — source is Preferences-only (ABSPreferencesNode), not My Solution main chrome

Intro:
REGRESSION PASS

My Solution:
REGRESSION PASS

Home:
NOT TOUCHED

Runtime:
NOT VERIFIED

Android:
NOT VERIFIED

Report:
requirements/req-port-acid-base-solutions/PHASE_4_VISUAL_QA_REPORT.md
```

---

## Changes (View only)

| Item | Path |
|---|---|
| Conductivity chrome | `view/abs_conductivity_layer.dart` |
| Graph axes / sci-notation | `view/abs_concentration_graph.dart` |
| Assets | `view/abs_assets.dart` + `assets/.../lightBulbOn|Off|batteryDCell.png` |
| Display helpers | `model/abs_math.dart` (`toFixed`, `linear`) — no chemistry |
| Visual tests | `test/.../visual_qa_test.dart` |
| Goldens | `test/.../golden_test.dart` + `goldens/*.png` |

---

## Source notes

- Conductivity: scenery-phet `ConductivityTesterNode` + `LightBulbNode` + `LightRaysNode` + `WireNode` cubic curves; probes move together on drag.
- Graph: `ConcentrationGraphNode` + `ConcentrationBarNode.concentrationToString`.
- Show Solvent: `ShowSolventControl` lives in preferences dialog only → remains P2.

---

## Scope gates

```text
Model / chemistry: LOCKED
Home: NOT TOUCHED
Global READY: NOT DECLARED
```
