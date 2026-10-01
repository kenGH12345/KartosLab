# ASSET_MAP — Ohm's Law

> 源码根：`phet sourses/ohms-law-main/ohms-law-main`  
> 政策：原 PhET Asset → SVG/PNG/Mipmap → Scenery geometry → Flutter Canvas；**Substituted Assets 目标 = 0**  
> 扫描日：2026-09-27 · Phase 0

---

## 0. 状态图例

| 标记 | 含义 |
|------|------|
| `[已确认：原图]` | 运行时使用 PhET 官方 PNG/Mipmap/音频 |
| `[已确认：源码绘制]` | Scenery Path/Shape/Gradient/Text，无位图 |
| `[已确认：依赖音效]` | 来自 tambo / shared sound，不在本仓库 |
| `[Home only]` | 仅 Home / 营销；sim 内部不使用 |
| `[非运行时]` | 文档/设计源，禁止当 UI asset |

---

## 1. 仓库内运行时音频（必须复用）

| Original Asset | Original Path | Used By | Flutter Path（建议） | 状态 |
| --- | --- | --- | --- | --- |
| `currentV3Loop.mp3` | `sounds/currentV3Loop.mp3`（import `currentV3Loop_mp3`） | `CurrentSoundGenerator` | `assets/simulations/ohms_law/current_v3_loop.mp3` | `[已确认：原图]` |

`assets/current-v3-loop.wav` = 同源 wav 备份；**运行时以 `sounds/*.mp3` 为准**。

---

## 2. 依赖库音效（tambo · 必须对齐语义）

| Asset | 来源 | Used By | 备注 |
| --- | --- | --- | --- |
| `click_mp3` | tambo `sounds/click_mp3.js` | `DiscreteSoundGenerator` ×2（V / R slider） | 本地另有 `assets/slider-click-001.wav`；**source 实际绑定 tambo click**，勿擅自换 wav |
| resetAll shared | tambo `sharedSoundPlayers.get('resetAll')` | `ResetAllButton` | L0 `KratosResetAllButton` 已有策略 |

---

## 3. 非运行时源文件（勿当 Flutter asset）

| 文件 | 路径 | 说明 |
|------|------|------|
| `ohms-law-screenshot*.png` | `assets/` | 文档/营销截图 |
| `ohms_law_mockup.png` | `doc/` | 早期 mockup |
| `*.wav` in `assets/` | `assets/` | 源音频备份；运行时用 mp3 / tambo |
| `slider-click-001.wav` | `assets/` | **未被 js import**；勿当作已接线 click |

---

## 4. 程序绘制对象（Canvas 等价 · 非替代素材）

| 对象 | PhET 源 | 类型 | 组成 | Flutter 策略 | 状态 |
|------|---------|------|------|--------------|------|
| **公式字母 V/I/R/=** | `FormulaNode` | 源码绘制 | Times New Roman Text + 动态 scale | Text/Custom；禁 Material | `[已确认：源码绘制]` |
| **电路线框** | `WireBox` | 源码绘制 | `Rectangle` 505×165，stroke 10，圆角 4 | Path/RRect | `[已确认：源码绘制]` |
| **电池** | `BatteryView` | 源码绘制 | LinearGradient 灰体 + 铜端 + nub + 电压 Text | Painter；禁 Icons.battery | `[已确认：源码绘制]` |
| **电池组** | `BatteriesView` | 复合 | 最多 6 节，按 V 显隐/缩短 | 同上 | `[已确认：源码绘制]` |
| **电阻** | `ResistorNode` | 源码绘制 | 红渐变圆柱 + 椭圆端盖 + 黑点 impurities | Painter；禁电阻 emoji | `[已确认：源码绘制]` |
| **电流直角箭头** | `RightAngleArrow` | 源码绘制 | polygon Path，fill `#FF5500` | Path | `[已确认：源码绘制]` |
| **电流读数面板** | `ReadoutPanel` | 源码绘制 | sun Panel + Text | Panel + Text | `[已确认：源码绘制]` |
| **控制面板** | `ControlPanel` / `SliderUnit` | 源码绘制 | sun Panel + VSlider + 蓝 V/R 标签 | 复用/对齐 PhET slider 视觉 | `[已确认：源码绘制]` |
| **Units 单选** | `UnitsRadioButtonContainer` | UI | VerticalAquaRadioButtonGroup | PhET-style aqua radio；禁 Material Radio | `[已确认：源码绘制]` |
| **Reset All** | scenery-phet `ResetAllButton` **radius: 28** | L0 | 橙色球面 + 白 ResetShape | **`KratosResetAllButton(radius: 28)`** | `[已确认：源码绘制]` |

**位图 mipmap：本 sim 电路/公式/控件全部为源码绘制，无 circuit PNG。**

---

## 5. Substituted Assets 门槛

| 指标 | Phase 0 目标 |
|------|----------------|
| Substituted Assets | **0** |
| Material / Cupertino Icons 冒充 | **禁止** |
| 截图 crop 当可交互 asset | **禁止** |

---

## 6. 颜色速查（source）

| Token | 值 | 用途 |
|------|-----|------|
| Screen background | `#ffffe8` | `OhmsLawScreen` |
| `BLUE_COLOR` | `rgb(0, 0, 225)` | V / R 符号与标签 |
| `RED_COLORBLIND` | `rgb(255, 85, 0)` = `#FF5500` | I、电流文案、箭头、电阻体 |
| Reset All base | `#F79722` | `PhetColorScheme.RESET_ALL_BUTTON_BASE_COLOR` |
| Slider thumb | `#c3c4c5` / highlight `#dedede` | `SliderUnit` |
| Wire stroke | `#000` width 10 | `WireBox` |
