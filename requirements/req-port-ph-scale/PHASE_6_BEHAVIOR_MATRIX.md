# PHASE 6 — Behavior Matrix

**req-id:** `req-port-ph-scale`  
**truth:** Local PhET source > Flutter  

Screens use **independent** models (`MacroScreen` / `MicroScreen` / `MySolutionScreen` each `createModel` once). Joist keeps instances across switch — Flutter must KeepAlive tab State.

---

## Screen × state

| Category | Initial | Acid | Neutral | Base | Extreme | Reset |
|---|---|---|---|---|---|---|
| Macro | ✓ | ✓ (solute/dropper) | ✓ (water) | ✓ | ✓ (pH −1…15 via dilution extremes N/A UI) | ✓ |
| Micro | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ model+view+graph |
| My Solution | ✓ pH7 V0.5 | ✓ spinner/graph | ✓ | ✓ | ✓ clamp [−1,15] | ✓ |
| Ratio | N/A Macro | ✓ Micro/MySol | ✓ 50/50 | ✓ | ✓ | ✓ toggle off |
| Counts | N/A Macro | ✓ | ✓ Avogadro | ✓ | ✓ | ✓ toggle off |
| Graph | N/A Macro | ✓ Micro RO | ✓ | ✓ | ✓ finite | ✓ units/scale/exp |
| Graph drag | N/A | N/A Micro | — | — | ✓ clamp | N/A MySol only |

---

## Cross-screen

| Transition | Source intent | Flutter gate |
|---|---|---|
| Macro → Micro | Independent models; each preserves own state | KeepAlive + independent instances |
| Micro → My Solution | Independent | KeepAlive |
| My Solution → Macro | Independent | KeepAlive |
| Shared solution across tabs | **NO** | Must NOT share |

---

## Reset All

| Item | Macro | Micro | My Solution |
|---|---|---|---|
| volumes / autofill 0.5 L water | ✓ | ✓ | volume→0.5 |
| solute → water | ✓ | ✓ | N/A |
| pH | derived | derived | → 7 |
| faucets / dropper | ✓ | ✓ | N/A |
| probe / meter | ✓ | N/A | N/A |
| ratio / counts toggles | N/A | → false | → false |
| graph units/scale/expanded/exp | N/A | ✓ | ✓ |
| accordion expanded | N/A | ✓ (SOURCE) | ✓ |

---

## Interaction notes (SOURCE)

- Faucet maxFlowRate **0.25 L/s**; Dropper **0.05 L/s**; Autofill dropper **0.45 L/s** → **0.5 L**
- My Solution pH: spinner ±0.01, clamp [−1,15]; **no free-text**; invalid = clamp/disable
- Graph drag My Solution only; totalVolume==0 → no-op; pH clamp after map
- Probe out of fluid → displayed pH **null**
- SimulationClock `toImage` hang = **VISUAL-HARNESS ISSUE** only

---

## Test mapping

| Gate | Automated |
|---|---|
| Macro chemistry / autofill / faucet / reset | `phase6_behavior_test.dart` + existing chemistry |
| Micro Ratio/Counts sync | phase6 + ratio tests |
| My Solution edit / clamp / graph drag | phase6 + graph_math |
| Cross-screen independence | phase6 |
| KeepAlive / lifecycle dispose | phase6 widget |
| Extreme / scientific notation | phase6 + existing |
| SimulationClock harness | documented HARNESS |
