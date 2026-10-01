# PHASE 7 — Mix Isotopes View Report

> Status: **PASS** · Date: 2026-09-18 · Viewport: **768 × 464** · Mix MVT: **(246, 153)**

## Gate

```text
PHASE 7 — MIX ISOTOPES VIEW

View:                 PASS
Controller:           PASS
Element Selection:    PASS (Z≤18)
Isotope Buckets:      PASS
Bucket Mode:          PASS
Slider Mode:          PASS
Mix Chamber:          PASS (black + clip)
Canvas:               PASS (IsotopeCanvasPainter)
Particle Rendering:   PASS (color cycle)
Drag:                 PASS → Model
Invalid Drop:         PASS
Removal:              PASS (drag out / clear)
Nature's Mix:         PASS (single canvas ~1000)
My Mix:               PASS
My Mix Restore:       PASS
Mode Switching:       PASS (separate Z+mode saves)
Percent Composition:  PASS (Model proportions)
Average Atomic Mass:  PASS (displayedAverage)
Clear:                PASS
Reset:                PASS (KratosResetAllButton)
Lifecycle:            PASS
Performance:          PASS (no per-particle Nature widgets)
768×464 Layout:       PASS
Assets:               PASS (icons + programmatic)
Widget Tests:         PASS
Integration Tests:    PASS
Regression:           PASS (108)
Analyze:              0 issues
APK:                  PASS (app-debug.apk)
P0:                   0
P1:                   open polish (accordion stacking / pie labels)
```

---

## Architecture

```text
Shared Data
    │
    ├─ MakeIsotopesModel → MakeIsotopesController → Make View
    └─ MixturesModel     → MixturesController     → Mix View
                                                      ├─ Bucket large particles
                                                      └─ Slider/Nature Canvas
```

View only forwards pointer → controller → model. No percent / average / Nature / drop logic in View.

---

## Files

| Path | Role |
|---|---|
| `controller/mixtures_controller.dart` | ChangeNotifier + clock |
| `screens/mix_isotopes_screen.dart` | MixturesScreenView |
| `screens/isotopes_and_atomic_mass_home.dart` | Isotopes \| Mixtures tabs |
| `widgets/mix_play_area.dart` | chamber / buckets / drag / canvas |
| `widgets/control_isotope.dart` | PhET-like slider control |
| `widgets/mix_statistics_panels.dart` | pie + average mass |
| `widgets/mix_selection_controls.dart` | My/Nature + mode + eraser |
| `painters/isotope_canvas_painter.dart` | clipped canvas particles |
| `model/get_isotope_color.dart` | 4-color cycle |
| `widgets/sim_coord_scope.dart` | shared pointer→sim |
| `widgets/expanded_periodic_table.dart` | generic Z max (Make 10 / Mix 18) |

Model frozen except: `kMixSliderY`, `get_isotope_color` (view color helper).

---

## PhET mapping

See `PHASE_7_VIEW_SOURCE_MAP.md`.

Highlights:

- Mix MVT ≠ Make MVT
- Chamber clipRect on canvas
- Nature / slider → single CustomPainter
- Bucket mode → Positioned spheres + drag → begin/update/endDrag
- grabOffset = 0 (unchanged)
- Reset = `KratosResetAllButton` radius 20.5×0.85

---

## Home navigation

```text
化学 → 原子结构 → 同位素与原子质量
  Tab Isotopes (isotopesIcon.png)
  Tab Mixtures (mixturesIcon.png)
```

Make screen unchanged in behavior.

---

## Tests

```text
flutter test test/isotopes_and_atomic_mass/
→ 108 PASS

dart analyze lib/chemistry/isotopes_and_atomic_mass
→ No issues found

flutter build apk --debug
→ build/app/outputs/flutter-apk/app-debug.apk
```

Mix view tests: render, Z≤18 select, drag, invalid drop, Nature canvas, clear/reset, mode switch.

Visual matrix: `requirements/.../visual-qa/V2/` (`mix_initial.png` + README).  
Full matrix / Nature frame: device APK QA (headless `toImage` of Mix stack is too slow offline).

---

## Known Differences (P1 / P2)

1. Pie chart label layout simplified vs PhET unconstrained collision solver.
2. Accordion vertical stacking uses approximate PT height (not live `periodicTableNode.bottom`).
3. Mode radio icons are miniature CustomPaint (not full BucketHole/HSlider Node clones).
4. Eraser is yellow panel + vector glyph (no scenery-phet SVG wired into IAAM assets yet).
5. Nature capture / paint of ~1000 arcs is intentionally canvas-only; first frame may hitch on low-end.

---

## Stop

Phase 7 complete. **Do not start Phase 8 Final QA yet** until dual-screen shell/lifecycle check is requested.

Next: PHASE 8 — dual Screen Integration / Final Visual QA.
