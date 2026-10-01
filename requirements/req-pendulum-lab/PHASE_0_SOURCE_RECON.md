# PHASE 0 — Source Recon

**Simulation:** Pendulum Lab  
**PRIMARY SOURCE:** `phet sourses/pendulum-lab-main/pendulum-lab-main`  
**Version:** `package.json` → `1.1.0-dev.5`  
**Date:** 2026-09-14  

网页 latest 仅作交叉验证；行为以本地源码为准。

---

## 1. Source Tree

```
pendulum-lab-main/
├── js/
│   ├── pendulum-lab-main.js          # simLauncher 入口
│   ├── common/model/                 # Pendulum, PendulumLabModel, Body, PeriodTrace, Ruler, Stopwatch, MovableComponent
│   ├── common/view/                  # ScreenView, PendulaNode, panels, protractor, ruler, playback
│   ├── intro/IntroScreen.js
│   ├── energy/model/EnergyModel.js + view/
│   └── lab/model/LabModel.js, PeriodTimer.js + view/
├── mipmaps/                          # 唯一运行时位图（无 images/）
├── doc/model.md, implementation-notes.md
└── pendulum-lab-strings_en.json
```

`assets/*.ai` 为设计源，不进运行时。

---

## 2. Simulation Entry

`js/pendulum-lab-main.js`：`new Sim(..., [IntroScreen, EnergyScreen, LabScreen])`。

屏幕顺序：Intro → Energy → Lab。

---

## 3. Screen Map

| Screen | Model | View | 差异 |
|--------|-------|------|------|
| Intro | `PendulumLabModel` | `PendulumLabScreenView` | 尺子默认可见；Period Trace 勾选 |
| Energy | `EnergyModel` | `EnergyScreenView` | 尺子默认隐藏；Energy Graph 默认展开 |
| Lab | `LabModel` | `LabScreenView` | 重力 tweakers；Period Timer；v/a 箭头；能量盒默认收起 |

继承：Model `PendulumLabModel` → `EnergyModel` → `LabModel`。

---

## 4. Model Map

- **Pendulum**：`length, mass, angle, ω, α, position, velocity, acceleration, KE/PE/thermal, isUserControlled, isTickVisible, isVisible`；`periodTrace`
- **PendulumLabModel**：body/gravity/customGravity/timeSpeed/numberOfPendula/isPlaying/friction/periodTraceVisible/energyZoom；pendula[2]；ruler；scenery-phet Stopwatch
- **EnergyModel**：`isEnergyBoxExpanded`, `activeEnergyPendulum`
- **LabModel**：`isVelocityVisible`, `isAccelerationVisible`, `periodTimer`
- **Body**：Moon 1.62 / Earth `PhysicalConstants.GRAVITY_ON_EARTH`（=9.8，非 model.md 的 9.81）/ Jupiter 24.79 / Planet X 14.2 / Custom null
- **PeriodTrace**：numberOfPoints 0→4 状态机
- **双重 Stopwatch**：toolbox 用 scenery-phet；PeriodTimer 用本地 `Stopwatch.js`

默认摆：#1 mass=1 kg length=0.7 m 可见；#2 mass=0.5 kg length=1.0 m 不可见。

---

## 5. View Map

`PendulumLabScreenView` 图层：background drag → protractor → left floating (energy/arrows/tools) → right panels+reset → playback → period traces → pendula → ruler → period timer → stopwatch。

MVT：`createSinglePointScaleInvertedYMapping(ZERO, (512, 15), 618/1.33)`，layoutBounds **1024×618**。

Bob：Rectangle 73×98，`scale = 0.3 + 0.4√(m/1.5)`，蓝/红线性渐变。杆为 Line。无摆锤位图。

---

## 6. Physics Map

**必须以 `Pendulum.js` 为准，不得用 `model.md` 简化式。**

文档只写二次阻力。实现为线性 + 二次：

```
θ'' = −frictionTerm(ω) − (g/L)·sin(θ)
frictionTerm = c·L·m^(−1/3)·ω|ω| + c·m^(−2/3)·ω
```

积分：RK4；子步 `numSteps = max(7, dt·120)`（JS 浮点循环上界）；`step = dt/numSteps`。

全局步进（`PendulumLabModel.step`）：

```
if playing: modelStep(min(0.05, dt) * timeSpeed * 1.007)
stepManual: modelStep(0.01)
```

能量：`KE = ½ m (L|ω|)²`；`PE = m g L (1−cosθ)`；有摩擦时 `Δ(KE+PE)` 转入 thermal。

角度：0 = 竖直向下，正方向向右；`modAngle` → (−π, π]。JS `%` 用 Dart `remainder`。

长度变化：`ω *= L_old/L_new`（保切向速度），不转 thermal。

近静止：`|θ|,|α|,|ω| < 1e-3` 则 θ=ω=0 仍再 step 一次。

坐标：`position = polar(L, θ−π/2)`（y-up）。

---

## 7. Interaction Map

| 交互 | 源码行为 |
|------|----------|
| 拖摆 | `angleOffset`；`modAngle`；对称四舍五入到整度；禁止精确 ±180° → ±179°；开始时 ω=0、thermal=0 |
| 触摸拾取 | `ClosestDragForwardingListener(0.15, 0)` |
| Length/Mass | NumberControl；slider constrain 0.1；箭头 delta 0.01 |
| Gravity | 滑条 0–25，constrain 0.5；Lab 有 tweakers；Planet X 隐藏数值 |
| Friction | `0.0005·(2^s−1)`，s∈[0,10] → c∈[0, 0.5115] |
| 1/2 摆 | radio |
| Return | `resetThermalEnergy` + `resetMotion`；Lab 停 PeriodTimer |
| Play/Pause / Step / Normal·Slow | isPlaying；step 仅暂停；timeSpeed 1 或 1/8 |
| Tools | ruler / stopwatch / periodTrace 或 periodTimer |
| Lab 箭头 | velocity / acceleration |
| Reset All | `model.reset()` |

---

## 8. Clock / Animation Map

Joist 每帧 `model.step(dt)` + `view.step(dt)`。Flutter：`SimulationClock`（固定 1/60）→ `model.step`；速度在 **model.timeSpeed**，不改 `clock.timeScale`。PeriodTrace 淡出在 view.step，用墙钟 dt（不含 1.007）。页面退出 `clock.dispose()`。`KratosTabSwitcher` 的 `TickerMode` 闸住非当前 tab。

---

## 9. Reset Map

**Reset All：** body/gravity/customGravity/timeSpeed/numberOfPendula/isPlaying/friction/periodTrace/energyZoom；ruler；stopwatch；两摆 `reset()`（不含 isVisible）；Energy 还重置能量盒与选中摆；Lab 还重置箭头与 periodTimer。

**Return：** 清 thermal + 运动；不停全局设置。

**拖开始：** ω=0，thermal=0，tick 可见。

---

## 10. Asset Map

| 原路径 | 类型 | 用途 | 尺寸 | Flutter |
|--------|------|------|------|---------|
| `mipmaps/introNavbarIcon.png` | image | Intro tab | 148×101 | `Image.asset` |
| `mipmaps/energyScreenIcon.png` | image | Energy tab | 694×472 | `Image.asset`（无独立 navbar） |
| `mipmaps/labNavbarIcon.png` | image | Lab tab | 148×101 | `Image.asset` |
| `mipmaps/periodTimerBackground.png` | image | Period Timer 外壳 | 231×158，view scale 0.6 | `Image.asset` |
| intro/lab ScreenIcon | image | Home 卡可选 | 694×472 | 已抽取，tab 用 navbar |
| 摆杆/摆锤/量角器/尺 | Path/Shape | 场景 | — | CustomPainter |
| Play/Pause/Reset/Stop | scenery-phet 几何 | chrome | — | CustomPainter（禁 Material Icons） |

Substituted Assets 目标：**0**。

---

## 11. Reusable KARTOSLAB Components

**复用：** `SimulationClock`、`KratosTabbedScreen` + `KratosTabSwitcher`、FittedBox 1024×618 壳（EFAC/CLB 模式）。

**不复用 L0：** `TimeControlBar`、`KratosSlider`、`KratosChart`、`NineGridLayout`（近期 HTML5 口均绕开）。

**sim 本地（与 MASB/ESP 一致，不上抽）：** NumberControl、尺、秒表、量角器、PeriodTrace、PeriodTimer、能量 Accordion、PlaybackControls。

**模板：** MASB（拖质量/尺/周期迹）、ESP（能量图/秒表）、CLB（黄 PlayPause + 橙 Reset All）。

---

## 12. Unknown / Risk Areas

1. 摩擦方程文档 vs 代码 — **以 Pendulum.js 为准**
2. Earth g = 9.8（phet-core），不是 9.81
3. 时间因子 **1.007** 必须保留（Period Timer 末位）
4. JS `%` vs Dart `%` — 用 `remainder`
5. `numSteps` 浮点 for-边界
6. 加速度箭头 `frictionTerm/mass` 量纲怪异 — 原样复制
7. Period Trace 状态机 + Lab PeriodTimer 耦合
8. Planet X ↔ Custom 防作弊 `customGravityProperty`
9. scenery-phet Stopwatch vs 本地 Stopwatch 勿混
10. 无独立 `images/`，UI 几乎全矢量

---

## Coordinate systems

| 系 | origin | x | y | 角度 |
|----|--------|---|---|------|
| Model | 支点 | 右+ | 上+ | 0=下，右+ |
| View (layout) | 左上 | 右+ | 下+ | scenery 顺时针+ |
| MVT | 模型 0 → (512,15) | scale=618/1.33 | Y 倒置 | 摆旋转 `−θ` |
