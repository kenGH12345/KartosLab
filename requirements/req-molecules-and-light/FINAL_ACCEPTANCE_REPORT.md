# Molecules and Light Final Acceptance

## Status

```text
READY
```

## Model

Phase 1:
- PhotonAbsorptionModel port unchanged
- Strategies: Null / Hold / Vibration / Rotation / Excitation / BreakApart
- Absorbed photon wavelength independent of later light selector

Behavior matrix:
- 8×4 combinations verified (Phase 3 + regression still PASS)

## View

Main Screen:
- Single `MoleculesAndLightScreen` (design space 768×504)
- Viewport: `Positioned.fill` + `FittedBox(contain, center)` — scaled to fill the window, not pinned top-left
- Production AppBar for Home Back only

Observation Window:
- Emitter PNGs, photon PNGs, molecule geometry painters

Controls:
- Light / Molecule / Normal·Slow / Pause / Step / Light Spectrum Diagram / Reset All (`KratosResetAllButton` r=18)

Spectrum:
- Full `SpectrumDiagram` CustomPainter (log Hz / wavelength / bands / chirp / arrows)
- Dialog height adapts under AppBar (no overflow)

## Behavior

4 Light Sources: PASS  
8 Molecules: PASS  
32 Combinations: PASS  

## Controls

Normal: PASS  
Slow: PASS (`SLOW_SPEED_FACTOR = 0.5`)  
Pause: PASS  
Step: PASS  
Reset: PASS → Infrared / OFF / Carbon Monoxide  

## Spectrum

Open: PASS  
Close: PASS  
State Preservation: PASS  

## Home

Entry: PASS — 化学 → 光与分子 → Molecules and Light  
Back: PASS  
Re-entry: PASS — fresh model / clock / defaults  
Lifecycle: PASS — SimulationClock paused + disposed; spectrum overlay cleared  

## Tests

Molecules and Light:
```text
flutter test test/molecules_and_light/
→ 58 PASS
```

Home:
```text
test/molecules_and_light/home_lifecycle_test.dart
→ 6 PASS (card, A/B/C, reset vs re-entry, double open/close)
```

Global:
```text
flutter test
→ +2483 ~1 -56

Relevant to Molecules and Light: PASS (0 failures in test/molecules_and_light/)

Unrelated:
- States of Matter visual_qa_capture timeouts
- Projectile Motion visual_qa_capture timeouts
- Pendulum Lab visual_qa_capture timeouts
- Forces scenario TimeoutException (10 min)
(same class of pre-existing unrelated failures; not modified)
```

## Analyze

```text
dart analyze lib/molecules_and_light test/molecules_and_light lib/screens/home_screen.dart
→ No issues found
```

## Visual

P0: 0  
P1: 0  
P2: residual VERSION_DELTA only  

## Assets

Original: PhET micro photon/emitter PNGs + Spectrum CustomPainter  
Substituted: **0**  

## Platform

Web: NOT VERIFIED (widget tests only)  
Windows: PASS (local `flutter test`)  
Android: **NOT VERIFIED**  

## Layout close-out (2026-09-21)

Previous build pinned the 768×504 canvas to the top-left (`alignment: topLeft`), leaving unused background on the right and bottom. Close-out keeps PhET layout coordinates and scales the whole stage with `BoxFit.contain` + `Alignment.center`. Regression: `flutter test test/molecules_and_light/` → **58 PASS**.

## Remaining VERSION_DELTA

- vibration mode fine detail (per-molecule source modes)
- VisibleColor LUT fine detail
- superscript tick typography

Negligible P2 — does not block READY.
