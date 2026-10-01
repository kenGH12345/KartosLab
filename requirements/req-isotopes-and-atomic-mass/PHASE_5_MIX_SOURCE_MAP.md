# PHASE_5_MIX_SOURCE_MAP

> Local: `phet sourses/.../js/mixtures/model/MixturesModel.ts` (+ IsotopeTestChamber, NumericalIsotopeQuantityControl)  
> Flutter destination: `lib/chemistry/isotopes_and_atomic_mass/model/mixtures_*`

| Concern | PhET source | PhET API | Flutter destination |
|---|---|---|---|
| Max Z | MixturesModel.ts | `MAX_ATOMIC_NUMBER = 18` | `kMixMaxAtomicNumber` |
| Default element | MixturesModel.ts | `NumberProperty(1)` | `selectedAtomicNumber = 1` |
| Mode | MixturesModel.ts | `interactivityModeProperty` default `bucketsAndLargeAtoms` | `InteractivityMode` |
| My / Nature | MixturesModel.ts | `showingNaturesMixProperty` default false | `showingNaturesMix` |
| Available isotopes | `updatePossibleIsotopesList` | `getStableIsotopesOfElement` sorted by mass | `IsotopeRepository.getStableIsotopesSortedByMass` |
| Test chamber | IsotopeTestChamber.ts | counts, average, proportions, rect | `IsotopeTestChamberState` / counts in model |
| Bucket fill | `fillBuckets` | chamber + bucket = 10 if chamber &lt; 10 | `bucketCountFor` / fill |
| Slider capacity | NumericalIsotopeQuantityControl | `CAPACITY = 100` | `kSliderCapacity` |
| set quantity | `setIsotopeQuantity` | add/remove particles | `setIsotopeQuantity` |
| Nature sample | `showNaturesMix` | `roundSymmetric(1000 * abundance_5)` min 1 | `showNaturesMix` |
| Nature pool | MixturesModel | `NUM_NATURES_MIX_ATOMS+4` prealloc | count records (+ optional positions) |
| Save / restore | `savedParticleStates[Z][mode]` | particle lists | `Map` of counts per Z+mode |
| Clear | `clearTestChamber` | My Mix only; refill / zero sliders; delete save | `clearTestChamber` |
| Reset | `reset` | clear saves; mode/nature reset; Z→1 | `reset` |
| Chamber average | IsotopeTestChamber | `Σ mass / n` or 0 | `chamberAverageAtomicMass` |
| Display average (Nature) | AverageAtomicMassIndicator | `getStandardAtomicMass(Z)` | `displayedAverageAtomicMass` |
| Percent (My) | chamber `getIsotopeProportion` | fraction | `isotopeProportion` |
| Percent (Nature UI) | IsotopeProportionsPieChart | natural abundance | View; Model exposes abundance via Phase 1 |
| Large / small radius | constants | 10 / 4 | constants (View Phase 6) |
| Random positions | `generateRandomPosition` | chamber rect | optional; Nature positions not required for count tests |
| step | isotopesList.step | animation | stub / no-op Phase 5 |

## Lifecycle (confirmed)

```
select Z (≠ current):
  updatePossibleIsotopes
  if Nature → showNaturesMix
  else → save(prev Z, mode) → clear chamber → restore(Z, mode) → controllers → fillBuckets

same Z reselect: NumberProperty no-op

Nature on: save My → showNaturesMix
Nature off: deactivate nature atoms → restore My → controllers → fillBuckets

mode change: save → clear → restore other mode → controllers → fillBuckets if buckets

clear: assert !Nature; buckets→empty+refill; sliders→0; delete saved(Z,mode)

reset: clear all saves; chamber empty; mode+nature reset; Z→1 (re-init)
```

## Count vs particles

| Mode | Count source | Particle instances |
|---|---|---|
| Bucket My Mix | chamber isotopes | PositionableAtom (≤10/iso) — Phase 5 stores counts; spatial Phase 6 |
| Slider My Mix | chamber isotopes | up to 100/iso — Phase 5 counts; Canvas in Phase 6/7 |
| Nature | activated naturesMixAtoms | ~1000+; Phase 5 stores per-isotope counts (+ optional random positions) |
