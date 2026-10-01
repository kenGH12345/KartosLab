# ASSET_MAP — Resistance in a Wire

> 源码根：`phet sourses/resistance-in-a-wire-main/resistance-in-a-wire-main`  
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

## 1. 仓库内运行时音频

**无。** 本 sim 目录下 **不存在** `sounds/`。

---

## 2. 依赖库音效（tambo · 必须对齐语义）

| Asset | 来源 | Used By | Flutter Path（建议） | 状态 |
| --- | --- | --- | --- | --- |
| `brightMarimbaShort_mp3` | tambo `sounds/brightMarimbaShort_mp3.js` | `ResistanceSoundGenerator` | `assets/simulations/resistance_in_a_wire/bright_marimba_short.mp3`（从 tambo 包抽出）或共享 tambo 资产目录 | `[已确认：依赖音效]` |
| resetAll shared | tambo `sharedSoundPlayers.get('resetAll')` | `ResetAllButton` | L0 `KratosResetAllButton` 已有策略 | `[已确认：依赖音效]` |

---

## 3. 非运行时源文件（勿当 Flutter asset）

| 文件 | 路径 | 说明 |
|------|------|------|
| `resistance-in-a-wire-screenshot.png` | `assets/` | 营销/文档截图 |
| `resistance-in-a-wire-screenshot-screen1.png` | `assets/` | 同上 |
| `resistance-in-a-wire-screenshot-alt1.png` | `assets/` | 同上 |
| `resistance-in-a-wire-screenshot-alt2.png` | `assets/` | 同上 |

**用户会话 Gold Standard 截图**保存在 Cursor workspace assets；仅作视觉对照，**禁止** crop 后当可交互 UI。

---

## 4. 程序绘制对象（Canvas 等价 · 非替代素材）

| 对象 | PhET 源 | 类型 | 组成 | Flutter 策略 | 状态 |
|------|---------|------|------|--------------|------|
| **公式字母 R/ρ/L/A/=** | `FormulaNode` + `OutlinedTextNode` | 源码绘制 | Times Text + 动态 scale + 背景色描边 | Text/Custom；禁 Material | `[已确认：源码绘制]` |
| **分数线** | `FormulaNode` Path | 源码绘制 | 线段 stroke 6 | Path | `[已确认：源码绘制]` |
| **导线主体** | `WireNode.wireBody` | 源码绘制 | Path + LinearGradient 铜棕 | Painter；禁圆柱 emoji | `[已确认：源码绘制]` |
| **导线端盖** | `WireNode.wireEnd` | 源码绘制 | Ellipse Path fill `#E8B282` | Painter | `[已确认：源码绘制]` |
| **杂质点** | `DotsCanvasNode` | Canvas 绘制 | 黑圆 radius 2；clip 近似椭圆 | Canvas/CustomPainter；固定 seed | `[已确认：源码绘制]` |
| **方向箭头** | scenery-phet `ArrowNode` | 源码绘制 | 白填充黑描边 | Path；复用 L0 Arrow 若视觉一致 | `[已确认：源码绘制]` |
| **控制面板** | `ControlPanel` / `SliderUnit` | 源码绘制 | sun Panel + VSlider + 蓝符号/标签 | 对齐 PhET slider 视觉 | `[已确认：源码绘制]` |
| **Reset All** | scenery-phet `ResetAllButton` **radius: 30** | L0 | 橙色球面 + 白 ResetShape | **`KratosResetAllButton(radius: 30)`** | `[已确认：源码绘制]` |

**位图 mipmap：本 sim 公式/导线/控件全部为源码绘制，无 wire PNG。**

---

## 5. Substituted Assets 门槛

| 指标 | Phase 0 目标 |
|------|----------------|
| Substituted Assets | **0** |
| Material / Cupertino Icons 冒充 | **禁止** |
| 截图 crop 当可交互 asset | **禁止** |
| `Icons.refresh` 冒充 Reset All | **禁止** |

---

## 6. 颜色速查（source）

| Token | Hex | 用途 |
|------|-----|------|
| `BACKGROUND_COLOR` | `#ffffdf` | 屏背景 / 公式 outline |
| `BLUE_COLOR` | `#0f0ffb` | ρ L A 符号、name、单位 |
| `RED_COLOR` | `#F22` | R 字母、resistance 读数 |
| `BLACK_COLOR` | `#000` | `=`、分数线、stroke、value |
| `WHITE_COLOR` | `#FFF` | 箭头 fill |
| Wire mid | `#E8B282` | 端盖 / 渐变中段 |
| Wire dark | `#8C4828` | 渐变上下 |
| Wire light | `#FCF5EE` / `#F8E8D9` | 渐变高光 |
| Thumb | `#c3c4c5` / `#dedede` | slider thumb |
| Reset | `#F79722` | `KratosResetAllButton.baseColor` |

---

## 7. 尺寸 / Anchor 速查

| 对象 | Intrinsic / 规则 |
|------|------------------|
| layoutBounds | **1024×618** |
| Formula `=` | Times 90；局部 (100,0) |
| Formula letters | Times 15 base × scaleMagnitude |
| Wire origin | 几何中心 (0,0) |
| Arrow | tailLength 140；head 45×30；tailWidth 10 |
| Slider track | 4×200 |
| Slider thumb | 45×22 |
| Reset radius | **30** |

---

## 8. Phase 交接

| Phase | 使用本图方式 |
|-------|-------------|
| 1 Model | 无 asset 依赖 |
| 2 View | 按「源码绘制」重建；Reset `radius: 30` |
| 3 Runtime | 接 tambo marimba（可延后） |
| 4 Visual | Substituted=0；dots 固定 seed |
| 5 Home | 可用营销截图作卡片缩略，**不可**回灌 play area |

---

*ASSET_MAP Phase 0. Substituted Assets = 0.*
