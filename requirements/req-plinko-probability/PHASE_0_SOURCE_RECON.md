# PHASE 0 — Source Recon · Plinko Probability

> 源码根：`phet sourses/plinko-probability-main/plinko-probability-main`  
> 版本：**1.2.0-dev.6**（`package.json`）  
> 侦察日期：2026-09-16 · **本地源码为 PRIMARY SOURCE OF TRUTH**  
> 网页仅用于交叉验证：https://phet.colorado.edu/sims/html/plinko-probability/latest/plinko-probability_all.html

---

## 1. Source Tree

```
plinko-probability-main/
├── package.json                    # 1.2.0-dev.6
├── images/                         # 7 PNG + *_png.ts + license.json
├── sounds/                         # bonk1 / bonk2 + license.json
└── js/
    ├── plinko-probability-main.js  # Entry
    ├── plinkoProbability.js        # Namespace
    ├── PlinkoProbabilityStrings.ts
    ├── common/
    │   ├── PlinkoProbabilityConstants.js
    │   ├── PlinkoProbabilityQueryParameters.js
    │   ├── model/
    │   │   ├── PlinkoProbabilityCommonModel.js
    │   │   ├── GaltonBoard.js
    │   │   ├── Ball.js / BallPhase.js
    │   │   └── Histogram.js
    │   └── view/
    │       ├── PlinkoProbabilityCommonView.js
    │       ├── Board.js / PegsNode.js / BallNode.js / BallsNode.js
    │       ├── Hopper.js / HistogramNode.js / HistogramModeControl.js
    │       ├── PlayButton.js / PauseButton.js / EquationNode.js
    │       └── …
    ├── intro/
    │   ├── IntroScreen.js
    │   ├── model/ IntroModel.js / IntroBall.js
    │   └── view/ IntroScreenView.js / IntroPlayPanel.js /
    │             CylindersFrontNode.js / CylindersBackNode.js /
    │             NumberBallsDisplay.js
    └── lab/
        ├── LabScreen.js
        ├── model/ LabModel.js / LabBall.js
        └── view/ LabScreenView.js / LabPlayPanel.js / PegControls.js /
                  HopperModeControl.js / StatisticsAccordionBox.js /
                  TrajectoryPath.js / OutOfBallsDialog.js / HistogramIcon.js
```

---

## 2. Entry Point

`js/plinko-probability-main.js` →

```js
new Sim( title, [ new IntroScreen(), new LabScreen() ], simOptions )
```

屏幕顺序：**Intro → Lab**。

---

## 3. Screen Map

| # | Screen | Model | 固定/可调 | 球落地表现 | 发射模式 | 特有 UI |
|---|---|---|---|---|---|---|
| 1 | Intro | `IntroModel` | rows=12, p=0.5（无滑条） | 气缸堆叠 | ×1 / ×10 / ×100 | counter↔cylinder、N 显示 |
| 2 | Lab | `LabModel` | rows 1–26, p 0–1 | 直方图顶附近后移除 | oneBall / continuous | ball/path/none、统计箱、Ideal |

---

## 4. Model Map

### `PlinkoProbabilityCommonModel`

| Property | Type | Default | Valid |
|---|---|---|---|
| `probabilityProperty` | Number [0,1] | **0.5** | BINARY_PROBABILITY_RANGE |
| `ballModeProperty` | String | `'oneBall'` | oneBall / tenBalls / maxBalls / continuous |
| `hopperModeProperty` | String | `'ball'` | ball / path / none |
| `isBallCapReachedProperty` | Boolean | false | — |
| `numberOfRowsProperty` | Integer | **12** | ROWS_RANGE (1…26) |
| `balls` | ObservableArray | [] | — |
| `galtonBoard` | GaltonBoard | — | — |
| `histogram` | Histogram | — | — |

联动：`probability` 或 `numberOfRows` 变化 → **自动 `erase()`**。

### Intro extras

- `ballsToCreateNumber` / `launchedBallsNumber`
- `cylinderInfo`（width / height / ellipseHeight / verticalOffset / top）
- **无** `isPlayingProperty`

### Lab extras

- `isPlayingProperty`（Boolean, default false）
- 理论二项：`getTheoreticalAverage` / `getTheoreticalStandardDeviation` / `getNormalizedBinomialDistribution`

---

## 5. Probability Map

### 单次球（实验）

构造 `Ball` 时对每一行预采样：

```
direction = (dotRandom.nextDouble() > probability) ? 'left' : 'right'
// ⇒ P(right) = probability = p
// ⇒ P(left)  = 1 − p
columnNumber += (direction === 'left') ? 0 : 1
binIndex = columnNumber   // 右移次数 ∈ [0, n]
```

证据：`js/common/model/Ball.js` L75–95。

### 长期分布（理论 · 仅 Lab）

二项分布 \(P(n,k,p)=\binom{n}{k} p^k (1-p)^{n-k}\)

- \(\mu = n p\)
- \(\sigma = \sqrt{n p (1-p)}\)
- Ideal 直方图条 = **按 max 归一化** 的理论概率（蓝描边），叠在样本红条上

---

## 6. Random Process Map

| 问题 | 结论 | 证据 |
|---|---|---|
| 是否刚体物理碰撞？ | **否** | Ball 无质量/冲量/反射 |
| 左右偏转如何决定？ | **Bernoulli(p) 预采样** | `Ball` 构造函数循环 |
| 动画是什么？ | peg 间抛物线插值 | `updatePosition` FALLING：`(shift·r, −r²)·pegSep` |
| 碰撞半径？ | **无物理碰撞半径**；仅视觉 peg | PegsNode 绘制 |
| path/none 模式 | 跳过动画，`updateStatisticsAndLand()` | LabModel.step |

**禁止**实现为重力+弹性碰撞。必须实现为预计算路径 + 插值动画。

---

## 7. Clock Map

| | Intro | Lab |
|---|---|---|
| 驱动 | `model.step(dt)`（PhET 标准） | 同 + `isPlayingProperty` |
| 创建节奏 | 队列 + `elapsed > 0.150 s` | `isPlaying && elapsed > interval` |
| ball 步进 cap | `min(0.1, dt*5)` | `min(0.09, dt*10)`（仅 hopper=ball） |
| 创建 interval (Lab) | — | ball 0.100 / path 0.050 / none 0.015 s |
| Pause | 无独立 pause（Play 只触发队列） | `isPlaying=false` 停创建；球步进仍随 step 走？→ Lab 中球步进在 `step` 内，**不**依赖 isPlaying（仅创建依赖）。需确认：`isPlaying` 只控创建；balls 仍在 step 中移动。 |

Flutter 映射：复用 `lib/common/simulation_clock.dart` → Controller 调 `model.step(dt)`。

---

## 8. View Map

| View | 职责 |
|---|---|
| `Board` | 三角板背景 |
| `PegsNode` (Canvas) | peg 网格；Intro `rotatePegs:false` 圆钉；Lab 默认扁平面随 p 旋转 |
| `BallsNode` / `BallNode` | 阴影球 |
| `Hopper` | 漏斗；底宽随 rows |
| `HistogramNode` | 柱状图 + 可选 Ideal |
| `CylindersFront/Back` | Intro 气缸 |
| `TrajectoryPath` | Lab path 模式折线 |
| `StatisticsAccordionBox` | Lab 样本/理论统计 |
| `PegControls` | Rows + Binary Probability |
| `IntroPlayPanel` / `LabPlayPanel` | Play(+Pause) + 模式选择 |
| `HistogramModeControl` | counter/cylinder 或 counter/fraction |

---

## 9. Interaction Map

| 交互 | Intro | Lab |
|---|---|---|
| Play | 按 ballMode 入队 | oneBall→加一球；continuous→isPlaying=true |
| Pause | — | continuous 时暂停创建 |
| ballMode / hopperMode | ×1/×10/×100 | ball/path/none + one/continuous |
| Rows / Probability 滑条 | — | 有；改后 erase |
| Histogram mode | counter ↔ cylinder | counter ↔ fraction |
| Eraser | erase | erase |
| Reset All | model+viewProperties | 同 |
| Ideal checkbox | — | 显示理论条 |
| Peg / Board 拖拽 | **无** | **无** |

---

## 10. Statistics / Distribution Map

### Histogram（实验）

球离开 pegs 时 `addBallToHistogram`：

\[
\bar{x}_N=\frac{(N-1)\bar{x}_{N-1}+k}{N},\quad
s^2=\frac{\sum k_i^2-N\bar{x}^2}{N-1},\quad
s_{\bar{x}}=s/\sqrt{N}
\]

（N=1 时方差类为 0）

Bins：`binCount`（含在途）/ `visibleBinCount`（已落地）/ `orientation`。

### 理论（Lab only）

与实验数组分离：`getBinomialDistribution()` vs `histogram.getNormalizedSampleDistribution()`。

---

## 11. Reset Map

| 动作 | 行为 |
|---|---|
| Reset All | `probability/ballMode/hopperMode/isBallCap/numberOfRows` 复位 + erase；Lab 另复位 `isPlaying`；viewProperties 复位 |
| Erase | 清空 balls、histogram、ballCap；Intro 另清队列计数 |
| 改 p / rows | 自动 erase |

---

## 12. Asset Map

### Images（必须复用）

| 文件 | 用途 |
|---|---|
| `images/introHomescreen.png` | Intro 主页图标 |
| `images/introNavbar.png` | Intro 导航栏 |
| `images/labHomescreen.png` | Lab 主页图标 |
| `images/labNavbar.png` | Lab 导航栏 |
| `images/counter.png` | 直方图计数模式图标 |
| `images/cylinder.png` | Intro 气缸模式图标 |
| `images/fraction.png` | Lab 分数模式图标 |

Board / Peg / Ball / Hopper：**程序绘制**（无独立 PNG）。

### Sounds

| 文件 | 用途 |
|---|---|
| `sounds/bonk1ForPlinko.mp3` | 球往 **left** |
| `sounds/bonk2ForPlinko.mp3` | 球往 **right** |

节流：`SOUND_TIME_INTERVAL = 0.1 s`。

---

## 13. Geometry（关键常量）

| 常量 | 值 | 来源 |
|---|---|---|
| `GALTON_BOARD_BOUNDS` | (−0.5, −1)→(0.5, 0) | Constants |
| `HISTOGRAM_BOUNDS` | (−0.5, −1.70)→(0.5, −1.03) | Constants |
| `CYLINDER_BOUNDS` | (−0.5, −1.80)→(0.5, −1.05) | Constants |
| `pegSpacing` | `bounds.width / (nRows+1)` = `1/(n+1)` | GaltonBoard |
| peg x | `(−row/2 + col) / (n+1)` | GaltonBoard / Ball |
| peg y | `(−row − 2·0.7) / (n+1)` | PEG_HEIGHT_FRACTION_OFFSET=0.7 |
| 可见 peg | `rowNumber < numberOfRows` | GaltonBoard |
| `ballRadius` | `pegSpacing × 0.193` | BALL_SIZE_FRACTION |
| peg 视觉 | `pegRadius:50` @ rows=1，再按 bins 缩放 | PegsNode |
| BACKGROUND | `rgb(186,231,249)` | Constants |
| BALL / PEG 色 | `rgb(237,28,36)` / `rgb(115,99,87)` | Constants |

**物理半径 vs 视觉半径：** 无碰撞半径；球半径仅用于绘制与气缸堆叠几何。

---

## 14. Reusable KARTOSLAB Components

| Component | Path | Reuse |
|---|---|---|
| SimulationClock | `lib/common/simulation_clock.dart` | **yes** |
| KratosTabbedScreen | `lib/common/widgets/kratos_tab_bar.dart` | **yes** |
| KratosResetAllButton | `lib/common/widgets/kratos_reset_all_button.dart` | **yes** |
| KratosSlider / Radio / Combo / NumberField | `lib/common/controls/` | **yes** |
| PropertyControlPanel | `lib/common/widgets/property_control_panel.dart` | **yes**（可选） |
| paintShadedSphere | `lib/gas_properties/painters/shaded_sphere.dart` | **yes**（球绘制） |
| TimeControlBar | `lib/common/widgets/time_control_bar.dart` | **no**（Material Icons）→ 新建 PhET 风 Play/Pause |
| KratosChart | `lib/common/chart/` | **extend**（时序图，非 bin histogram） |
| Gas HistogramPainter | `lib/gas_properties/painters/histogram_painter.dart` | **extend**（参考） |
| SomRandom / RandomSource | SoM / Gas | **extend**（可种子 RNG） |
| Visual QA 流水线 | `tool/diff_visual_qa.py` + Playwright capture | **yes** |
| ModelViewTransform L0 | — | **no** → 新建 `PlinkoMvt` |

建议包路径：`lib/plinko_probability/`。

---

## 15. Risks / Unknowns

| ID | Risk | Mitigation |
|---|---|---|
| R1 | 误做成刚体碰撞 | 单元测试锁定 Bernoulli 路径 + 抛物线插值 |
| R2 | Intro ×All 与网页 ×All 文案差异 | 源码为 `maxBalls`=100；UI 字符串以源码/strings 为准 |
| R3 | Peg 扁平面旋转角度公式 | 读完 PegsNode paintCanvas 再实现 Lab pegs |
| R4 | MVT / layout 坐标 | 从 CommonView 取 modelViewTransform 参数，建 VISUAL_LAYOUT_BASELINE |
| R5 | ROWS_RANGE.min≠5 的源码 TODO (#84) | 跟随 query 默认 min=1；回归测 rows=1 |
| R6 | Lab isPlaying 与球步进解耦 | 按源码：暂停只停创建，已在途球继续 step |
| R7 | 随机不可控 → 无法逐球路径对齐 | Statistical Validation 用种子 RNG + 分布容差 |
| R8 | Home 接入过早 | Final Gate 前禁止改 Home |

---

## 16. Checklist 自检摘要（80-rule）

- MVC：`model/` `controller/` `screens|widgets|painters/` ✅ 规划
- L0：Clock / Tab / Reset / Slider / Radio ✅
- Peg「碰撞」= 概率分支，非物理 ✅ 已取证
- Assets：7 PNG + 2 MP3 + Canvas 绘制 ✅
- 配置化/scenario：本 sim 无 PhET scenario JSON；Intrinsic 写入 constants + 可选 schema（Build 阶段评估）
