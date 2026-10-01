# PHASE_5_MIX_MODEL_REPORT

> Updated: 2026-09-18  
> Scope: **MixturesModel only** — no Mix UI / Controller / gestures

---

## Gate

| Item | Result |
|---|---|
| Source mapping | **PASS** (`PHASE_5_MIX_SOURCE_MAP.md`) |
| MixturesModel | **PASS** |
| Element selection (Z≤18) | **PASS** |
| Available isotopes (stable, mass-sorted) | **PASS** |
| Bucket mode | **PASS** (stock = max(0, 10−chamber)) |
| Slider mode | **PASS** (0..100 clamp) |
| Count limits | **PASS** |
| Mixture state | **PASS** (chamber counts) |
| My Mix | **PASS** |
| Nature's Mix | **PASS** (`roundSymmetric(1000×abund_5)`, min 1) |
| Natural abundance | **PASS** (Phase 1) |
| Percent composition | **PASS** (chamber proportions) |
| Average atomic mass | **PASS** (chamber Σm/n) |
| Standard mass | **PASS** (`displayedAverageAtomicMass` when Nature) |
| Clear | **PASS** (My Mix only; throws if Nature) |
| Reset | **PASS** |
| Element / mode switching + save/restore | **PASS** |
| Large-count / Performance | **PASS** (counts only; no 1000 widgets) |
| Tests | **PASS** (~20 new) |
| Phase 1–4 regression | **PASS** (total suite **88 PASS**) |
| Analyze | **0 issues** |
| UI | **NOT STARTED** |
| P0 | **0** |

---

## Architecture

```
ElementRepository / IsotopeRepository   (Phase 1)
                ↓
          MixturesModel                 (Phase 5)
                ↓
  chamberCounts / mode / natures flag
                ↓
  proportion / chamberAverage / displayedAverage
```

Files:

```
lib/chemistry/isotopes_and_atomic_mass/model/
  mixtures_constants.dart
  interactivity_mode.dart
  mixtures_model.dart
```

Make Model / View / Controller: **untouched**.

---

## Initial state

| Field | Value |
|---|---|
| Z | 1 (Hydrogen) |
| Mode | `bucketsAndLargeAtoms` |
| Nature | false |
| Chamber | empty |
| Possible | H-1, H-2 |
| Bucket stock | 10 per isotope |

---

## Known Differences (intentional Phase 5)

| Item | PhET | This phase |
|---|---|---|
| Particle instances | `PositionableAtom` lists | **Counts only** (spatial Phase 6) |
| Nature positions | `generateRandomPosition` | deferred |
| Bucket MonoIsotopeBucket geometry | SphereBucket stack | derived stock count |
| Slider `assert(quantity≤100)` | assert | clamp to 100 |
| Mode change while Nature | View hides control | Model ignores chamber mutation |

---

## Remaining

- Phase 6: Mix spatial / drag / Nature particle positions  
- Phase 7: Mix View  

**Stop — Mix UI NOT STARTED.**
