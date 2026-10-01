# FULL_USER_JOURNEY_SPEC_PHASE8

> Behavioral acceptance — user intent → control → Model → View → cleanup.
> Models / LayoutSpecs / Golden frozen unless interaction geometry fails.

## Launch → Screen path

```
Launch app (QM host)
→ Coins (default Classical)
→ Photons
→ Spin
→ Bloch
→ Cross transitions
→ Reset All (per screen)
→ Leave / Re-enter
```

Home / Android navigation are **out of scope** (NOT STARTED).

---

## Shared rules

| Concern | Source rule |
|---|---|
| Scene persistence | Coins Classical/Quantum each keep own `CoinsExperimentSceneModel`; switch does **not** reset |
| Photons modes | Single vs Many are separate scenes; Classical/Quantum = `photonBehaviorMode` on active scene |
| Spin experiment switch | Clears in-flight particles (`simulation.clear()`), applies experiment config |
| Bloch Erase | `resetCounts` only |
| Bloch Reset All | `model.reset()` → +X prepared |
| Dispose | Photons/Spin/Bloch tickers disposed; Continuous emissionRate=0 |

---

## Coins journeys

### C1 Classical default
- **Initial**: preparing=true, classical scene active, bias 0.5  
- **Expect**: Coin Bias slider visible; Flip/Reveal hidden; Start Measurement arrow present  

### C2 Flip
- Start Measurement → Flip  
- **Model**: `prepare` → measuredAndHidden (classical)  
- **View**: coin masked until Reveal  

### C3 Reveal / Hide
- Reveal → `revealed`; Hide → `measuredAndHidden` (not model.reset)

### C4 Flip and Reveal
- One action: prepare(revealWhenPrepared:true) → ends `revealed`

### Q1–Q4 Quantum
- Reprepare = prepare without sampling until Observe  
- Observe = sample + reveal  
- Reprepare and Observe = prepare then reveal  

### Count 10 / 100 / 10000
- Changing count updates `coinSet.numberOfCoins`; 10000 uses `Coins10kPainter` (100×100)

### Scene persistence
- Classical mutate → Quantum → Classical: classical state retained

---

## Photons journeys

### P1 Single
- Fire one emission path; one resolution event increments detector counts  

### P2 Single ×2
- Second Single after completion is allowed (independent event)

### Classical vs Quantum
- Classical: one path outcome  
- Quantum: SPLIT semantics at model level (`PhotonPathOutcome.split` return); counts still one detection sample  

### Continuous
- Many Photons + playing + emissionRate > 0 → multiple photons  
- Stop (pause / rate 0) → no new emissions after interval  

### Continuous → Single / Leave
- Switch mode or dispose → ticker disposed; no leaked emission  

---

## Spin journeys

### Experiments 1→6→Custom
- Selector updates apparatus visibility / orientation  

### Single
- Fire → exactly one particle trajectory → counts update  

### Block Up / Down
- Continuous multi-SG only; blocker hides branch per config  

### Continuous
- Cont. mode + amount → stream; stop clears rate  

### Experiment during Continuous
- Switch experiment → `clear()` particles + applyExperiment (source: clear stale particles)

---

## Bloch journeys

### Presets ±X±Y±Z
- Combo → `setSpinState` → prep + measure spheres sync  

### Observe / collapse / repeat
- Observe collapses; second Observe after Reprepare uses preparation; without Reprepare button is Reprepare  

### Magnetic Field
- ON → Observe becomes Start → TIMING → φ precession via `step(dt)`  

### Erase vs Reset
- Erase clears histogram; Reset All full model  

---

## Cross-screen

Independent Model instances; mutating Coins must not change Photons/Spin/Bloch.

## Leave / Re-enter

Dispose screen widget → no ticker; re-enter creates fresh tickers; Model may be re-injected to test persistence vs reset.
