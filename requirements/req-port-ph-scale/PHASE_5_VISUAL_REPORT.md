# PHASE 5 — Visual Report

**req-id:** `req-port-ph-scale`  
**date:** 2026-09-22  

---

## PHASE 5 STATUS

```text
PHASE 5 STATUS: PARTIAL
Overall Status: NOT READY
```

Reason for PARTIAL (not PASS): full 1024×618 screenshot matrix + pixel diff vs original not completed in-session (runtime capture hung on SimulationClock). Geometry / typography / meter structure P0–P1 fixes landed and unit/widget suite remains green. Pixel-level chrome still **CANDIDATE**.

---

## Viewport

```text
Source layoutBounds: 1100 × 700
Screenshot target:   1024 × 618 (FittedBox)
MVT: identity
```

---

## Screens

| Screen | Status | Notes |
|---|---|---|
| Macro | **CANDIDATE** | Sliding purple PHIndicator + scale; combo/neutral/fonts fixed |
| Micro | **CANDIDATE** | Graph right-align formula; accordion+probe; combo layout |
| My Solution | **CANDIDATE** | Accordion at beaker.left (P0 fixed); graph right = beaker.left−70 |

---

## Screenshot Matrix

| ID | Capture | Verdict |
|---|---|---|
| M1–M5 Macro | Manual / deferred | CANDIDATE (audited vs `assets/ph-scale-screenshot-screen1.png`) |
| MI1–MI8 Micro | Manual / deferred | CANDIDATE (vs `…-screen2.png`) |
| S1–S9 My Solution | Manual / deferred | CANDIDATE (vs `…-screen3.png`) |

Automated PNG capture deferred (clock/repaint hang). Official PhET assets used as reference.

Audit doc: `PHASE_5_VISUAL_AUDIT.md`

---

## Visual Audit (summary)

See `PHASE_5_VISUAL_AUDIT.md` for full table. Pre-fix P0: My Solution accordion at (40,40) vs source (525,15) — **fixed**.

---

## Macro

```text
PASS structure / CANDIDATE chrome
```

Fixes:

- SoluteComboBox: `left = beaker.left − 20`, `top = 15`, font 22 Arial  
- NeutralIndicator: `bottom = beaker.bottom − 30`, font 30  
- PH meter: **sliding** purple `PHIndicatorNode` (source-true), not fixed gray body  
- Scale tick fonts Arial 22 / neutral 28  
- ResetAll radius `20.8 × 1.32`  

Remaining: faucet/dropper Stack assembly vs full FaucetNode; joist bottom chrome (project uses TabBar).

---

## Micro

```text
CANDIDATE
```

Fixes:

- Graph: `right = drainFaucet.left − 40` (Flutter visual left estimate)  
- Heights 485 / 440 unchanged  
- pH accordion + probe stick; combo after accordion  
- Log tick font 22 Arial  
- Particle Counts / BeakerControl fonts Arial  

Remaining: Micro probe is simplified stick (not full scenery probe tip chrome); ABSwitch skin.

---

## My Solution

```text
CANDIDATE
```

Fixes:

- Accordion `left = beaker.left`, `top = 15` (**P0**)  
- Graph `right = beaker.left − 70`, log height 565  
- Spinner without Material InkWell  
- Probe stick into beaker  

Remaining: indicator callout bevel vs screenshot; drag arrow chrome polish.

---

## Graph

```text
PASS structure (Phase 4) / CANDIDATE chrome
```

Still **not curves** — vertical scale + H₂O / H₃O⁺ / OH⁻ indicators. Heights source-true. Tick font corrected to 22.

---

## Typography

```text
CANDIDATE → largely PASS for assigned sizes
```

`PhScaleFonts` (`fontFamily: Arial`) applied to meter, scale, beaker, volume, combo, graph ticks, particle counts, AB switch, accordion.

---

## Assets

```text
Original: faucet PNG, dropper PNG, screen icons — reused
Substituted: 0
```

Ratio particles remain programmatic flat circles (source Canvas). Molecule icons programmatic shaded spheres.

---

## Tests

```text
flutter test test/chemistry/ph_scale/
→ 66 PASS  (same count as Phase 4; no regressions)

dart analyze lib/chemistry/ph_scale
→ CLEAN
```

Model LOCKED. Phase 3 Ratio / Particle Counts math unchanged.

---

## Analyze

```text
CLEAN
```

---

## Regression

- `test/chemistry/ph_scale/`: **66 PASS** (NEW suite green)  
- Full-repo `flutter test`: not re-gated here; failures outside ph_scale treated as **PRE-EXISTING**

---

## P0 / P1 / P2

| Sev | Count | Notes |
|---|---|---|
| P0 | **0** | My Solution accordion misplacement fixed |
| P1 | **0** (structural) | Layout formulas + meter structure + fonts addressed |
| P2 | several | FaucetNode assembly, ABSwitch/sun skin, indicator bubble geometry, TabBar vs joist footer, 1–3 px |

---

## Remaining Visual Issues

1. Full screenshot matrix + side-by-side diff not generated this session  
2. scenery-phet FaucetNode / eye-dropper assembly still simplified Stack  
3. Graph indicator callout shape approximate  
4. AppBar/TabBar chrome ≠ joist navbar (shared project pattern)  
5. Micro/My Solution probe stick ≠ full probe Node  

---

## Next Gate

```text
PHASE 6 — Final Behavioral Acceptance
```

Then PHASE 7 Full Regression → PHASE 8 Home Final → PHASE 9 Final Status.

```text
Phase 5 PARTIAL ≠ Overall READY
```
