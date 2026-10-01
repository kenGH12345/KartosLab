# FUNCTION_MAP — Quantum Measurement

> PHASE 1 · Original Action → Model → Flutter → Test

## Coins

| Original Action | Model method / state | Flutter | Test |
|---|---|---|---|
| Toggle Classical / Quantum | `CoinsModel.setExperimentMode` | `coins_model.dart` | coins_model_test |
| Set initial orientation / basis | `setInitialCoinState` | scene model | coins_model_test |
| Bias slider P(up) | `setUpProbability` | scene model | coins_model_test |
| Start Measurement | `setPreparingExperiment(false)` | scene | (mapped; UI later) |
| New Coin | `setPreparingExperiment(true)` | scene | |
| Reveal / Observe | `CoinSet.reveal` | coin_set.dart | coins_model_test |
| Hide | `CoinSet.hide` | coin_set.dart | coins_model_test |
| Flip / Reprepare | `CoinSet.prepare()` | coin_set.dart | coins_model_test |
| Flip and Reveal / Reprepare and Observe | `prepare(revealWhenPrepared:true)` | coin_set.dart | coins_model_test |
| Identical Coins 10/100/10000 | `numberOfCoins = n` | coin_set.dart | coins_model_test |
| Reset All | `CoinsModel.reset` | coins_model.dart | coins_model_test |

## Photons

| Original Action | Model | Flutter | Test |
|---|---|---|---|
| Single / Many Photons | `PhotonsModel.experimentMode` | photons_model.dart | photons_model_test |
| Polarization preset / custom | `preset`, `customPolarizationAngle` | same | photons_model_test |
| Classical / Quantum behavior | `photonBehaviorMode` | same | photons_model_test |
| Emit / detect (abstracted) | `emitAndResolveOne` | same | photons_model_test |
| Pause / Slow | `isPlaying`, `slowMotion` | same | (fields; clock UI later) |
| Reset All | `PhotonsModel.reset` | same | photons_model_test |

## Spin

| Original Action | Model | Flutter | Test |
|---|---|---|---|
| Experiment 1–6 / Custom | `applyExperiment` | spin_model.dart | spin_model_test |
| Prep +Z/+X/−Z | `spinState` | same | |
| Custom α² | `setAlphaSquared` | same | spin_model_test |
| SGz / SGx orientation | `SternGerlachModel.isZOriented` | same | spin_model_test |
| Block Up / Down / None | `blockingMode` | same | spin_model_test |
| Single / Continuous | `sourceMode` | same | |
| Fire / stream measure | `fireSingleParticle` | same | spin_model_test |
| Expected % toggle | `expectedPercentageVisible` | same | |
| Reset All | `SpinModel.reset` | same | spin_model_test |

## Bloch Sphere

| Original Action | Model | Flutter | Test |
|---|---|---|---|
| Preset ±X±Y±Z / Custom | `setSpinState` / `setAngles` | bloch_sphere_model.dart | bloch_test |
| θ / φ sliders | `setAngles` | same | |
| Basis X/Y/Z (equation) | `equationBasis` | same | |
| Measurement axis | `measurementAxis` | same | bloch_test |
| ×1 / ×10 | `isSingleMeasurementMode` | same | |
| Observe | `initiateObservation` | same | bloch_test |
| Magnetic Field on/strength | `magneticFieldEnabled/Strength` | same | bloch_test |
| Erase | `erase` (= resetCounts) | same | bloch_test |
| Reprepare (implicit) | `reprepare` | same | bloch_test |
| Reset All | `BlochSphereModel.reset` | same | bloch_test |

## Audio (event hooks — no UI this phase)

| Event | Sound |
|---|---|
| Coins Start Measurement | tambo `collect_mp3` |
| Clear / erase | shared `erase` |
| Laser / particle release | shared `release` |
