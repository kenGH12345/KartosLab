# Balancing Act — Phase 2 Intro Report

> **req-id**: `req-port-balancing-act`  
> **Date**: 2026-09-23  
> **Scope**: Intro Screen only  
> **Gate**: **PASS**

---

## 1. Scope

Implemented:
- `BaIntroScreen` + `BaIntroController` + viewport/MVT
- Procedural scene (sky/ground, fulcrum, columns, plank, attachment bar)
- Original SVG masses (fire extinguisher, trash can)
- Drag/drop → Phase 1 snap/physics
- Show / Position / Column ABSwitch / Reset All
- Intro tests + Phase 1 regression

**Not** implemented: Balance Lab, Game, Home.

---

## 2. Source References

| Item | Source |
|------|--------|
| Screen | `BAIntroScreen` / `BAIntroView` / `BasicBalanceScreenView` |
| Model | Phase 1 `BAIntroModel` (locked) |
| Layout | `BASharedConstants.LAYOUT_BOUNDS` 768×504 |
| MVT | scale 105; origin `(w×0.375, h×0.79)`; inverted Y |
| Colors | SkyNode / GroundNode / FulcrumNode / PlankNode / LevelSupportColumnNode |
| Assets | `images/objects/fireExtinguisher.svg`, `trashCan.svg` |
| Reset | `ResetAllButton` scale 0.96 → `KratosResetAllButton` |

---

## 3. View Architecture

```
BaIntroScreen (TickerProvider)
└── BaViewport (FittedBox contain, 768×504)
    └── _BaIntroStage (Stack)
        ├── BaBalanceScenePainter (bg + fulcrum + columns + plank)
        ├── Marks / Rulers painters (optional)
        ├── LevelIndicator / ForceVectors painters
        ├── BaMassNode ×3 (SVG + labels + drag)
        ├── BaColumnSwitch
        ├── BaShowPanel + BaPositionPanel
        └── KratosResetAllButton
```

Physics: `SimulationClock` → `BAIntroModel.step(dt)` only. No fake AnimationController rotation.

---

## 4. MVT

`BaModelViewTransform`:
- scale = **105**
- origin = `(288, 398.16)`
- Y inverted

---

## 5. Layout

Fixed stage **768 × 504** via `BaViewport` + `FittedBox(BoxFit.contain)`.

---

## 6. Assets

| Asset | Path | Status |
|-------|------|--------|
| fireExtinguisher.svg | `assets/simulations/balancing_act/images/objects/` | FOUND (copied from PhET) |
| trashCan.svg | same | FOUND |
| Fulcrum / plank / columns / icons | PROCEDURAL | OK |

**Assets substituted = 0**

---

## 7. Plank / Pivot

Procedural:
- Fulcrum A-frame `rgb(240,240,0)` from Fulcrum shape
- Plank `rgb(243,203,127)` + tick marks + drop highlights
- Attachment bar + pivot circles
- Support columns with source gradient stops
- Rotation about pivot = `−tiltAngle` (Y invert)

---

## 8. Mass Objects

Intro seeds (unchanged Phase 1):
- 2× FireExtinguisher 5 kg
- 1× SmallTrashCan 10 kg

View: SVG height = `|modelToViewDeltaY(height)|`; bottom-center anchor; label `PhetFont(12)`.

---

## 9–10. Drag / Drop / Snap

Controller: continuous drag with offset; release → `BAIntroModel.endDrag` → Phase 1 snap algorithm (no View reimplementation).

---

## 11. Physics Rendering

`BaIntroController` clock @ 60 fps → `model.step` → `notifyListeners` → rebuild. Plank angle from model.

---

## 12. Controls

| Control | Implementation |
|---------|----------------|
| Show checkboxes | BaShowPanel |
| Position radios | BaPositionPanel (custom dots) |
| Column ABSwitch | BaColumnSwitch + procedural icons |
| Reset All | KratosResetAllButton radius `20.5×0.96` |

---

## 13. Reset

`resetAll()` → interrupt drag state + `model.reset()` + `viewProperties.reset()`.

---

## 14. Lifecycle

Screen dispose: remove listener, **pause clock**, dispose owned controller. Re-enter: `attach` rebinds ticker + `play`.

---

## 15. Visual QA

See `PHASE_2_INTRO_VISUAL_QA.md`.

Pixel baseline: **NOT AVAILABLE** (no golden harness run this phase). Structural QA against source + screenshots.

---

## 16. Test Matrix

| Area | File |
|------|------|
| Layout / MVT / chrome | intro_layout_test.dart |
| Drag / snap / occupation / tilt | intro_drag_test.dart |
| Reset | intro_reset_test.dart |
| Lifecycle | intro_lifecycle_test.dart |
| Phase 1 physics | existing 39 |

---

## 17. Test Count

| | Count |
|--|------:|
| Previous | 39 |
| Added | **10** |
| Final | **49** PASS |

---

## 18. Analyze

```
dart analyze lib/balancing_act test/balancing_act
→ No issues found!
```

---

## 19. P0 / P1 / P2

### P0 — 0

### P1 — 2 (carried from Phase 1)
1. Full random ChallengeFactory (Game)
2. Frame-rate sensitive integration strategy for production clocks

### P2 — 4
1–3 from Phase 1 (regional people / stanford / Vegas audio)  
4. SVG `<style/>` warning from flutter_svg (cosmetic; assets still render)  
5. Rulers/Marks are simplified procedural approximations (adequate for Intro controls; refine in visual polish if needed)

---

## 20. Known Limitations

- Lab / Game / Home not started
- Ruler geometry not full scenery-phet `RotatingRulerNode` port
- Checkbox still uses Flutter Checkbox (styled compact); radio uses custom dots
- No Home registration

---

## PHASE 2 STATUS: PASS
