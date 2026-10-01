# PHASE_3_INTERACTION_REPORT

> Updated: 2026-09-18  
> Scope: Make Isotopes **spatial / interaction model only** — UI untouched

---

## Gate

| Item | Result |
|---|---|
| Particle identities | **PASS** |
| Bucket particles | **PASS** (4 instances, unique ids) |
| Bucket positions | **PASS** (`SphereBucket.getFirstOpenPosition`) |
| Nucleus particles | **PASS** (protons + neutrons) |
| Nucleus positions | **PASS** (`ParticleAtom.reconfigureNucleus`) |
| Drag contract | **PASS** (`beginDrag` / `updateDrag` / `endDrag`) |
| Grab offset | **PASS** (`applyOffset: false` → 0) |
| Capture rule | **PASS** (`position.distance(atom) < 100`) |
| Release rule | **PASS** (else `addParticleNearestOpen`) |
| Capture radius | **PASS** (strict `< 100`) |
| Nucleus reconfigure | **PASS** (interleave + templates + spiral) |
| Position determinism | **PASS** |
| Particle conservation | **PASS** (bucket + nucleus + drag = constant) |
| Element switch | **PASS** (full rebuild = `initializeParticles`) |
| Same-element reselect | **PASS** (no-op) |
| Unstable jump | **PASS** (offset + translate nucleons) |
| Reset | **PASS** (spatial + counts) |
| Phase 1 regression | **PASS** (22) |
| Phase 2 regression | **PASS** (21) |
| New tests | **PASS** (19) |
| Analyze | **0 issues** |
| UI | **NOT STARTED** |

**P0 = 0**

---

## Source mapping

| Topic | Source | Flutter |
|---|---|---|
| Interaction chain | `IsotopesModel.ts` | `MakeIsotopesModel` |
| Capture | `placeNucleon`: `particle.position.distance(atom.position) < 100` | `endDrag` / `canCapture*` |
| Drag remove | `isDraggingProperty` → `container.removeParticle` | `beginDrag` |
| ParticleView drag | `SoundDragListener(positionProperty: destination, applyOffset: false)` | grab offset = 0; `updateDrag` sets center = pointer |
| Bucket geometry | phetcommon `SphereBucket.ts` | `SphereBucketLayout` |
| Bucket init | `addParticleFirstOpen(n, false)` × 4 | `_addNeutronToBucketFirstOpen` |
| Bucket return | `addParticleNearestOpen(n, true)` | `_addNeutronToBucketNearestOpen` (snap, no flight anim) |
| No refill | init only creates 4; transfers conserve | **confirmed — no auto-refill** |
| Nucleus layout | shred `ParticleAtom.reconfigureNucleus` | `NucleusReconfigure` |
| Jump | `IsotopesModel.step` sets `nucleusOffset`; `ParticleAtom` translates nucleons | `step` → `_setNucleusOffset` → `_translateNucleusParticles` |
| Element change | `initializeParticles`: clear + recreate all | `_initializeForElement` |
| Nucleon radius | `ShredConstants.NUCLEON_RADIUS = 10` | `kNucleonRadius` |
| Atom origin | `ParticleAtom.position` default (0,0); View moves via electron cloud | `atomX/Y` + `setAtomPosition` |

---

## Particle state

```
NucleonParticle
  id              // stable across bucket ↔ nucleus
  kind            // proton | neutron
  x, y / destX, destY
  zLayer
  isDragging
  container?      // bucket | nucleus | null (mid-drag)
```

Counts are **derived** from lists:

- `protonCount` = `_protons.length`
- `neutronCount` = `_nucleusNeutrons.length`
- `bucketNeutronCount` = `_bucketNeutrons.length`
- `totalNeutronCount` = nucleus + bucket + (dragging ? 1 : 0)

---

## Bucket state

- Position `(-220, -180)`, size `130×60`, sphere radius `10`
- `usableWidthProportion = 1.0`, `verticalParticleOffset = -4`
- Initial 4 neutrons via sequential `firstOpenPosition` (triangular stack)
- Remove → `relayout` dangling particles
- **No** auto-refill when transferring to nucleus

---

## Drag / Capture / Release contract

```
beginDrag(id, pointerX, pointerY)
  → remove from bucket|nucleus
  → isDragging=true, zLayer=0
  → placeAt(pointer)   // grabOffset = (0,0)

updateDrag(pointerX, pointerY)
  → move particle only (counts unchanged)

endDrag()
  → dist(particle.position, atom.position) < 100
       ? addToNucleus → reconfigureNucleus
       : addToBucketNearestOpen
```

Capture reference point = **neutron center vs atom position** (not nucleusOffset center).

---

## Nucleus reconfigure

Algorithm (deterministic):

1. Interleave neutrons/protons by `neutrons.length / protons.length`
2. Templates: 1 center / 2 side-by-side / 3 triangle / 4 diamond / ≥5 spiral
3. Center = `atomPosition + nucleusOffset`
4. Triggered on every add/remove nucleon (same as shred)

Phase 3 snaps position=destination (flight animation deferred to View phase).

---

## Unstable jump

- Period `0.1s`, preset angles/distances (Phase 2 constants)
- Changing offset **translates** all nucleus protons+neutrons by delta
- Stability change → offset reset to zero
- No `Random()` — fully deterministic sequences

---

## Conservation / identity

- Same neutron instance moves bucket → nucleus (and reverse)
- Element switch: all particles destroyed and new ids created
- Same-Z reselect: no particle/count/position change
- Protons never modified by neutron drag

---

## Files

```
lib/chemistry/isotopes_and_atomic_mass/model/
  iaam_vec2.dart
  nucleon_particle.dart
  nucleus_reconfigure.dart
  sphere_bucket_layout.dart
  make_isotopes_constants.dart   (+ kNucleonRadius, atom defaults)
  make_isotopes_model.dart       (extended)

test/isotopes_and_atomic_mass/make_isotopes_interaction/
  bucket_drag_capture_test.dart
  nucleus_invariants_jump_test.dart
```

---

## Tests

| Suite | Count |
|---|---|
| Phase 1 data | 22 PASS |
| Phase 2 make model | 21 PASS |
| Phase 3 interaction | 19 PASS |
| **Total** | **62 PASS** |

---

## Analyze

`dart analyze lib/chemistry/isotopes_and_atomic_mass test/isotopes_and_atomic_mass` → **0 issues**

---

## Known Differences

| Item | PhET | This phase |
|---|---|---|
| Particle flight to destination | `Particle.step` at ~200–300 px/s | Instant `placeAt` (snap) |
| Bucket return animate flag | `addParticleNearestOpen(..., true)` | Snap to nearest open |
| Atom position on scale | View updates from electron-cloud bounds | Default `(0,0)`; `setAtomPosition` ready for View |
| Touch grab offset | optional `touchOffset` in ParticleView | Model stores 0; View can supply later |
| Electron particles | created in initializeParticles | Count only (`electronCount = Z`); no spatial electrons yet |

None of these block Phase 4 View wiring.

---

## Remaining (NOT this phase)

- Phase 4: Make View / Widgets / Assets / Gestures
- Particle flight animation
- Mix Isotopes model/view
- Home integration

**UI: NOT STARTED** — stop here for Phase 3.
