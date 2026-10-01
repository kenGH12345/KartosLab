# SOURCE_MAP — Quantum Measurement

> PHASE 0 Source Archaeology · 2026-09-30  
> Source of truth: local PhET repo + `doc/model.md` + `doc/implementation-notes.md`  
> **Status: PASS (inventory complete; deeper model formulas → PHASE 1)**

---

## 1. Identity

| Field | Value |
|---|---|
| Name | Quantum Measurement |
| Package | `quantum-measurement` |
| Version | **1.0.4** (`package.json`) |
| Repo SHA (deps lock) | `69440e4f25488028894cd366c110bc8426df715f` |
| Branch | `1.0` |
| Official URL | https://phet.colorado.edu/sims/html/quantum-measurement/latest/quantum-measurement_all.html |
| Local path | `phet sourses/quantum-measurement-main` |
| Nested duplicate | `phet sourses/quantum-measurement-main/quantum-measurement-main/` (同内容副本；**以顶层为准**) |
| Language | TypeScript (Scenery / Axon / Joist) |
| Layout bounds | `ScreenView.DEFAULT_LAYOUT_BOUNDS` via `QuantumMeasurementConstants.LAYOUT_BOUNDS`（PhET 默认 **1024 × 618**） |

### Sim features (`package.json` → `phet.simFeatures`)

- `supportsDynamicLocale: true`
- `supportsInteractiveDescription: true`
- `supportsSound: true`
- Brands: `phet`, `phet-io`

### Screen name keys

1. `QUANTUM_MEASUREMENT/screen.coins`
2. `QUANTUM_MEASUREMENT/screen.photons`
3. `QUANTUM_MEASUREMENT/screen.spin`
4. `QUANTUM_MEASUREMENT/screen.blochSphere`

---

## 2. Entry & Screen Wiring

**Entry:** `js/quantum-measurement-main.ts`

```
Sim(
  CoinsScreen,
  PhotonsScreen,
  SpinScreen,
  BlochSphereScreen
)
```

| Screen | Screen class | Model | View | Base |
|---|---|---|---|---|
| Coins | `js/coins/CoinsScreen.ts` | `CoinsModel` | `CoinsScreenView` | `QuantumMeasurementScreen` / `QuantumMeasurementScreenView` |
| Photons | `js/photons/PhotonsScreen.ts` | `PhotonsModel` | `PhotonsScreenView` | same |
| Spin | `js/spin/SpinScreen.ts` | `SpinModel` | `SpinScreenView` | same |
| Bloch Sphere | `js/bloch-sphere/BlochSphereScreen.ts` | `BlochSphereModel` | `BlochSphereScreenView` | same |

**Shared base view behavior:** every screen gets `ResetAllButton` from `QuantumMeasurementScreenView` (right/bottom margins 10).

**Cross-screen state sharing:** Screens are **independent** `TModel` instances. Shared pieces are **reusable components / abstract models**, not live shared experiment state:

| Shared artifact | Used by |
|---|---|
| `AbstractBlochSphere` / `BlochSphereNode` | Spin, Bloch Sphere |
| `SimpleBlochSphere` | Spin |
| `ComplexBlochSphere` | Bloch Sphere |
| `QuantumMeasurementHistogram` | Coins, Spin, Bloch (+ variants) |
| `SystemType` (CLASSICAL / QUANTUM) | Coins, Photons scene semantics |
| `QuantumMeasurementColors` / `Constants` / strings | All |
| Preferences (`showGlobalPhase`, …) | Bloch equation display primarily |

---

## 3. Coins Screen — Architecture

### Model

| File | Role |
|---|---|
| `CoinsModel.ts` | Top: `experimentModeProperty` (CLASSICAL\|QUANTUM) + two scene models |
| `CoinsExperimentSceneModel.ts` | Per-scene: prepare/measure, bias, singleCoin, coinSet |
| `Coin.ts` | Single-coin specialization of `CoinSet` (n=1) |
| `CoinSet.ts` | Multi-coin set; **seeded RNG** via `seedProperty` + `dot.Random` |
| `ClassicalCoinStates.ts` | `'heads' \| 'tails'` |
| `QuantumCoinStates.ts` | `'up' \| 'down' \| 'superposition'` |
| `CoinStates.ts` | Union of classical + quantum |
| `ExperimentMeasurementState.ts` | Measurement lifecycle states |

**Key constants (source-verified):**

```ts
MULTI_COIN_EXPERIMENT_QUANTITIES = [10, 100, 10000]
MAX_COINS = 10000
// 10000 rendered as pixels (CoinSetPixelRepresentation / MaxCoinsViewManager)
```

**Classical vs Quantum controls (source `CoinExperimentButtonSet.ts`):**

| Classical | Quantum | Model action |
|---|---|---|
| Reveal / Hide | Observe / Hide | `reveal()` / `hide()` |
| Flip | Reprepare | `prepare()` |
| Flip and Reveal | Reprepare and Observe | `prepare(true)` |

**Probability:**

- `upProbabilityProperty` ∈ [0, 1]
- `downProbabilityProperty = 1 - up`
- Classical: up ≡ heads bias
- Quantum: P(up)=|α|² style bias via `upProbabilityProperty`; superposition when bias ∉ {0,1}

### View (major)

| File | Role |
|---|---|
| `CoinsScreenView.ts` | Root; scene selector; background |
| `CoinsExperimentSceneView.ts` | One classical or quantum scene; Start Measurement / New Coin; sounds |
| `CoinExperimentPreparationArea.ts` | Prepare side |
| `CoinExperimentMeasurementArea.ts` | Single + Multiple measurement boxes |
| `ClassicalCoinNode.ts` | SVG heads/tails |
| `QuantumCoinNode.ts` | Programmatic quantum coin (up/down/superposition opacity) |
| `SingleCoinViewManager` / `MultipleCoinsViewManager` / `MaxCoinsViewManager` | Animation & placement |
| `CoinSetPixelRepresentation.ts` | 10000-coin canvas pixels |
| `OutcomeProbabilityControl.ts` | Bias sliders |
| `ProbabilityEquationsNode.ts` | P(symbol) display |

---

## 4. Photons Screen — Architecture

### Model

| File | Role |
|---|---|
| `PhotonsModel.ts` | `experimentModeProperty`: SINGLE_PHOTON \| MANY_PHOTONS + two scene models |
| `PhotonsExperimentSceneModel.ts` | Laser, PBS, mirror, detectors, photon collection, Classical/Quantum behavior |
| `Photon.ts` / `PhotonCollection.ts` / `PhotonMotionState.ts` | Photon entities & motion |
| `Laser.ts` | Photon source |
| `PolarizingBeamSplitter.ts` | Path choice / split |
| `Mirror.ts` | Reflection |
| `PhotonDetector.ts` | Detection counts |
| `ExperimentModeValues.ts` | Single / Many |
| `TPhotonInteraction.ts` | Interaction contract |

**Behavior modes (from `doc/model.md`):**

- **Classical:** photon reflects OR transmits (definite path)
- **Quantum:** photon takes **both** paths with opacity ∝ probability until detector cylindrical region → measurement

### View (major)

`PhotonsScreenView`, `PhotonsExperimentSceneView`, `LaserNode`, `PolarizingBeamSplitterNode`, `MirrorNode`, `PhotonDetectorNode`, `PhotonSprites`, `PhotonPolarizationAngleControl`, `PhotonDetectionProbabilityPanel`, `NormalizedOutcomeVectorGraph`, `AveragePolarizationCheckboxGroup`, polarization indicators, equations.

**Polarization presets (UI — verify in PHASE 1 against control source):** Vertical / Horizontal / 45° / Unpolarized / Custom (screenshot + strings; confirm in `PhotonPolarizationAngleControl.ts` during PHASE 1).

---

## 5. Spin Screen — Architecture

### Model

| File | Role |
|---|---|
| `SpinModel.ts` | Top model: preparation + SG chain + particle collections |
| `SpinExperiment.ts` | Presets 1–6 + Custom |
| `SternGerlach.ts` | SG apparatus |
| `ParticleSourceModel.ts` | Emission |
| `SourceMode.ts` | SINGLE \| CONTINUOUS |
| `BlockingMode.ts` | NO_BLOCKER \| BLOCK_UP \| BLOCK_DOWN |
| `ParticleWithSpin.ts` | Particle state / stages |
| `SingleParticleCollection.ts` / `MultipleParticleCollection.ts` | Collections |
| `MeasurementDevice.ts` | Camera + Bloch readout devices |
| `SimpleBlochSphere.ts` | Prep state Bloch |
| `SpinDirection.ts` | Spin directions |

**Experiments (source-verified `SpinExperiment.ts`):**

| Enum | Label pattern | SG orientation chain |
|---|---|---|
| EXPERIMENT_1 | Experiment 1 [SGz] | Z |
| EXPERIMENT_2 | Experiment 2 [SGx] | X |
| EXPERIMENT_3 | Experiment 3 [SGz, SGx] | Z, X, X |
| EXPERIMENT_4 | Experiment 4 [SGz, SGz] | Z, Z, Z |
| EXPERIMENT_5 | Experiment 5 [SGx, SGz] | X, Z, Z |
| EXPERIMENT_6 | Experiment 6 [SGx, SGx] | X, X, X |
| CUSTOM | Custom | X, Z, Z (default) |

**Particle stages:** 0 (source→SG0) → 1 (SG0→SG1/SG2) → 2 (exit). Continuous mode uses `ManyParticlesCanvasNode`.

---

## 6. Bloch Sphere Screen — Architecture

### Model

| File | Role |
|---|---|
| `BlochSphereModel.ts` | Prep sphere + single + 10 multi measurement spheres; observe/reprepare; B-field; counts |
| `ComplexBlochSphere.ts` | Azimuth + polar + measurement basis + Z precession |
| `StateDirection.ts` | +X −X +Y −Y +Z −Z Custom |
| `MeasurementAxis.ts` | X / Y / Z measurement |
| `SpinMeasurementState.ts` | Prepared / timing / observed lifecycle |

**Controls (source):** spin state presets, θ/φ sliders, equation basis, measurement axis, ×1 / ×10 atoms, Observe, Magnetic Field strength, measurement delay/timer when B on, Erase histogram.

---

## 7. Common Layer

| Path | Role |
|---|---|
| `common/QuantumMeasurementConstants.ts` | Layout, fonts, symbols (☀ ☽ ket ħ), slider defaults, credits |
| `common/QuantumMeasurementColors.ts` | Scene / panel / coin / spin colors |
| `common/QuantumMeasurementQueryParameters.ts` | Query params |
| `common/model/SystemType.ts` | CLASSICAL / QUANTUM |
| `common/model/AbstractBlochSphere.ts` | Shared Bloch math base |
| `common/model/QuantumMeasurementPreferences.ts` | e.g. global phase toggle |
| `common/view/BlochSphereNode.ts` | Shared Bloch renderer |
| `common/view/QuantumMeasurementHistogram.ts` | Shared histogram |
| `common/view/SceneSelectorRadioButtonGroup.ts` | Top scene toggles |
| `common/view/QuantumMeasurementKeyboardHelpContent.ts` | Keyboard help |
| `common/view/ExperimentDividingLine.ts` | Prep/measure divider |

---

## 8. Assets (images/)

| File | Used by | Notes |
|---|---|---|
| `classicalCoinHeads.svg` | ClassicalCoinNode, ProbabilityOfSymbolBox | Amy Rouinfar |
| `classicalCoinTails.svg` | ClassicalCoinNode, ProbabilityOfSymbolBox | Amy Rouinfar |
| `greenPhoton.png` | PhotonsScreen icon (+ PhotonSprites source) | John Blanco |
| `spinScreenIcon.png` | SpinScreen home icon | Amy Rouinfar |

**assets/** (design / screenshots / .ai): not runtime-required except as provenance; `greenPhoton.svg` exists under assets as design companion.

**Audio:**

| Sound | Source | Usage |
|---|---|---|
| `collect_mp3` | `tambo/sounds` (shared) | Coins Start Measurement |
| `sharedSoundPlayers.release` | tambo | Laser / Particle source release |
| `sharedSoundPlayers.erase` | tambo | Coins erase / clear |

No sim-local mp3/wav in `images/` or `assets/` runtime set.

---

## 9. Randomness

| Location | Mechanism |
|---|---|
| `CoinSet.seedProperty` | Seed ∈ (0,1) → `new Random({ seed })`; 0/1 force all heads/up or tails/down |
| View cosmetics | `dotRandom` for flip animation axes / pixel noise (**visual only**) |
| Photons / Spin / Bloch | Measurement sampling — detail in PHASE 1 NUMERICAL_MODEL |

**Flutter rule:** core sampling must use injectable seeded RNG; never bare `Random()` in model core.

---

## 10. Accessibility / Keyboard / Preferences

- Interactive description supported (`simFeatures`)
- Per-screen a11y strings in `quantum-measurement-strings_en.json` / generated `QuantumMeasurementStrings.ts`
- `QuantumMeasurementKeyboardHelpContent.ts` — keyboard help content exists
- Preferences: global phase visibility (Bloch), other sim preferences via `QuantumMeasurementPreferencesNode`

---

## 11. Existing KartosLab related code

| Path | Relation |
|---|---|
| `lib/quantum_coin_toss/` | Partial Flutter port of **Coins Screen only**, exposed as separate Home sim |
| `assets/simulations/quantum_coin_toss/images/*.svg` | classical heads/tails copies |
| Home | `QuantumCoinTossHome` registered in `home_screen.dart` |

**Must not:** replace QM Coins with `Navigator.push` to QCT Home.  
**Must:** embed / adapt compatible model+view pieces under QM Coins lifecycle. See `QUANTUM_COIN_COMPONENT_MAP.md`.

---

## 12. TS file count

~126 TypeScript modules under `js/` (screens + models + views + common).

---

## 13. PHASE 0 → PHASE 1 handoff

PHASE 1 must produce `NUMERICAL_MODEL.md` with formulas traced from:

- `CoinSet` prepare/reveal/hide
- Photon PBS probability / classical vs quantum path
- Stern-Gerlach spin projection + blocking
- `ComplexBlochSphere` / basis change / magnetic precession (`MAX_PRECESSION_RATE = π/2`)
