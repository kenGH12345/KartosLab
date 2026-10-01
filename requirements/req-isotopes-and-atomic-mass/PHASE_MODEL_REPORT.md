# PHASE_MODEL_REPORT — Phase 1 Shared Element / Isotope Data

> Updated: 2026-09-18  
> Scope: **data only** — no UI

---

## Status checklist

| Gate | Result |
|---|---|
| SHRED | **PASS** (locked `f1a7da74…`; see `SHRED_SOURCE.md`) |
| Data source | **PASS** |
| Element Data | **PASS** |
| Isotope Data | **PASS** |
| Stable isotope data | **PASS** (`kStableNeutronsByZ` list preserved) |
| Natural abundance | **PASS** (proportion + TRACE) |
| Standard mass | **PASS** |
| AtomInfoUtils | **PASS** (IAAM subset) |
| Repository | **PASS** |
| Data immutability | **PASS** (final fields / const tables) |
| Tests | **PASS** (22) |
| Analyze | **0 issues** (`lib/chemistry/isotopes_and_atomic_mass`) |
| UI | **NOT STARTED** |

## P0 Data gate

| Item | Done |
|---|---|
| shred source/version locked | [x] |
| isotope dataset complete (Z=1..18) | [x] |
| element dataset complete | [x] |
| atomic masses correct | [x] |
| abundance correct | [x] |
| stability correct | [x] |
| standard masses correct | [x] |
| lookup correct | [x] |
| no duplicate dataset | [x] |
| no UI dependency | [x] |

**P0 Data = 0**

---

## Deliverables

```
lib/chemistry/isotopes_and_atomic_mass/model/data/
  atom_data_tables.dart      # generated
  atom_info_utils.dart
  element_data.dart
  element_repository.dart
  isotope_data.dart
  isotope_id.dart
  isotope_repository.dart
  phet_number_utils.dart
  data.dart

tool/isotopes_and_atomic_mass/convert_atom_data.py
test/isotopes_and_atomic_mass/data/isotope_data_test.dart

requirements/req-isotopes-and-atomic-mass/
  SHRED_SOURCE.md
  DATA_MIGRATION.md
  PHASE_MODEL_REPORT.md   # this file
```

---

## Behavioral notes (source-faithful)

1. **Default isotope** = `numNeutronsInMostStableIsotope[Z]` (H → 0 neutrons → H-1).
2. **Stable** = membership in `stableElementTable[Z]`, not half-life heuristics at runtime.
3. **Unknown isotope atomic mass** = `-1` (PhET).
4. **Unknown element / isotope lookup** = `null` / `RangeError` for standard mass OOB — **no** silent fallback to Hydrogen.
5. **Abundance** stored as proportion; rounding via PhET `toFixedNumber` when querying.
6. **Nature's Mix** will use `getStandardAtomicMass(Z)` (Phase 4) — already queryable.

---

## Phase 2 addendum

Make Isotopes runtime model: **PASS** — see `PHASE_2_MAKE_MODEL_REPORT.md`  
(`MakeIsotopesModel`, 21 tests, UI still not started).

## Remaining (Phase 3+)

- Phase 3: Make interaction / particle positions / nucleus reconfigure
- Phase 4: Mix Isotopes runtime model (+ Nature's Mix / composition / average mass)
- Phase 5–6: Assets + View
- Phase 7+: Visual QA, full tests, APK

**No UI work through Phase 2.**
