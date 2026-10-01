# Phase 1 — Source Analysis · Fourier Making Waves

> 需求：`req-fourier-making-waves`  
> 本地版本：`1.2.0-dev.0`  
> 标记：`[已确认]` / `[推测]` / `[待确认]`  
> Phase 1 完成 · 核心公式均可从源码确认 · **无阻塞** · 进入 Phase 2

---

## 1. Screen 注册

| 功能 | 文件 | class | 结论 |
|---|---|---|---|
| 入口 | `js/fourier-making-waves-main.ts:21-25` | `Sim` | 三屏顺序 Discrete → Wave Game → Wave Packet；第一项为默认 [已确认] |
| Discrete | `js/discrete/DiscreteScreen.ts` | `DiscreteScreen` | model=`DiscreteModel` |
| Wave Game | `js/waveGame/WaveGameScreen.ts` | `WaveGameScreen` | model=`WaveGameModel` |
| Wave Packet | `js/wavepacket/WavePacketScreen.ts` | `WavePacketScreen` | model=`WavePacketModel` |
| 共享 Model | — | — | **不共享** [已确认] |

---

## 2. Discrete — 波形表示与预设

### 2.1 表示

- Fourier series = 最多 11 个 `Harmonic`，每个持有 `amplitudeProperty ∈ [-1.5, 1.5]`。[已确认 `FourierSeries.ts` / `FMWConstants`]
- 基频 `f₀=440 Hz`，`T=1000/440 ms`，`L=1 m`。[已确认 `FourierSeries.ts:89-94`]
- **无独立相位**；仅 `SeriesType.SIN | COS`。[已确认]

### 2.2 预设振幅 · `Waveform.ts`

| Waveform | 公式（源码） | Infinite |
|---|---|---|
| SINUSOID | `A₁=1`，其余 0 | 不支持 |
| TRIANGLE SIN | odd: `(-1)^((n-1)/2) * 8/(n²π²)`；even: 0 | 折线 |
| TRIANGLE COS | odd: `8/(n²π²)` | 折线 |
| SQUARE SIN | odd: `4/(nπ)` | 折线 |
| SQUARE COS | odd: `(-1)^((n-1)/2)*4/(nπ)` | 折线 |
| SAWTOOTH | `(-1)^(n-1)*2/(nπ)` · **仅 SIN**；COS→OopsDialog | 折线 |
| WAVE_PACKET | **硬编码表**（11 行）· issue #18 | 不支持 |
| CUSTOM | `getAmplitudes` 抛错；UI 直接改振幅 | 不支持 |

### 2.3 Fourier 合成 · `getAmplitudeFunction.ts`

```
SPACE+SIN:     A·sin(2π n x / L)
SPACE+COS:     A·cos(2π n x / L)
TIME+SIN:      A·sin(2π n x / T)   // x 轴语义为时间
TIME+COS:      A·cos(2π n x / T)
SPACE_AND_TIME+SIN: A·sin(2π n (x/L − t/T))
SPACE_AND_TIME+COS: A·cos(2π n (x/L − t/T))
```

Sum 采样：`dx = xRange.length / MAX_POINTS_PER_DATA_SET`（1000），逐点 Σ。[已确认 `FourierSeries.createSumDataSet`]

### 2.4 Infinite Harmonics

**不是** n→∞ 级数求和。`INFINITE_HARMONICS_BASE_POINTS` + `mapBasePointsToDataSet`：按 Domain/SeriesType/t 平移折线。[已确认]

### 2.5 Domain / Equation / Tools

| 概念 | 作用 | 影响数学采样？ |
|---|---|---|
| Domain SPACE/TIME/SPACE_AND_TIME | x 轴语义 + 是否动画 | **是** |
| EquationForm (n / λ / T / …) | RichText 方程与刻度样式 | **否**（始终用 n 形式采样） |
| Wavelength/Period tool | 测量卡尺 | **否** |
| Zoom (`AxisDescription`) | 改可见 xRange 系数 | 改采样区间，**不改** L/T |

### 2.6 Erase / Reset / Clock

| 行为 | 源码 | 结论 |
|---|---|---|
| Erase | `waveform=CUSTOM` + `setAllAmplitudes(0)` | [已确认 DiscreteScreenView] |
| Reset | Property.reset + sub.reset + `updateAmplitudes()` | **不** new Model [已确认] |
| step(dt) | playing ∧ SPACE_AND_TIME → `t += dt*1000*0.001` | TIME_SCALE=0.001 |
| stepOnce | `t += 50*0.001` | STEP_DT=50 ms |
| 切换 waveform/domain | `tProperty.reset()` | [已确认] |

### 2.7 自定义编辑

任一振幅编辑 → `waveform=CUSTOM`；此后预设写入跳过。[已确认]

### 2.8 数值近似

有限采样 1000 点；谐波图点数 `ceil(1000 * order / maxHarmonics)`。[已确认]

---

## 3. Wave Game

| 项 | 结论 | 证据 |
|---|---|---|
| 结构 | 5 Level；每 Level 有 answerSeries + guessSeries | `WaveGameModel` / `WaveGameLevel` |
| Domain/Series | 固定 SPACE + SIN；`t=0` | Level 常量 |
| 出题 | 随机非零振幅，步长 0.1，范围 ±1.5 | `AmplitudesGenerator` |
| **判定** | `∀i \|guess[i]−answer[i]\| ≤ 0`（精确相等） | `AMPLITUDE_THRESHOLD=0` |
| 计分 | Check Answer 正确 → +1；Show Answer 不加分 | `POINTS_PER_CHALLENGE=1` |
| 奖励 | score==rewardScore（默认 5） | QueryParameters |
| Erase | guess 全 0 | |
| 时钟 | **无物理演化**；仅反馈/奖励动画 | [已确认：没有波形时钟] |
| 评分 | **有**振幅向量比较；**无**波形点集评分 | [已确认] |

---

## 4. Wave Packet

| 项 | 公式/行为 | 证据 |
|---|---|---|
| L≡T≡1 | Domain 切换不重算数值 | `WavePacket.ts` 注释 |
| A(k) | `exp(-(k-k0)²/(2σ²)) / (σ√(2π))` | `getComponentAmplitude` |
| 有限分量 | `An = A(k)·Δk`，`k=i·Δk` | |
| Δk=0 | Infinity 分量；Sum 用解析式 | |
| 无限 Sum | `y = exp(-x²/(2σₓ²)) · sin\|cos(k₀x)` | `createWavePacketDataSet` |
| Envelope | `√(ysin² + ycos²)` | `createEnvelopeDataSet` |
| width | `2σ`（k 域）/ `2σₓ`（x 域） | |
| σₓ | `1/σ_k` | |
| t | **恒 0**；无 play | [已确认] |
| phase | **无独立相位** | [已确认] |

---

## 5. Graph / Layout（源码常量）

| 常量 | 值 |
|---|---|
| ChartRectangle | 645×123 |
| X_CHART_RECTANGLES | 65 |
| MAX_HARMONICS | 11 |
| MAX_AMPLITUDE | 1.5 |
| layout | PhET ScreenView 默认 1024×618 [推测 joist；与 Normal Modes 对齐] |

---

## 6. Assets / Strings / Sound

- 字符串：`fourier-making-waves-strings_en.json` → Flutter 中文+关键 key
- Sound：仅 Discrete 有 Fourier 振荡音频 · **[待实现]**（见 `AUDIO_ANALYSIS.md`；**非**有意差异）
- images：home icon TS；图表矢量

---

## 7. 待确认清单

| ID | 项 | 影响 |
|---|---|---|
| T1 | 缺少原版运行截图（Phase 2 / Visual QA） | 视觉对齐深度 |
| T2 | Keyboard 完整行为 | 可标有意差异 |
| T3 | Harmonic 音色 | **[待实现]** · 见 AUDIO_ANALYSIS.md |
| T4 | 本地树相对上游 exact commit | 不阻塞；以文件为准 |
| T5 | Equation symbolic tick labels | 本轮仅方程文本 |

### Gap Closure（2026-09-03）已关闭

| 项 | 状态 |
|---|---|
| λ/T 测量工具 | **[源码一致]** / **[行为一致]** |
| Wave Packet width / continuous / envelope | **[源码一致]** / **[行为一致]** |
| EquationForm presentation | **[源码一致]** / **[行为一致]** |

**无核心数学 [待确认] 阻塞项。**

---

## Phase 1 状态：完成 · 自动进入 Phase 2
