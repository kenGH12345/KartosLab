# PHASE 8 STATUS

```
PHASE 8 STATUS

Scope:
Behavioral Acceptance + Full User Journey

Coins Classical:
PASS

Coins Quantum:
PASS

Coins Count Modes:
PASS

Coins Scene Persistence:
PASS

Photons Single:
PASS

Photons Classical:
PASS

Photons Quantum:
PASS

Photons Continuous:
PASS

Photons Lifecycle:
PASS

Spin Experiments:
PASS

Spin SGx / SGz:
PASS

Spin Block Up:
PASS

Spin Block Down:
PASS

Spin Single:
PASS

Spin Continuous:
PASS

Spin Custom:
PASS

Bloch Presets:
PASS

Bloch Measurement:
PASS

Bloch Collapse:
PASS

Bloch Magnetic Field:
PASS

Bloch Erase:
PASS

Bloch Reset:
PASS

Cross-Screen Isolation:
PASS

Rapid Screen Switching:
PASS

Reset During Animation:
PASS

Reset During Continuous:
PASS

Double Action / Spam:
PASS

Hit Targets:
PASS (Block chips overflow fixed)

Semantics:
PASS (controls retain labels / enabled state; no invented a11y)

Lifecycle Stress:
PASS (rapid enter/exit ×10 + Cont leave)

Seeded Replay:
PASS

Full User Journey:
PASS

Performance:
PASS (dispose stops tickers; no accumulation under rapid switch)

Regression:
PASS

Model Tests:
included in Full QM

Golden:
30 / 30 PNG baseline retained (qm_visual_golden_test PASS)

Full QM:
200 PASS

Analyze:
- User-path widget tests drive taps on real controls (not API-only).
- Spin/Bloch live Tickers forbid pumpAndSettle; tests use bounded pump frames.
- Continuous stop verified as emissionRate=0 with photon count never increasing (absorbs OK).
- Erase ≠ Reset All retained.
- One P1 hit-target: Block ↓ overflow — fixed with Wrap + wider chip box only.
- No Model physics refactor. No Golden redesign. No Home / Android.

P0:
none

P1:
none open (Block chip overflow closed in this phase)

P2:
none filed

Android:
NOT VERIFIED

Home:
NOT STARTED

Status:
READY CANDIDATE

Product:
NOT READY
```

---

## Docs produced

| Doc | Path |
|---|---|
| User Journey Spec | `FULL_USER_JOURNEY_SPEC_PHASE8.md` |
| Behavior Matrix | `BEHAVIOR_MATRIX_PHASE8.md` |
| State Machine Audit | `STATE_MACHINE_AUDIT_PHASE8.md` |
| Behavioral Evidence | `BEHAVIORAL_EVIDENCE_PHASE8.md` |
| This report | `PHASE_8_REPORT.md` |
| Behavior suite | `test/quantum_measurement/phase8_behavior_test.dart` (33 PASS) |

---

## A. User Journey Matrix

| Case | Screen | User Intent | Actions | Expected Result | Actual | Status |
|---|---|---|---|---|---|---|
| C1 | Coins | See default Classical | enter | preparing; Flip hidden | same | PASS |
| C2–C4 | Coins | Flip / Reveal / Hide / Flip+Reveal | Start → taps | states match source | same | PASS |
| Q1–Q3 | Coins | Reprepare ≠ Observe | Quantum path | ready then revealed | same | PASS |
| CNT | Coins | Change sample size | 10/100/10000 | counts + 10k canvas | same | PASS |
| PER | Coins | Keep Classical after Quantum | switch scenes | classical retained | same | PASS |
| P1 | Photons | Fire one photon | source / resolve | one detection event | same | PASS |
| P-CQ | Photons | Switch Classical/Quantum | radios | mode sync | same | PASS |
| P-CONT | Photons | Run then stop stream | rate→0 | no new photons | same | PASS |
| P-LIFE | Photons | Leave while Cont | dispose | screen gone | same | PASS |
| S-EXP | Spin | Change experiment | selector | Exp2 / Custom | same | PASS |
| S-1 | Spin | One particle | Single fire | 1 particle | same | PASS |
| S-BLK | Spin | Block branches | Cont + Block chips | blockDown/Up | same | PASS |
| B-PRE | Bloch | Set Bloch presets | dropdown ±axes | spinState sync | same | PASS |
| B-OBS | Bloch | Measure + Erase | Observe / Erase / Reset | Erase≠Reset | same | PASS |
| B-MF | Bloch | Precession then collapse | B-field + step | observed | same | PASS |
| JOURNEY | All | Full tour | long path | all steps OK | same | PASS |

---

## B. State Synchronization

| Screen | Action | Model State | View State | Animation State | Sync |
|---|---|---|---|---|---|
| Coins | Flip | measuredAndHidden | masked | idle | PASS |
| Coins | Reveal | revealed | face | idle | PASS |
| Coins | Observe | revealed | face | idle | PASS |
| Photons | Cont stop | emissionRate=0 | no new sprites | ticker idle path | PASS |
| Spin | Block ↓ | blockDown | chips + apparatus | clear particles | PASS |
| Spin | Exp switch | new experiment | selector label | particles cleared | PASS |
| Bloch | Observe | observed | vector collapsed | no precession | PASS |
| Bloch | Erase | counts 0; polar kept | hist empty | idle | PASS |
| Bloch | Reset All | +X prepared | default | speeds 0 | PASS |

---

## C. Lifecycle

| Screen | Enter | Active Resource | Leave | Expected Cleanup | Result |
|---|---|---|---|---|---|
| Photons | pump screen | PhotonAnimationController ticker | pump empty | dispose / no screen | PASS |
| Spin | pump screen | SpinAnimationController ticker | pump empty | dispose | PASS |
| Bloch | pump screen | BlochAnimationController ticker | pump empty | dispose | PASS |
| Cont ×10 | rapid four-screen loop | recreate models | final empty | no crash | PASS |
| Controllers | unit construct | ticker optional | dispose() | isRunning=false | PASS |

---

## D. Cross-Screen

| From | Action | To | Persistence | Isolation | Result |
|---|---|---|---|---|---|
| Coins | mutate Classical | Photons | Coins keeps own model | Photons independent | PASS |
| Photons | Quantum mode | Spin | Photons mode kept | Spin independent | PASS |
| Spin | Exp5 | Bloch | Spin Exp kept | Bloch independent | PASS |
| Bloch | +Y | Coins reset | Coins reset only | Bloch/Spin/Photons intact | PASS |
| Rapid | widget remount ×10 | next screen | N/A | dispose each mount | PASS |

---

## E. Regression

| Suite | Previous | Current | Result |
|---|---:|---:|---|
| Model (in Full QM) | included @167 | included @200 | PASS |
| Coins | 11+ (P3) | included | PASS |
| Photons | 18 (P4) | included | PASS |
| Spin | 17 (P5) | included | PASS |
| Bloch | 21 (P6) | included | PASS |
| Golden PNG | 30 | 30 | PASS |
| Behavior P8 | 0 | 33 | PASS |
| Full QM | 167 | **200** | PASS |

---

## Gates

```
Model + Visual(Golden) + Behavior + Lifecycle = PASS
Product = NOT READY
Home = NOT STARTED
Android = NOT VERIFIED
```
