# PHASE_2_MAKE_MODEL_REPORT

> Updated: 2026-09-18  
> Scope: Make Isotopes **runtime model only** — UI untouched

---

## Gate

| Item | Result |
|---|---|
| Element selection | **PASS** |
| Default isotope | **PASS** (`numNeutronsInMostStableIsotope[Z]`) |
| Proton count | **PASS** (derived = Z) |
| Neutron count | **PASS** (nucleus + bucket) |
| Add / remove neutron | **PASS** (bucket ↔ nucleus) |
| Isotope resolution | **PASS** (nullable if off-table) |
| Mass number | **PASS** (A = Z + N) |
| Atomic mass | **PASS** (table or `-1`) |
| Natural abundance | **PASS** (table or `0`) |
| Stable / Unstable | **PASS** (`stableElementTable`) |
| Capture radius contract | **PASS** (`distance < 100`) |
| Unstable jump state | **PASS** (`step(dt)` offset) |
| Reset | **PASS** |
| State invariants | **PASS** |
| Tests | **21 PASS** |
| Analyze | **0 issues** |
| UI | **NOT STARTED** |

**P0 Make Model = 0**

---

## Architecture

```
ElementRepository / IsotopeRepository   (Phase 1 static)
                ↓
        MakeIsotopesModel               (Phase 2 runtime)
                ↓
   nucleusNeutronCount + bucketNeutronCount
                ↓
   massNumber / currentIsotope? / atomicMass / abundance / isStable
```

Files:

```
lib/chemistry/isotopes_and_atomic_mass/model/
  make_isotopes_constants.dart
  make_isotopes_model.dart
```

Notification: `revision` bump (same pure-Dart style as Rutherford model) — no Flutter `ChangeNotifier`.

---

## Runtime state (source-faithful)

| Behavior | PhET source | Dart |
|---|---|---|
| Default Z | `NumberProperty(1)` | Hydrogen |
| Element change | `link` → `initializeParticles` | `selectElement` reinits |
| Same Z re-select | no listener fire | no-op (keeps neutrons) |
| Default N in nucleus | `getNumNeutronsInMostCommonIsotope(Z)` | same |
| Bucket on init | 4 neutrons | `kDefaultNeutronsInBucket` |
| Neutron moves | particle between bucket/atom | count transfer |
| Min nucleus N | 0 (drag all out) | `removeNeutron` stops at 0 |
| Max nucleus N | mostCommon + 4 (conserved total) | bucket empty → add fails |
| Off-table isotope | allowed | `currentIsotope == null`, mass `-1`, abundance `0` |
| Capture | `distance < 100` | `canCaptureNeutronAtDistance` |
| Stable | `isStable(Z,N)` if A>0 | same |
| Unstable jump | model `step` toggles `nucleusOffset` | `step(dt)` |
| Reset | reset Z; re-init if N ≠ most-common | `reset()` |

Make Z range enforced **1..10** (view `interactiveMax=10`; model affirms Z>0).

---

## Open questions / deferred

| Topic | Decision |
|---|---|
| Per-particle positions / z-layer | Deferred to Phase 3 (nucleus particle layout) |
| Mass Number vs Atomic Mass **toggle** | View-owned (`AtomScaleNode.displayModeProperty`); not Make model |
| Electron cloud size | View / shred cloud; not needed for isotope identity |

---

## Tests

```
test/isotopes_and_atomic_mass/make_isotopes_model/make_isotopes_model_test.dart
```

21 cases: initial, selection, neutron bounds, H/C isotopes, capture, jump, reset, invariants.

---

## Remaining

- **Phase 3**: drag contract details, particle positions, nucleus reconfigure  
- **Phase 4+**: Mix model, Nature's Mix, View, Visual QA, APK

**Stop here — no UI.**
