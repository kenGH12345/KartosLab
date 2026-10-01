# PHASE 4 — DYNAMIC BEHAVIOR REPORT · Faraday's Law

## Status

```
Phase 4 = COMPLETE
CODE CHANGES (lib/) = 0
Overall = NOT_READY
Home = NOT STARTED
Android = NOT VERIFIED
```

## Verdict

Dynamic chain is source-defined and continuous:

`Magnet position → B → ΔB/dt → N·ΔB/dt → signal → voltage dynamics → needle + bulb(|V|)`

Polarity and coil configuration alter Model state as in Phase 1; View only reads Model and calls `model.step(dt)` from `SimulationClock`.

## Gates

| Gate | Result |
| --- | --- |
| Stationary | PASS — EMF~0; voltage does not climb; settles near 0 |
| Slow motion | PASS — continuous B/EMF/signal; EMF = N·ΔB/dt identity |
| Fast motion | PASS — smaller dt / larger rate → larger \|EMF\| (source formula) |
| Direction reversal | PASS — toward vs away flips EMF sign; bulb uses \|V\| |
| Stop / settling | PASS — EMF→0 next frames; voltage damps (not frozen at peak); ≠ reset() |
| Polarity NS/SN | PASS — same trajectory flips EMF sign |
| Double flip | PASS — state + response restore |
| 1 / 2 coil | PASS — top coil stepped only when visible; signal differs |
| Field lines dynamic | PASS — geometry tracks position/polarity; visibility independent of EMF |
| Voltmeter dynamic | PASS — ± drive; clamp ±π/2; signal 0.2·Σemf |
| Bulb dynamic | PASS — +V/−V symmetry; \|V\| mapping |
| Control during motion | PASS — Field/Voltmeter toggles do not reset physics |
| Reset during motion | PASS — full initial + VD-02 voltage clear |
| Dispose during motion | PASS — no throw; clock detached; model usable |
| Clock / dt | PASS — ≤0 no-op; >0.1 clamp to 0.1 |
| Frame independence | PASS — same end position → same B |
| No View-side physics | PASS — **View Physics Calculations = 0** |
| No electron regression | PASS — no particle / charge animation added |
| Phase 1–3 regression | PASS |
| Analyze | CLEAN |

## Model → View chain (runtime)

```
Gesture / control
  → FaradaysLawModel (position / polarity / visibility / coil mode)
  → SimulationClock.onTick(dt)
  → FaradaysLawModel.step(dt)
  → Coil.step / VoltmeterModel.step
  → ChangeNotifier
  → PlayArea setState
  → painters/widgets read Model only
```

## Tests

| Suite | Count (approx) |
| --- | --- |
| Phase 1 model | 49 |
| Phase 2 view | 10 |
| Phase 3 controls | 10 |
| Phase 4 dynamic | 36 |
| **Total** | **105 PASS** |

```bash
flutter test test/faradays_law/   # 105 PASS
dart analyze lib/faradays_law test/faradays_law  # No issues found
```

## P0 / P1 / P2

| Severity | Count |
| --- | --- |
| P0 | 0 |
| P1 | 0 |
| P2 | recorded (Phase 2/3 visual + none new for dynamics) |

No new dynamic P2 blockers. Existing visual P2 (P2-01…P2-05, P2-C1…C3) unchanged.

## View Physics Calculations

**0** — grep `lib/faradays_law/view/` for `voltage=` / `emf=` / `deltaB` / brightness formulas: none. Play area only `model.step(dt)`.

## VERSION_DELTA (unchanged)

| ID | Notes |
| --- | --- |
| VD-02 | `reset()` immediately clears voltage / needle dynamics |
| VD-SOUND | Sound not ported |
| VD-A11Y | Keyboard / a11y not ported |
| VD-DRAG | Drag UX differences vs GrabDragInteraction (if any) recorded prior |

No new VD for Phase 4.

## Substituted assets

**0**

## Out of scope (confirmed not done)

- Home / navigation
- Phase 5 Final Visual QA
- New controls (strength, electrons, pause, speed)
- Model semantics changes
