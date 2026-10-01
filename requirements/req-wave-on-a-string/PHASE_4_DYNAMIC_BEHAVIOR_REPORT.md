# PHASE 4 — DYNAMIC BEHAVIOR REPORT

## Scope

Dynamic QA only. **CODE CHANGES = 0** (production). Added tests + reports only.

## Results

| Area | Result |
| ---- | ------ |
| Manual dynamic | PASS — displace → evolve propagation; release holds; repeated pulses leave history |
| Oscillate dynamic | PASS — 40+ frames periodic drive; live amp/freq without restart |
| Pulse dynamic | PASS — multi-frame triangular; width changes duration |
| Fixed / Loose / No End | PASS — source boundary rules under continuous drive |
| Reflection | PASS — Fixed LAST=0 + mid energy; Loose Neumann; No End nonzero LAST |
| Boundary switch | PASS — not ResetAll; Fixed → `zeroOutEndPoint` only |
| Damping | PASS — β path; damp=1 decays faster than damp=0 |
| Tension | PASS — higher tension → more evolves; α stays 1 |
| Pause / Play / Step | PASS — freezes model; Step deterministic; resume continuous |
| Slow / Normal | PASS — 0.25× phase; ordering Slow→Pause→Step→Play→Normal |
| Restart ≠ ResetAll | PASS |
| Tools | PASS — no wave reset; stopwatch = sim time |
| Determinism | PASS |
| Frame independence | PASS — FRAME slices, not widget FPS |
| Dispose | PASS — no setState-after-dispose |
| Performance | PASS — 1000-frame Oscillate; single clock; no 61 tickers |
| E2E A–H | PASS |
| View physics | 0 |
| Control physics | 0 |

## P0 / P1 / P2

- P0 = 0
- P1 = 0
- P2 = recorded from Phase 3 (slider chrome / Restart glyph approx) — not reopened

## VERSION_DELTA (unchanged)

VD-SOUND · VD-A11Y · VD-PHETIO · VD-LOCALE · VD-BEAD-CACHE
