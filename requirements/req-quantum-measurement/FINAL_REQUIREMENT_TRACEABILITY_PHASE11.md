# FINAL_REQUIREMENT_TRACEABILITY_PHASE11

| Requirement | Source Evidence | Model | LayoutSpec | Component | Behavior Test | Golden | Android | Final |
|---|---|---|---|---|---|---|---|---|
| Coins Classical Flip/Reveal/Hide | PHASE_1 NUMERICAL_MODEL / Coins JS | `CoinsModel` | `QmCoinsLayoutSpec` | Classical scene + controls | phase8 C2–C4 | coins_* | A2 / runtime | PASS |
| Coins Quantum Reprepare/Observe | PHASE_1 | `CoinsModel` quantum scene | same | Quantum scene | phase8 Quantum | coins_quantum_* | A2 | PASS |
| Coins 10/100/10000 | PHASE_1 / PHASE_3 | coinSet.numberOfCoins | composer | MultiCoin / 10k painter | phase8 Count; A3 | coins_* | A3 | PASS |
| Coins scene persistence | PHASE_1 | dual scenes | IndexedStack | Coins screen | phase8 PER | — | — | PASS |
| Photons Classical one-path | PHASE_1 / PHASE_4 | photonBehaviorMode | Photons layout | PhotonsScene | phase8 / A4 | photons_* | A4 | PASS |
| Photons Quantum SPLIT | PHASE_1 | SPLIT outcome | same | trajectory | model + A4 | photons_* | A4 | PASS |
| Photons Continuous start/stop | PHASE_4 | emissionRate | — | PhotonAnimationController | phase8 Cont; A4 | — | A4 + stress | PASS |
| Photons dispose | PHASE_4/8/9 | — | — | dispose ticker | A7 leave | — | lifecycle | PASS |
| Spin Exp 1–6 + Custom | PHASE_5 | `SpinModel.applyExperiment` | Spin layout | ExperimentSelector | phase8 / A5 | spin_* | A5 | PASS |
| Spin Block Up/Down | PHASE_5 / P8 Wrap fix | blockingMode | SG apparatus | Block chips | A5 | — | A5 | PASS |
| Spin Single/Continuous | PHASE_5 | SourceMode | — | SpinSource + anim | phase8 / A5 | — | A5 | PASS |
| Bloch presets ±axes | PHASE_6 | `setSpinState` | Bloch layout | StatePresetControls | phase8 / A6 | bloch_* | A6 | PASS |
| Bloch Observe / collapse | PHASE_6 | measurementState | — | MeasurementControls | phase8 | — | A6 | PASS |
| Bloch Erase ≠ Reset | PHASE_6 | resetCounts vs reset | — | Erase / ResetAll | phase8 | — | A6 | PASS |
| Bloch Magnetic Field | PHASE_6 | step(dt) precession | — | MagneticFieldControl | phase8 FPS | — | A6 | PASS |
| Global visual / DesignFrame | PHASE_7 | — | QmGlobalLayoutSpec | QmTypography/Visual | scale tests | 30 PNG | screenshots | PASS |
| Behavioral user paths | PHASE_8 | existing APIs | — | screens | 33 paths | — | journey | PASS |
| Android runtime | PHASE_9 | — | — | harness | 8 integration | — | VERIFIED | PASS |
| Home Registry entry | PHASE_10 | — | — | QuantumMeasurementHome | phase10 7 | — | Home 2 | PASS |
| Simulation ID | PHASE_10 | — | — | `quantum-measurement` | registry test | — | — | PASS |

Open P0/P1 requirement gaps: **none**.
