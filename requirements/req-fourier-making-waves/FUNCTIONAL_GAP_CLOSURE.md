# Functional Gap Closure · Fourier Making Waves

> 日期：2026-09-03  
> 原则：**不重构** Model/Solver/Clock/Screen architecture · 只补齐源码已确认功能  
> 测试：`fourier_making_waves` **36** · `normal_modes` **50** · `dart analyze lib/fourier_making_waves` **0 issues**

---

## 1. 总览

| 优先级 | 功能 | 状态 |
|---|---|---|
| P1 | λ / T 测量工具 | **[行为一致]** · 数学 **[源码一致]** |
| P2 | Wave Packet 宽度指示 / Continuous / Envelope | **[行为一致]** · 数学 **[源码一致]** · 视觉 **[视觉近似]** |
| P3 | EquationForm | **[行为一致]** · presentation only **[源码一致]** |
| P4 | Audio | 取证完成 · **[待实现]**（用户要求本轮不做） |
| Visual QA | 原版/Flutter 截图对照 | **[待确认：缺少原版运行截图]** |

禁止把未完成功能标成「有意差异」。Audio 明确为 **[待实现]**，不是有意差异。

---

## 2. λ / T 测量工具

### 2.1 源码证据

| 项 | 证据 |
|---|---|
| 存在 / Screen | Discrete · `DiscreteMeasurementTool` + Calipers / Clock |
| λₙ | `L / n`，L=1 m · `FourierSeries` / `Harmonic` |
| Tₙ | `T₀ / n`，T₀=1000/440 ms |
| 宽度 | `chartTransform.modelToViewDeltaX(λₙ|Tₙ)` · **禁止**用屏宽硬编码 |
| Domain 门控 | λ: SPACE∥SPACE_AND_TIME；T 卡尺: TIME；T 时钟: SPACE_AND_TIME |
| Reset | selection + order + view position |
| 与 waveform | **无关** · 测固定 harmonic 量 |

### 2.2 Flutter 实现

```
HarmonicQuantities → DiscreteMeasurementTool → RenderData(FmwCalipersData / FmwPeriodClockData)
  → HarmonicsChartWithTools（拖拽改 view position）
```

- `FmwMvt.modelToViewDeltaX` 映射测量宽度  
- Control panel：checkbox + order spinner  
- Reset 恢复选中/阶数/位置  

| 标记 | |
|---|---|
| 数学 | **[源码一致]** |
| 交互 | **[行为一致]** |
| 卡尺视觉微几何 | **[视觉近似]** |

---

## 3. Wave Packet 指示

| 功能 | 源码默认 | Flutter | 标记 |
|---|---|---|---|
| Continuous Waveform | `true` · step π/10 · A(k)[·Δk] | 默认 true · 绘制于 Amplitudes | **[行为一致]** |
| Waveform Envelope | `true` · √(ysin²+ycos²) | 已有 + 开关 | **[行为一致]** |
| Width indicators | `false` · Amplitudes: 2σ @ (k₀,A)；Sum: 2σₓ @ (0,1/√e) | 开关 + 绘制 | **[行为一致]** |
| 振幅棒 k 轴定位 | waveNumber | `waveNumber` 字段 + painter | **[行为一致]** |

视觉箭头/标签样式：**[视觉近似]**（非 PhET Caliper 矢量完全复刻）。

---

## 4. EquationForm

| 项 | 结论 |
|---|---|
| 类型 | **Presentation** · 不改采样 |
| Screen | **仅 Discrete** |
| 实现 | `EquationMarkup` + ComboBox + 图上方程文本 |
| Domain 切换 | 非 MODE → HIDDEN |

| 标记 | **[源码一致]** / UI **[行为一致]** |

---

## 5. Audio

见 `AUDIO_ANALYSIS.md`。

- 仅 Discrete 有 Fourier 振荡音频  
- **[待实现]** · **[待确认：工程级 Audio architecture]**  
- **未**标为有意差异  

---

## 6. Visual QA

| 证据 | 状态 |
|---|---|
| 原版运行截图（每 Screen ≥1） | **[待确认：缺少原版运行截图]** |
| Flutter 截图 | 可用 widget test / 实机补；本轮未入库假图 |
| mean RGB | **未使用** |

因此：**不得**写「视觉已对齐 / 视觉一致」。几何常量对齐标 **[视觉近似]**；外壳 AppBar/Tab/NineGrid **[有意差异]**。

---

## 7. 测试清单

| 套件 | 结果 |
|---|---|
| `fmw_gap_closure_test` | measurement / packet / equation · passed |
| `fmw_math_test` | 原有数学 · passed |
| `test/normal_modes` | 50 passed（回归） |
| `dart analyze lib/fourier_making_waves` | 0 issues |

---

## 8. 仍待办（诚实列表）

| 项 | 标记 |
|---|---|
| Harmonic 音频 | **[待实现]** |
| 原版截图 Visual QA overlay | **[待确认]** |
| 测量工具 dragBounds 精确对齐 ScreenView | **[视觉近似]** / 可选精校 |
| Equation symbolic tick labels | **[待确认]**（本轮仅方程文本） |
| Discrete Sum Y auto-fit | **[待确认]**（既有缺口，非本轮目标） |

**BLOCKED：无**
