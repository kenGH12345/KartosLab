# PHASE 1 — MODEL / CHEMISTRY CORE REPORT

**Sim:** PhET Acid-Base Solutions → Flutter (KartosLab)  
**Req id:** `req-port-acid-base-solutions`  
**Source:** `phet sourses/acid-base-solutions-main/acid-base-solutions-main`  
**Phase 0:** `requirements/req-port-acid-base-solutions/PHASE_0_SOURCE_AUDIT.md`  
**Dart root:** `lib/chemistry/acid_base_solutions/model/`

---

## PHASE 1 STATUS: PASS

```text
Intro View: NOT STARTED
My Solution View: NOT STARTED
Home: NOT TOUCHED
Runtime: NOT VERIFIED
Android: NOT VERIFIED
```

---

## Models

| Model | Dart | Notes |
|---|---|---|
| ABSModel | `abs_model.dart` | Shared beaker + tools + selected solution |
| IntroModel | `intro_model.dart` | 5 presets incl. Water; independent of MySolution |
| MySolutionModel | `my_solution_model.dart` | No Water; isAcid×isWeak; C/strength sync |
| AqueousSolution | `solutions/aqueous_solution.dart` | Abstract + pH rounding chain |
| Beaker | `abs_beaker.dart` | Fixed 360×270 @ (230,410); no volume Property |
| PHMeter | `abs_ph_meter.dart` | Tip position; displayedPH from solution when immersed |
| PHPaper | `abs_ph_paper.dart` | percentColored + color + step float 250 px/s |
| ConductivityTester | `abs_conductivity_tester.dart` | brightness; **strict** `pH == 7 → 0` |
| ABSPreferences | `abs_preferences.dart` | showSolvent default false; not Reset All |
| ABSViewProperties | `abs_view_properties.dart` | viewMode + toolMode only |

### Solution Types

| Type | Dart | Key formulas (source-faithful) |
|---|---|---|
| Water | `water.dart` | `[H3O+]=sqrt(Kw)`; `[OH-]=[H3O+]`; `[H2O]=W` |
| StrongAcid | `strong_acid.dart` | `[H3O+]=C`; `[A-]=C`; `[HA]=0`; `[H2O]=W−C` |
| WeakAcid | `weak_acid.dart` | `[H3O+]=(-Ka+sqrt(Ka²+4KaC))/2` |
| StrongBase | `strong_base.dart` | `[OH-]=C`; `[H3O+]=Kw/[OH-]`; `[H2O]=W` |
| WeakBase | `weak_base.dart` | `[BH+]=(-Kb+sqrt(Kb²+4KbC))/2`; `[OH-]=[BH+]` |

---

## Chemistry

```text
H3O+:     subclass getH3OConcentration()
OH-:      subclass getOHConcentration()
Kw:       1e-14 (AbsConstants.waterEquilibriumConstant)
Ka/Kb:    strength Property (weak only); range [1e-10, 1e2], default 1e-7
pH:       -roundSymmetric(100 * log10([H3O+])) / 100
Rounding: AbsMath.roundSymmetric (PhET half-away-from-zero)
Concentration: [1e-3, 1] mol/L, default 1e-2; spinner Δ=0.001
Strength: Ka/Kb itself (unitless ionization constant)
Conductivity brightness:
  open circuit → 0
  pH == 7 (strict) → 0
  else linear vs |pH−7|/7 with neutralBrightness=0.05
```

**No water-contribution correction** for strong acid/base beyond source formulas.  
**No** invented dilution / volume / pOH Properties.

---

## Particle Count / Position

```text
Particle Count: absParticleCount(c) from ParticlesCanvasNode.getParticleCount
  BASE_CONCENTRATION=1e-7, BASE_DOTS=2, MAX=200
  H2O skipped in canvas (solvent.png via preferences)

Particle Position: AbsParticleField
  Production: Random()
  Tests: seeded Random for determinism
  Polar: distance = R*sqrt(U), angle = 2πU
  No dynamics step
```

---

## Tools

| Tool | Behavior |
|---|---|
| PHMeter | blank unless tip in beaker; value = solution.pH |
| PHPaper | color from pH; percentColored monotonic while dipped; step floats up @ 250 px/s when released |
| ConductivityTester | dual probes; brightness as above |

---

## Reset

| Target | Behavior |
|---|---|
| Intro | all solutions.reset → Water selected → tools reset |
| My Solution | isAcid/isWeak/C/strength defaults → WeakAcid → tools reset |
| Tools | meter/paper/probes positions + paper percentColored |
| Preferences | **not** cleared by Reset All |
| View Properties | viewMode=particles, toolMode=pHMeter (ResetAll button pairs with model.reset) |

---

## Chemistry Oracle

| Oracle | Coverage | Status |
|---|---|---|
| A Water | H3O/OH/pH/strength | PASS |
| B Strong Acid | C∈{1e-3,1e-2,1e-1,1} | PASS |
| C Strong Base | same C set | PASS |
| D Weak Acid | quadratic + not √(KaC) | PASS |
| E Weak Base | quadratic + sweeps | PASS |
| F Particle Count | 2/54/200/0 + seeded layout | PASS |
| G Reset | Intro + MySolution + prefs | PASS |

Plus: conductivity strict equality, PHMeter/PHPaper, screen isolation, defaults.

---

## Tests

```text
Source: 0
Added: 52
Final: 52
Path: test/chemistry/acid_base_solutions/
```

```text
flutter test test/chemistry/acid_base_solutions/
→ All tests passed!
```

## Analyze

```text
dart analyze lib/chemistry/acid_base_solutions test/chemistry/acid_base_solutions
→ No issues found!
```

---

## P0 / P1 / P2

### P0
(none)

### P1 (deferred to View phase)
1. ConductivityTester / ResetAll **visual** L0 wiring  
2. Particle canvas rendering (counts/layout model ready)  
3. LogSlider view mapping for C and strength  
4. Dual-screen View isolation  

### P2
1. Local audio unavailable (framework slider sounds later)  
2. ToolMode.none unused in UI  
3. Particle positions non-deterministic in production (by design)

---

## File Index

```text
lib/chemistry/acid_base_solutions/model/
  abs_math.dart
  abs_range.dart
  abs_constants.dart
  abs_colors.dart
  particle_key.dart
  abs_particle.dart
  particle_count.dart
  abs_particle_field.dart
  abs_beaker.dart
  abs_ph_meter.dart
  abs_ph_paper.dart
  abs_conductivity_tester.dart
  abs_view_properties.dart
  abs_preferences.dart
  abs_model.dart
  intro_model.dart
  my_solution_model.dart
  solutions/
    aqueous_solution.dart
    water.dart
    strong_acid.dart
    weak_acid.dart
    strong_base.dart
    weak_base.dart
```

---

*Phase 1 complete. Do not start Screen View until explicitly requested.*
