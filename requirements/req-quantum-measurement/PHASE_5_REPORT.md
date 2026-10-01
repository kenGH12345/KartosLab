# PHASE 5 STATUS

Scope:
Spin Visual Component + Composer + Experiments

Source Evidence:
PASS

LayoutSpec:
PASS

Experiment 1:
PASS

Experiment 2:
PASS

Experiment 3:
PASS

Experiment 4:
PASS

Experiment 5:
PASS

Experiment 6:
PASS

Custom:
PASS

Shared Apparatus Architecture:
PASS (one SternGerlachApparatus ×3 + config visibility)

SGx:
PASS

SGz:
PASS

Block Up:
PASS

Block Down:
PASS

Single:
PASS

Continuous:
PASS

Trajectory:
PASS

Animation:
PASS

Assets:
PASS (spinScreenIcon.png available; apparatus programmatic; Substituted=0)

Composer:
PASS

Lifecycle:
PASS

Performance:
PASS (idle ticker silent; particle list bounded)

Real User Paths:
PASS (selector / Single / Continuous / Block / Custom α / dispose)

Tests:
17 PASS (`spin_phase5_test.dart`)

Regression:
PASS

Coins Regression:
PASS (11)

Photons Regression:
PASS (18)

Bloch:
NOT STARTED

Golden:
PREPARED

Android:
NOT VERIFIED

Home:
NOT STARTED

P0:
none

P1:
- MeasurementDevice (camera/Bloch readout) simplified to count panel in prep — not full MeasurementDeviceNode
- Histograms for continuous are count text, not HistogramWithExpectedValue chrome
- Continuous emission uses amount×5×dt (source calls shoot without dt; comment says per-second)

P2:
- Experiment selector uses PopupMenu (ComboBox chrome approximate)
- Prep Bloch sphere not drawn (scale 0.9 area deferred; state radios/sliders present)
- SpinSource mode label shortened to "Cont."

Status:
READY CANDIDATE

---

## A. Experiment Configuration

| Experiment | Shared Apparatus | Orientation | Visible Nodes | Axis | Special Behavior |
| --- | --- | --- | --- | --- | --- |
| 1 | Source+SG0 | Z | SG1/2 hide | SGz | single |
| 2 | Source+SG0 | X | SG1/2 hide | SGx | single |
| 3 | Source+SG0–2 | Z,X,X | blockable | SGz→SGx | multi |
| 4 | Source+SG0–2 | Z,Z,Z | blockable | SGz | multi |
| 5 | Source+SG0–2 | X,Z,Z | blockable | SGx→SGz | multi |
| 6 | Source+SG0–2 | X,X,X | blockable | SGx | multi |
| Custom | Source+SG0–2 | default X,Z,Z | + axis radios | user | custom |

## B. Apparatus Geometry

| Component | Parent | Anchor | Geometry Rule | Transform | Status |
| --- | --- | --- | --- | --- | --- |
| Divider | Screen | x=300 top=70 | LayoutSpec | design | PASS |
| Source | measure | (−0.5,0) | LayoutSpec | ×180 | PASS |
| SG0 | measure | (0.8,0) 0.75×0.5 | SternGerlach | ×180 | PASS |
| SG1 | measure | (2,0.3) | same | ×180 | PASS |
| SG2 | measure | (2,−0.3) | same | ×180 | PASS |
| Blocker | SG0 exit +0.1 | BLOCKER_OFFSET | continuous multi | ×180 | PASS |

## C. Trajectory

| Segment | Source Coordinates | View Coordinates | Experiment Dependency | Status |
| --- | --- | --- | --- | --- |
| Approach | sourceExit→SG0 in | MVT | all | PASS |
| Up branch | topExit→∞/SG1 | MVT | outcome | PASS |
| Down branch | bottomExit→∞/SG2 | MVT | outcome | PASS |

## D. Controls

| Control | Model/API | View Effect | Experiment Dependency | Status |
| --- | --- | --- | --- | --- |
| Experiment selector | applyExperiment | config rebuild | all | PASS |
| Single/Continuous | setSourceMode | source UI + visibility | all | PASS |
| Fire / Amount | fireSingle / particleAmount | emit | sourceMode | PASS |
| Block Up/Down | setBlockingMode | hide SG1/2 + bar | multi+continuous | PASS |
| Prep state / α | spinState / setAlphaSquared | prep | custom vs preset | PASS |
| SG Z/X | setSgOrientation | label+axis | custom | PASS |
| Reset All | reset + clear | L0 button | all | PASS |

## E. Regression

| Suite | Before | After | Result |
| --- | ---: | ---: | --- |
| Model | 47+ | still PASS | PASS |
| Coins | 11 | 11 | PASS |
| Photons | 18 | 18 | PASS |
| Spin | 0 | 17 | PASS |

Product remains **NOT READY**.
