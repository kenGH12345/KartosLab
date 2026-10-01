# VISUAL_ASSET_AUDIT — Quantum Measurement

> PHASE 0 initial inventory · 2026-09-30  
> Goal: **Assets Substituted = 0** at FINAL READY  
> Policy: `.cursor/rules/85-phet-original-assets.mdc`

---

## 1. Runtime image assets (`images/`)

| Original Asset | Source Usage | Flutter Path (planned / existing) | Component | Transform | Status |
|---|---|---|---|---|---|
| `images/classicalCoinHeads.svg` | `ClassicalCoinNode`, `ProbabilityOfSymbolBox` | Existing: `assets/simulations/quantum_coin_toss/images/classicalCoinHeads.svg` → migrate/copy into `assets/simulations/quantum_measurement/images/` | Classical coin face | Intrinsic SVG; scale per CoinNode radius | **AVAILABLE** — must re-verify under QM layout (not QCT-only) |
| `images/classicalCoinTails.svg` | same | Existing QCT twin → QM path | Classical coin face | same | **AVAILABLE** |
| `images/greenPhoton.png` | `PhotonsScreen` icon; `PhotonSprites` SpriteImage source | TBD `assets/simulations/quantum_measurement/images/greenPhoton.png` | Photon sprite / screen icon | Sprite scale in PhotonSprites | **NOT YET COPIED** |
| `images/spinScreenIcon.png` | `SpinScreen` homeScreenIcon | TBD | Spin tab / Home icon | ScreenIcon proportions | **NOT YET COPIED** |

License provenance: `images/license.json` (CU Boulder / PhET; contact phethelp@colorado.edu).

---

## 2. Design-only / non-runtime (`assets/`)

| File | Role | Flutter action |
|---|---|---|
| `classical-coins.ai` | Design source | Do not ship |
| `spinScreenIcon.ai` | Design source | Do not ship |
| `greenPhoton.svg` | Design companion to PNG | Prefer PNG if source uses PNG Sprite; SVG optional audit |
| `quantum-measurement-screenshot*.png` | Marketing / README | Do not ship as UI |

---

## 3. Programmatic drawing (NOT substituted assets)

These are **allowed** CustomPainter / Canvas equivalents because source draws them in code:

| Visual | Source files | Notes |
|---|---|---|
| Quantum coin (up/down/superposition) | `QuantumCoinNode.ts` | Opacity blend; no PNG |
| Bloch sphere | `BlochSphereNode.ts`, variants | Shared component |
| Stern-Gerlach apparatus | `SternGerlachNode.ts` | Path geometry |
| Particle source box | `ParticleSourceNode.ts` | |
| Measurement camera device | `MeasurementDeviceNode.ts` + `CAMERA_SOLID_SHAPE_SVG` constant | SVG path string in constants |
| Polarizing beam splitter / mirror | `PolarizingBeamSplitterNode`, `MirrorNode` | |
| Laser body | `LaserNode.ts` | |
| Histograms / graphs | `QuantumMeasurementHistogram`, `NormalizedOutcomeVectorGraph`, `BlochSphereHistogram` | |
| 10k coin pixel field | `CoinSetPixelRepresentation.ts` | Canvas pixels |
| Many particles / photon sprites overlay | `ManyParticlesCanvasNode`, `PhotonSprites` | Canvas/WebGL sprites; photon interior uses greenPhoton image |
| Magnetic field arrows | `MagneticFieldNode`, `MagneticFieldArrowNode` | |
| Atom (red sphere) | `SystemUnderTestNode` | Programmatic |
| Experiment dividing dashed line | `ExperimentDividingLine` | |
| Scene selector radio chrome | `SceneSelectorRadioButtonGroup` | Sun/Scenery controls → PhET-style Flutter controls |

---

## 4. Shared PhET sound assets (tambo)

| Sound | Source import | Flutter plan |
|---|---|---|
| `collect_mp3` | Coins Start Measurement | Locate in local tambo or PhET shared sounds; copy if present in workspace; else BLOCKED until obtained |
| `release` shared player | Laser / Particle source | Shared tambo |
| `erase` shared player | Clear/erase actions | Shared tambo |

Audio scan of sim tree: **no local mp3/wav/ogg** in quantum-measurement `images/` or runtime `assets/`.

---

## 5. Icons that must NOT become Material Icons

| UI element | Correct approach |
|---|---|
| Reset All | `KratosResetAllButton` (L0) — rule 86 |
| Coins / Photons / Spin / Bloch tab icons | Source ScreenIcon construction (QuantumCoinNode stub, greenPhoton Image, spinScreenIcon PNG, Bloch programmatic) |
| Classical sun/moon | Unicode symbols from constants (`CLASSICAL_UP_SYMBOL` / `CLASSICAL_DOWN_SYMBOL`) **or** coin SVG — follow source node, not Material |
| Eraser | Source-drawn / original asset if any — audit PHASE 2 |

---

## 6. Substituted Assets counter

| Metric | Current |
|---|---|
| Assets Substituted | **N/A (pre-implementation)** |
| Target at READY | **0** |

---

## 7. Next audit steps (PHASE 2+)

1. Copy `greenPhoton.png`, `spinScreenIcon.png`, coin SVGs into `assets/simulations/quantum_measurement/`
2. Register in `pubspec.yaml`
3. Trace every `new Image(` / `SpriteImage` / SVG path constant into ASSET_MAP rows
4. Resolve tambo `collect_mp3` binary availability in KartosLab
5. Per-screen ASSET_MAP sections before Visual QA
