# PHASE 5 BEHAVIORAL REPORT

## Method

Automated Model + Host widget paths in `test/buoyancy/phase5_behavioral_test.dart` (+ goldens for visual state). Manual PhET live compare deferred (no attached screenshots this turn).

## Paths

### Compare — PASS

Enter → change mode → drag A then B → reset.

| Check | Result |
|-------|--------|
| Drag follow (ray ∩ z=0) | PASS |
| No teleport (only +0.0001 m lift) | PASS |
| A/B identity preserved | PASS |
| Mass/volume not corrupted by drag | PASS |
| Reset → sameMass / 4 kg | PASS |

### Explore — PASS

Material / mode / drag / sink vs float / reset.

| Check | Result |
|-------|--------|
| material → density → mass | PASS (existing + PHASE5) |
| aluminum sinks vs wood | PASS |
| Reset mode/material/visibility | PASS |

### Lab — PASS

Gravity / fluid density / forces / reset.

| Check | Result |
|-------|--------|
| F_g = (0, −mg) | PASS |
| F_b = (0, ρ V_sub g) | PASS |
| Higher g → higher \|F_g\| | PASS |
| Honey > water buoyancy when submerged | PASS |
| Reset gravity/fluid/force flags | PASS |

### Shapes — PASS (duck separation)

| Check | Result |
|-------|--------|
| Duck visual = DuckSourceMesh | PASS |
| Duck ≠ ellipsoid vertex count | PASS |
| Physics kind remains duck (ellipsoid displacement approx) | PASS (model contract) |
| Reset → block wood | PASS |

### Applications — PASS with caveat

| Check | Result |
|-------|--------|
| Bottle mesh elongated (not stub cylinder) | PASS |
| Boat ONE_LITER bounds | PASS |
| Waterline tracks `pool.fluidY` | PASS |
| Reset → bottle mode / interior 0.004 | PASS |
| Boat cabin basin coupling | **DEFERRED** (not claimed) |

## Drag / pointer

| Case | Result |
|------|--------|
| view→ray→z0 ≈ model near lookAt | PASS (±0.1 m) |
| +x → larger screen x (no axis invert) | PASS |
| Edge / small viewport rays finite | PASS |
| start/move/end clears userControlled | PASS |

## Reset / lifecycle

| Case | Result |
|------|--------|
| Injected Screen models not disposed by Screen | PASS (PHASE5 fix) |
| Host A→B→A preserves Compare mode | PASS |
| Inactive models paused; active resumed | PASS |
| Host dispose clean | PASS |

## Determinism

| Case | Result |
|------|--------|
| Lab snapshot ×3 identical | PASS |
| Explore drag+steps end pose ×3 | PASS |

## Physical sanity

Invariants checked; no new formulas introduced.

**p2 integration equivalence = APPROXIMATE** (frozen P1) — not hidden.

## Behavioral Acceptance verdict

**PASS** for automated user-path coverage above.

Remaining behavioral risk: Applications full cabin fill/spill vs p2 (DEFERRED); live PhET pixel parity (no screenshots).
