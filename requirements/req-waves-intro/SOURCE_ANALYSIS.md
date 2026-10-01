# SOURCE_ANALYSIS — Waves Intro

## 版本与依赖

| 项 | 值 | 标记 |
|---|---|---|
| waves-intro | `1.2.0-dev.0`（本地 package.json） | [已确认] |
| dependencies.json WI | `31ebfd71800f065c2da3bc8d402cb65eafe65932` | [已确认] |
| 分析 clone WI | `5443da0…` | [已确认] mismatch SHA |
| 核心波判定 | **A** — FDTD/λ/点源与 lock 语义一致 | [已确认] 见 `DEPENDENCY_PROVENANCE.md` |
| Lattice @ lock | **WI 内** `js/common/model/Lattice.js`（非 scenery-phet） | [已确认] |
| Lattice @ 现代 | scenery-phet `Lattice.ts`，公式同构 `c=0.5` | [已确认] |

P0 功能取证强制：**WI `31ebfd7`**。`5443da0` 仅对照。

## Screens

**[已确认：3 Screens]** Water / Sound / Light — `waves-intro-main.ts` → `MediumScreen`

## 核心波（禁止因 mismatch 修改）

| 功能 | 源 | 结论 |
|---|---|---|
| FDTD | Lattice.js@31ebfd7 ≡ Lattice.ts | [物理一致] |
| λ=v/f | Scene.getWavelength | [数学一致] |
| 点源 | `-sin(ωt+φ)·A·1.2` | [源码一致] |
| EVENT_RATE | `20 * CALIBRATION_SCALE` | [已确认] |

## P0 取证（lock `31ebfd7`）

| 功能 | file | class / method | state | trigger / timing |
|---|---|---|---|---|
| 水滴 | `WaterDrop.js` | `step(dt)` | `y`, `amplitude`, `startsOscillation` | `y -= dt*140`；`y0=100`；`y<0` → `onAbsorption` |
| 水场景 | `WaterScene.js` | `launchWaterDrop`, `step` | `desiredAmplitude/Frequency`, `waterDrops`, `lastDropTime` | 发射周期=`1/frequencyProperty`；`handleButton*Toggled` **no-op** |
| 卷尺 | `WavesScreenView.js` + MeasuringTapeNode | tip/base **view** | `isMeasuringTapeInPlayArea` | `multiplier = waveAreaWidth / waveAreaNode.width` |
| 秒表 | `WavesModel.js` + StopwatchNode | `stopwatch.step(dt)` | time 0..999.99 | `dt = wallDT * timeScaleFactor` |
| 波表 | `WaveMeterNode.js` | 双探针 + series | `isWaveMeterInPlayArea` | 采样晶格；Flutter UI [视觉近似] |

## P1 取证（lock `31ebfd7`）

| 功能 | file | 要点 | 标记 |
|---|---|---|---|
| Side view | `ViewpointRadioButtonGroup`, `rotationAmountProperty`, `WaterSideViewNode`, `WaveInterferenceUtils` | TOP/SIDE；水全侧视=中心线水面；非缩放伪装 | [已确认] |
| Light intensity | `IntensitySample`, `LightScreenNode` | ⟨w²⟩×90；piecewise；Intro 无 intensity graph | [已确认] |
| Audio | `WavesScreenSoundView` + tambo + `sounds/` | **存在** → `AUDIO_ANALYSIS.md` | [已确认] |

## 关键常量（摘录）

| 符号 | 值 |
|---|---|
| latticeSize | 151 |
| LATTICE_PADDING | 20 |
| initialAmplitude | 8 |
| AMPLITUDE_CALIBRATION_SCALE | 1.2 |
| WAVE_SPEED / c² | 0.5 / 0.25 |

## 非 Intro 范围

Interference 双源、Slits、Diffraction FFT、Intensity graph（BaseScreen `showIntensityCheckbox:false`）。
