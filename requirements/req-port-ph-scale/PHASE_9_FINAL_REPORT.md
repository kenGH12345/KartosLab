# PHASE 9 FINAL VISUAL RECONCILIATION & RELEASE GATE

**req-id:** `req-port-ph-scale`  
**date:** 2026-09-22  

---

```text
PHASE 9 STATUS: PASS

FINAL STATUS: READY CANDIDATE
```

**Why not READY:** full 1024×618 screenshot matrix + pixel diff remain **BLOCKED** by `SimulationClock + toImage` harness (runtime behavior unchanged). Phase 5 Visual evidence therefore cannot be closed to **PASS**. Residual chrome is **P2 only**. Android runtime still **NOT VERIFIED**.

**Why not NOT READY:** P0 = 0, P1 = 0; Model / Behavior / Graph / Home / Regression / Analyze gates hold; structural visual formulas and original assets verified against local PhET source + official screenshots.

---

## A. Phase 5 Issue Reconciliation

| Old Issue | Class | Current State | Action |
|---|---|---|---|
| My Solution accordion left 40 vs 525 (**P0**) | A | Fixed (left = beaker.left = 525, top = 15) | None |
| Micro / My Solution Graph absolute placement (**P1**) | A | Fixed (Micro: drain.left−40; MySol: beaker.left−70) | None |
| Macro SoluteComboBox position/font (**P1**) | A | Fixed (left = beaker.left−20, top = 15, Arial 22) | None |
| NeutralIndicator position/font (**P1**) | A | Fixed (bottom = beaker.bottom−30, font 30) | None |
| Meter sliding PHIndicator (**P1**) | A | Sliding purple indicator + scale (source structure) | None |
| Arial / key font sizes (**P1**) | A | `PhScaleFonts` applied | None |
| Material AppBar vs joist footer (**P1** note) | B→P2 | Project TabBar pattern; navbar PNGs used | Accept as P2 / project chrome |
| Faucet / dropper Stack vs full FaucetNode | B | Still simplified Stack; **original PNGs** | P2 — no Phase 9 redesign |
| Graph indicator callout bevel | B | Approximate callout | P2 |
| Micro / MySol probe stick chrome | B | Simplified stick (source accordion probe) | P2 |
| ABSwitch / sun skin | B | Simplified toggle | P2 |
| Full 1024×618 screenshot matrix | C | Still incomplete | Harness — do not alter SimulationClock |
| Pixel diff vs official PNG | C | Not completed | Harness / evidence gap |
| SimulationClock + toImage hang | C | Confirmed harness-only | Documented; runtime unchanged |
| Environment / platform raster noise | D | N/A without capture | — |
| New structural mismatch found in Phase 9 | E | **None** requiring code fix | Code changes = tests + docs only |

### Classification summary

```text
A. Resolved:          structural P0/P1 from Phase 5 audit
B. Still present:     P2 chrome only
C. Harness:           screenshot matrix / toImage hang
D. Environment:       platform font/AA (no capture)
E. Needs code fix:    0 (production View)
```

---

## B. Visual Matrix

Evidence basis:

1. Local PhET source layout formulas (re-verified in code)  
2. Official assets: `ph-scale-screenshot-screen{1,2,3}.png` (manual structural compare)  
3. Widget structural tests (`phase9_visual_structure_test.dart`) — **no toImage**  
4. Automated PNG capture: **BLOCKED**

| Screen | State | Result | Evidence |
|---|---|---|---|
| Macro | Initial | **PASS*** | Structure + Neutral/combo/faucet/dropper/Reset |
| Macro | Acid | **PASS*** | Behavior Phase 6 + meter slides with pH |
| Macro | Base | **PASS*** | Same |
| Macro | Neutral | **PASS*** | Neutral badge + water autofill |
| Macro | Probe / Reset | **PASS*** | Phase 6 + Reset All present |
| Micro | Initial | **PASS*** | Graph Concentration + Logarithmic/Linear |
| Micro | Ratio | **PASS*** | Checkbox + Ratio layer (Phase 3/6) |
| Micro | Counts | **PASS*** | Particle Counts panel |
| Micro | Reset | **PASS*** | Phase 6 |
| My Solution | Initial | **PASS*** | accordion @ beaker.left; pH 7.00; no faucet |
| My Solution | Drag | **PASS*** | Graph drag → pH (Phase 4/6; not re-audited as behavior change) |
| My Solution | Ratio / Counts | **PASS*** | Same control panel as Micro |
| My Solution | Reset | **PASS*** | Phase 6 |

\* **PASS\*** = structural / behavioral PASS; **not** pixel-diff PASS.

### Visual Screenshot Harness

```text
Visual Screenshot Harness:
BLOCKED / LIMITED

Reason:
SimulationClock + toImage hangs in current harness.

Runtime behavior:
UNCHANGED
```

No SimulationClock / animation / fake-frame / screenshot-only UI changes in Phase 9.

---

## C. Assets

```text
Original Assets: 19 PNG (faucet + dropper + 6 screen icons)
Substituted: 0
```

Map: `ASSET_MAP.md`

- Faucet / dropper / navbar icons: original PhET / scenery-phet PNGs  
- Home catalog icon: Material `Icons.science_outlined` — **KartosLab Home convention** (same as sibling sims; not sim chrome)  
- Ratio particles / molecules / beaker / scale: procedural = source Canvas / Node approach  

---

## D. Tests

```text
pH Scale Tests: 94 PASS  (88 → 94; +6 phase9_visual_structure_test)
Analyze: CLEAN (lib/chemistry/ph_scale; also lib+test after minor `!` cleanup)
Full Regression: Phase 7 baseline — 3119 pass / 1 skip / 56 pre-existing
  pH Scale-related failures: 0
```

Phase 9 did **not** re-run full-repo `flutter test` (View/docs/tests only; no shared Home/nav change).

---

## E. Home

```text
Home: PASS (Phase 8; no Phase 9 Home edits)
Default Screen: Macro (initialIndex 0)
Navigation: 化学 → 溶液与浓度 → pH 标度 → PhScaleScreen
Lifecycle: PASS
Reset: PASS
```

No Home regression introduced (CODE CHANGES to Home = 0).

---

## F. Platform

| Platform | Status |
|---|---|
| Windows | widget tests PASS (this machine) |
| Chrome | NOT VERIFIED |
| Edge | NOT VERIFIED |
| Android Build | PASS (Phase 7 Debug APK) |
| Android Runtime | **NOT VERIFIED** |

---

## G. Issue Count

```text
P0: 0
P1: 0
P2: 5 (documented)
```

### P2 list

1. FaucetNode Stack assembly incomplete vs full scenery-phet FaucetNode (flange/shaft/track unused)  
2. Graph indicator callout bevel / pointer geometry approximate  
3. Micro / My Solution probe tip chrome simplified vs full ProbeNode  
4. ABSwitch skin ≠ scenery-phet ABSwitch  
5. AppBar + TabBar ≠ joist black navbar (project pattern; original navbar icons used)

---

## H. Final Gate

```text
[x] Model
[x] Behavior
[ ] Visual          ← structural PASS; pixel evidence BLOCKED → cannot mark PASS
[x] Regression      ← Phase 7 baseline; ph_scale green
[x] Home
[x] Analyze
[x] Assets          ← Substituted = 0
[x] Platform status explicitly reported
```

### Phase summary

| Phase | Status |
|---|---|
| 0 Source Audit | PASS |
| 1 Model | PASS |
| 2 Core Interaction | PASS |
| 3 Ratio / Particle Counts | PASS |
| 4 Graph | PASS |
| 5 Visual Reconstruction | **PARTIAL** (unchanged — harness) |
| 6 Behavior Matrix | PASS |
| 7 Regression | PASS |
| 8 Home Integration | PASS |
| 9 Final Reconciliation | **PASS** (decision issued) |

---

## Code changes this phase

```text
Production View / Model / Home: 0 functional fixes required
Added:
  - test/chemistry/ph_scale/phase9_visual_structure_test.dart (+6)
  - requirements/req-port-ph-scale/ASSET_MAP.md
  - requirements/req-port-ph-scale/PHASE_9_FINAL_REPORT.md
Cleanup:
  - unnecessary `!` in ratio_particle_counts_test.dart (analyze noise)
```

---

## Known Issues

1. **Visual evidence incomplete** — cannot claim Visual = PASS or Overall READY  
2. **SimulationClock + toImage** harness hang — do not disable clock for screenshots  
3. **P2 chrome** listed above — deferred polish  
4. **Android Runtime NOT VERIFIED**  
5. Phase 5 remains **PARTIAL** in meta (honest continuity)

---

## Final Verdict

```text
FINAL STATUS: READY CANDIDATE
```

Ship-ready for functional / Home / Model / Behavior acceptance with residual visual-chrome P2 and incomplete pixel evidence. Promote to **READY** only after:

1. Screenshot matrix (or alternate harness that does not alter production timing) completes, **and**  
2. Structural pixel review clears P1-class mismatches (expect none), **and**  
3. Optionally Android runtime Home → pH Scale verified.

**Stop here — no further refactor.**
