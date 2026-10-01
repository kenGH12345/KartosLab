# ASSET_MAP — Capacitor Lab Basics

> 源码根：`phet sourses/capacitor-lab-basics-main/capacitor-lab-basics-main`  
> 依赖库：`phet sourses/scenery-phet`（CapacitorNode / lightBulb* mipmaps）  
> 政策：`VISUAL_ASSET_POLICY.md`（优先级：原图 → Scenery geometry → Canvas；**Substituted Assets 目标 = 0**）  
> 扫描日：2026-09-12

---

## 0. 状态图例

| 标记 | 含义 |
|------|------|
| `[已确认：原图]` | 运行时使用 PhET 官方 PNG/Mipmap |
| `[已确认：源码绘制]` | Scenery Path/Shape/Gradient，无位图 |
| `[已确认：复合对象]` | 原图 + 程序绘制组合 |
| `[待确认]` | 尚需对照运行态 / Flutter 落地时再核 |

---

## 1. 仓库内位图（必须直接复用）

> Phase 1 深挖：origin / parent / layer / 交互。完整行为见 `SOURCE_ANALYSIS.md` §4。

| Original Asset | Original Path | Intrinsic | Used By | Flutter Path（建议） | Scale | Rotation | Crop | Opacity | Transform | 状态 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `probeBlack.png` | `images/probeBlack.png`（+ `_png.ts`） | **63×510** | `VoltmeterProbeNode`（负）；icon 内缩略 | `assets/simulations/capacitor_lab_basics/probe_black.png` | Probe **0.25**；icon **0.10** | Node `rotate(-yaw)`（默认 yaw=−45° → **+45°**） | 否 | 1 | Origin：Image 顶中心 `translate(-w/2,0)`；线 `centerBottom`；Parent=`VoltmeterProbeNode`；**可拖** | `[已确认：原图]` |
| `probeRed.png` | `images/probeRed.png` | **62×501** | 正探针 | `…/probe_red.png` | 同黑探针 | 同 | 否 | 1 | 同；**可拖** | `[已确认：原图]` |
| `voltmeterBody.png` | `images/voltmeterBody.png` | **405×502** | `VoltmeterBodyNode`；icon body | `…/voltmeter_body.png` | Body **0.336**；icon body **0.17**；（有 timer 时 toolbox×0.6） | 0 | 否 | 1 | Origin：左上 + `MVT(bodyPos)`；读数 Rect 叠加；层：body 最底；**可拖**；`hitTestPixels` | `[已确认：复合对象]` |
| `switchCueArrow.png` | `images/switchCueArrow.png` | **157×117** | `SwitchNode` | `…/switch_cue_arrow.png` | **25/height**；底开关再 `scale(1,-1)` | 底：竖直翻转 | 否 | 1 | `leftTop=wireSwitch.center` + `translate(-80,-250)`；Switch **最先**子节点；`!switchUsed`；**不可拖** | `[已确认：原图]` |
| `capacitanceScreenIcon.png` | `mipmaps/capacitanceScreenIcon.png` | **549×374** | `CapacitanceScreen` homeScreenIcon | `…/capacitance_screen_icon.png` | ScreenIcon proportion 1 | 0 | 否 | 1 | 仅 Home；**不可拖** | `[已确认：原图]` |

**Flutter 接入**：

- Phase 3–7：`StaticCircuitView` / `VoltmeterDragLayer` / `BulbNodeOverlay` 使用 `Image.asset`
- Phase 8 Home：`CapacitorLabBasicsHome` Tab 图标复用 `capacitance_screen_icon` + `light_bulb_base`
- `ClbConstants.asset*` 全覆盖 6 个强制原图

**Substituted Assets = 0**（无 Material/Cupertino/emoji/第三方/截图 crop 冒充 PhET）

**禁止**：用 `assets/*-screenshot*.png` 或 PSD/AI 源文件当作运行时 UI asset。截图仅供对照，非交互资源。

---

## 2. 依赖库位图（scenery-phet · 必须直接复用）

| Original Asset | Original Path | Intrinsic | Used By | Flutter Path（建议） | Scale | Rotation | Crop | Opacity | Transform | 状态 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `lightBulbBase.png` | `scenery-phet/mipmaps/lightBulbBase.png` | 89×71 | `BulbNode` 灯座 | `assets/simulations/capacitor_lab_basics/light_bulb_base.png`（或 common 共享） | `BULB_BASE_WIDTH / height`（42 / h） | 灯体坐标系见源码注释 | 否 | 1 | 复合：底座图 + Path 泡壳/灯丝 + halo | `[已确认：复合对象]` |
| `lightBulbOff.png` | `scenery-phet/mipmaps/lightBulbOff.png` | 108×189 | 本 sim **未直接 import**（保留映射；Faraday 等用） | 若引入则同名复用 | — | — | 否 | — | — | `[待确认]`（本 sim 路径未用） |
| `lightBulbOn.png` | `scenery-phet/mipmaps/lightBulbOn.png` | 136×203 | 本 sim **未直接 import** | 同上 | — | — | 否 | — | — | `[待确认]`（本 sim 路径未用） |

---

## 3. 非运行时源文件（勿当 Flutter asset）

| 文件 | 路径 | 说明 |
|------|------|------|
| `*.ai` / `*.psd` | `assets/` | 设计源；已导出为 `images/*.png` |
| `capacitor-lab-basics-screenshot*.png` | `assets/` | 营销/文档截图，**禁止** crop 当 UI |
| `capacitance_screen_icon.ai` | `assets/` | 已导出 mipmap |

---

## 4. 程序绘制 / 复合对象（Canvas 等价重建 · 非替代素材）

| 对象 | PhET 源 | 类型 | 组成 | Flutter 策略 | 状态 |
|------|---------|------|------|--------------|------|
| **Battery** | `BatteryGraphicNode` + `BatteryNode` | 源码绘制 | Path 椭圆/柱体 + LinearGradient + VSlider + 电压文字；`scale: 0.30`；极性翻转换子节点 | CustomPainter 按常量复刻渐变几何；**禁止** `Icons.battery_*` | `[已确认：源码绘制]` |
| **Capacitor / Plates** | `scenery-phet/.../CapacitorNode` → `PlateNode` / `BoxNode` | 源码绘制 | 顶/底板 Path 盒体 + 透视 | Canvas 按 PlateNode/BoxNode | `[已确认：源码绘制]` |
| **E-field** | `EFieldNode` | 源码绘制 | 场线箭头 canvas | CustomPainter | `[已确认：源码绘制]` |
| **Plate charge** | `PlateNode` 内 charge | 源码绘制 | +/- 电荷标记 | CustomPainter | `[已确认：源码绘制]` |
| **Wires** | `WireNode` + shapeCreator | 源码绘制 | Path 导线 | Path / Painter | `[已确认：源码绘制]` |
| **Switch / Hinge / Connection** | `SwitchNode` / `HingePointNode` / `ConnectionNode` | 复合 | Circle + Path + **switchCueArrow 图** | Circle/Path + 原图箭头 | `[已确认：复合对象]` |
| **Light bulb** | `BulbNode` | 复合 | **lightBulbBase 图** + Path 泡壳/灯丝 + RadialGradient halo | Image + Painter | `[已确认：复合对象]` |
| **Voltmeter** | `VoltmeterBodyNode` / probes / `ProbeWireNode` | 复合 | **body/probe 图** + Rectangle 读数 + Path 导线 | Image + Text/Rect + Path | `[已确认：复合对象]` |
| **Bar meters** | `BarMeterNode` / `BarNode` / `BarMeterPanel` | 源码绘制 | Rectangle 条 + 文字 + Panel | Painter + Panel（对齐 sun 风格） | `[已确认：源码绘制]` |
| **Drag handles** | `PlateArea/SeparationDragHandle*` / `DragHandleArrowNode` | 源码绘制 | Arrow / Line / Circle / 数值 Text | Painter + Text | `[已确认：源码绘制]` |
| **Current indicator** | `CurrentIndicatorNode` | 源码绘制 | 箭头指示 | Painter | `[已确认：源码绘制]` |
| **Controls** | `ToolboxPanel` / `CLBViewControlPanel` / Checkbox 等 | sun UI | Panel 几何 | 优先 L0/通用；视觉对齐 PhET | `[待确认]`（对照 L0） |
| **LightBulb screen icon** | `BulbNode.createBulbIcon()` + `rotate(-π/2)` | 复合绘制 | 非单独 mipmap | 复用 Bulb 绘制逻辑 | `[已确认：源码绘制]` |
| **DebugLayer** | `DebugLayer.js` | 调试 | 生产 UI 不复刻 | 跳过 | N/A |

**Dielectric**：Capacitor Lab **Basics** 源码为 vacuum gap 电容（`CapacitorNode` 注释），无独立 dielectric 贴图 → `[已确认：源码绘制]`（无原图可复用）。

---

## 5. Capacitor Lab 检查清单（§10）

| 对象 | 判定 |
|------|------|
| capacitor / plates | `[已确认：源码绘制]`（scenery-phet Plate/Box） |
| battery | `[已确认：源码绘制]`（BatteryGraphicNode） |
| wires | `[已确认：源码绘制]` |
| dielectric | `[已确认：源码绘制]`（Basics 无介质贴图） |
| voltmeter | `[已确认：复合对象]`（body/probe PNG + 读数/线） |
| electric field | `[已确认：源码绘制]` |
| charge visualization | `[已确认：源码绘制]` |
| measurement tools（bar meters） | `[已确认：源码绘制]` |
| buttons / control elements | `[待确认]`（sun + 本 sim panel） |
| background graphics | `[待确认]`（`CLBConstants.SCREEN_VIEW_BACKGROUND_COLOR`） |
| switch cue / probes / bulb base / screen icon | `[已确认：原图]` 或复合 |

---

## 7. 打包清单（Phase 2 — 已执行）

已从官方源复制到 `assets/simulations/capacitor_lab_basics/` 并注册 `pubspec.yaml`：

| Flutter 文件 | 来源 |
|--------------|------|
| `probe_black.png` | `images/probeBlack.png` |
| `probe_red.png` | `images/probeRed.png` |
| `voltmeter_body.png` | `images/voltmeterBody.png` |
| `switch_cue_arrow.png` | `images/switchCueArrow.png` |
| `capacitance_screen_icon.png` | `mipmaps/capacitanceScreenIcon.png` |
| `light_bulb_base.png` | `scenery-phet/mipmaps/lightBulbBase.png` |

**未**使用截图 / AI / PSD 导出。

---

## 7. Final QA 计数模板（收尾填写）

```
Assets:
Original Assets Reused:   _  (目标 ≥ 5 本仓 + 1 bulb base)
Original SVG Reused:      0  (本 sim 无运行时 SVG)
Original PNG Reused:      _
Original Mipmap Reused:   _
Canvas Reconstructed:     _
Custom Assets:            0
Substituted Assets:       0
```

若 `Substituted Assets ≠ 0`，必须逐项：Asset / Reason / Original Source Evidence / Why Direct Reuse Was Impossible / Flutter Replacement / Visual Impact。

---

## 8. 禁止事项（本 sim）

- ❌ `Icons.battery_std` 冒充电池  
- ❌ 自绘「差不多」的探针 / 电压表机身（已有官方 PNG）  
- ❌ 截图 crop 当 voltmeter / probe  
- ❌ 裁掉 PNG 透明 padding 导致 tip/origin 偏移  
- ❌ 探针忽略 `scale: 0.25` 与 yaw 旋转  
- ❌ 电池忽略 `BatteryGraphicNode` 渐变常量而改用位图或 Icon  
