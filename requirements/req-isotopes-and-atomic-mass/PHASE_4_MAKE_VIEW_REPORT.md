# PHASE_4_MAKE_VIEW_REPORT

> Updated: 2026-09-18  
> Scope: Make Isotopes **View / Widgets / Assets / Drag integration**  
> Model (Phase 1–3): **FROZEN** (no semantic changes)

---

## Gate

| Item | Result |
|---|---|
| Root Layout (768×464) | **PASS** (`IaamPageShell` FittedBox) |
| Periodic Table | **PASS** (Z≤10 expanded cells) |
| Element Selection | **PASS** → `model.selectElement` |
| Nucleus | **PASS** (model positions) |
| Proton / Neutron rendering | **PASS** (ParticleNode gradient) |
| Neutron Bucket | **PASS** (SphereBucket positions) |
| Mass Number / Atomic Mass | **PASS** (scale.png + radios) |
| Abundance | **PASS** (accordion + pie) |
| Stable / Unstable | **PASS** (model.isStable) |
| Neutron Drag | **PASS** → Phase 3 contract |
| Capture / Removal | **PASS** (Model only) |
| Reset | **PASS** (`KratosResetAllButton` → `model.reset`) |
| Unstable Step | **PASS** (`SimulationClock` → `model.step`) |
| Assets | **PASS** (original mipmaps; Substituted=0) |
| Widget Tests | **PASS** (6) |
| Regression Tests | **PASS** (Phase1–3 + view = 68) |
| Analyze | **0 issues** |
| APK | see below |
| Home integration | **PASS** (化学 → 原子结构) |
| P0 | **0** (functional) |
| P1 polish | remaining (cloud radii, PT mini table chrome, bucket bevel) |

---

## View architecture

```
IsotopesAndAtomicMassHome
  └── MakeIsotopesScreen (768×464 FittedBox)
        ├── MakeIsotopesController (ChangeNotifier + SimulationClock)
        │     └── MakeIsotopesModel (Phase 2/3 — frozen)
        ├── AtomScaleWidget (scale.png)
        ├── MakeIsotopePlayArea (cloud / nucleons / bucket / drag)
        ├── ParticleCountDisplay
        ├── ExpandedPeriodicTable
        ├── SymbolAccordion / AbundanceAccordion
        └── KratosResetAllButton
```

Pointer path:

```
GestureDetector pan
  → viewToModel
  → controller.beginDrag / updateDrag / endDrag
  → model (Phase 3)
  → notifyListeners → repaint
```

---

## Coordinate mapping

| Space | Definition |
|---|---|
| Model | PhET model units; atom default then `setAtomPosition` |
| MVT | `createSinglePointScaleInvertedYMapping(0, (0.4W, 0.49H), 1.0)` → origin view (307, 227) |
| ScreenView | 768 × 464 |
| Device | `FittedBox.contain` |

---

## Node mapping

| PhET | Flutter |
|---|---|
| IsotopesScreenView | `MakeIsotopesScreen` |
| AtomScaleNode | `AtomScaleWidget` |
| InteractiveIsotopeNode | `MakeIsotopePlayArea` |
| ExpandedPeriodicTableNode | `ExpandedPeriodicTable` |
| ParticleCountDisplay | `ParticleCountDisplay` |
| Symbol AccordionBox | `SymbolAccordion` |
| Abundance AccordionBox | `AbundanceAccordion` |
| ResetAllButton | `KratosResetAllButton` |
| ParticleView drag | `_DraggableNeutron` |

---

## Asset mapping

See `ASSET_MAP.md`. Runtime rasters: `scale.png`, icons. Particles / PT / bucket / cloud: Canvas.

---

## Known Differences (P1)

| Item | PhET | This phase |
|---|---|---|
| Electron cloud radii | IsotopeElectronCloudView table | Empirical table by Z |
| Mini periodic table | Full PeriodicTableNode scale 0.5 | Simplified Z≤10 cue grid |
| Bucket chrome | scenery-phet gradients | Approximate trapezoid + ellipse |
| Particle flight | Particle.step animation | Instant snap (Phase 3) |
| Mix screen | Second tab | Deferred Phase 5 |
| Atom-on-scale | live electron-cloud bounds link | One-shot empirical place |

---

## Tests

| Suite | Count |
|---|---|
| Phase 1 data | 22 |
| Phase 2 model | 21 |
| Phase 3 interaction | 19 |
| Phase 4 view | 6 |
| **Total** | **68 PASS** |

---

## Analyze

`dart analyze lib/chemistry/isotopes_and_atomic_mass` → **0 issues**

---

## APK

`flutter build apk --debug` → **PASS** (`build/app/outputs/flutter-apk/app-debug.apk`)

Emulator install: no device attached at build time (`adb devices` empty). Install when Pixel Tablet Emulator is running:

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

Runtime QA path: Home → 化学 → 原子结构 → 同位素与原子质量.

---

## Remaining

- Phase 5: Mix Isotopes Model  
- P1 visual polish on Make (cloud / PT / bucket)  
- Visual QA screenshots under `visual-qa/V1/` (device/runtime)

**Stop here — do not start Mix Isotopes.**
