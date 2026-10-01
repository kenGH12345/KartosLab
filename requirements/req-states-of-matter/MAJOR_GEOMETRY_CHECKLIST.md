# MAJOR_GEOMETRY_CHECKLIST · States of Matter

> Status gate: **Major Geometry P1** must be 0 before P2 chrome / READY.  
> Diff % alone is **not** a pass criterion. Attribute: **A** = KartosLab shell (allowed), **B** = simulation content (must clear P1).  
> Updated: 2026-09-16

Legend: **PASS** / **OPEN** / **N/A**

---

## States

| Screen | Component | Original Geometry | Flutter Geometry | Delta | Root Cause | Fix | Status |
|---|---|---|---|---|---|---|---|
| States | Scene shell / scale | Joist fit 834×504 into viewport | `SomSceneShell` letterbox fit | minor | capture unscaled | shell | PASS |
| States | Container | MVT (0.325W,0.75H)×0.028 Y-inv | `SomCoordinateTransform` | minor | — | — | PASS |
| States | Thermometer | centerX = container − 0.3×W; top lift 55 | same | minor | — | — | PASS |
| States | Particle region | interior of container | same MVT | minor | — | — | PASS |
| States | Molecules panel | right − 15, top + 10, width 175 | Column right stack, width 175 | minor | — | Column below inset | PASS |
| States | Phase buttons | `top = molecules.bottom + 10`; VBox spacing **10**; iconH **25**; font 14; x/y margin 5/8 | Column gap 10; spacing 10; icon 25; font 14; margins 5/8 | was spacing 6 + magic top | fixed height guess | source spacing + Column | PASS |
| States | Heat/Cool | scale 0.79, top = container.bottom+30 | same | minor | — | — | PASS |
| States | Play/Pause | left of heater − 50 | same | minor | — | — | PASS |

---

## Phase Changes

| Screen | Component | Original Geometry | Flutter Geometry | Delta | Root Cause | Fix | Status |
|---|---|---|---|---|---|---|---|
| Phase Changes | Pump | translation (106,466), ~90×110 | `PhaseChangesSceneLayout` | minor | — | — | PASS |
| Phase Changes | Hose | attach left, bottom−70 | `PumpHosePainter` | minor | — | — | PASS |
| Phase Changes | Container | same MPM MVT | same | minor | — | — | PASS |
| Phase Changes | Pressure Gauge | right = area.minX+0.2W; top = area.top−75; L elbow pipe; elbowHeight = 30+Δlid | same + `DialGaugePainter` collar/elbow; top tracks lid | was dial-only / fixed initialTop | missing connector | L-pipe + live top | PASS |
| Phase Changes | Right accordion stack | width 170; top 5; **INTER_PANEL_SPACING=8**; tops from prior bottoms | `RightPanelLayout` Column | was ad-hoc heights | magic 72px graph | unified layout | PASS |
| Phase Changes | Interaction Potential content | narrow graph **135×108**; red curve; σ/ε | height 108; red `#E50000`; σ/ε labels | was cyan, no greek | chrome gap | curve + markers | PASS |
| Phase Changes | Phase Diagram content | **148×111** | content 148×111 | was (W−12)×0.75 | wrong aspect base | `phaseDiagramWidth/Height` | PASS |
| Phase Changes | Piston / lid | lid + HandleNode scale 0.28 | lid + grip/stubs when `volumeControlEnabled` | was bare lid | missing handle | `HandleNode` paint | PASS |
| Phase Changes | Pointing Hand | WIDTH **150**; centerX+**30**; full finger overflow above y=0; fingertip on lid; green hint arrows | full `pointingHand.png`; no ClipRect stub; `#33FF00` arrows on hover/drag | was fingertip strip only | false clip for capture | restore PhET overflow | PASS |
| Phase Changes | Heat/Cool / Play | same as States | same | minor | — | — | PASS |

---

## Interaction

| Screen | Component | Original Geometry | Flutter Geometry | Delta | Root Cause | Fix | Status |
|---|---|---|---|---|---|---|---|
| Interaction | MVT | (145,360)×**0.25** | `SomInteractionTransform` | none | fake radius MVT | fixed earlier | PASS |
| Interaction | Graph | wide **350×262.5**; left = MVT(0)−31; top = panel.top+5 | 350×262.5; same left/top; no accordion header | was 320×180 + header | wrong wide size | `PotentialGraphNode` wide | PASS |
| Interaction | Atom pair | fixed (0,0)→(145,360); movable along x | same | minor | — | — | PASS |
| Interaction | Hand | scenery-phet `hand.png` WIDTH **80**; left=atomX; top≈atomY | asset + 80; same anchors | missing | no asset + decode | copied + `HandNode` | PASS |
| Interaction | Push Pin | width **20**; right/bottom = atom − 0.5×radius | same; painted above atoms | was centered / under atom | wrong anchor + z-order | PhET `updatePushPinPosition` | PASS |
| Interaction | Right controls | panel width 209; right − 15 | same | minor | — | — | PASS |
| Interaction | Bottom controls | time centerX = layoutCenter+20; bottom − 14 | same | minor | — | — | PASS |

---

## Gate summary

| Gate | Result |
|---|---|
| States major relations | PASS |
| Phase Changes major relations | PASS |
| Interaction major relations | PASS |
| **Major Geometry P1** | **PASS** (code + refreshed FLUTTER/DIFF 15/15) |
| P2 chrome | **NOT STARTED** (by design) |
| Browser QA | **PASS** |
| Final Status | **READY** |

Notes:

- A (KartosLab shell): known, allowed, do not modify for Diff %.
- B (sim content): P1 geometry addressed above; re-capture ORIGINAL/FLUTTER/DIFF before READY.
- Physics / Model / Clock / `SomSceneShell` architecture: not redesigned this round.
