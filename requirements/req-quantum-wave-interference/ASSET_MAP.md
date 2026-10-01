# ASSET_MAP — Quantum Wave Interference

Policy: 原版 PhET assets 优先；Substituted Assets 必须为 **0**。

---

## Runtime assets（sim 自带）

| Original Path | Used By | Flutter Path (planned) | Scale / Notes | Type |
|---|---|---|---|---|
| `images/photon.svg` | source icons / labels | `assets/simulations/quantum_wave_interference/photon.svg` | intrinsic | runtime |
| `images/electron.svg` | same | `.../electron.svg` | intrinsic | runtime |
| `images/neutron.svg` | same | `.../neutron.svg` | intrinsic | runtime |
| `images/heliumAtom.svg` | same | `.../heliumAtom.svg` | intrinsic | runtime |
| `images/singleParticleEmitter.svg` | SP emitter | `.../singleParticleEmitter.svg` | match node scale | runtime |
| `images/experimentScreenIcon.svg` | home/nav icon | `.../experimentScreenIcon.svg` | icon | runtime |
| `images/highIntensityScreenIcon.svg` | home/nav | `.../highIntensityScreenIcon.svg` | icon | runtime |
| `images/singleParticlesScreenIcon.svg` | home/nav | `.../singleParticlesScreenIcon.svg` | icon | runtime |
| `sounds/snapshotCaptured.mp3` | snapshot shutter | `.../snapshotCaptured.mp3` | SoundClip level 0.4 in PhET | runtime |

Companion `*_svg.ts` / `*_mp3.js` = bundler wrappers → Flutter 不需要。

`images/license.json` / `sounds/license.json`：Matthew Blackman / CU Boulder。

---

## Shared dependency assets

| Asset | Source | Status |
|---|---|---|
| `VisibleColor` wavelength→Color | scenery-phet（锁 SHA） | MISSING locally at correct SHA |
| MeasuringTape / Stopwatch / Time controls chrome | scenery-phet / KartosLab L0 | prefer KartosLab L0 if pixel-compatible；else port |
| `sharedSoundPlayers` erase / drag / valueChange | tambo | shared hooks — see AUDIO_MAP |
| Reset All | **KartosLab** `KratosResetAllButton`（L0 强制） | not PhET Material refresh |

---

## Generated geometry（非 bitmap）

| Element | Implementation |
|---|---|
| Wave field | Canvas from solver samples |
| Barrier / slits | Path geometry (`DoubleSlitNode`) |
| Detector screen (skew) | Path + texture |
| Hits | stamped buffer |
| Graphs | polylines / bars |
| Probe circle | Path overlay |
| Experiment overhead apparatus | composed nodes / paths + beams |

---

## Forbidden substitutes

- Material `Icons.refresh` / `Icons.science` / emoji particles
- GIF/video waves
- Static interference PNG as live detector
- AI-generated particle art
- Non-uniform stretch of SVGs

---

## Substituted Assets

| Count | Status |
|---|---|
| 0 | PHASE 0 baseline — must remain 0 at Final QA |