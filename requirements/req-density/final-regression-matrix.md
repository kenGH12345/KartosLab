# Density Final Regression Matrix

> Loop 12 Close · 2026-09-02 · Density sealed. Unrelated full-suite failures tracked separately.

## Acceptance matrix

| Area | Test | Result |
|---|---|---|
| Introduction | Screen + controls | PASS |
| Compare | Screen + constraints | PASS |
| Mystery | Screen + sets/table | PASS |
| Material | Intro 7 + Custom | PASS |
| Mass / Volume / Density | SSOT via DensityRelation | PASS |
| One / Two Block | Mode switch | PASS |
| Buoyancy | Float / sink | PASS |
| Drag | Single + pointer constraint | PASS |
| Stacked Drag | X/Y stable (Loop 9–10) | PASS |
| Compare Constraints | Same Mass / Volume / Density | PASS |
| Mystery Sets | Set 1 / 2 (11340) / 3 | PASS |
| Random / Refresh | Reroll + Refresh | PASS |
| Density Table | 13 rows kg/L ascending + overlay | PASS |
| Reset | All screens + table collapse | PASS |
| Texture | 9 JPEG + cache preload | PASS |
| Semantics | Grab Mass / controls | PASS |
| Layout | 1024×768 / 1280×800 / 1366×1024 / 840×520 | PASS |
| Lifecycle | Ticker + TextureCache.dispose | PASS |
| License / Attribution | NOTICE.md + in-app About | PASS |

## Density-specific gates (Loop 12 re-verify)

| Command | Result | Notes |
|---|---|---|
| `flutter analyze lib/density test/density` | PASS | **0 errors**. Non-blocking: 1 info (`_setPad` naming), 1 warning (unused import in `runtime_acceptance_test.dart`) |
| `flutter test test/density` | **81/81 PASS** | No Density regression |

## Full-suite status

```text
Full-suite status:
PARTIAL

Density-related failures:
0

Known unrelated failures:
1. astronomy/keplers_laws/keplers_home_nav_test.dart
   → Home page missing Kepler's Laws card (existing project issue)
2. forces/forces_scenario_test.dart
   → netforce-tug scenario puller validation (existing project issue)
```

| Command | Result | Notes |
|---|---|---|
| `flutter test` (full) | PARTIAL | ~963 passed · 1 skipped · **2 failed** (both unrelated; see above) |
| `flutter analyze` (full) | FAIL* | `phet/quantum_coin_toss/` existing — not Density |
| `flutter build apk --release` | FAIL* | `integration_test` plugin — project Android config, not Density |

**Do not treat the 2 full-suite failures as Density regressions.**

## Runtime (Loops 8–11 retained)

```text
Windows App launches
Intro PASS
Compare PASS
Mystery PASS
Texture PASS (assets present; visual quality was manual-spot)
Buoyancy PASS
Drag PASS
Stacked Drag PASS
Y-axis oscillation FIXED
```

## Assets

| Check | Result |
|---|---|
| `assets/density/images/materials/` 9 col JPEG | PASS |
| `assets/density/NOTICE.md` Adapted from PhET · GPL-3.0 · CC0 | PASS |
| `DensityTextureCache` preload once (`_loaded` guard), not per-frame | PASS |
| `tool/extract_density_textures.py` retained as asset tool | PASS |

## Not in scope (deferred — not blockers)

| Item | Status |
|---|---|
| Keyboard help | deferred |
| PhET-iO | deferred |
| Grab/release sound | deferred |
| PBR normal/metalness | deferred |

## Close

```text
Density implementation complete.
Density-specific tests: 81/81 PASS.
Full-suite has 2 unrelated existing failures:
- astronomy/keplers_laws/keplers_home_nav_test.dart
- forces/forces_scenario_test.dart
```

`meta.yaml`: `phase: 3.close` · `status: done`
