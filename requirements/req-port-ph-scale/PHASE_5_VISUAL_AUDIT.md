# PHASE 5 — Visual Audit

**req-id:** `req-port-ph-scale`  
**date:** 2026-09-22  
**status:** AUDIT COMPLETE — fixes pending  

**Truth order:** LOCAL PHET SOURCE > official assets screenshots > Flutter runtime  

**Model / Phase 3 Ratio math / Graph semantics:** LOCKED — do not change.

---

## Viewport

| Item | Value | Source |
|---|---|---|
| layoutBounds | **1100 × 700** | `PHScaleConstants.ts` |
| Flutter | FittedBox → `PhScaleConstants.layoutBounds` | OK |
| Screenshot matrix size | **1024 × 618** (FittedBox scales 1100×700 into viewport) | Phase brief |

MVT = identity (model = view coordinates).

---

## Screenshot Matrix (planned)

### Macro
| ID | State |
|---|---|
| M1 | Initial |
| M2 | Acid |
| M3 | Neutral |
| M4 | Base |
| M5 | After Reset |

### Micro
| ID | State |
|---|---|
| MI1 | Initial |
| MI2 | Ratio ON |
| MI3 | Counts ON |
| MI4 | Ratio + Counts ON |
| MI5 | Acid |
| MI6 | Neutral |
| MI7 | Base |
| MI8 | Graph |

### My Solution
| ID | State |
|---|---|
| S1 | Initial |
| S2 | Acid |
| S3 | Neutral |
| S4 | Base |
| S5 | Ratio |
| S6 | Particle Counts |
| S7 | Graph |
| S8 | Graph after drag |
| S9 | After Reset |

Reference images in repo: `phet sourses/ph-scale-main/ph-scale-main/assets/ph-scale-screenshot*.png` (official). No user-provided Phase 5 screenshots found under `requirements/`.

---

## Absolute coordinates (source, identity MVT)

```
beaker:     center (750,580) size 450×300 → L525 R975 T280 B580
dropper:    (700, 265)  scale 0.85
water tap:  (925, 235)  faucet scale 0.6
drain tap:  (450, 623)  faucet scale 0.6 mirrored
meter:      body (150, 75)  scale 55×450
probe:      start (300, 580)
combo Macro: left 505 (= beaker.left−20), top 15
ResetAll:   right−40, bottom−20; radius 20.8×1.32
ParticleCounts: centerX 750, bottom 555
BeakerControl:  centerX 750, top 590
Micro Graph:    top 15; right = drainFaucetNode.left − 40
MySol Graph:    right = beaker.left − 70 = 455; top 15; logH 565
MySol Accordion: left = beaker.left = 525; top 15
```

---

## Macro Audit

| Component | Source | Flutter now | Severity |
|---|---|---|---|
| Beaker geometry | (750,580)/450×300 | Aligned via constants | OK |
| Liquid / color | SolutionNode | SolutionPainter | CANDIDATE |
| Faucet assets | scenery-phet PNG | Original PNG reused | OK assets; assembly CANDIDATE |
| Dropper assets | eyeDropper PNG | Original PNG | OK assets; scale CANDIDATE |
| Probe/meter | ProbeNode + ScaleNode | Custom paint + simplified | **P1** chrome/size |
| pH color scale | basic→neutral→acidic | Present | CANDIDATE |
| Solute combo | left 505, top 15, font 22 | left≈590, top 40, font 16 Material Dropdown | **P1** |
| Neutral badge | bottom = beaker.bottom−30, font 30 | mid-height approx, font 18 | **P1** |
| Volume indicator | font 24 bold | font 24 bold | CANDIDATE (no Arial) |
| Reset All | r=20.8×1.32, R−40 B−20 | r=20.5×1.32, position OK | P2 |
| Screen chrome | joist | Material AppBar+TabBar | **P1** (project pattern; note) |

---

## Micro Audit

| Component | Source | Flutter now | Severity |
|---|---|---|---|
| Ratio particles | flat circles r=3 | Canvas circles r=3 | OK math; shading N/A (source flat) |
| Particle Counts | Avogadro N + icons | Locked Phase 3 | OK math; font 22 Arial missing |
| Graph structure | vertical scale + 3 indicators | PhScaleGraphNode | OK structure |
| Graph position | right = drain.left−40, top 15 | **left: 20** hardcoded | **P1** |
| Graph heights | 485 / 440 | Correct | OK |
| Log tick font | 22 | 18 | **P1** |
| pH accordion | left = beaker.left−0.4×w, top 15 | left: 380 hardcoded | **P1** |
| BeakerControl / Counts | source formulas | Approximate Positioned | CANDIDATE |
| Linear switch | source ABSwitch | Simplified toggle | CANDIDATE |

---

## My Solution Audit

| Component | Source | Flutter now | Severity |
|---|---|---|---|
| No faucet/dropper | Correct | Correct | OK |
| pH accordion | left 525, top 15 | **left 40, top 40** | **P0** layout |
| Graph | right 455, top 15, H 565 | **left 15**, H 565 | **P1** |
| Drag H3O/OH → pH | Interactive | Wired Phase 4 | OK behavior; chrome CANDIDATE |
| Spinner font | 28 | ~28 | CANDIDATE |
| Ratio / Counts | same as Micro | Present | CANDIDATE |

---

## Typography

Source default: **Arial** (`PhetFont`).  
Flutter: mostly platform default — **P1** to set `fontFamily: 'Arial'` (with fallback) on sim text styles.

---

## Assets

| Asset | Status |
|---|---|
| Faucet PNGs | Original reused |
| Dropper PNGs | Original reused |
| Screen icons | Original reused |
| Substituted | **0** (no Material Icons for PhET chrome icons) |
| Ratio particles | Programmatic (source Canvas circles — correct) |
| Molecule icons | Programmatic ShadedSphere-style — correct approach |

---

## Graph Visual (structure)

```
PASS structure (Phase 4): not curves; vertical scale + indicators
FAIL/CANDIDATE chrome: indicator callout shape, ABSwitch skin, tick font size, absolute position
```

---

## P0 / P1 / P2 (pre-fix)

### P0
1. My Solution pH accordion far from source (left 40 vs 525) — wrong screen structure / hierarchy

### P1
1. My Solution / Micro Graph absolute placement  
2. Macro SoluteComboBox position + Material styling + font  
3. NeutralIndicator position + font  
4. Meter / probe typography & scale polish  
5. Arial / key font sizes (log ticks 22, combo 22, Neutral 30, counts 22)  
6. Material AppBar vs PhET (document; align if project L0 exists)

### P2
1. Reset radius 20.5 vs 20.8  
2. Indicator bubble bevel  
3. Faucet/dropper Stack assembly vs full FaucetNode  
4. 1–3 px offsets  

---

## Fix plan (geometry first)

1. Shared font helper (`PhScaleFonts` / Arial)  
2. Macro: combo left/top; NeutralIndicator; Reset radius  
3. Micro: Graph right-align; accordion left formula  
4. My Solution: accordion + Graph right-align  
5. Graph painters: tick fontSize 22 (log)  
6. Meter fonts  
7. Screenshot smoke + report  

**Do not change:** Chemistry Model, Ratio math, Particle Counts N, Graph valueToY semantics.
