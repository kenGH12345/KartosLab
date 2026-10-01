# PHASE 2 REPORT — Layout Archaeology

**Req:** req-quantum-measurement  
**Date:** 2026-09-30  
**Status:** READY CANDIDATE (phase) · product **NOT READY**

---

## PHASE 2 STATUS

```
Scope:
Layout Archaeology

Source:
Quantum Measurement 1.0.4

Global Layout: PASS
Coins Layout: PASS
Photons Layout: PASS
Spin Layout: PASS
Bloch Sphere Layout: PASS

Coordinate Systems: PASS
Anchor Mapping: PASS
Constraint Mapping: PASS
Responsive Rules: PASS
Asset Geometry: PASS (with MEDIUM items for intrinsic measure-at-copy)
Typography Geometry: PASS (constants recorded; baseline P2)
Animation Geometry: PASS (Coins divider/travel; Photons trajectory; Spin paths; Bloch precession)

Source Evidence: PASS
Layout Specs: 4 / 4

Geometry Tests: 18 PASS (layout_geometry_test.dart)

Analyze: CLEAN on layout package (spot)

P0: 0
P1: 0 blocking (R15 MEDIUM — complete BlochMeasurementArea XY at Composer kickoff)
P2:
1. Font baseline Flutter vs PhetFont
2. Radio height → Photons scene Y content-driven
3. SVG viewBox numeric until asset copy

UI: NOT STARTED
Golden: NOT STARTED
Android: NOT VERIFIED
Home: NOT STARTED

Status: READY CANDIDATE
```

---

## Table A — Screen Geometry

| Screen | Design Bounds | Content Bounds | Main Region | Primary Layout Direction | Scale Rule |
|---|---|---|---|---|---|
| Global | 1024×618 | inset 10 | — | — | uniform center |
| Coins | 1024×618 | scene @ (0,75) | prep \| divider \| measure (toggle Classical/Quantum scenes) | horizontal + mode animation | uniform |
| Photons | 1024×618 | scene @ (0, radio.bottom+10) | experiment @ (420,225) + L/R panels | mixed | uniform + MVT 640 |
| Spin | 1024×618 | prep \| divider@300 \| measure | horizontal | uniform + MVT 180 |
| Bloch | 1024×618 | prep mid-left \| divider@350 \| measure@390 | horizontal | uniform + sphere local R=100 |

## Table B — Major Modules (sample)

| Screen | Module | Parent | Category | Anchor | Width Rule | Height Rule |
|---|---|---|---|---|---|---|
| Coins | Divider | Scene | Structural | centerX=dividerX | 2px stroke | 525 FIXED |
| Coins | Prep | Scene | Structural | centerX=d/2 | CONTENT | CONTENT |
| Coins | MultiTestBox | Measure HBox | Display | HBox | 200 FIXED | 200 FIXED |
| Photons | ExperimentArea | Scene | Display | center (420,225) | MVT region | MVT region |
| Photons | Laser | TestingArea | Display | model (−0.15,0)×640 | content | content |
| Spin | Divider | Screen | Structural | x=300,top=70 | — | 525 |
| Spin | SG0 | Measure | Display | model (0.8,0)×180 | SG const | SG const |
| Bloch | Prep | Screen | Structural | mid left column | CONTENT | CONTENT |
| Bloch | Sphere | Prep/Measure | Display | local center | 2R×scale | 2R×scale |

## Table C — Dynamic Geometry

| Screen | Dynamic Region | Driver | Static/Dynamic | Formula |
|---|---|---|---|---|
| Coins | Divider X | preparingExperiment | DYNAMIC | 389↔205 animate 0.5s |
| Coins | Multi coins | numberOfCoins | DYNAMIC | nodes vs 100×100 pixel canvas |
| Photons | Photon sprites | emission/step | DYNAMIC | MVT(model pos) |
| Spin | SG visibility | experiment | DYNAMIC | settings + sourceMode |
| Bloch | Vector tip | θ,φ / B precession | DYNAMIC | port BlochSphereNode |

## Table D — Remaining Risks

| Risk | Severity | Evidence | Composer impact |
|---|---|---|---|
| R15 Bloch measurement XY incomplete | P1→track | MEDIUM | Finish line-scan before placing Observe/Erase |
| R9 Asset intrinsic | P1 until measured | MEDIUM | Measure SVG/PNG on copy |
| R10 Font baseline | P2 | known | Accept micro-diff |
| R11 QCT layout reuse | P1 process | map | Use QM Coins spec only |

---

## Deliverables

| Path | Status |
|---|---|
| LAYOUT_GLOBAL.md | PASS |
| COINS_LAYOUT_SPEC.md | PASS |
| PHOTONS_LAYOUT_SPEC.md | PASS |
| SPIN_LAYOUT_SPEC.md | PASS |
| BLOCH_LAYOUT_SPEC.md | PASS |
| LAYOUT_SOURCE_EVIDENCE.md | PASS |
| LAYOUT_RISK_REGISTER.md | PASS |
| `lib/quantum_measurement/layout/qm_*_layout_spec.dart` | PASS |
| `test/quantum_measurement/layout_geometry_test.dart` | PASS |

## Model

**Unchanged** (PHASE 1 models not modified).

## Next

PHASE 3 — Visual Component / Composer Implementation (per-screen Spec→Composer→Components; no Mega Composer).
