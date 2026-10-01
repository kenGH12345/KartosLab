# PHASE 1 — MODEL REGRESSION · Faraday's Law

## Test Matrix

| Category | Cases | Result |
|----------|-------|--------|
| Initial | default magnet / polarity / coils / visibility / voltage | PASS |
| Magnet | position, bounds, flip twice, reset | PASS |
| Polarity | NS/SN B sign, EMF sign flip | PASS |
| Coil | N=2 / N=1, topCoilVisible on/off | PASS |
| Field | on/off, move, flip arrow flag | PASS |
| B | near / far / sign / default-position regression | PASS |
| EMF | stationary / moving / reverse / speed | PASS |
| Voltage | zero / + / − / settle | PASS |
| Voltmeter | signal 0.2, needle dynamics, clamp ±π/2 | PASS |
| Bulb | zero / + / − same brightness / threshold | PASS |
| Clock | dt≤0 no-op, dt>0.1 clamp | PASS |
| Reset | full restore including voltage (VD-02) | PASS |
| Drag bounds | magnet stays in 834×504 | PASS |

## Test Count

**49** (`flutter test test/faradays_law/` — all PASS)

## Key regression values

| Scenario | Expected |
|----------|----------|
| Default magnet (647,200), bottom coil (448,310), NS | `B ≈ -0.06275922714109236` |
| Magnet at coil center, NS | `B = -2` |
| Magnet at coil center, SN | `B = +2` |
| `signal` | `0.2 * (bottomEmf + topEmf)` |
| EMF | `N * ΔB / dt` with `N = spirals/2` |
| maxDT | step uses `min(dt, 0.1)` |

## Analyze

`No issues found` — `lib/faradays_law` + `test/faradays_law`

## VERSION_DELTA

| ID | Description | Phase 1 choice |
|----|-------------|----------------|
| VD-02 | Source `reset()` does not clear `voltageProperty` | Flutter `reset()` **clears** voltage + needle ω/α for deterministic initial state |
| VD-DT0 | Source does not guard `dt <= 0` | Flutter `step` no-ops when `dt <= 0` (safe for tests) |
| VD-DRAG | Source uses edge-line collision | Flutter uses AABB binary-search clamp against restricted rects + layout; physics chain tests use `setMagnetPositionForTest` |
| VD-03 | No electrons | Not modeled |
| VD-04 | No magnet strength | Not modeled |
| VD-05 | Field lines predefined | Ellipse specs only; no dipole solver |

## Notes for Phase 2

- Keep magnet between coil back and front layers.
- Read `voltage` / `clampedNeedleAngle` / `bulb.haloScale` from Model — do not recompute EMF in View.
- Field lines: paint `FieldLineGeometry.ellipses` centered on magnet.
