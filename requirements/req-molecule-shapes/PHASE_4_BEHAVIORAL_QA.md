# PHASE 4 — Behavioral QA

对照 local source · full sim (`isBasicsVersion = false`) · 不接 Home。

## Method

- Gap matrix: `PHASE_4_FINAL_GAP_MATRIX.md`
- Automated regression: `test/molecule_shapes/phase4/phase4_final_regression_test.dart` + Phase 1–3 suites
- Code review of Model / Real screens, shared painter, dispose paths

## Dual-screen regression

| Area | Model Screen | Real Molecules | Result |
|---|---|---|---|
| Launch / render | ✅ | ✅ | PASS |
| Initial state | 2× single bond | H₂O + Real | PASS |
| Add / remove atom & bond | ✅ | N/A (source) | PASS |
| Single / double / triple | 1 domain each | CO₂ order 2 | PASS |
| Lone pair add/remove | ✅ | central LPs from data | PASS |
| Remove All | ✅ | N/A | PASS |
| Drag atom → angle≠name | ✅ | N/A primary | PASS |
| Rotate (quaternion only) | ✅ | ✅ | PASS |
| Show Bond Angles | ✅ | ✅ | PASS |
| Show Lone Pairs | ✅ | ✅ | PASS |
| Show Outer Lone Pairs | N/A prefs UI | preference + gate | PASS |
| Electron / Molecule Name | labels only | labels only | PASS |
| Reset | Model defaults | H₂O Real + toggles | PASS |
| Molecule selector 1→13 | N/A | TAB_2 order | PASS |
| Real / Model radios | N/A | angles isolate | PASS |

## Isolation

| Test | Result |
|---|---|
| Model edits ≠ Real molecule/bonds/options/quat | PASS |
| Real selection ≠ Model domains/bonds/options/quat | PASS |
| Real rotate → Model → Real restores Real coords + 104.5° | PASS |
| Independent quaternions across screen instances | PASS |
| Options flags not cross-wired | PASS |
| Model reset vs Real reset semantics | PASS |
| Outer LP preference survives Real reset | PASS |

## H₂O hard regression

```text
Real 104.5° → Model 109.5° → Real 104.5°
```

PASS（不得粘在 109.5°）。

## Geometry / VSEPR

| Check | Result |
|---|---|
| Domains 2–6 + lone-pair configs | PASS names + finite after step |
| Bond order = 1 domain | PASS |
| Max 6 domains | Phase 1 + Model canAdd | PASS |
| Drag does not rename | PASS |
| Ideal tetrahedral 109.5° | PASS |

## 3D / repulsion

| Check | Result |
|---|---|
| Perspective + depth sort path | PASS (shared painter) |
| World positions finite after rotate | PASS |
| step(dt) with dt>0.2 capped | PASS |
| 600× step finite / no NaN | PASS |
| 13 molecules finite xyz / bonds / angles | PASS |

## Lifecycle

| Check | Result |
|---|---|
| ModelMoleculesScreen dispose | PASS (ticker) |
| RealMoleculesScreen dispose | PASS (ticker) |
| Single shared update ticker (no per-atom controllers) | PASS |

## Assets

Substituted = **0**. Reset = `KratosResetAllButton`.

## P0 / P1 / P2

| Level | Open |
|---|---|
| P0 | 0 |
| P1 | 0 |
| P2 / VERSION_DELTA | lone-pair shell approx; bonding thumbnails 2D; Real↔Model orientation match; bond half-colors |

## Tests / Analyze

```text
flutter test test/molecule_shapes/
58 tests, All tests passed

dart analyze lib/molecule_shapes test/molecule_shapes
No issues found
```

## Global suite note

`flutter test` (whole repo): **+2541 ~1 -56** — failures are unrelated sims (SoM / gas_properties / pendulum / projectile visual timeouts; forces hang). Molecule Shapes not modified for global green.

## Status

```text
Model Screen Behavioral: PASS
Real Molecules Behavioral: PASS
PHASE 4 Behavioral: PASS
```
