# PHASE 6 — Mix Isotopes Spatial / Interaction Model

> Status: **PASS** · UI: **NOT STARTED** · Analyze: **0** · Date: 2026-09-18

## Gate

```text
PHASE 6 — MIX SPATIAL / INTERACTION MODEL

Source mapping:          PASS
Particle identity:       PASS
Bucket state:            PASS
Bucket positions:        PASS
Chamber state:           PASS
Chamber positions:       PASS
Drag contract:           PASS
Grab offset:             PASS (= 0, ParticleView applyOffset:false)
Drop contract:           PASS
Invalid drop:            PASS
Removal:                 PASS (chamber→bucket / slider remove last match)
Mode switch:             PASS (per Z+mode save lists)
Bucket mode:             PASS (stock = 10 − chamber)
Slider mode:             PASS (0..100 → N small particles)
Nature's Mix:            PASS (~1000 MixParticle + random pos)
My Mix:                  PASS (counts + positions saved)
Nature ↔ My Mix:         PASS
Element switch:          PASS
Same-Z reselect:         PASS
Clear:                   PASS
Reset:                   PASS
Lifecycle:               PASS (cancel drag on switch/reset)
Performance:             PASS (lightweight MixParticle; Nature recreates list)
Tests:                   PASS (101 full suite)
Phase 1–5 regression:    PASS
Analyze:                 0 issues
UI:                      NOT STARTED
P0:                      0
```

---

## Source mapping

| Concern | PhET | Flutter |
|---|---|---|
| Particle | `PositionableAtom` | `MixParticle` (`mix_particle.dart`) |
| Chamber | `IsotopeTestChamber` 450×280 @ origin | `_chamberParticles` + `kTestChamber*` |
| Bucket | `MonoIsotopeBucket` + `SphereBucket` layout | `_bucketParticles` + `SphereBucketLayout` |
| Drag | `isDraggingProperty.lazyLink` remove/place | `beginDrag` / `updateDrag` / `endDrag` |
| Drop | `isIsotopePositionedOverChamber` = rect contains center | `isPositionInChamber` inclusive rect |
| Invalid | `placeIsotope` → `addIsotopeInstanceNearestOpen` | `_addToBucketNearest` |
| Slider qty | `NumericalIsotopeQuantityControl.setIsotopeQuantity` | `setIsotopeQuantity` |
| Nature | pool `naturesMixAtoms` + `generateRandomPosition` | chamber list + injectable `Random` |
| Save | `savedParticleStates[Z][mode]` atom refs | `SavedMixParticle` (mass, x, y, radius) |
| Counts | derived from `containedIsotopes.length` | derived from `_chamberParticles` |

Local sources:

- `phet sourses/.../js/mixtures/model/MixturesModel.ts`
- `IsotopeTestChamber.ts` / `MonoIsotopeBucket.ts` / `NumericalIsotopeQuantityControl.ts`
- `MixturesScreenView.ts` (ParticleView; canvas for small/nature — View-only)

---

## Particle identity

```text
MixParticle
  id            monotonic int (_nextParticleId) — NOT list index
  massNumber
  radius        10 large / 4 small
  x, y / dest
  container     bucket | chamber | null(while dragging)
  isDragging
```

Invariants:

- unique `id` among live particles
- `container` matches list membership
- chamber counts = `#chamber particles` per mass number

---

## Count vs spatial

| Mode | Count truth | Visible particles |
|---|---|---|
| Bucket My Mix | `#chamber` | large atoms in chamber + bucket stock particles |
| Slider My Mix | `#chamber` | exactly N small atoms in chamber (no bucket particles) |
| Nature | `#chamber` (== Nature quantity rules) | ~1000 small atoms in chamber list |

**No** separate count map: counts are derived from chamber particle list (PhET `containedIsotopes`).

Bucket stock is **finite relative to chamber**: `fillBuckets` adds `max(0, 10 − chamberCount)` per isotope. Dragging from bucket does **not** auto-refill until next `fillBuckets` (element/mode/clear/Nature-off).

---

## Bucket spatial state

- One logical bucket per stable isotope (`bucketPositionForIndex` / Y=`-250`)
- Up to **10** large spheres (`kNumLargeIsotopesPerBucket`)
- Positions: `SphereBucketLayout.firstOpenPosition` over occupied destinations (deterministic for same occupied set)
- No “+N” overflow UI in model (PhET also only shows ≤10)
- Drag out → remove + nearestOpen relayout on return

---

## Chamber spatial state

- Rect: `[-225, -140] × [225, 140]` (width 450, height 280)
- Drop test: **center** inside rect (inclusive edges)
- On successful add: clamp so radius + BUFFER(1) stays inside walls
- Overlap: light repulsive nudge when `total ≤ 100` (bucket drops); full PhET force loop deferred if needed in View polish
- Placement for new atoms: `generateRandomPosition` equivalent (`Random` injectable)

---

## Drag / Drop / Remove contracts

```text
beginDrag(id, pointerX, pointerY)
  → remove from bucket|chamber
  → grabOffset = (0,0)   // ParticleView default applyOffset:false
  → place at pointer

updateDrag(pointer)
  → position = pointer − grabOffset
  → counts UNCHANGED

endDrag()
  → if center in chamber: addToChamber (+ clamp / light overlap)
  → else (bucket mode): addToBucketNearest
  → else (slider): re-add to chamber at random (slider atoms not dragged in PhET)

cancel (element/mode/Nature/reset/quantity):
  → invalidate session; return to bucket (bucket mode) or chamber (slider)
```

Removal:

- Bucket mode: drag chamber atom outside → nearest bucket slot; count−−
- Slider: `setIsotopeQuantity` decrease removes **last matching** chamber particle (PhET `removeIsotopeMatchingConfig` last-wins loop)
- Clear Box: `clearTestChamber` — chamber empty, delete save(Z,mode), refill buckets if bucket mode

---

## Mode switch

PhET saves **separate** particle lists per `(Z, mode)`:

```text
Bucket mix ≠ Slider mix
switch to mode with no prior save → empty chamber
```

Counts are **not** copied across modes. Phase 5 regression test `bucket↔slider mode saves separate mixtures` preserved.

---

## Nature's Mix

- Quantity: `roundSymmetric(1000 × abundance_5)`, minimum **1** (unchanged Phase 5)
- Positions: random in chamber; re-randomized each time Nature is shown
- Radius: small (4)
- Buckets empty (legend only in View later)
- Drag disabled while Nature showing
- `displayedAverageAtomicMass` = `standardMassTable[Z]` (not chamber mean)

**Known difference:** PhET reuses a preallocated `naturesMixAtoms` pool + `isActive`; Flutter recreates lightweight `MixParticle` list. Observable counts/positions-validity match; identity reuse does not.

---

## My Mix / Nature ↔ My Mix

- Save includes **positions + massNumber + radius** (not only counts)
- Restore recreates particles (new ids) at saved coordinates
- Nature on: save My Mix → clear → Nature particles
- Nature off: restore My Mix → fillBuckets if bucket mode

---

## Element switch

- Same Z → no-op (particles/drag untouched)
- Different Z → cancel drag → save previous My Mix → clear → restore/fill for new Z
- No residual C-* particles after switching to O (tested)

---

## Clear / Reset / Lifecycle

| Action | Spatial effect |
|---|---|
| `clearTestChamber` | chamber empty; buckets refilled to 10−0; drag cleared; save deleted |
| `reset` | all saves wiped; mode=bucket; Nature=false; Z=1; buckets=20 for H; drag null |
| Mode/element/Nature/quantity | `_cancelDrag` before mutating |

---

## Performance

- `MixParticle` is a plain Dart object (no Widget/Flutter refs)
- Nature ≈1000 particles: list of positions only
- Slider 100: create/remove delta, not full rebuild unless mode switch
- Avoided using `particleInstances.length` as a second count store

---

## Files

```text
lib/chemistry/isotopes_and_atomic_mass/model/
  mix_particle.dart                 NEW
  mixtures_model.dart               EXTENDED (spatial + drag)
  mixtures_constants.dart           EXTENDED (chamber/bucket geometry)
  sphere_bucket_layout.dart         GENERALIZED (occupiedDestinations)

test/isotopes_and_atomic_mass/mix_interaction/
  mix_spatial_drag_test.dart        NEW
```

Make Isotopes model/view: unchanged behavior (bucket layout API generalized with Make callers updated).

---

## Tests

```text
flutter test test/isotopes_and_atomic_mass/
→ 101 PASS

dart analyze lib/chemistry/isotopes_and_atomic_mass
→ No issues found
```

Coverage groups: bucket spatial, drag/drop/boundary, mode switch saves, Nature spatial, My↔Nature, clear/reset/element/lifecycle, slider quantity spatial.

---

## Known Differences

1. Nature atom **pool reuse** → recreate list (same counts/random placement contract).
2. Overlap adjust is a **simplified** repulsion vs PhET’s full force iteration (same containment; ≤100 gate kept).
3. Restore assigns **new ids** (PhET keeps object identity); positions/mass preserved.
4. Slider-mode drag is not a PhET UX path; model still defines safe cancel/end for completeness.

---

## UI Gate

```text
Mix UI: NOT STARTED
```

No Widget / GestureDetector / CustomPainter / Canvas for Mix.

**Stop here.** Next: PHASE 7 Mix View / Controller / Canvas / Widgets.
