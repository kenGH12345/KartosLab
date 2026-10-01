# LIFECYCLE_MAP

## Screen ownership

| Screen | Owns |
|---|---|
| ExperimentScreen | ExperimentModel + ExperimentScreenView |
| HighIntensityScreen | HighIntensityModel + HighIntensityScreenView |
| SingleParticlesScreen | SingleParticlesModel + SingleParticlesScreenView |

三屏 **independent models** — 切换 Joist/Flutter tab 不得污染彼此状态。

---

## Model ownership

- Screen model 生命周期 = sim 生命周期（PhET `isDisposable: false`）。
- 4× scene 常驻；`sceneProperty` 只切换指针。
- DynamicProperties 跟随 current scene。

---

## Solver ownership

| Owner | Solver |
|---|---|
| HighIntensitySceneModel | HighIntensitySolver |
| SingleParticlesSceneModel | SingleParticleSolver |
| Experiment SceneModel | **none**（Fraunhofer functions） |

Solver state 随 scene；可 PhET-iO serialize。

---

## Clock ownership

```text
Flutter Ticker / Screen.step(wallDt)
  → ScreenModel.getEffectiveDt / Experiment multipliers
  → SceneModel.step(effectiveDt)
  → WaveSolver.step(dt)   // HI/SP
  → hit accumulators / packet timers
```

`SimulationClock` 必须可在测试中替换（fixed dt, paused, seed）。

Stopwatch：model-owned；physicalDt 由 displayPropagationSpeed / effectiveWaveSpeed 换算。

---

## Animation ownership

- Snapshot flash / slit detector flash：短生命周期 Animation
- Wave canvas：每帧 raster（dirty 时）
- 不得用 ImplicitlyAnimatedWidget 代替 solver time

---

## Focus ownership

ScreenView / Flutter FocusScope per screen；对话框（Snapshots）打开时捕获焦点；关闭后归还 camera 按钮（PhET 行为）。

---

## Snapshot ownership

Per **scene** list（max 4）；screen model `takeSnapshot()` → current scene。

---

## Audio ownership

View-layer players；由 snapshot / drag 手势触发；不进入 solver。

---

## No global singleton

```text
❌ GlobalQuantumWaveSimulation.instance
```

除非未来 KartosLab 平台强制且不跨屏共享可变状态。