# NUMERICAL_MODEL — Quantum Wave Interference

> 所有答案均来自本地 TypeScript 源码。`doc/model.md` 仅作概念补充；数值冲突时以源码为准。

---

## 1. Wave 如何表示？

**双层表示：**

| Layer | Type | Meaning |
|---|---|---|
| `FieldComponent` | complex `value` + `coherenceGroup` + optional `support` | 单条相干路径振幅 |
| `FieldSample` | `{ kind: 'field', components[] }` / `unreached` / `blocked` / `absorbed` | 模型向采样 |
| Intensity | `sum_g \| sum(components in g) \|²` | 同组相干叠加，组间强度相加（无交叉项） |
| Compatibility complex | `getRepresentativeComplex` | 给旧 API 的代表复数值 |

证据：`WaveKernel.ts`, `FieldSampleMath.ts`, `WaveKernelTypes.ts`。

**没有**活跃的 FDTD / lattice 求解器。HI / SP 使用**解析核**（analytical kernel）。

Experiment **不**维护 2D 波场；探测器用闭式 Fraunhofer。

---

## 2. Wave 如何随时间传播？

### High Intensity（plane wave）

- Source：平面波 `exp(i(kx − ωt))`，envelope 由 `sourceOnTime` 决定波前未到达则为 0。
- 显示传播速度：`regionWidth / DISPLAY_TRAVERSAL_TIME * displaySpeedScale`，`DISPLAY_TRAVERSAL_TIME = 2.0`。
- Barrier：入射区用源场；缝上吸收/透过；缝后每条开缝独立 `getFresnelApertureTransfer`。
- Solver `step(dt)` 推进内部 `time`，标记 cache dirty。

证据：`HighIntensitySolver.ts`, `WavePropagation.ts`。

### Single Particles（Gaussian packet）

- 初始高斯包：σx/σy = `0.15 * region`；起点偏左 `2σ`；穿越时间基线 `1.5` s。
- 随时间：`sigma` 按 longitudinal/transverse spread traversals (2.5 / 1.5) 展宽；chirp 相位。
- 缝后：在孔径处采样包络 + Fresnel 传递。

证据：`QuantumWaveInterferenceConstants.ts`, `WavePropagation.getGaussianPacketState`。

### Experiment

- **无时域波传播**。Hits 模式按 `MAX_EMISSION_RATE * intensity * dt` 累积计数。

---

## 3. Wave Packet 如何表示？

`GaussianPacketSource`：

| Field | Role |
|---|---|
| `waveNumber`, `speed` | 载频 / 群速（显示坐标） |
| `initialCenterX`, `centerY` | 初始中心 |
| `sigmaX0`, `sigmaY0` | 初始宽度 |
| `longitudinalSpreadTime`, `transverseSpreadTime` | 展宽时间尺度 |
| `isActive` | 包是否存在 |

Which-path 检测后可替换为 `packetReEmission`（从选中缝重新发射）。

---

## 4. Interference 如何计算？

### Experiment（闭式）

`DetectorPattern.getExactDetectorIntensity`：

```text
envelope = sinc²(π a sinθ / λ)
bothOpen → cos²(π d sinθ / λ) * envelope
left/rightCovered → 0.5 * envelope(centered on open slit)
which-path detectors → envelope only（无 cos²）
noBarrier → 1（Experiment UI 无此配置）
```

`sinθ = y / sqrt(y² + L²)`，`L = screenDistance`。

### HI / SP（解析场叠加）

双缝开且同 `coherenceGroup`：`components` 复振幅相加再取模方。  
不同 decoherence 组：强度相加。

---

## 5. Diffraction 如何计算？

| Path | Mechanism |
|---|---|
| Experiment single slit | `sinc²` envelope（Fraunhofer） |
| Experiment double slit | envelope × interference |
| HI / SP | `FresnelApertureTransfer.getFresnelApertureTransfer(k, xPast, y, slit)` |

禁止用「永远双缝干涉公式」覆盖单缝。

---

## 6. Probability 如何得到？

| Screen | Detector PDF |
|---|---|
| Experiment | 闭式 intensity ∈ [0,1] 直接作为接受概率（rejection） |
| High Intensity | 时间平均瞬时 edge intensity → 按 max 归一化 |
| Single Particles | 瞬时 `|ψ|²` 沿 detector 边缘积分 → 归一化 |

探针：圆内 `|ψ|²` / 全域 `|ψ|²`。

---

## 7. Detector 如何采样？

| Screen | Algorithm | RNG |
|---|---|---|
| Experiment | Rejection sampling vs intensity；max 1000 iter；失败 → 中心 0 | `dotRandom.nextDouble()` |
| HI / SP | Discrete PDF roulette + sub-bin jitter | `dotRandom.nextDouble()` |

**本 sim 未暴露 seed。** Flutter 测试层必须注入 `Random` / seed。

---

## 8. Hits 如何产生？

| Screen | Rate / Trigger |
|---|---|
| Experiment Hits | `100 * sourceStrength` hits / model-second（默认 strength 0.5 → ~50/s） |
| HI Hits | 40 /s；有缝探测器时 5 /s；需波前到达屏 |
| SP | 每包结束时 **恰好 1 hit**（探针成功检测则 **0** screen hit） |

上限：`MAX_HITS = 25000` / scene；达上限关闭发射源。  
改变 λ / 速度 / 缝距 / 屏距 / slit config → `clearScreen()`。

---

## 9. Intensity 如何显示？

| Screen | Meaning |
|---|---|
| Experiment Intensity | 闭式概率图案（非时间平均） |
| HI Intensity | **时间平均** wave intensity at detector edge + formation factor 缓入 |
| SP | **无 Intensity 模式**（始终 Hits） |

`screenBrightness`（0–100，默认 50）只改视觉增益，**不改**概率模型。

---

## 10. Slit 如何影响模型？

| Config | Effect |
|---|---|
| `bothOpen` | 相干双缝干涉 |
| `leftCovered` / `rightCovered` | 仅开缝衍射（Experiment：强度×0.5） |
| `leftDetector` / `rightDetector` / `bothDetectors` | which-path → 去相干；屏上无双缝条纹 |
| `noBarrier`（仅 HI/SP） | 自由传播到探测器侧 |

Orientation：Experiment 俯视 left/right ≡ 正视 top/bottom。

---

## 11. Detector-on-slit 如何影响模型？

按 PhET 实现（非自创量子理论）：

- **Experiment**：pattern 公式去掉 cos²；Hits 时 50/50 选路径并计数有探测器侧。
- **HI**：以 `SLIT_DETECTOR_EVENT_RATE=5/s` 调度 decoherence records；平面波按时间带分层渲染。
- **SP**：每包最多一次 on-slit 交互；有探测器 → 计数 + 从该缝 re-emit；无探测器侧 → decoherence 事件。

---

## 12. Wavelength 如何影响模型？

- Photons：用户设 λ（nm）；颜色 `VisibleColor.wavelengthToColor`；a11y 色带见 `WavelengthColorUtils`。
- Matter：`λ = h / (m v)`，`h = 6.626e-34`。
- 显示尺度：默认有效 λ × `DISPLAY_WAVELENGTHS=15` 决定 region 物理宽度；中子显示尺度故意用电子默认 λ。

---

## 13. Screen distance 如何影响模型？

**仅 Experiment**：`screenDistance ∈ [0.4, 0.8] m`，默认 `0.6`。进入 Fraunhofer `sinθ` 与 fringe spacing。  
HI/SP：探测器在显示坐标系固定边缘；物理尺度由 region 映射，无独立 screen-distance slider。

---

## 14. Slit separation 如何影响模型？

物理缝心距 `d`：

- Experiment：进入 `cos²(π d sinθ / λ)`。
- HI/SP：映射到显示坐标后改变双缝几何与 Fresnel 路径差。

**源码默认（覆盖过时 model.md）：**

| Screen | Photons | e⁻ / n | He |
|---|---|---|---|
| Experiment | 0.25 mm (0.05–0.5) | 0.001 mm (1e-4–0.002) | same |
| HI & SP | 2 μm (1–3 μm) | 2 nm (1–3 nm) | 0.30 nm (0.10–0.40 nm) |

---

## 15. Intensity（源强度）如何影响模型？

- **Experiment**：`sourceStrength` ∈ [0,1] 默认 0.5 → 线性缩放 hit 发射率。
- **HI / SP**：**无可调源强度**；snapshot 存 `intensity: 1`。

---

## 16. Pause 如何影响模型？

`isPlaying=false` → screen `step` 不向 scene 推进 `dt`（或推进 0）。  
Solver / hit accumulator / packet 时钟冻结。  
工具 stopwatch 亦不前进。

HI/SP：发射中若暂停后逻辑见 BaseScreenModel（emitter ON 时可自动 resume playing——移植时需逐行对照）。

---

## 17. Step 推进什么？

HI/SP：`stepOnce()` → `scene.step(NOMINAL_DT)`，`NOMINAL_DT = 1/60`（**固定**），再按物理换算推进 stopwatch。  
Experiment：**无** `stepOnce` API（仅 continuous step + TimeSpeed）。

Step 推进的是 **model time / solver time**，不是 Flutter animation duration。

---

## 18. Speed 修改什么？

对 wall-clock `dt` 乘因子：

| Screen | Slow | Normal | Fast |
|---|---|---|---|
| Experiment | 0.25 | 1.0 | 4.0 |
| High Intensity | 0.15 | 0.35 | 0.65 |
| Single Particles | 0.15 | 0.7 | **16** |

---

## Fixed vs variable timestep

- 连续播放：`variable dt`（来自 joist frame），经 TimeSpeed 缩放后交给 scene。
- `dt > 0.5`：Experiment / HI hit 累计会跳过异常大步（防 spiral）。
- 单步：`fixed 1/60`。
- **物理正确性不得绑定 Flutter FPS**；低帧率应累加/限幅 `dt`，而非改变方程。

---

## Particle masses & defaults

| Source | Mass (kg) | Experiment speed | HI/SP speed |
|---|---|---|---|
| photons | 0 | n/a；λ=650 nm | n/a；λ=650 nm |
| electrons | 9.109e-31 | 6e5 (2e5–1e6) | 1.1e6 (7e5–1.5e6) |
| neutrons | 1.675e-27 | 600 (200–1000) | 500 (200–800) |
| heliumAtoms | 6.646e-27 | 600 (200–1000) | 1200 (400–2000) |

Photon UI slider 显示范围 [400,700] nm；Property 范围 [380,780] nm。

---

## Phase 1 solver deliverables

必须可单测的纯 Dart（无 Flutter）：

1. `FraunhoferDetectorPattern.getExactDetectorIntensity`
2. `WaveKernel.evaluateSample`（plane + packet + slits + decoherence + projection）
3. `HighIntensitySolver` time-average detector PDF
4. `SingleParticleSolver` packet + detection timing + probe projection
5. Hit samplers（seedable）
6. `SimulationClock`（time, dt, paused, step, speed）