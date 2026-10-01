# Source Analysis · My Solar System

> 需求：`req-my-solar-system`  
> 日期：2026-09-01  
> **Source of Truth**：`D:\OneDrive\Desktop\KartosLab\KartosLab\phet sourses\my-solar-system-main\my-solar-system-main`  
> 标记：`[已确认]` 本地该树 · `[二次证据]` Kepler / Flutter 重建 · `[BLOCKED]` 缺 solar-system-common · `[文档冲突]`

本文件只陈述原版。不写 Flutter 实现。

---

## 0. 源码登记

```text
Source Root:
D:\OneDrive\Desktop\KartosLab\KartosLab\phet sourses\my-solar-system-main\my-solar-system-main

Project: my-solar-system
Version: 1.4.0-dev.4          # package.json
Git: 不是 git checkout（git rev-parse 失败）
dependencies.json comment: my-solar-system 1.3.0-dev.8 / sha 681f3ef1…
HTML Entry: my-solar-system_en.html
Main JS Entry: js/my-solar-system-main.ts
Model: js/common/model/  + intro/model/  + lab/model/
View:  js/common/view/   + intro/view/   + lab/view/
Control: 无独立 control 包；控件在 view/
Assets: 无 images/ 无 sounds/（图标与音在 solar-system-common）
Preset: js/lab/model/OrbitalSystem.ts
Strings: my-solar-system-strings_en.json
phetLibs: solar-system-common
solar-system-common 本机: 缺失（全 Desktop 搜索 0 文件）
```

`package.json` `phet.screenNameKeys`: `screen.intro` / `screen.lab`。  
入口创建两 Screen：`IntroScreen` + `LabScreen`（`my-solar-system-main.ts:49-51`）。

**不要只看 HTML。** 可运行逻辑全在 `js/` TS。`assets/original-source/*.as` 是 Flash 遗留，**不是**本迁移算法源。

---

## 1. 调用链

```
my-solar-system-main.ts
  IntroScreen → IntroModel → MySolarSystemModel → SolarSystemCommonModel  [BLOCKED 父类]
                 IntroScreenView → MySolarSystemScreenView → SolarSystemCommonScreenView
  LabScreen  → LabModel  → 同上
                 LabScreenView → 插入 OrbitalSystemPanel
```

`NumericalEngine` 继承 `solar-system-common/js/model/Engine.js`（`NumericalEngine.ts:15`）。

---

## 2. State（SSOT 在 axon Property，无单一 immutable 对象）

### 2.1 时间 / 播放（父类 + MSS 覆盖）

| 量 | 原版行为 | 证据 |
|---|---|---|
| `engineTimeScale` | **0.05**（注释：适合 NumericalEngine） | `MySolarSystemModel.ts:75` |
| `zoomLevelRange` | 1–6，默认 **4** | `:76` |
| `zoomScale` | `linear(1,6, 25,125, zoomLevel)` | `:167-169` |
| `stepOnce(dt)` | 见 physics-analysis | `:262-284` |
| Step 按钮 | `stepOnce(1/8)` | `TimePanel.ts:36` |
| 时钟 | `timeProperty` years，2 位小数 | `TimePanel.ts:68-79` |
| Clear | `timeProperty.reset()`；`time===0` 时 `clearPaths` | `TimePanel.ts:85` + Model `:161-165` |
| 默认暂停 | `[二次证据]` Kepler 同父类 `isPlaying=false` | Kepler SOURCE_ANALYSIS |

Kepler 的 `engineTimeScale` 是 **0.002**（解析引擎）。**禁止混用。**

### 2.2 Intro 两体 `[已确认 IntroModel.ts:23-26]`

| # | mass | position (AU) | velocity (km/s) | color |
|---|---|---|---|---|
| 1 | 250 | (0, 0) | (0, -2.3446) | yellow / projector #FFAE00 |
| 2 | 25 | (2.00, 0) | (0, 23.4457) | magenta |

颜色：`MySolarSystemColors.ts`。Lab 另加 cyan、green。

### 2.3 Lab 槽位

静态 **4** 个 Body，永不 dispose（`implementation-notes.md`）。  
`defaultBodyInfo` 写了 4 个全 `isActive:true`，但 `orbitalSystemProperty` 默认 `SUN_PLANET`，link 里 `loadBodyInfo` 覆盖为 2 体（`LabModel.ts:34-90`）。

`numberOfActiveBodiesProperty` Lab 可写（`:49`）；Intro 只读（Model 默认 `phetioReadOnly: true`）。

### 2.4 可见性

`MySolarSystemVisibleProperties` 扩展父类，新增：

- `centerOfMassVisibleProperty` 默认 **false**
- `moreDataVisibleProperty` 默认 **false**（Intro tandem OPT_OUT）

父类默认 `[二次证据 Kepler]`：speed=false, **velocity=true**, gravity=false, **path=true**, grid=false, measuringTape=false。

### 2.5 CoM / Return / 碰撞旗标

- `CenterOfMass.position` 单位 AU；`velocity` 单位 km/s（`CenterOfMass.ts:32-44`）
- `followingCenterOfMassProperty`：`|r|<1 && |v|<0.01`（`MySolarSystemModel.ts:175-179`）
- 按钮 visible = **NOT** following（`ScreenView.ts:196`）
- `bodiesAreReturnableProperty` = 任一体 `isOffscreen` **或** `isAnyBodyCollided`（`:125`）
- 碰撞：`collidedEmitter` → `isAnyBodyCollided=true`（`:127-130`）

### 2.6 用户拖动副作用 `[已确认 :132-150]`

- 控 **位置或速度** → `isPlaying=false`
- 控位置/速度/**质量** → `userInteractingEmitter`；`hasPlayedProperty.reset()`（禁用 rewind 直至再次 save）
- 松手且 **不可 Return** → `saveStartingBodyInfo()`
- 质量 NumberControl 有 workaround：非 userIsControllingMass 时 mass link 也 save（`:152-158`）

Lab：`userInteractingEmitter` → `orbitalSystem=CUSTOM`（`LabModel.ts:70-72`）。

---

## 3. Preset 表

源：`OrbitalSystem.ts`。字符串：`my-solar-system-strings_en.json`（**Slingshot** 不是 Flyby）。

| Enum / UI 文案 | N | bodies (mass, pos, vel) |
|---|---|---|
| SUN_PLANET / Sun, Planet | 2 | 250 (0,0) (0,-2.3446)；25 (2,0) (0,23.4457) |
| SUN_PLANET_MOON / Sun, Planet, Moon | 3 | 200 (0,0) 0；10 (1.60,0) (0,25.3467)；1e-6 (1.40,0) (0,11.1948) |
| SUN_PLANET_COMET / Sun, Planet, Comet | 3 | 200 0；1 (1.50,0) (0,25.3467)；1e-6 (-2.20,1.30) (-4.2244,-7.3928) |
| TROJAN_ASTEROIDS / Trojan Asteroids | 4 | 200 0；5 (1.50,0) (0,25.1355)；1e-6 (0.75,-1.30) (21.7559,12.6733)；1e-6 (0.75,1.30) (-21.7559,12.6733) |
| ELLIPSES | 4 | 250 (-1,0) 0；三颗 1e-6 在 x=-0.15/1.50/3.20，vy=31.8946/12.6733/7.8152 |
| HYPERBOLIC | 4 | 250 (0,0.25) 0；三颗 1e-6 x=-2.50 y=-0.70/-1.40/-2.10，vx=25.3467 |
| SLINGSHOT / Slingshot | 3 | 200 (0.01,0) (0,-0.2112)；10 (1.31,0.55) (-11.6172,24.2906)；1e-6 (-0.06,-1.28) (17.5315,0) |
| DOUBLE_SLINGSHOT | 4 | 见源码 :62-67 |
| BINARY_STAR_PLANET | 3 | 150 (-1,0) (0,-12.6733)；120 (1,0) (0,10.5611)；1e-6 (-0.50,0) (0,25.3467) |
| FOUR_STAR_BALLET | 4 | 四颗 120，正方形 ±1，速度见 :73-77 |
| DOUBLE_DOUBLE | 4 | 见 :79-84 |
| ORBITAL_SYSTEM_1..4 | 4 | 全 100，x=-3/-1/1/3，v=(0,10)；**isPhetioConfigurable**；ComboBox `visible=false` |
| CUSTOM | 0 BodyInfo | 切到此项不 load；由用户状态定义 |

切换非 CUSTOM（`LabModel.ts:74-94`）：

1. `hasPlayed.reset`；`clearPaths`；`interruptSubtree`；**pause**
2. `isAnyBodyCollided.reset`；`time.reset`
3. `loadBodyInfo(orbitalSystem.bodyInfo)`
4. 非 phetioConfigurable → **`followCenterOfMass()`**（只减 CoM **速度**，不平移位置）
5. `saveStartingBodyInfo`；`gravityForceScalePower.reset`
6. 若 FOUR_STAR_BALLET 且非 phetio state → `gravityForceScalePower = -1.1`

---

## 4. View 层级（MSS 本树）

`MySolarSystemScreenView.ts`：

- `centerOrbitOffset: (100, 100)`（`:70`）—— MVT 原点偏移，父类实现 `[BLOCKED]`
- BodyNode + DraggableVelocityVectorNode + VectorNode(gravity) 每体各一
- CenterOfMassNode：红色 X
- 右上 VBox：Lab 时先插入 OrbitalSystemPanel；TimePanel；VisibilityControlPanel
- 左上：MagnifyingGlassZoomButtonGroup
- 顶中：Return Bodies + offscale 重力提示
- 左下：More Data + Info（仅 Lab 且 valuesPanel 可见）；ValuesPanel；Bodies spinner；Follow CoM 按钮
- `resetAllButton` 来自父类 `[BLOCKED]`
- PathsCanvasNode 在 `bottomLayer`，`pathVisibleProperty`
- `getDragBoundsItems`：右上面板、zoom、左下各控件（`:332-354`）

IntroScreenView：无额外控件。  
LabScreenView：preset 面板插入 `topRightVBox` 第 0 位。

---

## 5. Data Panel 编辑范围 `[已确认 ValuesColumnNode.ts]`

| 量 | range | 小数 |
|---|---|---|
| mass UI | **0.1 … body.massProperty.range.max** | 2；指数显示；minDisplayed 0.1 |
| x | -14 .. 14 AU | 2 |
| y | -8 .. 8 AU | 2 |
| Vx, Vy | -100 .. 100 km/s | 2 |

Preset 质量 **1e-6 低于滑条下限**。UI 可能显示 ≤0.1。不得把 preset 质量夹到 0.1。  
`MASS_SLIDER_STEP` 在 common `[BLOCKED]`。  
改 x/y/Vx/Vy 的 `onEditCallback` = `clearPaths`。

---

## 6. Path 渲染 `[已确认 PathsCanvasNode.ts]`

- 线宽 3，round cap；褪色段 15%、线宽 0.7 square cap
- 最大路径视图长度 = `modelToViewDeltaX(MAX_PATH_DISTANCE * 3/5)` — `MAX_PATH_DISTANCE` `[BLOCKED]`
- **paint 内 `points.shift()` 裁历史** —— 副作用在绘制。Flutter 应在 Controller/Solver 裁剪，Painter 只读。

---

## 7. 缺 solar-system-common 时无法从本树确认的符号

Body, BodyInfo, Engine, SolarSystemCommonModel, SolarSystemCommonScreenView, SolarSystemCommonConstants (G, MASS_SLIDER_STEP, MAX_PATH_DISTANCE, PANEL_OPTIONS, INITIAL_VECTOR_OFFSCALE, GRAB/RELEASE 音), BodyNode, DraggableVelocityVectorNode, VectorNode, GravityForceZoomControl, MeasuringTape, Grid, TimeControlNode, VisibleProperties 基类默认值, `isOverlapping` / `preventCollision` / `isOffscreen` / `addPathPoint`, `loadBodyInfo` / `restart` / `reset` / `saveStartingBodyInfo`, `constrainDragPoint`, `timeSpeedMap`, `modelToViewTime`, `gravityForceScalePowerProperty` range。

二次证据见 `physics-analysis.md` §8 与 Kepler `SOURCE_ANALYSIS.md`。
