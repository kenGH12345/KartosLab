# FINAL-VISUAL-P3-3

> Chart Intro Typography · 2026-08-31  
> 未改 Theme / 未打包字体 / 未改 Decay 几何 / 未改 NineGrid / 未进 P4

Family 全程：**[视觉近似：font family]**（平台默认 + YaHei fallback，不是 Arial）。

截图：`requirements/req-build-a-nucleus/visual-qa/chart-intro/`（C-12 · 1280×800）。

---

## 1. 修改的 Typography

| 组件 | 修前 | 修后 | 原版 | 依据 |
|---|---|---|---|---|
| Element name（测试壳） | 16，色 `0xFFE50000` | **20 regular**，`#FF0000` | `ElementNameText` REGULAR 20 | `ElementNameText.ts` |
| Element name（正式屏） | 20（未写 weight） | **20 regular** | 同上 | 只补 `fontWeight.normal` |
| Chart 当前格标签 Partial | 11 **w600** | **11 regular** | `cellTextFontSize: 11`，无 weight | `NuclideChartAndNumberLines.ts` |
| Chart 当前格标签 Zoom | 11 w600 | **18 regular** | `cellTextFontSize: 18` | `ZoomInNuclideChartNode.ts` |
| Chart 当前格标签 Focused | 11 w600 | **6 regular** | `cellTextFontSize: 6` | `FocusedNuclideChartNode.ts` |
| Full Chart dialog 标题 | 32 **w500** | **32 regular** | `TITLE_FONT` PhetFont(32) | `FullChartTextButton.ts` |

未改（源码已对齐或禁止动）：

- Symbol A / Z / 符号（150 / 70 × 0.15，2G-3）
- Periodic table 14 + 高亮 bold + 居中；25px / 0 gap
- 方程 parent / daughter / emitted / 箭头 / 标题 12 / Stable 20
- Full Chart **按钮** 12；Dialog 正文 19
- 轴刻度 / 轴标题 12；图例 12；Accordion 20；Counters 18；Decay 键 14
- Partial / Zoom **文案** 12（原版是图标按钮）
- Tab 标签（Home chrome）

---

## 2. 源码依据（摘要）

- `PhetFont(n)` 只设 size，weight 默认 **normal**
- Chart Intro **没有** `StabilityIndicatorText`
- 格标签三套独立 `cellTextFontSize`：Partial 11 / Zoom 18 / Focused 6
- Dialog 标题是 `TITLE_FONT` 32，**不是** w500

---

## 3. 修改前 / 后

正式屏元素名字号本来就是 20，bbox 不因本阶段变。

| | 修前 | 修后 |
|---|---|---|
| 测试壳元素名 | 16 | 20 regular |
| Zoom 当前格符号 | 11 w600（画在 30px 格内） | 18 regular |
| Focused 当前格符号 | 11 w600（画在 10px 格内） | 6 regular |
| Dialog 标题 | 32 w500 | 32 regular |

---

## 4. bbox 变化（C-12 · 逻辑 px · 1280×800 · DPR 1）

NineGrid 边格 `FittedBox.scaleDown` 后的 **屏幕外包**（不是源码 fontSize）：

| 控件 | Partial | Zoom | 备注 |
|---|---|---|---|
| Element | 104.5×**13.6** cx=52.3 | 同 | 源码 20；topLeft 缩到 ~14 高 |
| Counters（质子行） | 42.8×12.2 | 同 | 源码 18 |
| Periodic table 整块 | 104.5×41.9 | 同 | 25px cell 几何未改 |
| Symbol 盒 | 12.1×14.3 | 同 | 150/70 ×0.15 未改 |
| Chart 整块 | 104.5×118.8 | 104.5×114.1 | 格边长未改；Zoom 换内容 |
| Accordion 标题 | 99.8×**6.8** | 同 | 源码 20；midRight 强缩 |
| Equation（Stable） | — | 63.3×12.2 | Zoom-only；源码 20 |
| Full Chart 按钮 | 39.4×11.3 | 同 | 源码 12 |
| Dialog 标题 | — | **728×46** | 源码 32 regular；不经 NineGrid |
| Dialog 正文 | — | 600×189 | 源码 19 |

格标签在 Canvas 上，**没有独立 Widget bbox**。Zoom 当前格字号 11→18、Focused 11→6，不改变 CustomPaint 声明尺寸。

正式屏元素名本阶段只补 `fontWeight.normal`，字号仍 20 → **Element bbox 相对 P3-2 后的 Chart Intro 无 Δ**。

---

## 5. FittedBox 影响

- 正式屏：`topLeft` / `topRight` / `midRight` / footer 仍 `BoxFit.scaleDown`
- 格标签字号改在 Painter 内，**不改变** CustomPaint 声明尺寸 → midRight FittedBox 缩放比不因 11→18 而变
- 未偷改 fontSize 去补偿 FittedBox
- 测试壳元素名无 FittedBox，16→20 会如实变高

**[视觉近似：NineGrid constraint]**：矮/窄视口下 topLeft / midRight 仍可能整体缩小；源码 fontSize 保持 20 / 11 / 18 / 6。

---

## 6. [视觉近似]

- **[视觉近似：font family]** 全部未指定 Arial
- **[视觉近似：NineGrid constraint]** 边格 FittedBox 可能缩小整块，不改源码字号

---

## 7. [有意差异]

- Partial / Zoom：原版 **图标按钮**，Flutter 保留文案「Partial」「Zoom」+ 12
- Tab：「衰变」/ `Chart Intro` 是 Home chrome，不改全局 Theme
- Nuclear Shell Model / Energy：Flutter **没有这些控件**，不为 Typography 新建
- Chart Intro **无** Stability 行
- Full Chart 正文是纯文本 URL，不是 RichText 超链接（行为未改）
- 方程 A/Z 列源码有效高 15+2.25+15=32.25，Flutter 把 `minContentHeight: 30` 写成了固定 `SizedBox(height: 30)`。衰变核会溢出 2.3px。**本阶段不改方程几何**；采图用稳定 C-12。**[有意差异：equation minHeight]**

---

## 8. 测试结果

- `flutter analyze lib/chemistry/build_a_nucleus test/chemistry/build_a_nucleus`：**No issues found**
- BAN：**407/407**
- 640×360 / 1024×768 / 1280×800：空核 Partial / Zoom 无 overflow；Full Chart / Reset 仍在
- 未因字号放大导致按钮消失

停在 P3-3。未进 P4 / Colors / Decay 几何。
