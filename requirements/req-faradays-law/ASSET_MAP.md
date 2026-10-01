# ASSET_MAP — Faraday's Law

> 源码根：`phet sourses/faradays-law-main/faradays-law-main`  
> 依赖位图：`phet sourses/scenery-phet/mipmaps/lightBulbBase.png`  
> 政策：原 PhET Asset → SVG/PNG/Mipmap → Scenery geometry → Flutter Canvas；**Substituted Assets 目标 = 0**  
> 扫描日：2026-09-22 · Phase 0

---

## 0. 状态图例

| 标记 | 含义 |
|------|------|
| `[已确认：原图]` | 运行时使用 PhET 官方 PNG/Mipmap |
| `[已确认：源码绘制]` | Scenery Path/Shape/Gradient，无位图 |
| `[已确认：复合对象]` | 原图 + 程序绘制组合 |
| `[Home only]` | 仅 Home / 营销；sim 内部不使用 |

---

## 1. 仓库内位图（必须直接复用）

| Original Asset | Original Path | Intrinsic | Used By | Flutter Path（建议） | Scale | Rotation | Crop | Opacity | Transform | 状态 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `fourLoopFront.png` | `mipmaps/fourLoopFront.png` | **420×468** | `CoilNode` FOUR_COIL front；radio 图标 | `assets/simulations/faradays_law/four_loop_front.png` | **1/3** | 0 | 否 | 1 | center 相对 coil + `CoilNode.xOffset=8`；**提到 magnet 之上** | `[已确认：原图]` |
| `fourLoopBack.png` | `mipmaps/fourLoopBack.png` | **420×468** | `CoilNode` FOUR_COIL back | `…/four_loop_back.png` | 1/3 | 0 | 否 | 1 | 同；**在 magnet 之下** | `[已确认：原图]` |
| `twoLoopFront.png` | `mipmaps/twoLoopFront.png` | **318×468** | `CoilNode` TWO_COIL front；双线圈 radio | `…/two_loop_front.png` | 1/3 | 0 | 否 | 1 | center + `xOffset+twoOffset`（8+8）；magnet 之上 | `[已确认：原图]` |
| `twoLoopBack.png` | `mipmaps/twoLoopBack.png` | **318×468** | `CoilNode` TWO_COIL back | `…/two_loop_back.png` | 1/3 | 0 | 否 | 1 | magnet 之下 | `[已确认：原图]` |
| `faradays-law-128.png` | `assets/faradays-law-128.png` | （icon） | Sim / Home 图标候选 | Home 策略另定 | — | — | 否 | 1 | **仅 Home** | `[Home only]` |

**禁止**：用 `assets/*screenshot*`、`*.ai` 当运行时 UI。

---

## 2. 依赖库位图（scenery-phet · 必须复用）

| Original Asset | Original Path | Used By | Flutter Path（建议） | Scale | 状态 |
| --- | --- | --- | --- | --- | --- |
| `lightBulbBase.png` | `phet sourses/scenery-phet/mipmaps/lightBulbBase.png` | `BulbNode` 灯座 | 可复用已有 `assets/simulations/capacitor_lab_basics/light_bulb_base.png`（同源）或复制到 `faradays_law/` | `BULB_BASE_WIDTH(36) / height` | `[已确认：原图]` |

---

## 3. 非运行时源文件（勿当 Flutter asset）

| 文件 | 路径 | 说明 |
|------|------|------|
| `four-loop.ai` / `two-loop.ai` | `assets/` | 设计源；已导出 mipmap |
| `light-bulb.ai` / `light-bulb-base.ai` | `assets/` | 设计源；运行时用 scenery-phet PNG + Path |
| `faradays-law-html5.ai` | `assets/` | 设计源 |
| `faradays-law-screenshot*.png` | `assets/` | 文档/营销截图 |
| `*.wav` in assets | `assets/` | 源音频；运行时用 `sounds/*.mp3` |

---

## 4. 程序绘制 / 复合对象（Canvas 等价 · 非替代素材）

| 对象 | PhET 源 | 类型 | 组成 | Flutter 策略 | 状态 |
|------|---------|------|------|--------------|------|
| **Bar magnet** | `MagnetNode` | 源码绘制 | 红/蓝半块 Rectangle + 3D Path 阴影 + N/S Text | CustomPainter；禁 Material magnet icon | `[已确认：源码绘制]` |
| **Field lines** | `MagnetFieldLines` | 源码绘制 | 4 椭圆×2 侧 + Path 箭头；随磁铁平移；flip 旋转 π | CustomPainter；**禁止自写 dipole** | `[已确认：源码绘制]` |
| **Drag hint arrows** | `MagnetMovementArrowsNode` | 源码绘制 | 四向浅绿箭头 `#B2FCB7` | Painter | `[已确认：源码绘制]` |
| **Coil wires** | `CoilsWiresNode` | 源码绘制 | Path `#7f3521` width 3 | Path | `[已确认：源码绘制]` |
| **Light bulb** | `BulbNode` | 复合 | **lightBulbBase** + Path 泡壳/灯丝 + RadialGradient 填充 + halo Circles | Image + Painter | `[已确认：复合对象]` |
| **Voltmeter body** | `VoltmeterNode` | 源码绘制 | `ShadedRectangle` 深蓝 + 白读数区 + yellow "voltage" + ±/−端子 | Painter（禁数字 Text 电压） | `[已确认：源码绘制]` |
| **Voltmeter gauge** | `VoltmeterGauge` | 源码绘制 | 半圆弧 + ArrowNode 针 + Plus/Minus | Painter | `[已确认：源码绘制]` |
| **Voltmeter wires** | `VoltmeterWiresNode` | 源码绘制 | 蓝紫线 `#353a89` + pad Circles | Path | `[已确认：源码绘制]` |
| **Flip polarity button** | `FlipMagnetButton` | 复合 | 小 MagnetNode + 弯箭头 Path；底色 `rgb(205,254,195)` | 自绘按钮内容；禁 Icons.sync | `[已确认：复合对象]` |
| **Coil radio icons** | `ControlPanelNode` | 复合 | 缩小 `CoilNode`（含 mipmap）scale 0.21 | 复用 coil PNG | `[已确认：复合对象]` |
| **Checkboxes** | sun `Checkbox` | UI | PhET 风格勾选框 + PhetFont 16 | **复用 KartosLab PhET-style Checkbox L0**；禁 Flutter 默认 Checkbox 外观 | `[已确认：源码绘制]` |
| **Reset All** | scenery-phet `ResetAllButton` scale 0.75 | L0 | 橙色球面 + ResetShape | **`KratosResetAllButton`** radius≈20.5×0.75 | `[已确认：源码绘制]` |

---

## 5. Sounds（可选 Phase；行为链不依赖）

| Asset | Path | Used By |
|-------|------|---------|
| grab / release magnet | `sounds/grabMagnet.mp3`, `releaseMagnet.mp3` | `MagnetNodeWithField` |
| coil bump | `coilBumpLow.mp3`, `coilBumpHigh.mp3` | `FaradaysLawScreenView` |
| voltage max | `voltageMaxClick.mp3` | `VoltmeterGauge` |
| voltage tones | `lightbulbVoltageNote*.mp3` | `VoltageSoundGenerator` |

---

## 6. Substituted Assets 门禁

| 阶段 | Substituted |
|------|-------------|
| Phase 0（审计） | N/A（尚未实现） |
| Final 目标 | **0** |

禁止清单（sim 内部）：

- Material / Cupertino Icons（含 `Icons.refresh` 冒充 Reset）
- Emoji / 网络图 / AI 图
- 截图 crop 当可交互 asset
- Generic bulb / magnet / voltmeter / coil 第三方素材

---

## 7. Coil 端点相对坐标（导线接线）

| CoilType | topEnd | bottomEnd |
|----------|--------|-----------|
| TWO_COIL | (30, −10) | (60, 6) |
| FOUR_COIL | (0, −10) | (70, 6) |

相对线圈中心；绝对位置 = coil.position + relative。
