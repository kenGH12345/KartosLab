# PHASE 0 — SOURCE AUDIT · Faraday's Law

本地基准：`phet sourses/faradays-law-main/faradays-law-main`  
入口：`js/faradays-law-main.js`（仓库内**无** `faradays-law-main.ts`；入口为 JS）  
`package.json` 版本：`1.5.0-dev.3`  
`dependencies.json` 注释：`# faradays-law 1.5.0-dev.3 Tue Mar 28 2023`  
官方 runtime：https://phet.colorado.edu/sims/html/faradays-law/latest/faradays-law_all.html  
官方 GitHub：https://github.com/phetsims/faradays-law  

**本阶段**：只审计，不写 Flutter simulation implementation。  
**状态**：Phase 0 COMPLETE → 待进入 Phase 1（Model）  
**FINAL STATUS**：NOT STARTED / NOT READY（禁止宣布 READY）

---

# Screen Structure

## Screens = 1

来源：`js/faradays-law-main.js` 第 33–37 行：

```js
const sim = new Sim( faradaysLawTitleStringProperty, [
  new FaradaysLawScreen( Tandem.ROOT.createTandem( 'faradaysLawScreen' ) )
], simOptions );
```

| 项 | 值 |
|---|---|
| screen 数量 | **1** |
| screen 类 | `FaradaysLawScreen` |
| screen 名称 / 标题 | `FaradaysLawStrings['faradays-law'].title` → **"Faraday's Law"** |
| screen 顺序 | 唯一 |
| default screen | 该唯一 screen |
| Screen model factory | `() => new FaradaysLawModel( LAYOUT_BOUNDS, tandem )` |
| ScreenView | `FaradaysLawScreenView` |
| 背景色 | `rgb( 151, 208, 255 )` → `#97D0FF` |
| maxDT | `0.1` s（tab 隐藏后恢复时防大步长） |
| screen icon | 本仓库 `assets/faradays-law-128.png` / screenshot assets；Home 图标策略另定（Phase 7） |

**禁止依据官网截图假设多 screen。Source 明确只有 1 个 screen。**

```text
Faraday's Law
└── FaradaysLawScreen
    ├── FaradaysLawModel
    └── FaradaysLawScreenView
```

---

# Main Classes

| 层 | 类 | 路径 |
|---|---|---|
| Entry | `faradays-law-main.js` | `js/faradays-law-main.js` |
| Screen | `FaradaysLawScreen` | `js/faradays-law/FaradaysLawScreen.js` |
| Constants | `FaradaysLawConstants` | `js/faradays-law/FaradaysLawConstants.js` |
| Model root | `FaradaysLawModel` | `js/faradays-law/model/FaradaysLawModel.js` |
| Magnet | `Magnet` | `js/faradays-law/model/Magnet.js` |
| Coil | `Coil` | `js/faradays-law/model/Coil.js` |
| Voltmeter (dynamics) | `Voltmeter` | `js/faradays-law/model/Voltmeter.js` |
| Enums | `OrientationEnum`, `CoilTypeEnum`, `MagnetDirectionEnum` | `model/` |
| ScreenView | `FaradaysLawScreenView` | `js/faradays-law/view/FaradaysLawScreenView.js` |
| Controls | `ControlPanelNode` | `view/ControlPanelNode.js` |
| Magnet view | `MagnetNodeWithField`, `MagnetNode`, `MagnetFieldLines`, `MagnetMovementArrowsNode` | `view/` |
| Coil view | `CoilNode`, `CoilsWiresNode` | `view/` |
| Bulb | `BulbNode` | `view/BulbNode.js` |
| Voltmeter view | `VoltmeterAndWiresNode`, `VoltmeterNode`, `VoltmeterGauge`, `VoltmeterWiresNode` | `view/` |
| Flip | `FlipMagnetButton` | `view/FlipMagnetButton.js` |
| Sound | `VoltageSoundGenerator` | `view/VoltageSoundGenerator.js` |
| a11y / keyboard | `FaradaysLawKeyboardDragListener`, `MagnetAutoSlideKeyboardListener`, `MagnetRegionManager`, `MagnetDescriber`, … | `view/` |

---

# Model Classes

## FaradaysLawModel（根）

| Property / 字段 | 默认 | 说明 |
|---|---|---|
| `bounds` | `LAYOUT_BOUNDS` 0–834 × 0–504 | 拖拽外边界 |
| `topCoilVisibleProperty` | `false` | **双线圈模式**：true 显示顶部 2-loop coil |
| `magnetArrowsVisibleProperty` | `true` | 四向拖拽提示箭头 |
| `voltmeterVisibleProperty` | `false` | 电压表可见性 |
| `voltageProperty` | `0` | **双用途**：驱动针角（radians）+ 灯泡亮度；单位标注 `V`，但数值实际按角度动力学演进 |
| `magnet` | `Magnet` | 可拖磁铁 |
| `bottomCoil` | `Coil(BOTTOM_COIL_POSITION, 4, magnet)` | 始终存在；4 spirals |
| `topCoil` | `Coil(TOP_COIL_POSITION, 2, magnet)` | 仅当 `topCoilVisible` 时参与 `step` |
| `voltmeter` | `Voltmeter(this)` | 针动力学 → 写回 `voltageProperty` |
| Restricted bounds | 每线圈上下各 1 块 | 经验尺寸，挡磁铁穿过线圈实体 |

### step(dt)

```text
bottomCoil.step(dt)
if topCoilVisible: topCoil.step(dt)
voltmeter.step(dt)
```

### reset()

重置：`magnet`、`topCoilVisible`、`magnetArrowsVisible`、`bottomCoil`、`topCoil`、`voltmeterVisible`。  
**不直接** `voltageProperty.reset()`；线圈 EMF 归零后靠后续 `voltmeter.step` 阻尼归零（见 Known VERSION_DELTA）。

---

## Magnet

| 项 | Source 事实 |
|---|---|
| position | `Vector2Property` 默认 **`(647, 200)`**（中心，view 坐标） |
| size | width **140**, height **30** |
| orientation / polarity | `OrientationEnum`: **`NS`（默认）** 或 `SN` |
| strength | **无独立 strength Property**；B 场公式固定标定 |
| physical rotation | **不存在**；仅 Flip Polarity 交换 N/S 半块左右位置 |
| field lines visible | `fieldLinesVisibleProperty` 默认 **`false`** |
| isDragging | `isDraggingProperty` |
| drag range | `model.bounds` 内，且避开 coil restricted zones |
| collision | `moveMagnetToPosition` → `checkProposedMagnetMotion` 限制平移；碰线圈发 `coilBumpEmitter`；碰边发 `edgeBumpEmitter` |
| velocity | **无显式 velocity 状态**；位置由 pointer/keyboard 每帧设定；`Coil.step` 用 `dB/dt` 隐含速度效应 |
| drag speed → EMF | **是**：位移越快 → `ΔB` 越大（同 dt）→ `|emf|` 越大 |

`OrientationEnum.NS`：北（红）在左、南（蓝）在右（与截图一致）。  
`SN`：交换半块位置。

---

## Coil（Pickup Coil）

### 两个配置选择器的真实含义（禁止猜 small/large）

`ControlPanelNode` → `RectangularRadioButtonGroup( model.topCoilVisibleProperty )`：

| Radio value (`topCoilVisible`) | UI 图标 | 实际电路 |
|---|---|---|
| **`false`（默认）** | 仅 4-loop 图标（`singleCoilRadioButton`） | **仅 bottom coil**（4 spirals） |
| **`true`** | 上下两个线圈图标（`doubleCoilRadioButton`） | **top 2-spiral + bottom 4-spiral** |

- Coil **不可拖拽**；位置固定。
- 配置切换只改顶部线圈可见性 + 顶部导线；底部线圈始终存在。
- 若切换到双线圈时磁铁与 top restricted area 相交 → **磁铁 position reset 到默认**。

| Coil | position | numberOfSpirals | EMF 匝数 `numberOfCoils` |
|---|---|---|---|
| bottom | `(448, 310)` | 4 | `4/2 = 2` |
| top | `(422, 110)` | 2 | `2/2 = 1` |

近场半径：`NEAR_FIELD_RADIUS = 50`（像素标定）。

---

## Faraday 计算链（Source 实际实现）

**不是**教科书式独立 `Φ = ∫B·dA` 网格积分。Source 使用**标定简化模型**：

### B field（`Coil.updateMagneticField`）

```text
sign = (orientation === NS) ? -1 : +1
r² = distance²(coil, magnet) / NEAR_FIELD_RADIUS²

if r² < 1:   B = sign * 2          // 近场饱和
else:        B = sign * (3·dx² − r²) / r⁴   // 修改偶极，幂次 2（注释：比立方更「手感好」）
             dx = (magnet.x − coil.x) / NEAR_FIELD_RADIUS
```

### EMF（`Coil.step`）

```text
numberOfCoils = numberOfSpirals / 2
emf = numberOfCoils * (B − B_prev) / dt
```

### Voltage / needle / bulb（`Voltmeter.step`）

```text
signal = 0.2 * (bottomCoil.emf + topCoil.emf)   // 0.2 经验标定（含符号）
needleAccel = 50*(signal − voltage) − 10*ω
voltage ← 半隐式积分（针角，radians）
|voltage|、<ω、|<accel| < 1e-3 → 钳到 0（防永久振荡）
```

### 灯泡

`BulbNode`：`halo.scale ∝ 20 * |voltage|`；`< 0.1` 隐藏 halo。  
**正负电流同样亮**（绝对值）。无独立 `current` Property。

### 电子 / 电流粒子

**Source 不显示 electron / charge particles / wire current arrows。**  
电流可视化 = 灯泡光晕 +（可选）电压表指针 + 音效。

### 完整数据链图

```text
Magnet.position + Magnet.orientation
        ↓
   Coil.updateMagneticField → B
        ↓
   Coil.step: emf = N * ΔB / dt
        ↓
   Voltmeter.signal = 0.2 * Σ emf
        ↓
   voltageProperty (needle angle / “V”)
        ↓
   ┌────────────────┬─────────────────┐
   │ LightBulb halo │ Voltmeter needle│
   │ (|V|)          │ (clamped ±π/2)  │
   └────────────────┴─────────────────┘
        ↓
   VoltageSoundGenerator（|V| 分层音高）
```

Field lines **不参与**该计算链（纯视觉，绑在磁铁节点上）。

---

# View Classes

## Layering（z-order，阻塞级）

`FaradaysLawScreenView` 添加顺序 + front detach：

1. `CircuitDescriptionNode`（a11y）
2. `CoilsWiresNode`（导线）
3. `BulbNode`
4. `bottomCoilNode` / `topCoilNode`（含 back + 初建的 front）
5. `ControlPanelNode`
6. `VoltmeterAndWiresNode`
7. `MagnetNodeWithField`（**含** `MagnetFieldLines` 子节点 + 磁铁 + 拖拽箭头）
8. **`bottomCoilNode.frontImage` 提到最前**
9. **`topCoilNode.frontImage` 提到最前**
10. `interactionCueLayer`（GrabDrag 提示）

**磁铁夹在线圈后层与前层之间。** 禁止 Flutter 把拖拽对象无条件 `bringToFront` 盖住线圈前层。

---

## Voltmeter（View）

| 项 | Source |
|---|---|
| dial | 半圆弧 radius 55；左 −、右 + |
| needle range | clamp **`[−π/2, +π/2]`** |
| center zero | 竖直向上 |
| + 方向 | 向右（正电压） |
| − 方向 | 向左（负电压） |
| units | 标签 `"voltage"`；无数字读数 |
| default visibility | **隐藏**（checkbox 关） |
| animation | `voltageProperty` 每帧驱动；非瞬时跳变 |
| max 触边 | 播放 `voltageMaxClick`（正负不同 playbackRate） |

符号约定以 `signal = 0.2 * Σemf` + `OrientationEnum` 的 B sign 为准，**不以常识推导**。

---

## Light Bulb

| 项 | Source |
|---|---|
| asset | `scenery-phet/mipmaps/lightBulbBase.png` + Path 泡壳/灯丝/halo |
| brightness | `scale = 20 * abs(voltage)`；`< 0.1` → halo 不可见 |
| +/- current | **同样亮** |
| default | 灭（voltage=0） |
| position | `BULB_POSITION (190, 200)` + `BULB_X_DISPLACEMENT -45` |

---

## Magnetic Field Lines

| 项 | Source |
|---|---|
| default | **OFF** |
| geometry | **预定义 4 条椭圆**×上下两侧（`LINE_DESCRIPTION`），**非**实时 B 网格 |
| arrows | 白箭头，位置角固定；**flip polarity 时绕点旋转 π** |
| dependency | 随磁铁 `translation` 移动；极性改箭头方向；**无 strength 参数** |
| 禁止 | 自行 dipole approximation 替换预定义椭圆 |

---

## Electrons / Current visualization

**不存在。** Phase 2–4 不得新增电子动画（除非未来 VERSION_DELTA 明确）。

---

# Interaction Map

| 控件 / 手势 | 类型 | 绑定 | 默认 | 行为 |
|---|---|---|---|---|
| Magnet drag | pointer `DragListener` | `moveMagnetToPosition` | pos (647,200) | 连续更新 position；隐藏箭头；受 bounds + coil obstacles |
| Magnet keyboard | `KeyboardDragListener` | dragSpeed 300 / shift 100 | — | WASD / arrows |
| Magnet auto-slide | keys 1/2/3 | speeds 90 / 300 / 500 | — | 水平滑向目标；`step(dt)` 动画 |
| Voltmeter checkbox | PhET `Checkbox` | `voltmeterVisibleProperty` | false | 显隐电压表+导线 |
| Field Lines checkbox | PhET `Checkbox` | `magnet.fieldLinesVisibleProperty` | false | 显隐场线 |
| Coil selector | `RectangularRadioButtonGroup` | `topCoilVisibleProperty` | false（单线圈） | 单 4-loop vs 双线圈 |
| Flip Polarity | `RectangularPushButton` | toggle NS↔SN | NS | 重建 MagnetNode；B sign 翻转；场线箭头翻转 |
| Reset All | `ResetAllButton` scale 0.75 | `model.reset` | — | 见 Reset Behavior |

**Source 不存在**：pause、speed slider、timer、tabs、独立 current slider。禁止自行新增。

---

# Assets

见 `ASSET_MAP.md`。

摘要：

- **必须复用 PNG**：`fourLoopFront/Back`、`twoLoopFront/Back`、`scenery-phet lightBulbBase`
- **源码绘制**：磁铁、场线椭圆、导线、电压表表体/针、灯泡泡壳、Flip 按钮箭头、拖拽提示箭头、Reset（KartosLab L0）
- Home card icon：可走 KartosLab Home 策略（`faradays-law-128.png`）

目标：**Substituted = 0**

---

# Sounds

| 文件 | 用途 |
|---|---|
| `grabMagnet.mp3` | 抓起磁铁 |
| `releaseMagnet.mp3` | 放开磁铁 |
| `coilBumpLow.mp3` | 碰底部 4-coil |
| `coilBumpHigh.mp3` | 碰顶部 2-coil |
| `voltageMaxClick.mp3` | 针顶到 ±max |
| `lightbulbVoltageNoteC4/E4/G4/C5/BFlat4.mp3` | `VoltageSoundGenerator` 分层音 |

另：`boundaryReached` 来自 tambo shared（碰屏边）。

---

# Constants

| 常量 | 值 |
|---|---|
| `LAYOUT_BOUNDS` | **834 × 504** |
| `BULB_POSITION` | (190, 200) |
| `VOLTMETER_POSITION` | bulb − (0, 120) = (190, 80) |
| `MAGNET_WIDTH/HEIGHT` | 140 / 30 |
| `TOP_COIL_POSITION` | (422, 110) |
| `BOTTOM_COIL_POSITION` | (448, 310) |
| `NEAR_FIELD_RADIUS` | 50 |
| Coil restricted height | 12 |
| Top coil restricted width | 25 |
| Bottom coil restricted width | 55 |
| `NEEDLE_RESPONSIVENESS` | 50 |
| `NEEDLE_FRICTION` | 10 |
| EMF→signal 系数 | 0.2 |
| Background | `rgb(151, 208, 255)` |
| ResetAll scale | 0.75 → Flutter `KratosResetAllButton` radius 按项目惯例 ≈ 20.5×0.75 |
| Coil UI radio baseColor | `#cdd5f6` |
| Flip button baseColor | `rgb(205,254,195)` |
| Wire color (coils) | `#7f3521`, width 3 |
| Coil image scale | `1/3` |
| `CoilNode.xOffset` / `twoOffset` | 8 / 8 |

---

# Initial State

与用户原版截图一致：

| 状态 | 值 |
|---|---|
| Magnet position | (647, 200) |
| Polarity | NS（N 左红 / S 右蓝） |
| Movement arrows | **可见** |
| Field lines | OFF |
| Voltmeter | OFF |
| Coil mode | **单线圈**（仅 4-loop bottom） |
| voltage / bulb | 0 / 灭 |
| Top coil | 不可见 |

---

# Reset Behavior

`FaradaysLawModel.reset()`：

1. `resetInProgressProperty = true`（抑制「已拖动」标记等）
2. magnet：position、orientation、fieldLinesVisible
3. `topCoilVisible` → false
4. `magnetArrowsVisible` → true
5. bottom/top coil：B、B_prev、emf 重置并重算
6. `voltmeterVisible` → false
7. `resetInProgressProperty = false`
8. View：`GrabDragInteraction.reset()`；`magnetDragged = false`

**必须真正 reset Model**，禁止仅 `Navigator.pop` + rebuild。

---

# Lifecycle

| 事件 | Source 行为 |
|---|---|
| create | Screen 建 Model + ScreenView；sound generators 注册 |
| step | Joist Screen 调 `model.step(dt)`；`maxDT=0.1` |
| dispose | `VoltageSoundGenerator.dispose` unlinks；键盘 listener dispose |
| re-entry | 新 Screen/Model 实例；无全局 static 物理状态 |

Flutter 要求：Model clock 与 Widget 生命周期解耦；统一 Ticker；dispose 清 listener/ticker。

---

# Animation / Clock

| 项 | Source 事实 |
|---|---|
| ConstantDtClock | **不使用** |
| 时钟 | Joist `Screen` / `step(dt)` + `maxDT: 0.1` |
| Model step | `FaradaysLawModel.step` |
| View step | `MagnetAutoSlideKeyboardListener.step`（键盘滑行） |
| 帧率 | 浏览器 rAF；非固定 60 强制 |
| 插值 | 无独立插值层；针用阻尼积分 |
| 禁止 Flutter | 每个 widget 自建 `Timer`；`Future.delayed`+`setState` 做核心仿真 |

推荐：`simulation clock` + 单一 `Ticker`，服从 source `dt` 语义。

---

# Source Version

| 项 | 值 |
|---|---|
| package version | `1.5.0-dev.3` |
| dependencies stamp | 2023-03-28 |
| faradays-law sha (dependencies.json) | `abe873882c846600e9dcd4f06f11f3c9ff5a76a6` |
| 本地入口文件 | `js/faradays-law-main.js`（非 `.ts`） |

---

# Known VERSION_DELTA

| ID | 描述 | 迁移影响 |
|---|---|---|
| VD-01 | 入口为 `.js` 而非用户提及的 `.ts` | 审计以 `faradays-law-main.js` 为准 |
| VD-02 | `voltageProperty` 在 `reset()` 中未显式归零 | Flutter 可在 reset 后立即清 voltage/针速度以匹配「初始态」观感，或严格跟随 source 阻尼；**需 Phase 1 测试固定并记录选择** |
| VD-03 | 无 electron / current particle | 不实现电子；不算缺失 asset |
| VD-04 | 无 magnet strength 可调 | 不增加 strength slider |
| VD-05 | Field lines 为预定义椭圆，非物理 B 场线求解 | 必须复刻椭圆几何，禁止自写 dipole 场线 |
| VD-06 | `Coil.sense` 字段恒为 1，未使用 | 忽略或保留但不改符号逻辑 |
| VD-07 | `lightBulbBase` 来自 **scenery-phet** 依赖，不在 faradays-law/mipmaps | 从 `phet sourses/scenery-phet/mipmaps/lightBulbBase.png` 或已有 `assets/simulations/capacitor_lab_basics/light_bulb_base.png` 复用（同源） |
| VD-08 | a11y / PhET-iO / GrabDrag 大量存在 | MVP 可延后完整 a11y，但拖拽/物理/UI 控件不可省略 |
| VD-09 | 截图目测「3 圈」vs source **4 spirals / fourLoop PNG** | 以 mipmap + `numberOfSpirals=4` 为准 |

---

# Phase 0 完成条件检查

| 条件 | 状态 |
|---|---|
| Screen 结构明确 | ✅ Screens = 1 |
| Model 结构明确 | ✅ Magnet / Coil×2 / Voltmeter / Properties |
| Interaction 明确 | ✅ 见 Interaction Map |
| Clock 明确 | ✅ Screen.step + maxDT 0.1；无 ConstantDtClock |
| Assets 明确 | ✅ ASSET_MAP.md |
| Initial state 明确 | ✅ |
| Reset 明确 | ✅ |
| Screenshot audit | ✅ PHASE_0_SCREENSHOT_AUDIT.md |

**下一阶段：PHASE 1 — MODEL（`lib/faradays_law/model/` + 单元测试）**  
禁止本阶段写 Flutter 页面 / 改 Home。
