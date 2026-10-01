# PHASE 1 — Feature Spec · Plinko Probability

> 依据：本地源码 `1.2.0-dev.6`（见 PHASE_0）  
> 原则：**实际存在什么就实现什么；不存在的功能禁止添加。**

---

## 1. Screens（必须实现）

| Screen | 背景色 | 核心场景 |
|---|---|---|
| Intro | `rgb(186,231,249)` | Galton 板 + 气缸 + Play 面板 + N + histogram mode |
| Lab | 同上 | Galton 板 + 直方图 + PegControls + 统计箱 + hopper mode |

Home：`PlinkoProbabilityHome` = `KratosTabbedScreen`（Intro | Lab）。  
**Final Gate 前不接入工程 Home。**

---

## 2. Plinko Board / Pegs

### Board

- Bounds：`GALTON_BOARD_BOUNDS = (−0.5,−1)–(0.5,0)`
- 外观：米色三角板 + 阴影（`Board.js`）
- 行数：Intro 固定 12；Lab ∈ [1, 26]，默认 12
- Peg 数：第 r 行有 r+1 个 peg（r 从 0）；可见行 `0 .. nRows-1`
- Bin 数：`nRows + 1`

### Peg layout

```
pegSpacing = 1 / (nRows + 1)
x = (−row/2 + column) / (nRows + 1)
y = (−row − 2×0.7) / (nRows + 1)
```

### Peg appearance

| | Intro | Lab |
|---|---|---|
| 形状 | 实心圆 | 带扁平面的弧（可旋转） |
| 旋转 | 无 | 随 `probability` 旋转扁平面 |
| 颜色 | `rgb(115,99,87)` | 同 |
| 阴影 | RadialGradient 软阴影 | 同 |
| 视觉半径 | `pegRadius=50` @ rows=1 再按 `(minRow+1)/(nRows+1)` 缩放 | 同 |

**无独立 collision radius**（见下节）。

---

## 3. Ball Model（AC）

### AC-B1 Path precompute

给定 `p` 与 `nRows`，球构造时生成 `pegHistory`：

- 对 `row = 0 .. nRows`：采样方向；`P(right)=p`
- `binIndex` = 右移次数
- 不在运行时再随机改方向

### AC-B2 Phases

`INITIAL → FALLING → EXITED → COLLECTED`

### AC-B3 Motion（动画，非物理）

- INITIAL：从 hopper 落到第一 peg（线性）
- FALLING：`pos = (shift·r, −r²)·pegSep + pegPos`，`shift=±0.5`
- EXITED：竖直落入 bin，速度 ×2
- COLLECTED：静止

### AC-B4 Radius

`ballRadius = pegSpacing × 0.193`；颜色 `rgb(237,28,36)` + 白色高光。

### AC-B5 Intro stacking

`binCount % 3` → 中 / 随机左右 / 取反上一球；`deltaY` 按气缸几何堆叠。

### AC-B6 Lab landing

`finalBinVerticalOffset = HISTOGRAM_BOUNDS.maxY − 6×ballRadius`；落地后移除前一球。

---

## 4. “Collision” Behavior（AC）

| 项 | 要求 |
|---|---|
| AC-C1 | **不是**刚体碰撞 / 不是重力弹跳 |
| AC-C2 | 碰到 peg 的“事件”= 相位切到下一 peg → 发声（left/right） |
| AC-C3 | 左右由构造时 Bernoulli 决定，运行中不改 |
| AC-C4 | path/none：无动画，直接统计落地 |

---

## 5. Probability / Statistics（AC）

### Experimental

| 符号 | 公式 | 更新时机 |
|---|---|---|
| N | `landedBallsNumber` | 球 EXITED → histogram |
| \(\bar{x}\) | 递推均值 | 同 |
| s | 样本标准差（N>1） | 同 |
| \(s_{\bar{x}}\) | \(s/\sqrt{N}\) | 同 |
| bin counts | `visibleBinCount` | 同 |

### Theoretical（Lab only）

| 符号 | 公式 |
|---|---|
| μ | \(n p\) |
| σ | \(\sqrt{n p(1-p)}\) |
| Ideal bars | \(\binom{n}{k}p^k(1-p)^{n-k}\) 按 max 归一化 |

实验与理论**分数组**，禁止混用。

---

## 6. Controls

### Intro

| Control | Initial | Min | Max | Step | Model |
|---|---|---|---|---|---|
| Play | — | — | — | — | `updateBallsToCreateNumber` |
| ×1 / ×10 / ×100 | ×1 | — | — | — | `ballMode` |
| Histogram mode | counter | — | — | — | view property |
| Eraser | — | — | — | — | `erase` |
| Sound | muted/on | — | — | — | sound toggle |
| Reset All | — | — | — | — | `reset` |
| N display | 0 | — | — | — | histogram.N |

Intro **无** rows/p 滑条。

### Lab

| Control | Initial | Min | Max | Step | Model |
|---|---|---|---|---|---|
| Play / Pause | paused | — | — | — | `isPlaying` + ballMode |
| oneBall / continuous | oneBall | — | — | — | `ballMode` |
| ball / path / none | ball | — | — | — | `hopperMode` |
| Rows | 12 | 1 | 26 | 1 | `numberOfRows` |
| Binary Probability | 0.50 | 0 | 1 | 0.01 | `probability` |
| Histogram mode | counter | — | — | — | counter↔fraction |
| Ideal | false | — | — | — | view |
| Statistics panel | expanded | — | — | — | accordion |
| Eraser / Sound / Reset | 同 Intro | | | | |

---

## 7. Fire / Drop / Multi-ball

### Intro

- Play → 按模式 +1 / +10 / +100 入队
- 每 ≥150 ms 吐一球，直到队列空或达 `maxBallsIntro=100`
- 达上限 → Play 禁用（`isBallCapReached`）

### Lab

- oneBall + Play → `addNewBall()` 一次
- continuous + Play → `isPlaying=true`，按 hopperMode interval 持续创建
- Pause → `isPlaying=false`（停创建；在途球继续动画）
- 单 bin ≥ `maxBallsLab=9999` → OutOfBallsDialog + cap

所有球进入**同一** model + **同一** clock step。禁止每球独立 Timer。

---

## 8. Histogram / Cylinders / Fraction

| Mode | Intro | Lab |
|---|---|---|
| counter | 柱上显示整数 | 同 |
| cylinder | 气缸堆叠球 | — |
| fraction | — | 柱上显示分数/占比 |

---

## 9. Reset / Erase（AC）

| AC | 行为 |
|---|---|
| AC-R1 | Reset All 恢复 controls 默认 + erase |
| AC-R2 | Erase 清球/直方图/cap（保留 p、rows、modes） |
| AC-R3 | 改 p 或 rows → erase |
| AC-R4 | Intro erase 清队列与 launched 计数 |

---

## 10. Sound（AC）

- left → bonk1；right → bonk2
- 最小间隔 0.1 s
- Sound toggle 可静音

---

## 11. Explicit Non-Goals

- ❌ 刚体物理 / Box2D / 重力弹跳
- ❌ 用户拖拽 peg 或板
- ❌ Intro 上 rows/p 控件
- ❌ Lab 上气缸模式
- ❌ 网络图 / Material Icons 冒充 Play/Reset
- ❌ Final Gate 前改 Home / 全局 shell
- ❌ 写死路径或伪造直方图数据

---

## 12. Acceptance Matrix（摘要）

| ID | 验收 |
|---|---|
| F-INTRO | Intro 固定 12/0.5；×1/×10/×100；气缸；N |
| F-LAB | rows/p 可调；one/continuous；ball/path/none；统计+Ideal |
| F-PATH | 路径预采样；动画插值；bin=右移次数 |
| F-STAT | 实验递推统计正确；理论二项正确；分列显示 |
| F-CLK | 单一 SimulationClock；无 Timer leak |
| F-RST | Reset/Erase/改参清盘 |
| F-ASSET | Substituted Assets = 0 |
| F-VIS | Major geometry 对齐；P0=P1=0 |
| F-TEST | `flutter test test/plinko_probability` PASS；analyze 0 error 0 warning |
