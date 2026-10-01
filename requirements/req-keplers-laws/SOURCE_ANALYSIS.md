# Phase 1 — Source Analysis · Kepler's Laws

> 需求：`req-keplers-laws`  
> 日期：2026-09-01  
> 本地源码（优先）：`d:\OneDrive\Desktop\phet sourses\keplers-laws-main\keplers-laws-main`  
> 远程：https://github.com/phetsims/keplers-laws · 依赖 https://github.com/phetsims/solar-system-common  
> 标记：`[已确认]` / `[推测]` / `[待确认]`

本文件只陈述原版行为与源码证据，不写 Flutter 实现。

**2026-09-01 续：** 用户提供完整 keplers-laws 仓库检出（`package.json` version `1.3.0-dev.0`）。后续取证以该目录为准，不再访问 GitHub ZIP。本检出 **不含** `solar-system-common` / `kite`；`constrainDragPoint` 定义在父类 ScreenView。`images/` 与 `sounds/` 是 PhET 的 `*_png.ts` / `*_mp3.js` 包装，没有独立 `.png` / `.mp3` 文件。

---

## 1. State（SSOT）

原版 **没有** 单一 immutable State 对象。状态散落在 axon `Property` 上，以 `KeplersLawsModel` 为根。

### 1.1 时间与播放（`SolarSystemCommonModel`）

| Property | 默认 | 证据 |
|---|---|---|
| `timeProperty` | 0 years，只读 | `SolarSystemCommonModel.ts` 构造器 |
| `isPlayingProperty` | **false**（默认暂停） | 同上 |
| `hasPlayedProperty` | false；`time>0` 变 true | 同上 |
| `timeSpeedProperty` | `TimeSpeed.NORMAL` | 同上 |
| `timeSpeedMap` | FAST=7/4, NORMAL=1, SLOW=1/4 | `:81-85` |

### 1.2 两体

| Body | mass | position | velocity | 可拖 |
|---|---|---|---|---|
| sun | 200 | (0,0) 只读 | (0,0) 只读 | 否 |
| planet | 50 | (2.00, 0) | (0, 17.2358) | 是 |

太阳位置 link 断言必须为原点。[已确认 `KeplersLawsModel.ts:151-212`]

质量范围太阳 `0.5×200 … 2×200`；行星质量只读固定 50。  
`Body.massToRadius(m) = max(0.03, 0.023·m^{1/3})`。[已确认 `Body.ts` 末尾]

### 1.3 定律与 UI 布尔

- `selectedLawProperty`：First/Second/Third；All Laws 才可运行时改
- `alwaysCircularProperty`：false
- `periodDivisionsProperty`：RangeWithValue(2, 6, **4**)
- `targetOrbitProperty`：默认 NONE；Second Law 屏不挂 tandem
- `selectedAxisPowerProperty` / `selectedPeriodPowerProperty`：默认 1，范围 1–3
- `correctPowersSelectedProperty`：`axis==3 && period==2`
- `stopwatch`：scenery-phet Stopwatch
- `userIsInteractingProperty`
- `resetting` / `restarting` / `steppingForward` 内部旗标

[已确认 `KeplersLawsModel.ts`]

### 1.4 可见性（`KeplersLawsVisibleProperties`）

基类默认：speed=false, **velocity=true**, gravity=false, **path=true**, grid=false, measuringTape=false。  
Kepler 屏再把 `velocityVisibleProperty` 设 true 并 `setInitialValue(true)`。[已确认 `KeplersLawsScreenView.ts`]

第一定律：axes/semiaxes/foci/string/eccentricity 默认 **false**。  
`semiaxesVisible = axes AND semiaxesChecked`；`stringVisible = foci AND stringChecked`。

第二定律：apo/peri/areaValues/timeValues 默认 false；accordion **expanded=true**。

第三定律：`semiMajorAxisVisible` 默认 **true**；period 默认 false；accordion expanded=true。

切定律：`saveAndDisableVisibilityState(last)` 把当前律的 property 存为 initial 再全 false，再 `resetVisibilityState(new)` 恢复新律的 initial。[已确认]

### 1.5 引擎公开量

`a,b,c,e,w,M,W,T,nu,L,d1,d2`；`allowedOrbitProperty`；`orbitTypeProperty`（STABLE/CRASH/ESCAPE）；`escapeSpeed/Radius`；`orbitalAreas[0..5]`；`activeAreaIndex`；`retrograde`；`alwaysCircles`。

---

## 2. Model 层级

```
SolarSystemCommonModel          时间、zoom、bodies、measuringTape、restart/reset
  KeplersLawsModel              定律、目标轨道、Always Circular、幂次、秒表
    EllipticalOrbitEngine       解析轨道（非数值 N-body）
      OrbitalArea × 6
    PeriodTracker
    Body sun / planet
```

`Engine` 抽象：`run / update / reset / checkCollisions`。[已确认 `Engine.ts`]

Kepler **不用** 数值积分。`doc/implementation-notes.md` 写明 `EllipticalOrbitEngine` 用 vis viva + Kepler 方程。

`startingBodyInfoProperty`：用户松手后保存，Restart 加载；Reset 回到 `defaultBodyInfo`。

---

## 3. Solver · EllipticalOrbitEngine

常量 [已确认]：

```
epsilon = 0.99
INITIAL_G = 4.45669
INITIAL_MU = 891.34
TWO_PI = 2π
```

`μ = INITIAL_G * sunMass`（质量变化时更新）。

### 3.1 `update(bodies)` — 由 r,v 重建椭圆

1. `resetOrbitalAreas()`；清 period trace
2. `enforceValidPosition`：`|r|==0` → `(0.01, 0)`
3. `updateForces`；`escapeSpeed = √(2μ/|r|) · ε`
4. `enforceValidVelocity`：`v≠0`；若 r∥v（sin≤1e-6）则旋转 0.01 rad
5. Always Circular → `enforceCircularOrbit`：`v = ±perp(r̂)·1.0001·√(μ/|r|)`
6. 否则若 `|v| ≥ escapeSpeed` → 夹到 escapeSpeed；若 `|v| ≥ escapeSpeed·ε` → ESCAPE，`e=1`，`allowed=false`
7. `L = r × v`（2D 叉积标量）
8. `calculateEllipse` → a,b,c,e,w,M,W,nu
9. `T = thirdLaw(a)` = `(a³ · INITIAL_MU / μ)^{1/2}`
10. `totalArea = π a b`；`segmentArea = totalArea / periodDivisions`
11. `collidedWithSun`: `a(1-e) < massToRadius(sunMass)` → CRASH，`allowed=false`
12. `e < 0.01` 或 alwaysCircles → 显示 e=0
13. `changedEmitter` + `ranEmitter`

### 3.2 公式

**vis viva 半长轴** `calculate_a`：

```
a = |r| μ / (2μ − |r| |v|²)
```

**离心率** `calculate_e`：

```
e = √ | 1 − (|r| |v| sin(θv−θr))² / (a μ) |
```

**极径** `calculateR`：

```
r(ν) = a(1−e²)/(1+e cos ν)
```

**角度** `calculateAngles`：

- 圆：`ν = θr`
- 椭圆：`ν = ±arccos(clamp((1/e)(a(1−e²)/|r| − 1), -1, 1))`；`cos(θr−θv)>0` 则取负
- `W = −500 / T`；若 `r×v > 0` 则 retrograde，ν 与 W 变号
- `M = getMeanAnomaly(ν,e)`；`w = θr − ν`

**Kepler 方程 Newton-Raphson** `getTrueAnomaly(M)`：

```
g = E − e sin E − M
g' = 1 − e cos E
ε_iter = 1e-2
ν = atan2(√(1−e²) sin E, cos E − e)  ∈ [0, 2π)
```

**推进** `run(dt)`：

```
M += dt · W
ν = getTrueAnomaly(M)
pos = createPolar(ν, w)
vel = calculateOrbitalVelocity(ν, w)
vel *= L / (pos × vel)   // 保角动量
```

速度分量 [已确认]：

```
Vθ = 2π a (1 + e cos ν) / (T √(1−e²))
Vr = −2π a e sin ν / (T √(1−e²))
```

**面积分割**：等平均近点角间隔 `2π/N`，再 `getTrueAnomaly`。运行中当前扇区随行星切开；`alreadyEntered` 控制填充。播放开始会 `resetOrbitalAreas(isPlaying)` 从而清空已扫面积（`periodDivisionsProperty.link`）。

**重力**（模型单位，非 SI）：

```
F_planet = r · (−μ · m_planet / |r|³)
F_sun = −F_planet
```

### 3.3 单位换算（solar-system-common）

```
METERS_PER_AU = 149597870700
SECONDS_PER_YEAR = 31557600
G_model = 4.4567          // 与引擎 INITIAL_G 4.45669 差 1e-5 [已确认两处]
POSITION_MULTIPLIER = 0.01
MASS_MULTIPLIER = 1e28
```

显示半径夸张：文档写真实太阳 0.004 AU，sim 约 0.15 AU。[已确认 `doc/model.md`]

---

## 4. Render

### 4.1 坐标

`ModelViewTransform2.createSinglePointScaleInvertedYMapping(ZERO, layoutCenter − offset, zoomScale)`  
Y 向上。`zoomScale` 来自动画属性，范围 **45–100**，默认 100（zoomLevel=2）。zoomLevel=1 动画到 45。[已确认 `KeplersLawsModel.ts:304-333` + `SolarSystemCommonScreenView.ts`]

网格：spacing=1 AU，60 条，原点加粗，挂 `interfaceLayer`。

### 4.2 椭圆节点

`EllipticalOrbitNode` 是 `Path`，`lineWidth: 3`，`stroke: fuchsia`（orbitColor）。  
非法轨道 `lineDash=[5]`，合法 `[0]`。

局部坐标：椭圆平移到焦点中心 `(-c,0)*scale`，再绕 `-w` 旋转。子节点用局部坐标。

| 元素 | 几何 | 颜色 |
|---|---|---|
| 全轴 | (−a,0)–(a,0) 与 (0,−b)–(0,b) | foreground |
| a | (0,0)–(−a,0) | #FF9500 |
| b | (0,0)–(0,b) | #B0EE86 |
| c | (0,0)–(e·a,0) | #E6C7FF |
| 弦 | 焦点1 → 行星 → 焦点2，dash [10,2] | #ccb285 |
| 焦点 | XNode scale 0.8 | #29ABE2 |
| 近日/远日 | XNode | gold / cyan |
| 面积扇 | `moveTo(radiusC,0).ellipticalArc(0,0,radiusX,radiusY,0,startAngle,endAngle,false).close()` [已确认 本地 EllipticalOrbitNode.ts:440] | fuchsia 族 |
| 分割点 | Circle r=4 | black fill + orbit stroke |

`topLayer`（焦点）在 bodies 之上，与椭圆同变换。

### 4.3 天体

`ShadedSphereNode`，半径 = `modelToViewDeltaX(massToRadius)`。太阳黄、行星 magenta。速度数字在球体上下 ±30 view px，半透明黑底。

### 4.4 警告

模型坐标 `(0, −0.5)` 转视图。字号 18 bold，maxWidth 410。`visible = !allowedOrbit`。[已确认 `OrbitalWarningMessage.ts`]

### 4.5 面板锚点（layoutBounds）

| UI | 锚 |
|---|---|
| 左上 First/Second/Third 面板 | AlignBox left-top，margin 10 |
| 右上 zoom + 可见性面板 | AlignBox right-top，margin 10 |
| TimeControl | centerX，bottom = layoutBottom − 10 |
| Reset All | right = interfaceRight − 10，bottom 同 |
| Laws radio（仅 All） | left-bottom margin 10 |
| DistancesDisplay | center-top |
| 秒表初始 | `resetAll.left - 200`, `timeControl.bottom - 75` |
| PeriodTimer | layoutBounds 内可拖 |

面板 fill `Color(40,40,40)`，cornerRadius 5，x/yMargin 10。[已确认 `SolarSystemCommonConstants.PANEL_OPTIONS`]

右栏三块：TargetOrbitPanel → OrbitalInformationPanel → visibilityPanel（Always circular / Speed / Velocity / Gravity+zoom / Grid / Tape / Stopwatch）。

---

## 5. Interaction

### 5.1 行星拖拽

- `SoundDragListener` 绑 `positionProperty`，经 MVT
- `mapPosition`：若 `|p| > escapeRadius` 则夹到该半径；再 `constrainDragPoint` 避开 UI 矩形
- Kepler 覆盖 `dragSpeed: 150`，`shiftDragSpeed: 50`（基类默认 450/100）
- start：`clearPath` + `userIsControllingPosition=true` → 暂停播放
- end：`userIsControllingPosition=false` → `saveStartingBodyInfo`
- 提示箭头：`cueingArrowsVisible = !userHasInteracted`；播放或任何 userInteracting 后消失，Reset 恢复

[已确认 `BodyNode.ts` + `KeplersLawsScreenView.ts` planetNode options]

### 5.2 速度矢

`DraggableVelocityVectorNode`：`minimumMagnitude: 1.055`，`snapToZero: false`，`maxMagnitude = escapeSpeed`，Always Circular 时不可交互，`dragSpeed 200` / `shift 70`。

### 5.3 恒星质量（仅第三定律面板）

滑条 100–400（0.5–2 太阳），thumb 14×24，track 150×1。距 200 相对误差 < **0.05** 则吸附 Our Sun。start/end 设 `userIsControllingMass`。刻度：0.5, Our Sun, 1.5, 2.0。[已确认 `StarMassPanel.ts`]

### 5.4 播放门闩

`playingAllowedProperty: engine.allowedOrbitProperty`。崩溃/逃逸不能 Play。步进：`stepOnce(1/8, true)`。[已确认 ScreenView + Model.stepOnce]

### 5.5 目标轨道

Mercury e=0.2056 a=0.4 … Jupiter e=0.0484 a=5.2。仅太阳质量==200 且非第二定律显示。[已确认 `TargetOrbit.ts` + ScreenView visibleProperty]

### 5.6 多指

未发现多指同时拖两体（太阳不可拖）。键盘拖存在；本工程 **[有意差异]** 可不做 PDOM 键盘拖，指针拖必须做。

### 5.7 Hit / 边界

球体 mouse/touch area = 半径 + 10 view 单位。  
`constrainDragPoint`：interfaceBounds 侵蚀 radius 后，减去各面板扩到边的矩形。点在外则 `shape.getClosestPoint`。

---

## 6. Animation

| 对象 | from→to | duration | easing | 中断 |
|---|---|---|---|---|
| zoomScale | 100↔45 | **0.5 s** | CUBIC_IN_OUT | Reset 时跳到 100，不播动画 |
| PeriodTracker FADING | 描线淡出 | **3 s** | Stopwatch 线性 | `softReset` 清 |
| 轨道运行 | 解析推进 | 由 dt·speed·0.002 | 无 easing | Pause 停 `run` |
| ExplosionNode | 碰撞 | BodyNode collided | [待确认细节] | Kepler 用 CRASH 警告为主，太阳不爆炸 |

无 Nucleon 飞入类动画。

---

## 7. Clock

- 默认 **暂停**
- `step(dt)`：仅 playing 时 `stepOnce`；始终 `periodTracker.step`
- `stepOnce`：`dt *= timeSpeedMap * engineTimeScale(0.002)` → `engine.run` → `dt *= modelToViewTime(1000/12.6)` 加到 `timeProperty`（years）与秒表
- 步进按钮额外 `usingStepForwardButton=true` 避免 multilink 重建轨道
- Restart 按钮 enabled = `hasPlayedProperty`

[已确认 Model.step / stepOnce + TimeControlNode]

---

## 8. Reset / Restart / Undo

| 操作 | 行为 |
|---|---|
| **Reset All** | 暂停；时间 0；zoom/重力缩放/卷尺默认；bodies=defaultBodyInfo；定律/分割/幂次/circular/tracker/target/stopwatch reset；`hardVisibilityReset`；`userHasInteracted` reset；引擎 reset |
| **Restart** | 暂停；时间 0；`loadBodyInfo(startingBodyInfo)`；`restarting=true` 以免逃逸音 |
| **Undo** | **不存在** |

用户开始拖/改质量：`hasPlayed.reset()` 使 Restart 禁用，直到松手保存新 starting。[已确认]

秒表 checkbox 关：时间清 0 且 stop。周期 checkbox 关：`periodTracker.timerReset`。

---

## 9. Invalid / Boundary

| 状态 | 判定 | UI | 播放 |
|---|---|---|---|
| STABLE | 非 crash 非 escape | 实线椭圆 | 允许 |
| CRASH | periapsis < 太阳半径 | 虚线 + “crash into the sun” + BodiesCollide.mp3 | 禁止 |
| ESCAPE | \|v\| ≥ vesc·ε | 虚线 + “escape” + ObjectWillEscape.mp3；e 显示 1 | 禁止 |
| v 被夹 | 永远到不了真正抛物线 | 近抛物线椭圆 | — |

Always Circular 改速度会 `engine.reset()` 避免形状跳变。

---

## 10. Lifecycle

- 多数 listener **不 unlink**（官方：静态分配、sim 生命周期）
- `interruptSubtreeEmitter`：播放开始 / reset / restart 取消拖拽
- 切 joist Screen 保留各屏自己的 Model（四屏四实例）
- 本工程 Tab 无 KeepAlive → 切 Tab dispose。[有意差异，同 BAN]

`userHasInteracted`：playing 或 userInteractingEmitter。Reset 清零。

---

## 11. Responsive

PhET `ScreenView` 固定 `layoutBounds`（joist 默认 768×504 量级）[推测：未读 joist 默认，待测截图]。  
`visibleBounds` 变时 AlignBox 贴边；TimeControl 以 **layoutBounds** 定 bottom，不是 visibleBounds。  
Zoom 只改 MVT scale，不改 layoutBounds。  
本工程用 NineGrid + 中心格 LayoutBuilder 做 MVT，**禁止为截图写死像素**。

---

## 12. Assets

### images（Info / 周期计时器）

`focalDistance.png` · `infoSemiMajorAxis.png` · `infoSemiMinorAxis.png` · `periodTimerBackground.png` · `periodTimerIcon.png` · `planetPosition.png` · `planetVelocity.png` · `rvAngle.png`

### sounds

BodiesCollide · ObjectWillEscape · Success（T²/a³）· Metronome 1/2 + reverb · PeriodDivisionSelection_2..6 · OrbitEccentricity_loop.wav  
另：solar-system-common 的 grab/release 与天体循环音。

### strings

见 `keplers-laws-strings_en.json`。工程文案用英文原串，不自造中文（BAN Chart Intro 先例）。

### 官方截图（仓库 assets，非运行时）

`keplers-laws-screenshot-screen1.png` … `screen4.png` 及 alt。Phase 2 下载。

---

## 13. 四屏功能矩阵

| 功能 | First | Second | Third | All |
|---|---|---|---|---|
| 椭圆 + 拖行星/速度 | ✓ | ✓ | ✓ | ✓ |
| Axes/Foci/String/e | ✓ | — | — | 选 First |
| 面积分割/节拍 | — | ✓ | — | 选 Second |
| Target orbit | ✓ | 隐藏 | ✓ | 非 Second |
| T vs a + 质量 | — | — | ✓ | 选 Third |
| 定律 radio | — | — | — | ✓ |
| More orbital data | ✓ | ✓（非 All） | pref | pref |

---

## 14. 本阶段结论

- 核心可移植物是 **EllipticalOrbitEngine 公式全集** + **KeplersLawsModel 时间尺度** + **可见性依赖图**。
- 没有 Undo。Reset ≠ Restart。
- 渲染是 scenery Path 场景图，不是单 Canvas；Flutter 用 CustomPainter + Overlay widgets 等价，不复制 Node 树。
- **Blocked：** 无。  
- **测试 / analyze：** 无代码。  
- **下一阶段：** Phase 2 Visual Baseline。
