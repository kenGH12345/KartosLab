# Balancing Act — Phase 1 Model Report

> **req-id**: `req-port-balancing-act`  
> **Date**: 2026-09-23  
> **Scope**: Model + Physics + Core Interaction Semantics + Tests  
> **Gate**: **PASS**

---

## 1. Model Architecture

```
lib/balancing_act/
├── balancing_act.dart                 # barrel
├── ba_shared_constants.dart           # BASharedConstants + BaGeometry + BaGameConstants
└── model/
    ├── ba_vector2.dart
    ├── ba_enums.dart                  # ColumnState, PositionIndicatorChoice, …
    ├── ba_mass.dart                   # Mass + catalog
    ├── mass_force_vector.dart         # display force only
    ├── plank.dart                     # physics core
    ├── balance_model.dart             # Intro/Lab base
    ├── ba_intro_model.dart
    ├── balance_lab_model.dart         # + LabCarouselState + BalanceViewProperties
    └── game/
        ├── balance_game_challenge.dart  # dataset schema + DeterministicChallengeFactory
        └── balance_game_model.dart      # independent Game model
```

Semantic hierarchy (matches PhET):

```
BAIntroModel ─┐
BalanceLabModel ┼─► BalanceModel ─► Plank + Masses
BalanceGameModel (standalone; own Plank)
```

**No View / Home / Screen UI** in this phase.

---

## 2. Physics Constants

| Constant | Value | Source |
|----------|-------|--------|
| `PLANK_LENGTH` | 4.5 m | Plank.ts |
| `PLANK_THICKNESS` | 0.05 m | |
| `PLANK_MASS` | 75 kg | |
| `INTER_SNAP` | 0.25 m | |
| `NUM_SNAP` | 17 | |
| `I` | `75*(4.5²+0.05²)/12` | |
| `PLANK_HEIGHT` | 0.75 m | BalanceModel.ts |
| `FULCRUM_HEIGHT` / pivot | 0.85 m @ (0, 0.85) | |
| `maxTiltAngle` | `asin(1/3)` | |
| `COMPARISON_TOLERANCE` | 1e-6 | BASharedConstants |
| Display g | −9.8 | MassForceVector.ts |
| Damping | 0.91 / step | Plank.step |
| LAYOUT | 768×504 | |

---

## 3. Physics Equations (SOURCE TRUTH)

**Dynamics torque** (no g):

```
τ_masses = Σ( pivotX − x_i · m_i )   // literal operator precedence
τ_plank  = (pivotX − bottomCenterX) · 75
τ_net    = τ_masses + τ_plank   // only if ColumnState.NO_COLUMNS else 0
```

**Display force** (view vectors only):

```
F = (0, m · (−9.8))
```

**Balance**:

```
isBalanced ⇔ |Σ(m · d_surface)| < 1e-6   // strict <
```

---

## 4. Update Order (`Plank.step`)

```
1. updateNetTorque()
2. α = τ / I ; zero if |α| ≤ 1e-5
3. ω += α                    // NOT ω += α·dt
4. zero ω if |ω| ≤ 1e-5
5. θ_new = θ + ω·dt
6. clamp to ±maxTiltAngle or snap θ→0 if |θ|<1e-4
7. if θ changed → updatePlank + updateMassPositions
8. ω *= 0.91
9. update activeDropPositions
```

Locked by one-step + multi-step oracles in `angular_dynamics_test.dart`.

---

## 5. Balance Semantics

- Uses **signed surface distance** stored at drop (`massDistancePairs`), not live Cartesian for `isBalanced`.
- Ignores support columns.
- Threshold: **strict `< 1e-6`** (equal → not balanced).

---

## 6. Mass Model

- `BaMass`: massValue, position, rotation, onPlank, userControlled, animation fields, type, height.
- Catalog: all PhET image masses (kg), BrickStack (`n×5`), Mystery A–H default values.
- Intro seeds: 2× FireExtinguisher 5 kg @ (2.7,0)/(3.2,0); SmallTrashCan 10 kg @ (3.7,0).
- Pivot **fixed** — no drag-pivot API.

---

## 7. Snap Semantics

Not `round(x/0.25)*0.25`. Algorithm from `getOpenMassDroppedPosition`:

1. Build 17 rotated snap points at 0.25 m.
2. Remove center (fulcrum).
3. Exclude occupied (`dist < 0.025`) and far (`|Δx| > 0.5`).
4. Among remaining with `|Δx| ≤ 0.25`, pick closest by Euclidean distance.

During drag: **continuous**. On release: **snap**.

---

## 8. Drag / Drop Semantics

| Screen | Miss behavior |
|--------|---------------|
| Intro | In viewport model-X → `y=0`; else position reset |
| Lab | `initiateAnimation` back to toolbox → remove |
| Game | movable → `(3, 0)` |

Pick-up: `beginDrag` removes from plank surface.

---

## 9. AB Switch

| A | B |
|---|---|
| `ColumnState.doubleColumns` | `ColumnState.noColumns` |

API: `setSupportsEnabled(bool)`. DOUBLE forces θ=0, ω=0; NO allows free dynamics.  
(`SINGLE_COLUMN` used by Game challenges only.)

---

## 10. Show / Position

`BalanceViewProperties` (view-layer state, reset with Reset All):

| Property | Default |
|----------|---------|
| massLabelsVisible | true |
| forceVectorsFromObjectsVisible | false |
| levelIndicatorVisible | false |
| positionMarkerState | none / rulers / marks |

---

## 11. Carousel Model

`LabCarouselState` pages (non-stanford):

`bricks → people1 → people2 → mystery1 → mystery2`

No wrap; `next`/`previous` clamp; `reset` → index 0.

---

## 12. Game Model

`BalanceGameModel` independent of `BalanceModel`.

States: choosingLevel → presenting → feedback → next / levelResults.

Scoring (source):

- Max 2 points/problem; 6 problems/level; max 12/level.
- First correct: 2; after 1 wrong: 1; maxAttempts=2.

Answer:

- Balance Me → `plank.isBalanced()` after columns off.
- Tilt → `getTorqueDueToMasses()` sign vs prediction (`=== 0` for balanced).
- Mass deduction → `mass == sum(fixed.massValue)`.

---

## 13. Game Dataset

`BaGameLevelDataset.challengeKindsForLevel(0..3)` mirrors `generateChallengeSet` switch (kind sequence).

`DeterministicChallengeFactory` supplies reproducible samples for tests.  
**Full random PhET factory** deferred (Vegas / P1 limitation).

---

## 14. Game Answer Semantics

See §12. Not copied from Balancing Chemical Equations.

---

## 15. Reset Semantics

| Model | Resets |
|-------|--------|
| BalanceModel | removeAllMasses; columns → DOUBLE |
| BAIntroModel | mass positions/rotations → seed; super |
| BalanceLabModel | clear all masses; carousel; super |
| BalanceGameModel | timer/level/score/state/columns/times/bestScores; clear plank |
| BalanceViewProperties | Show/Position defaults |

---

## 16. Vegas Boundary

| Required later | Phase 1 status |
|----------------|----------------|
| LevelSelectionButtonGroup / stars UI | Not implemented |
| GameAudioPlayer | Not implemented |
| FaceWithPointsNode / LevelCompletedNode | Not implemented |
| Random challenge uniqueness history | Replaced by DeterministicChallengeFactory |

Game **Model scoring / answer / progression** fully testable without Vegas.

---

## 17. Test Matrix

| Area | File | Coverage |
|------|------|----------|
| Balance A–E + force vs torque | physics_test.dart | Cases A–E, g separation |
| Angular oracle | angular_dynamics_test.dart | 1-step, multi-step, columns, maxTilt |
| Snap | snap_test.dart | grid, center, midpoint, occupy, bounds |
| Drag/AB/Show/Carousel/Reset/Mass | interaction_model_test.dart | Intro/Lab semantics |
| Game dataset/answer/progress | game_model_test.dart | scoring 2/1, tilt, deduction, next |

---

## 18. Test Count

| | Count |
|--|------:|
| Previous balancing_act tests | 0 |
| Added | **39** |
| Final | **39** PASS |

---

## 19. Analyze

```
dart analyze lib/balancing_act test/balancing_act
→ No issues found!
```

---

## 20. P0 / P1 / P2

### P0 — 0

### P1 — 2
1. Full random `BalanceGameChallengeFactory` not ported (deterministic adapter only).
2. Frame-rate sensitivity of `ω += α` / `×0.91` — locked by oracle; Flutter clock strategy for View phase TBD.

### P2 — 3
1. Regional people image selection not in model (catalog types only).
2. Stanford mystery mass table / query param not wired.
3. Vegas audio/celebration remaining for later phases.

---

## 21. Known Limitations

- No ScreenView / painters / assets wired.
- Intro drop viewport bounds derived from MVT constants (ported into model for testability).
- Game challenges for production need random factory + uniqueness history.
- Home untouched.

---

## PHASE 1 STATUS: PASS
