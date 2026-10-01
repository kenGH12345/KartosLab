# FONTS / Typography Source Audit（P3-1）

> 只调查，不改 UI。2026-08-31  
> 原版：`d:\OneDrive\Desktop\phet sourses\build-a-nucleus-main\`  
> Flutter：KartosLab `lib/chemistry/build_a_nucleus/` + 全局 `lib/main.dart` / `pubspec.yaml`

**先区分再谈字号**：截图上文字块更高，不一定是 `fontSize` 偏小。还可能是 **family 字形度量**、**baseline**、**line-height / `TextStyle.height`**、**容器 padding / FittedBox**。本阶段不因截图高度直接加大字号。

---

## 1. 原版字体来源

### 1.1 `PhetFont` [已确认]

`scenery-phet/js/PhetFont.ts`（BAN 仓库不包含该文件，以官方 main 为准）：

- 默认 `family = sceneryPhetQueryParameters.fontFamily`
- 查询参数默认值：**`Arial`**
- 再拼接 fallback：`Arial, sans-serif`
- 数字参数 `new PhetFont(20)` **只设 size**，不设 weight / letter-spacing

### 1.2 scenery `Font` 默认 [已确认]

`scenery/js/util/Font.ts`：

| 属性 | 默认 |
|---|---|
| style | `normal` |
| weight | **`normal`（400）** |
| stretch | `normal` |
| size | `10px`（PhetFont 覆盖为传入 px） |
| lineHeight | **`normal`**（CSS；Canvas 实际强制 normal） |
| family | `sans-serif`（PhetFont 覆盖为 Arial） |
| letter-spacing | **无此字段** |

BAN 内所有 `new PhetFont(n)` **都没有** `weight: 'bold'`、**没有** letter-spacing。

### 1.3 字体文件 [已确认]

- BAN 工程、本地 `phet sourses` **没有** `.ttf` / `.otf` / `.woff`
- PhET **不随 sim 打包 Arial**；依赖操作系统 / 浏览器已装字体
- 未使用 `MathSymbolFont`（Times New Roman）；BAN 正文不是衬线公式字体

### 1.4 上标 [已确认]

| 机制 | 参数 |
|---|---|
| 数轴刻度 `RichText` `10<sup>n</sup>` | `supScale: 0.6`，`supYOffset: -1` |
| `ScientificNotationNode` 指数 | 默认 `exponentScale: 0.75`，`exponentXSpacing: 2`，`exponentYOffset: 0`，`capHeightScale: 0.75`；本体字体随调用方（Decay 读数为 `PhetFont(24)`） |
| 衰变按钮文案 | `β<sup>-</sup> decay` / `β<sup>+</sup> decay`（`RichText` + `PhetFont(18)`） |

### 1.5 使用 `PhetFont` 的 BAN 组件 [已确认]

`BANConstants`：`REGULAR_FONT` 20、`LEGEND_FONT` 12、`TITLE_FONT` 32、`INFO_DIALOG_TEXT_OPTIONS` 19、`BUTTONS_AND_LEGEND_FONT_SIZE` 18。

其余见 §3 矩阵。核素图格子 `NuclideChartNode` 只用 `fontSize`、**未传 `PhetFont`** → scenery 默认 family **`sans-serif`**（Windows 上常映射到 Arial，但是 **[待确认]**）。

---

## 2. Flutter 字体来源

### 2.1 工程 [已确认]

| 项 | 现状 |
|---|---|
| `pubspec.yaml` `fonts:` | **注释掉，未注册任何自定义字体** |
| `assets/fonts` | **不存在** |
| `google_fonts` | **未依赖** |
| `uses-material-design` | true（Material Icons，不是正文字体包） |
| `ThemeData.fontFamily` | **未设** |
| `fontFamilyFallback` | `Microsoft YaHei`, `PingFang SC`, `Noto Sans CJK SC`, `Arial`（`lib/main.dart`） |
| BAN / 其他 sim | **没有** `PhetFont` 等价物；BAN 各处裸 `TextStyle(fontSize: …)` |

### 2.2 当前实际渲染字体 [已确认逻辑 / 待确认像素]

- 未指定 `fontFamily` 时，Flutter 用平台默认（Windows 常见 **Segoe UI**；Android **Roboto**）。
- 全局 fallback **第一项是微软雅黑**。雅黑含拉丁字形 → 在 Windows 上，**英文也很可能走 YaHei，而不是排在最后的 Arial**。
- 局部 `fontFamily: 'monospace'`：半衰期 info dialog 公式、`color_vision`、`time_control_bar` 等，**与 BAN 正文无关**。

### 2.3 原字体能否接入

| 路径 | 合法 / 技术 | 影响 |
|---|---|---|
| **不打包**，BAN 内 `TextStyle(fontFamily: 'Arial')` + fallback `sans-serif` | 技术可行。Arial 为系统字体时可用；Linux 可能没有 | **sim-local 则不影响其他 sim** |
| 把 `ThemeData.fontFamily = 'Arial'` | 同样不打包文件 | **[工程风险]** 光学 / 电路 / 声音 / 色觉等全部变 |
| **打包 Arial.ttf** | **不宜**：专有字体，无授权不能随应用分发 | — |
| 开源度量近似字体（Liberation Sans / Arimo）并打进 BAN assets | 合法，需加 `pubspec` fonts，**只给 BAN 用 family 名** | 不影响其他 sim；度量仍非 100% Arial |

**建议（本阶段只记录，不实施）**：Typography 用 **BAN 本地 TextStyle / 小 helper**，不要改全局 Theme。

---

## 3. 组件 Typography 矩阵

Weight 原版未写时 = `normal`。Flutter 未写 `fontWeight` = `w400`。Family 原版 = Arial（PhetFont）；Flutter = 平台默认 + YaHei 优先 fallback。

| Component | PhET Font | Size | Weight | Flutter Current | Difference |
|---|---|---:|---|---|---|
| **Element name** | `REGULAR_FONT` = `PhetFont(20)` | 20 | normal | 16 **bold** 红 | 字号 −4；**多了 bold**；family 不同 |
| **Stability** | `REGULAR_FONT` | 20 | normal | 13 regular 黑 | 字号 −7 |
| **Proton / Neutron count** | `PhetFont(18)`（`BUTTONS_AND_LEGEND`） | 18 | normal | 12；中文「质子/中子」+ `FittedBox` | 字号 −6；文案语言不同；边格再缩放 |
| **Decay title** | `PhetFont(24)` | 24 | normal | 20 **w600**，`FittedBox` 压进 ~18 高带 | 字号 −4；半粗；窄栏再缩小 |
| **Decay buttons** | `PhetFont(18)` + RichText 全名（`α decay` / `β<sup>-</sup> decay`…） | 18 | normal | 短符号 α/β-/β+/p/n，字号 `buttonH×0.55`（1280 约 **19**）**w700** | **文案模型不同**（NineGrid）；多了 bold |
| **Half-Life label** | `TITLE_FONT` = `PhetFont(24)`（`Half-life:`） | 24 | normal | 24，`height: 1` | 字号对齐；family / height 不同 |
| **Half-Life value** | 同上 24 + `ScientificNotationNode` 指数 **0.75** | 24 / 18 | normal | 24 / `24×0.75`，`height: 1` | 字号与指数比例对齐；family / baseline **[待确认]** |
| **Half-Life 轴刻度** | `PhetFont(15)` + `supScale 0.6` | 15 / 9 | normal | 15 / `15×0.6`，`height: 1` | 字号与上标比例对齐 |
| **less / more stable** | `PhetFont(14)` | 14 | normal | 14 | 字号对齐 |
| **Symbol box 标题** | Accordion `REGULAR_FONT` 20 | 20 | normal | 「Symbol」**11** | 字号 −9 |
| **Symbol 元素符号** | `PhetFont(150)` × Decay `scale: 0.3` → **有效 45** | 45 | normal | **28 w600**，盒 72×84（原盒 275×325×0.3） | 有效字号 −17；多了 w600 |
| **Symbol A / Z** | `PhetFont(70)` × 0.3 → **有效 21** | 21 | normal | **12** | 有效字号 −9 |
| **Chart 格标签** | scenery `fontSize: 11`（Partial）；family **未设 PhetFont** | 11 | normal | 11 w600 | 字号对齐；Flutter **偏粗**；family 可能都是 sans |
| **Chart 轴标签** | `fontSize: 12` | 12 | normal | 12 | 字号对齐 |
| **图例 / Most likely decay** | `LEGEND_FONT` 12 | 12 | normal | 12 | 字号对齐 |
| **手风琴标题** | `REGULAR_FONT` 20 | 20 | normal | 20 | 字号对齐 |
| **Periodic table 符号** | `PhetFont(14×length/25)` → 14；高亮 shred 加粗 | 14 | normal / bold 高亮 | 14，高亮 bold | 字号/粗细对齐 |
| **Equation 核素符号** | `PhetFont(150)` × 0.15 → **22.5** | 22.5 | normal | 22.5 | 字号对齐 |
| **Equation A/Z** | `PhetFont(100)` × 0.15 → **15** | 15 | normal | 15 | 字号对齐 |
| **Equation Stable / 说明** | 稳定行 20；旁注 `LEGEND` 12 | 20 / 12 | normal | 20 / 12 | 字号对齐 |
| **Full Chart 按钮** | 标题 `TITLE_FONT` 32；说明 `LEGEND` 12 | 32 / 12 | normal | 按钮 14（`chart_intro_decay_controls`） | **按钮字号偏小** |
| **Full Chart dialog** | 标题 32；正文 `PhetFont(19)` | 32 / 19 | normal | 32 **w500** / 19 | 标题多了 w500 |
| **Generator 标签** | `PhetFont(20)` “Protons/Neutrons” | 20 | normal | **12**「质子/中子」 | 字号 −8；语言不同 |
| Electron Cloud（对照，本阶段不修） | `REGULAR_FONT` 20 | 20 | normal | 14 | 字号 −7 |
| Info dialog 标题 | `TITLE_FONT` 32 | 32 | normal | 32 w500 | 多了 w500 |

---

## 4. 当前差异（按原因，不是「先加大号」）

1. **Family**：原版 Arial；Flutter 平台默认 + **YaHei 抢拉丁**。同等 `fontSize` 的 **em 方、字怀、基线**仍会不同。
2. **`TextStyle.height`**：Flutter 默认约 **1.2×fontSize** 行盒；原版 Canvas/`lineHeight: normal`。半衰期读数已设 `height: 1`，Element / Stability / 计数 **未设**。
3. **Weight 误加**：Element bold、Decay title w600、Decay 符号 w700、Symbol 符号 w600、Chart 格 w600 —— 原版这些是 **normal**。
4. **字号未跟源码**：Element 16、Stability 13、计数 12、Decay 标题 20、Symbol 标题/符号/数字、Generator 12。
5. **有效字号 vs 盒缩放**：Symbol / 方程用「未缩放 PhetFont × scale」。Flutter Symbol 没有按 150×0.3，而是另选 28/12。
6. **Decay 按钮**：原版是 **18px 全名 + 上标**；Flutter 是短符号（P2-4 NineGrid）。不是单纯字号问题。
7. **padding / FittedBox**：计数、Decay 标题、Symbol 整盒 `FittedBox` 会再缩小，**改 fontSize 不等于屏幕上的 px**。

---

## 5. 可修复性

### [可精确修复]

源码数字清楚，且只改 BAN 本地 `TextStyle`（family 仍可先不动）：

- Element / Stability → **20 regular**（去掉 Element 的 bold）
- 计数 → **18**（边格仍可能 `scaleDown`，那是布局不是字号源）
- Decay 标题 → **24 regular**（去掉 w600；窄栏 FittedBox 仍会缩）
- Generator 标签 → **20**
- Symbol 标题 → **20**；符号/数字按 **150×0.3 / 70×0.3** 或等价
- Decay 按钮 weight → **normal**（若仍用短符号，字号可维持 ~18–19）
- Chart 格标签去掉无来源的 **w600**
- Full Chart 按钮字号、dialog 标题 weight
- 给上述控件补 `height: 1`（对齐 Canvas，避免「看起来矮就加大号」）

系统 Arial（不打包）作为 BAN `fontFamily`：**技术可做**，属 family 层，建议 P3-2 与字号分开验证。

### [视觉近似]

- 只改 size/weight、**不改 family**：字形仍不是 Arial。
- 改 `fontFamily: 'Arial'` 但无 TTF：有 Arial 的机器接近；无则 sans-serif。
- 上标：数轴 0.6 / 科学计数 0.75 已按源码；**baseline / capHeight 像素**仍可能差 1–2px。
- Decay 按钮全名 + RichText 上标：边格宽度不够，保持短符号 = **[有意差异：NineGrid]**，不是 Typography 能单独修齐的。

### [工程风险]

- 改 **`ThemeData.fontFamily` / 全局 fallback 顺序**：所有 sim 受影响。
- **打包 Arial**：版权。
- 把字体注册成应用默认 family 名且被 common 控件继承。

### [待确认]

- Windows 上当前英文到底是 YaHei 还是 Segoe UI（需实际 `TextPainter` / 截图像素，本阶段未测）。
- 核素图 `fontSize`-only 在浏览器里 `sans-serif` 是否等于 Arial。
- Arial 与 Flutter `TextPainter` 的 alphabetic baseline 相对 scenery Canvas 的 px 差。
- `ScientificNotationNode` 的 `capHeightScale` 在 Flutter 未复刻时的指数垂直位置。
- 截图外包高度里，多少来自 Accordion / Panel padding 而不是 glyph。

---

## 6. 不宜修改项（P3-2 也应对齐此表）

- 全局 Theme / 其他 sim 的 `TextStyle`
- 打包专有 Arial
- **仅因截图文字块偏高/偏低就加大 `fontSize`**（先对齐 family、weight、`height`、padding）
- 为「看起来一样大」而改 NineGrid、Symbol 盒外接矩形、Decay 按钮文案模型
- Electron Cloud / Reset（用户划在 Typography 主线外）
- 半衰期 **24 / 15 / 0.6 / 0.75** 已对齐的数字不要再凭截图改

---

## 7. 标记汇总

### [已确认]

- PhetFont = **Arial + sans-serif**；默认 **normal / lineHeight normal**；无 letter-spacing
- BAN **不带字体文件**；KartosLab **未注册字体**
- `REGULAR 20` / `LEGEND 12` / `TITLE 32` / 按钮图例 **18** / 数轴刻度 **15** / 读数 **24** / 上标 **0.6** / 科学计数指数 **0.75**
- Element 与 Stability **同一 REGULAR 20**；Element **红、非 bold**
- Decay 按钮源码是 **18px 全名 RichText**，不是单独 α
- Symbol：150 / 70，Decay **×0.3**
- 全局 `fontFamilyFallback` 把 **YaHei 放在 Arial 前**
- 不存在可复用的 Flutter `PhetFont` 类

### [视觉近似]

- 同等 size 下 Arial vs 平台/YaHei 的 glyph 与行盒
- 上标垂直位置（scale 有、cap/baseline 未逐像素对齐）
- Decay 短符号代替全名（NineGrid）

### [待确认]

- 当前 Windows 实际 family 光栅
- 核素图 sans-serif 映射
- TextPainter vs scenery 基线差（px）
- 截图高度中 padding 占比

---

## 8. 停止

P3-1 只完成取证与矩阵。未改代码，未进入 P3-2。

---

## 9. P3-3 Chart Intro Typography 矩阵（2026-08-31）

Family 全程保持平台默认，不打包 Arial。**[视觉近似：font family]**

| Component | PhET size | PhET weight | Flutter size | Flutter weight | FittedBox | 差异 |
|---|---:|---|---:|---|---|---|
| Element name（正式屏） | 20 | regular | **20** | **regular** | topLeft `scaleDown` | 字号已对齐；family 近似 |
| Element name（测试壳） | 20 | regular | 16→**20** | regular | 无 | 已修 |
| Stability | — | — | — | — | — | Chart Intro **无** StabilityIndicatorText；不造 |
| isotope A | 70×0.15=10.5 | regular | 70×0.15 | regular | 无（Painter scale 0.15） | 2G-3 已确认；本阶段未改 |
| isotope Z | 70×0.15=10.5 | regular | 70×0.15 | regular | 无 | 同上；Z 色 `#D14600` |
| isotope symbol | 150×0.15=22.5 | regular | 150×0.15 | regular | 无 | 2G-3 已确认；本阶段未改 |
| periodic table symbol | 14 | regular / **bold 高亮** | 14 | regular / bold 高亮 | topRight `scaleDown` | 已对齐；25px cell / 0 gap 未动 |
| chart axis labels | 12 | regular | 12 | regular | midRight `scaleDown` | 已对齐 |
| chart labels Partial | 11 | regular | 11 | 11 **w600**→**regular** | midRight `scaleDown` | 去掉无来源 w600 |
| chart labels Zoom | **18** | regular | 11→**18** | w600→**regular** | midRight `scaleDown` | 已修 |
| chart labels Focused | **6** | regular | 11→**6** | w600→**regular** | midRight `scaleDown` | 已修 |
| Partial / Zoom 控件 | 图标按钮 | — | 文案 12 | regular | 无 | **[有意差异]** 原版无字号 |
| Focused | 格标 6 | regular | **6** | regular | 随 Zoom 列 | 已修 |
| Decay equation title | LEGEND 12 | regular | 12 | regular | midRight `scaleDown` | 已对齐 |
| parent / daughter / emitted | 150/100×0.15 | regular | 22.5 / 15 | regular | midRight `scaleDown` | 已对齐 |
| Stable / Unknown | 20 | regular | 20 | regular | midRight `scaleDown` | 已对齐 |
| Full Chart button | LEGEND 12 | regular | 12 | regular | 无 | 已对齐 |
| Full Chart dialog title | TITLE 32 | regular | 32 | w500→**regular** | 无 | 已修 |
| Full Chart dialog body | 19 | regular | 19 | regular | Dialog 可滚 | 已对齐 |
| tab labels | joist Screen | — | 「衰变」/ Chart Intro | Theme | Home chrome | **不改** 全局 Tab |
| Accordion title | REGULAR 20 | regular | 20 | regular | midRight `scaleDown` | 已对齐 |
| Counters（Chart Intro） | 18 | regular | 18 | regular | topLeft `scaleDown` | 已对齐 |
| Decay 按钮 | 14 | regular | 14 | regular | 无 | 已对齐 |
| Nuclear Shell Model / Energy | REGULAR 20 | regular | — | — | — | Flutter **无此控件**；不为 Typography 新建 |

### P3-3 源码依据

- `ElementNameText`：`BANConstants.REGULAR_FONT` = `PhetFont(20)` regular，`fill: Color.RED`
- `NuclideChartAndNumberLines`：`cellTextFontSize: 11`
- `ZoomInNuclideChartNode`：`cellTextFontSize: 18`
- `FocusedNuclideChartNode`：`cellTextFontSize: 6`
- `NuclideChartNode` label：`fontSize` only，**未设 weight**
- `NucleonNumberLine` 刻度 / 轴标题：`fontSize: 12`
- `PeriodicTableCell`：`PhetFont(14)`；高亮 shred **bold**；居中
- `SymbolNode`：`PhetFont(150)` / `PhetFont(70)` × `scale: 0.15`（2G-3，不重查 Repository）
- `DecaySymbolNode`：`PhetFont(150)` / `PhetFont(100)` × `0.15`
- `DecayEquationNode`：标题/百分数 `LEGEND_FONT` 12；Stable/Unknown `fontSize: 20`
- `FullChartTextButton`：按钮 `LEGEND_FONT` 12；Dialog 标题 `TITLE_FONT` 32 regular；正文 `PhetFont(19)`
- `NuclideChartAccordionBox`：标题 `REGULAR_FONT` 20；Decay 按钮 `fontSize: 14`

### P3-3 未改

- 全局 Theme / 打包 Arial / 其他 sim
- PeriodicTable 25px cell / 0 gap / 90 cells / highlight 几何
- 方程 logic / `availableDecays[0]` / Zoom-only visibility
- Full Chart PNG / dialog 行为 / chart state
- NineGrid / Decay Screen / Colors / Icons / Generator / Reset / Electron Cloud
