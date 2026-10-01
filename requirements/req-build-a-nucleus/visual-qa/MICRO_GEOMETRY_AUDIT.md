# Icon / Micro-Geometry Audit（P5-1）

> 只取证，不改代码。2026-08-31  
> 原版：`d:\OneDrive\Desktop\phet sourses\build-a-nucleus-main\`  
> 共用控件：scenery-phet / sun（GitHub `phetsims/*`，本仓库无这些文件）  
> Flutter：`lib/chemistry/build_a_nucleus/`

**不要把 Material 里「看起来像」的 icon 写成视觉一致。**  
SVG / Path / Shape 必须对 shape，不能对名字。

颜色 / Typography / NineGrid / 主锚点本阶段不谈（P4 / P3 / P2 已冻）。  
Radio fill 已确认：选中 / 未选都是 `#F1FAFE`，不要改。

---

## 0. 读法

| 标记 | 含义 |
|---|---|
| [源码一致] | 几何参数已对齐，或已用同配方 Path 画出 |
| [视觉近似：Material] | sun / scenery-phet 控件 vs Material；**不要整套重写** |
| [可修复] | 1–5px 线宽 / icon 尺寸 / padding / 小间距，或盒内换 Path，不动锚点 |
| [有意差异] | 缺控件 / 用字代替图标 / NineGrid 裁掉的 chrome |
| [待确认] | 仓库无 scenery-phet 文件，或截图无法量 |

交互列：Y = 可点；N = 纯装饰。

---

## 1. 总表

| Component | PhET | Flutter | Difference | Evidence | Action |
|---|---|---|---|---|---|
| Decay Reset | `ResetAllButton` 橙圆 r=20.8，白 `ResetShape`，touch +5.2 | `IconButton` + `Icons.restart_alt` | 圆钮/Path vs Material 刷新 | `BANScreenView.ts` 121–131；scenery-phet `ResetAllButton.ts` | [视觉近似：Material] |
| Chart Intro Reset | 同 `ResetAllButton`（`BANScreenView`） | `TextButton`「Reset」 | 橙圆 Path vs 文字键 | `chart_intro_screen.dart` 152–155 | [视觉近似：Material] |
| Decay Undo | `ReturnButton` 黄方，`ReturnIcon` h=17×0.7，margin 5 | 面板内 `Icons.undo` 14–18，无黄底 | 自定义回流 Path vs Material undo | `DecayScreenView.ts` 99–100；`ReturnIcon.ts` | [视觉近似：Material] |
| Chart Intro Undo | 同 `ReturnButton` scale 0.7，在 Decay 键左，spacing 5 | `Icons.undo` 18，spacing 5 | 同左；位置关系已近 | `NuclideChartAccordionBox.ts` 116–128 | [视觉近似：Material] |
| Half-life Info | `InfoButton` 圆，`infoCircleSolidShape` ×1.45，maxH 30，粉底 | 30 圆 + `Icons.info` 22 | Path ≠ Material「i」 | `HalfLifeInformationNode.ts` 60–64；`InfoButton.ts` | [视觉近似：Material] |
| Available Decays Info | 同 Info，底 **白** | **无此按钮** | 缺控件 | `AvailableDecaysPanel.ts` 70–75 | [有意差异] |
| Decay 键旁图 | `IconFactory` α叠球 / β 反应式 / 发射运动线 | 键上短符号 α/β-/β+/p/n | 图不是字 | `IconFactory.ts` | [有意差异] |
| Decay 键盒 | 145×35，橙，全名 RichText | 拉满列宽，高≤35，短符号 | 盒宽受 NineGrid | `AvailableDecaysPanel.ts` 34–36 | [有意差异] |
| 半衰期指针 | `ArrowNode` 长 30，tail 4，headW 12，fill `#FF00FF`，stroke null | 同；headH 用默认 10 | headH 未在 BAN 覆盖 | `HalfLifeNumberLineNode.ts` 147–151 | [源码一致] 长/尾/头宽；headH [待确认] 已用 10 |
| less/more 箭 | `ArrowNode` 长 30，headW 6，tail 1，**填黑** | 描边折线 + 开叉头 | 填箭头 vs 空心 V | `HalfLifeInformationNode.ts` 27–30 | [可修复] 盒内改 Path |
| 生成器单箭 | `ArrowButton` 三角 14×14，白底黑边 1，r=4，x/yMargin 7/5 | `Icons.arrow_drop_up/down`，无底无边 | Path 三角 ≠ drop glyph；缺 chrome | `NucleonCreatorsNode.ts` 50–55；`ArrowButton.ts` | [可修复] 盒内三角；chrome 可选 |
| 生成器双箭 | `DoubleArrowButton` **并排** 两三角，左质子色右中子色 | `Icons.keyboard_double_arrow_*` **叠**双尖，单色 `black87` | 形状/配色都不是 | `DoubleArrowButton.ts` 59–82 | [可修复] 盒内双三角；勿动 X/bottom/spacing |
| Chart Intro 双箭 | 原版 `NucleonCreatorsNode` **有**双箭 | **无**双箭列 | 缺控件 | `chart_intro_nucleon_controls.dart` 头注释 | [有意差异] |
| 生成器球 | `NucleonCreatorNode` = ParticleNode | 同径向 白→base −0.4r / 1.6r | 描边默认 1 | `_CreatorNode` | [源码一致] |
| 面板边 | `PANEL_OPTIONS` GRAY，corner 6，xMargin 10 | `Border.all` GRAY，r=6 | lineWidth 默认 1 | `BANConstants.ts` 120–125 | [源码一致] 色/圆角；宽 [待确认] =1 |
| Available Decays 边 | stroke GRAY，x/yMargin 15 | GRAY，pad 4–6 | 内边距压缩 | `AvailableDecaysPanel.ts` 176–180 | [有意差异] NineGrid |
| Electron Cloud 勾 | sun `Checkbox` + 字 20 + 云圆 r=字高×0.82 | Material Checkbox + 字 14 + 云 16×16 | 勾选框皮肤；字号属 Typography | `ShowElectronCloudCheckbox.ts` | [视觉近似：Material] 框；云半径已近 16 |
| Partial Radio **图标** | `CompleteNuclideChartIconNode` 格 3.5 的真核素图 | **文字**「Partial」 | 图标不是字符串 | `CompleteNuclideChartIconNode.ts`；`ChartIntroScreenView.ts` 231–240 | [有意差异] |
| Zoom Radio **图标** | `ZoomInNuclideChartIconNode` 格 7、裁 5×5、黑边 0.5 | **文字**「Zoom」 | 同上 | `ZoomInNuclideChartIconNode.ts` | [有意差异] |
| Radio fill | 全部 `baseColor` `#F1FAFE` | 同（P4-3） | 无 | `BANColors.ts` 122–124 | [源码一致] **不要改** |
| Radio 边 / 选中指示 | sun RectangularRadioButton | `black87` / `black26`，r=4 | 选中描边配方不同 | `_modeButton` | [视觉近似：Material] |
| Radio 间距 | 组 `orientation: horizontal`（sun 默认 gap） | `SizedBox(8)` | gap [待确认] | `_ChartModeRadio` | [待确认] |
| Radio 命中 | 整颗 RadioButton + 默认 dilation | InkWell = 视觉盒 | 无额外 dilation | — | [视觉近似：Material] |
| Full Chart 按钮 | `TextPushButton` 白底黑边 1，minW 80 maxW 160，字 12 | `OutlinedButton` 同色边，min 80×32，字 12 | 高 32 vs sun 内容+margin | `FullChartTextButton.ts` 73–87 | [视觉近似：Material]；高 [待确认] |
| Dialog Close | sun `CloseButton` `iconLength` **18.2**，透明底 | `Icons.close` 默认 **24** | 叉 Path 尺寸差 ~6 | `Dialog.ts` `closeButtonLength: 18.2` | [可修复] 只改 size |
| 方程箭 | `ArrowNode(0,0,25,0)` + `DECAY_ARROW_OPTIONS` | 长 25，尾 3，白填黑边 0.5；**头长写死 7** | 默认 headW/H = **10** | `DecayEquationNode.ts` 98；`ArrowNode.ts` | [可修复] 头 7→10 |
| 方程 + | `PlusNode` 9×2 黑 | 横 9×2 + 竖 2×9 | 同 | `IconFactory.ts` 96–97 | [源码一致] |
| Focused 框 | 黑，线宽 **1.5** | 同 | 无 | `FocusedNuclideChartNode.ts` 21 | [源码一致] |
| Zoom 裁剪框 | 黑 1.5（图） | 同 | 无 | painter clip stroke 1.5 | [源码一致] |
| 图例色块 | 14×14 + 格描边 `#8F8F8F`，spacing 5 | 同 | 无 | `NuclideChartLegendNode.ts` 23–44 | [源码一致] |
| 当前格八角 | Path 八角，底=格 fill | 同公式 | 无 | `NuclideChartNode.ts` 78–86 | [源码一致] |
| 格内衰变箭 | Partial/Zoom `ArrowNode` + `DECAY_ARROW_OPTIONS`（Focused 关） | **未画** | 缺小箭头 | `NuclideChartNode.ts` 69–74 | [可修复] 仅 Zoom/Partial |
| Energy 竖箭 | `ArrowNode` tailWidth 2，从生成器顶到周期表底 | **无** | 缺装饰 + 占位 | `ChartIntroScreenView.ts` 165–169 | [有意差异] 布局 chrome |
| Zoom 虚线 | `Line` dash `[6,3]` 黑，壳层→ mini-atom | **无** | 缺 | `ChartIntroScreenView.ts` 187–201 | [有意差异] |
| Magic checkbox | `Checkbox` boxWidth 15 | **无** | 缺功能 | `ChartIntroScreenView.ts` 244–248 | [有意差异] |
| 空核虚线圆 | GRAY，dash `[2,2]`，宽 1，r=particle−1 | 同 | 无 | `nucleus_painter.dart` 84–85 | [源码一致] |
| 轴箭头（图） | bamboo `AxisArrowNode` | 自画三角头 7×宽 6 | 头几何未对 AxisArrowNode | painter `_arrow` | [待确认] / 小 |
| Home Tab 图标 | joist ScreenIcon（核素图 / α 图） | `Icons.blur_circular` / `grid_on` | 工程 chrome | `build_a_nucleus_home.dart` | [有意差异] 不改 Home |

---

## 2. Decay 逐项

### 2.1 Reset

| 项 | PhET | Flutter |
|---|---|---|
| source | scenery-phet `ResetAllButton` → `ResetButton` → `ResetShape` | `build_a_nucleus_screen.dart` `Icons.restart_alt` |
| shape | 圆钮 + 弯箭头 Path（内 r×0.4 / 外 r×0.625） | Material refresh 字形 |
| size | `DEFAULT_BUTTON_RADIUS` **20.8**；margin = r×3/20.8 | IconButton 默认 ~48 触控，icon 24 |
| fill | 钮 `RESET_ALL_BUTTON_BASE_COLOR` 橙；箭 **白** | Theme 透明钮 + 默认前景 |
| border | RoundPushButton 描边；`adjustShapeForStroke` | 无 |
| rotation / anchor | 内容微偏（yContentOffset −0.0125 r） | 居中 |
| padding | x/yMargin = r × MARGIN_COEFFICIENT | IconButton 默认 |
| hit | touchAreaDilation **5.2** | Material 48 最小靶 |
| interactive | Y → `model.reset` | Y → `_reset` |
| Material 可替代？ | **否**。`Icons.restart_alt` ≠ `ResetShape` | — |

锚点：原版 `right/bottom = layout − 15`。Flutter 在 NineGrid `bottomRight`（P2 已冻）。  
**不要重写按钮体系。** 只有明确 radius / 橙底可局部画圆，仍算换控件，P5-2 需克制。

### 2.2 Undo

| 项 | PhET | Flutter |
|---|---|---|
| source | `ReturnButton` + `ReturnIcon` | Decay：`available_decays_panel.dart` `Icons.undo`；Chart：`chart_intro_decay_controls.dart` |
| shape | 回流折线+二次贝塞尔（高 17） | Material undo 弧 |
| size | icon h=17 × **scale 0.7** ≈ 11.9；钮 margin 5 | Decay 14–18；Chart 18 |
| fill | 钮 `PhetColorScheme.BUTTON_YELLOW`；icon 黑 | 无黄底 |
| border | RectangularPushButton 默认 | 无 |
| padding | x/yMargin 5 | 0 / compact |
| hit | 钮 bounds + sun dilation | 行高=衰变键高 或 IconButton 默认 |
| interactive | Y，衰变后 visible | Y，`canUndoDecay` 时插入 |
| Material 可替代？ | **否**（黄方 + ReturnIcon Path） | — |

Decay：原版 Undo **贴在刚点的衰变键旁**（`repositionUndoDecayButton`），不是第五键下面。Flutter 插在五键列底。位置属布局，本阶段不改。

### 2.3 Info

| 项 | PhET | Flutter |
|---|---|---|
| source | `InfoButton` + sun `infoCircleSolidShape` | `_InfoButton`：`Icons.info` |
| shape | 国际「i」实心圆 Path | Material outlined/round i |
| size | maxHeight **30**；iconScale **1.45** | 盒 30；glyph 22 |
| fill | 钮粉 `#FF99FF`（半衰期）；Available Decays **白** | 粉圆；第二颗不存在 |
| border | RoundPushButton | 无独立描边 |
| padding | 默认 x/yMargin 10，被 maxHeight 压到 30 | InkWell 铺满 30 |
| hit | touchAreaDilation 10（再被 maxH 限） | 30×30 |
| interactive | Y → Dialog | Y → Dialog |

盒 30 与粉底已齐。差别在 **glyph Path**。不要为了像而换整套 Theme。

### 2.4 Decay / 图例箭头

| 项 | PhET | Flutter |
|---|---|---|
| 面板内衰变图 | `createDecayArrowNode`：长 20，tail 1，headW 7.5，fill `#0000FF`，stroke null | **无** IconFactory |
| 半衰期指针 | 见总表 | CustomPaint，品红填 |
| less/more | 填黑 ArrowNode | 描边 V 字 |

指针参数已写入 `HalfLifeNumberLineMetrics`。less/more 头宽 6、长 30、间距 5 **数字齐**，差在 **fill vs stroke**。

### 2.5 Generator 单箭 / 双箭

BAN 覆盖（两屏共用 `NucleonCreatorsNode`）：

```
ARROW_BUTTON_OPTIONS: arrowWidth 14, arrowHeight 14, fireOnHold false, touchAreaYDilation 3
```

`ArrowButton` 默认（再被上面覆盖）：白底、黑边 1、corner 4、xMargin 7、yMargin 5、touch 7。

`DoubleArrowButton`：两枚三角 `HBox spacing 0`；朝下 `rotation = π` 并交换左右色。左 `#D14600` 右 `#737373`。

| 项 | PhET 单 | Flutter 单 | PhET 双 | Flutter 双 |
|---|---|---|---|---|
| shape | 等腰三角 Path | `arrow_drop_*` | 并排两三角 | 纵向双 chevron |
| fill | 核子色 | 核子色 | 左 p / 右 n | `black87` 单色 |
| button | 白 + 黑边 | 无 | 同 | 无 |
| glyph | 14×14 | `nucleonArrowGlyphSize` 14 | 各 14，并排 | Material 默认 ~24 压进 42×24 |
| V 间距 | 7 | 7 | 7 | 7 |
| hit | 钮 + Y dilation 3 | shrinkWrap 盒 | + dilation 7 | 同单 |

列宽公式（`ban_constants` 28 / 42 / 高 24）按 margin+glyph **估**，与 sun 实测可能差 1–2px。[待确认] 像素，但 **X / bottom / HBox 5 / minContentWidth 150 已冻，禁止动**。

Chart Intro：原版仍有双箭；Flutter 只有 p/n 两列。`minWidth 32` 且无 14 常量 → 比 Decay 列更宽。[有意差异] + 微几何未对齐。

### 2.6 核子视觉

ParticleNode 径向（P4 已确认）。生成器球、壳层球、计数点（描边 0.5 vs 1）见颜色审计。本阶段不重谈渐变。

### 2.7 面板 / 键边

- 通用 Panel：GRAY `#808080`，corner 6。Flutter `Border.all` 默认宽 1。  
- 衰变键：sun RectangularPushButton，无 BAN 自定义 lineWidth。Flutter `RoundedRectangleBorder` r=3，**无描边**。  
- Available Decays 外框：原版 yMargin 15；Flutter pad 4–6。[有意差异]

### 2.8 Dialog Close（半衰期）

sun `CloseButton` 叉长 **18.2**，透明扁钮，上/右 margin 10。  
Flutter `IconButton` + `Icons.close` 24。交互都是关 Dialog。  
Material 叉 ≈ 视觉近似；**size 24→18 属 [可修复]。**

---

## 3. Chart Intro 逐项

### 3.1 Partial / Zoom Radio

原版 **没有**「Partial」「Zoom」字。内容是缩微核素图：

| | Partial | Zoom |
|---|---|---|
| class | `CompleteNuclideChartIconNode` | `ZoomInNuclideChartIconNode` |
| 格边 | `getChartTransform(3.5)` → 约 3.5px | `getChartTransform(7)` → 约 7px |
| 范围 | p0–10 × n0–12 全图 | 裁在 He-4 附近 5×5 |
| 边 | 各格 `#8F8F8F` | 外框黑 **0.5** |
| 选中 | sun Radio（fill 仍 `#F1FAFE`） | 同 |

Flutter：文字 12、padding 10×6、圆角 4、间距 8。Fill 已对齐。  
**图标不是字符串 → 不能标 [源码一致]。** 画迷你图不是 1–5px 微几何，标 [有意差异]。P5-2 若只改边宽/padding 可以；不要为了对齐去改 fill。

### 3.2 Full Chart 按钮

白底、黑边 1、字 12、minWidth 80：数字对齐。  
高：Flutter 锁 32；sun 随字+margin。[待确认] 差是否 >5px。  
交互：Y → Dialog。PNG 不重处理。

### 3.3 Info / Close

Full Chart Dialog **没有**独立 Info 圆钮；说明是正文 RichText。  
Close：同 §2.8，`chart_intro_full_chart_close`。

### 3.4 Equation Arrow

| 项 | PhET | Flutter |
|---|---|---|
| length | **25** | 25（`CustomPaint` 宽） |
| fill | WHITE | WHITE |
| stroke | BLACK | BLACK |
| lineWidth | **0.5** | 0.5 |
| head | ArrowNode 默认 **headWidth 10, headHeight 10** | 头长 **7**，翼 ±4 |
| tail | **3** | 3 |
| position | HBox spacing 10，方程行 | 同 spacing 常量 |
| interactive | N | N |

逻辑（availableDecays[0]、Zoom-only）不在本审计改。  
头 10 vs 7 = **3px** → [可修复]。

Plus：9×2 黑，[源码一致]。

### 3.5 Focused / 小标记

- 窗外 opacity 0.65、fill 不变：P4 已确认，不改。  
- 高亮框 1.5 黑：[源码一致]。  
- 格标签字号 11 / 18 / 6：Typography 已冻。  
- 当前格八角：[源码一致]。  
- Partial/Zoom **格内衰变方向 ArrowNode**（Focused `arrowSymbol: false`）：Flutter 未画 → [可修复] 小 Path，勿改 focus 语义。

### 3.6 小控件 / 缺件

| 原版 | Flutter | Action |
|---|---|---|
| Energy 字 + 竖 `ArrowNode` tailWidth 2 | 无 | [有意差异] 会动布局 |
| 壳层→atom 虚线 `[6,3]` | 无 | [有意差异] |
| Magic Numbers checkbox | 无 | [有意差异] |
| 图例 14 盒 | 有 | [源码一致] |
| 周期表/符号盒边 1 / 2 | 有 | [源码一致] |

---

## 4. 分类汇总

### [可修复]（P5-2 候选，仍禁止动锚点 / NineGrid / Theme）

1. 方程箭头 head 7 → ArrowNode 默认 10（长仍 25）  
2. Dialog Close icon 24 → 约 18  
3. less/more stable：描边 V → 填黑 Arrow 形（盒仍 30×8）  
4. 生成器：盒内三角 Path 14×14；双箭改为 **并排两色**（可加白底黑边 r=4）。**不改** X / bottom / spacing 5 / 列宽常量  
5. Partial/Zoom 格内衰变小箭（DECAY_ARROW_OPTIONS）  
6. （可选）Info glyph 仍 Material，只微调 22 的 padding — 价值低  

### [视觉近似：Material]（不要整系重写）

Reset（含 Chart 的 TextButton）、Undo、Info Path、Checkbox、Radio 边、Full Chart `OutlinedButton`、Close 的 Material 叉形、生成器若继续用 `IconButton` 当壳。

### [有意差异]

IconFactory 衰变图、Available Decays Info、衰变键短符号、Radio **用字代替缩微图**、Chart Intro 无双箭、无 Energy 箭、无 zoom 虚线、无 Magic checkbox、Home Tab Material 图标。

### [待确认]

- `ResetAllButton` / `BUTTON_YELLOW` 精确 hex（P4 取样 Reset 中心约 `#F89626`，EDGE）  
- sun Panel / RectangularPushButton 默认 lineWidth  
- Radio 组默认 gap vs 8  
- Full Chart 按钮实测高度  
- `AxisArrowNode` 头 vs 自画 7  
- 指针 `headHeight`（已按 ArrowNode 默认 10 画）  
- `infoCircleSolidShape` 未缩放像素盒  
- Chart Intro 箭头列 32×28 vs Decay 28×24  

---

## 5. 禁止带进 P5-2

- 改 Theme / Material color scheme / 其他 sim  
- 改 NineGrid、CanvasProjection、nucleus / generator 锚点  
- 改 Typography、已确认颜色（含 Radio `#F1FAFE`、Focused 0.65）  
- 改 State / Controller / 方程数据逻辑 / Full Chart PNG  
- 为 Reset/Undo **重写** sun 按钮体系  
- 把 Radio 缩微图做成新布局或改 fill  

---

## 6. 停止

P5-1 只完成 Icon / Micro-Geometry **取证**。

**未改** 任何 Dart / 测试 / Theme。

等待 P5-2。
