# PHASE_7_REPORT

```text
PHASE 7 STATUS

Scope:
Global Visual Convergence + Golden Matrix

Global Shell:
PASS

Global Scaling:
PASS

Typography:
PASS (shared QmTypography; residual unmigrated local TextStyle = P1)

Shared Controls:
PASS (QmPhetTextButton / QmAquaRadio / QmCheckbox / divider / time icons)
  remaining ChoiceChip = P1 similar-not-same

Panels:
PASS (QmPanel spec; not every screen panel swapped)

Assets:
PASS — Substituted = 0

SVG:
PASS (original coin SVG; flutter_svg style warning logged)

PNG:
PASS greenPhoton 50×50 decoded from source; display Ø=10

Z-Order:
PASS

Coins Visual:
PASS

Photons Visual:
PASS

Spin Visual:
PASS

Bloch Visual:
PASS

Responsive:
PASS (1280×800 + 800×600 goldens)

Golden:
30 / 30 files PASS (implemented matrix)

Golden Determinism:
PASS (transform ×3; full golden suite re-run without update)

Golden Baseline:
PASS — GOLDEN_BASELINE_PHASE7.md

Visual Diff Log:
COMPLETE

Performance:
PASS (no extra clocks; debug overlay off)

Functional Regression:
PASS — full test/quantum_measurement 167 PASS

Real User Paths:
PASS (widget goldens + prior phase path tests)

Analyze:
No errors. 1 info (coin_set super params, pre-existing)

P0:
none

P1:
- ChoiceChip vs AquaRadio on polarization / Bloch axis
- Not all Text widgets switched to QmTypography
- Golden subset: no dedicated Coins 10 / 100 files (default model is 100; 10k has density golden)
- No Photons in-flight / continuous FakeClock checkpoint (static t=0 only)
- Observe absolute XY still CONTENT_DRIVEN (PHASE 6 R15)

P2:
- Panel 0.5 hairline vs source transparent stroke
- SVG unhandled <style/>
- Font AA / G9 raster

Android:
NOT VERIFIED

Home:
NOT STARTED

Product:
NOT READY

Visual Status:
READY CANDIDATE
```

## Golden Matrix summary

```text
Golden Matrix:
Coins       5 / 5 implemented
Photons     5 / 5 implemented
Spin        8 / 8 implemented
Bloch      12 / 12 implemented
Total      30 / 30 files
```

Canonical 1024×618 · Responsive 1280×800 · Constrained 800×600 as listed in table D.

## A. Global Visual

| Element | Source Rule | Shared Across Screens | Flutter Primitive | Status |
| --- | --- | --- | --- | --- |
| Canvas | 1024×618 | yes | QmDesignFrame | PASS |
| Scale | min(w/1024,h/618) center | yes | QmGlobalLayoutSpec.designFrame | PASS |
| Divider style | dash 6/5, w=2, h=525 | yes | QmExperimentDividingLine | PASS |
| Divider X | screen-specific | no | LayoutSpecs | PASS |
| Font | PhetFont Arial 8–26 | yes | QmTypography | PASS |
| Reset All | BR inset 10, r=20.5 | yes | KratosResetAllButton | PASS |
| Background | Coins tinted; others white | no | screen stacks | PASS |

## B. Asset Audit

| Asset | Source | Flutter Path | Actual Usage | Substituted | Status |
| --- | --- | --- | --- | --- | --- |
| classicalCoinHeads.svg | PhET images | assets/.../classicalCoinHeads.svg | Classical faces | 0 | PASS |
| classicalCoinTails.svg | PhET images | .../classicalCoinTails.svg | Classical faces | 0 | PASS |
| greenPhoton.png | greenPhoton_png.ts | .../greenPhoton.png | PhotonRenderer | 0 | PASS |
| spinScreenIcon.png | spinScreenIcon_png.ts | .../spinScreenIcon.png | reserved Home | 0 | PASS |

## C. Control Audit

| Control | Source Style | Shared Primitive | Screens | Status |
| --- | --- | --- | --- | --- |
| TextPushButton | #99CDFF / #72EB97 | QmPhetTextButton | Coins, Bloch | PASS |
| Aqua radio | 16px #0094BD | QmAquaRadio | Photons, Spin | PASS |
| Checkbox 16 | sun | QmCheckbox | Bloch, Photons Slow | PASS |
| Time icons | TimeControlNode | QmTimeControlButton | Photons | PASS |
| Divider | ExperimentDividingLine | QmExperimentDividingLine | Coins, Spin, Bloch | PASS |
| ChoiceChip | — | Material (P1) | Photons pol, Bloch axis | P1 |

## D. Golden Matrix

| Screen | State | 1024×618 | 1280×800 | 800×600 |
| --- | --- | ---: | ---: | ---: |
| Coins | Classical default | ✓ | ✓ | ✓ |
| Coins | Quantum default | ✓ | — | — |
| Coins | 10000 | ✓ | — | — |
| Photons | Default | ✓ | ✓ | ✓ |
| Photons | Classical | ✓ | — | — |
| Photons | Quantum | ✓ | — | — |
| Spin | Exp 1–6 + Custom | ✓ each | Exp1 only | — |
| Bloch | Default | ✓ | ✓ | ✓ |
| Bloch | ±X ±Y ±Z | ✓ | — | — |
| Bloch | Collapsed / B t=0 / Erased | ✓ | — | — |

## E. Visual Diff

See `VISUAL_DIFF_LOG_PHASE7.md` (shared transform, dashed Bloch divider, no Material Observe/play icons, photon PNG restored).

## F. Regression

| Suite | Previous | Current | Result |
| --- | ---: | ---: | --- |
| Full QM | 130 | **167** | PASS |
| Coins | 11 | 11 | PASS |
| Photons | 18 | 18 | PASS |
| Spin | 17 | 17 | PASS |
| Bloch | 21 | 21 | PASS |
| Scale geometry | 0 | 8 | PASS |
| Golden | prepared | 29 tests / 30 PNG | PASS |
