# PHASE 4 STATUS

Scope:
Photons Visual Component + Composer + Animation

Source Evidence:
PASS

LayoutSpec:
PASS

Physics → View Transform:
PASS

Photon Source:
PASS

Measurement Element:
PASS (PolarizingBeamSplitter + Mirror)

Detector:
PASS (Vertical + Horizontal)

Photon Trajectory:
PASS

Classical:
PASS

Quantum:
PASS

Single:
PASS

Continuous:
PASS (Many Photons emissionRate 0–200)

Animation:
PASS

Controls:
PASS

Original Assets:
PASS (greenPhoton.png 50×50, Substituted=0)

Composer:
PASS

Lifecycle:
PASS

Performance:
PASS (list of particles + O(states) paint; no 10k widgets)

Real User Paths:
PASS (Single emit; Quantum; Many rate; dispose)

Tests:
18 PASS (`photons_phase4_test.dart`)
92 PASS full `test/quantum_measurement/`

Regression:
PASS

Analyze:
info only (unnecessary getters/setters on animation controller)

P0:
none

P1:
- Probability accordion / histograms / normalized vector graph are simplified readout (not full PhotonsEquationNode / QuantumMeasurementHistogram chrome)
- PhotonSprites z-order: source `moveToBack`; Flutter draws photons above apparatus for visibility (documented)

P2:
- LaserPointerNode is approximate (body/nozzle sizes match constants)
- TimeControl uses Material play/pause icons (scenery-phet TimeControlNode chrome deferred)
- Oblique polarization indicator simplified to flat angle dial
- Emission y-jitter uses QmRandom (visual-only RNG per RNG_SPEC)

Coins Regression:
PASS (11 Coins phase3 tests still in 92 total)

Spin:
NOT STARTED

Bloch:
NOT STARTED

Android:
NOT VERIFIED

Home:
NOT STARTED

Golden:
PREPARED (default / classical / quantum / single / continuous mountable)

Status:
READY CANDIDATE

---

## A. Photon Geometry

| Module | Source Geometry | View Geometry | Transform | Status |
| --- | --- | --- | --- | --- |
| Laser | (−0.15, 0) m | (−96, 0) + experiment center | ×640 Y-inv | PASS |
| PBS | (0, 0) 0.07×0.07 m | (0,0) size 44.8 | ×640 | PASS |
| Mirror | (0.11, 0) | (70.4, 0) | ×640 | PASS |
| V detector | (0, 0.20) | (0, −128) | ×640 | PASS |
| H detector | (0.11, −0.09) | (70.4, 57.6) | ×640 | PASS |
| Experiment center | (420, 225) scene | design frame | LayoutSpec | PASS |

## B. Trajectory

| Segment | Physics Coordinates | View Coordinates | Mode | Status |
| --- | --- | --- | --- | --- |
| Approach | (−0.15,0)→(0,0) | (−96,0)→(0,0) | both | PASS |
| Reflect | (0,0)→(0,0.20) | (0,0)→(0,−128) | classical/quantum A | PASS |
| Transmit | (0,0)→(0.11,0)→(0.11,−0.09) | via mirror | classical/quantum B | PASS |

## C. Animation

| Event | Duration | Easing | Source Evidence | Status |
| --- | --- | ---: | --- | --- |
| Fly | 0.3 m/s | linear | Photon.ts | PASS |
| Continuous | rate×dt | n/a | Laser.step | PASS |
| Slow | ×0.4 | n/a | TimeSpeed | PASS |

## D. Controls

| Control | Model API | Visual State | LayoutSpec Anchor | Status |
| --- | --- | --- | --- | --- |
| Single/Many | experimentMode | SceneSelector | top center | PASS |
| Emit / Rate | emitAPhoton / emissionRate | red button / slider | laser body | PASS |
| Classical/Quantum | photonBehaviorMode | radios | above laser | PASS |
| Polarization | preset / customAngle | chips + slider | bottom-left | PASS |
| Play/Pause/Step/Slow | isPlaying / slowMotion / stepForward | time row | bottom | PASS |
| Reset All | model+sim reset | KratosResetAllButton | BR margin 10 | PASS |

## E. Regression

| Suite | Before | After | Result |
| --- | ---: | ---: | --- |
| Model (+layout) | ~63 | included | PASS |
| Coins | 11 | 11 | PASS |
| Photons | 0 | 18 | PASS |
| Full QM folder | — | 92 | PASS |

Product remains **NOT READY**.
