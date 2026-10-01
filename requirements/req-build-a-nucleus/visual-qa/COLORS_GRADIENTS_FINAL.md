# COLORS / Gradients Final（P4-3 · Chart Intro）

> Chart Intro 已确认 Color / Gradient · 2026-08-31  
> 只改本屏 play 底 + Radio 未选 fill。未改 Decay / Theme / Typography / NineGrid / zoom·focus 语义 / Equation logic / Full Chart 行为与 PNG / Home / Tab。  
> 未进入 P5。

截图：`chart-intro/flutter_chart_intro_c12_{partial,zoom,dialog}.png`（1280×800 @ DPR 1）  
取样：`p4_3_screenshot_samples.json`（5×5 中位；`var>400` = 抗锯齿/缩边，不当 base）

Chart Intro **没有 Fe-69**（上限 10 proton）。本阶段只用 C-12。  
仓库 **无** 原版 Chart Intro 截图，**不能**算与原版的 mean |ΔRGB|。

---

## 0. 对照矩阵（改码前结论 → 本阶段处置）

| Component | PhET source | Flutter current（改前） | Target | 类型 |
|---|---|---|---|---|
| play / screen 底 | `ChartIntroScreen.backgroundColorProperty` = `BANColors.screenBackground` WHITE | Theme Scaffold `#FEF7FF` | BAN local `#FFFFFF` | **已修** |
| AppBar / Tab chrome | joist 底栏 | Theme `#FEF7FF` / Home `#B45309` | 不改 Theme | [有意差异] |
| 核子球 | `ParticleNode` 白→base，中心 −0.4r，半径 1.6r，描边=base | `NucleonBall` 同配方 | 同 | [源码一致] **resolved** |
| 核子 base | proton `#D14600` / neutron `#737373` | 同 | 同 | [源码一致] **resolved** |
| 电子云 | `#0000FF` 径向 stop 0 α=1 / 0.9 α=0 | 同；原先叠在 lilac 上 | 同配方，叠在白底 | [源码一致] 配方 **resolved** |
| 能级线 | `Color.interpolateRGBA(black, p\|n, occupancy)` | `Color.lerp(black, p\|n, t)` | 同 | [源码一致] **resolved** |
| 能级空 / 满宽 | 空黑；满层宽 4 / 默认 1 | 同 | 同 | [源码一致] **resolved** |
| 壳层 fade | Node.opacity 0↔1 | `saveLayer` 白×opacity | 不改合成路径 | [视觉近似] |
| 图格 fill | stable / α / β± / p / n / unknown | `ChartIntroVisuals` 同 hex | 同 | [源码一致] **resolved** |
| 当前格 | 八角标签底 = 格 fill，不换格 fill | `_paintCurrentLabel` 同 | 同 | [源码一致] **resolved** |
| Focused 窗外 | 整 Node opacity **0.65**；fill 不变 | `focusedDimOpacity=0.65`；fill 不变 | 同 | [源码一致] **resolved** |
| Focused 框 | BLACK，线宽 1.5 | 同 | 同 | [源码一致] **resolved** |
| 图格描边 | `#8F8F8F` | `cellBorder` | 同 | [源码一致] **resolved** |
| Magic 描边 | checkbox + `#FBFF24` | 常量有，Painter / UI 未接 | 不加 checkbox | [有意差异] |
| Accordion 底 | WHITE | `chartAccordionFill` | 同 | [源码一致] **resolved** |
| Radio **全部** | `baseColor` `#F1FAFE` | 选中 `#F1FAFE`，未选 **`#E8EEF2` 自造** | 未选也 `#F1FAFE` | **已修** |
| Radio 边 | sun RectangularRadioButton | `black87` / `black26` | 不换 Material 边 | [视觉近似：Material] |
| 周期表 disabled | Chart Intro 覆盖为 **不透明白** | `#FFFFFF` | 同；Z>10 格仍在 | [源码一致] **resolved** |
| 周期表高亮 | 黑底白字，描边宽 1 | 同 | 同 | [源码一致] **resolved** |
| 周期表面板 | `#F1FAFE` + GRAY | 同 | 同 | [源码一致] **resolved** |
| 同位素符号 Z | shred positive `#D14600` | `isotopeProtonNumber` | 同；A/Z 几何不改 | [源码一致] **resolved** |
| 符号盒 | 白填 / 黑边 2 | 同 | 同 | [源码一致] **resolved** |
| 方程箭头 | 白填 / 黑描边 0.5 | 同 | 同 | [源码一致] **resolved** |
| 方程 Z | `#FF5500` | 同 | 同 | [源码一致] **resolved** |
| 方程 parent / daughter / % / 标题 | 黑 | 同 | 同；logic 不改 | [源码一致] **resolved** |
| Chart Decay 键启用 | `#FBB240` | 同 | 同 | [源码一致] **resolved** |
| Chart Decay 键 disabled | sun 灰化 | α=0.4 | — | **[待确认]** 不修 |
| Full Chart 按钮 | 白底黑边 | 同 | 同 | [源码一致] **resolved** |
| Full Chart Dialog 底 | `INFO_DIALOG_OPTIONS` 无 fill → 可能白 | `#FFFEF4` | — | **[待确认]** 不修 |
| Full Chart PNG | 静态图 | 同 asset | 不重处理 | **resolved** |
| Reset / Undo | scenery-phet | Material `TextButton` / 图标 | 不换组件 | [视觉近似：Material] |
| LinearGradient | 正文无 | 无 | — | [源码一致] **resolved** |

---

## 1. 修改项

只两处，均 BAN / Chart Intro 本地，不改 Theme、不改 Decay：

1. **play 底 WHITE**  
   - `ChartIntroVisuals.screenBackground` → `BanConstants.screenBackgroundValue`（`0xFFFFFFFF`，P4-2 已有常量）  
   - `ChartIntroScreen`：embedded 用 `ColoredBox` 铺白；独立 Scaffold `backgroundColor` 白  
2. **Radio 未选 fill**  
   - `nuclide_chart_view.dart` `_modeButton`：去掉自造 `0xFFE8EEF2`  
   - 选中 / 未选都用 `ChartIntroVisuals.chartRadioBackground`（`#F1FAFE`）

未改：`NucleonBall`、能级 lerp、图 fill、Focused opacity、周期表、符号几何、方程、Full Chart Dialog / PNG、Decay 屏。

---

## 2. 源码证据

### play 底

`ChartIntroScreen.ts`：

```
backgroundColorProperty: BANColors.screenBackgroundColorProperty
```

`BANColors.ts`：

```
screenBackgroundColorProperty … default: Color.WHITE
```

### Radio

`ChartIntroScreenView.ts`：

```
radioButtonOptions: { baseColor: BANColors.chartRadioButtonsBackgroundColorProperty }
```

该 `baseColor` 作用在 **组内每一个** RectangularRadioButton，没有第二套「未选色」。

`BANColors.ts`：

```
chartRadioButtonsBackgroundColorProperty … default: new Color(241, 250, 254)  // #F1FAFE
```

### 核子 / 能级（确认相同，未复用 Decay 公式当猜测）

- 球：shred `ParticleNode.updateFill` — 径向中心 `(-0.4r,-0.4r)`、半径 `1.6r`、stop 0 WHITE、stop 1 base、stroke=base。Chart Intro 与 Decay 共用 ParticleNode，故配方相同。  
- 线：`NucleonShellView.ts` `Color.interpolateRGBA(black, proton|neutron, occupancy/capacity)`。

### Focused

`makeOpaque`：`Δp>2 || Δn>2` → 整格 Node opacity **0.65**；fill 仍是 `cellModel.colorProperty`。

### 当前格

八角是 **标签底**，颜色 = 当前格 fill，不是换掉格子本身的 fill。

### 周期表

Chart Intro 覆盖 shred 默认灰：`disabledPeriodicTableCellColorProperty` = WHITE。Z>10 的 cell 仍在表上。

---

## 3. 修改前

| | Flutter 原值 |
|---|---|
| Chart Intro play | Theme surface `#FEF7FF`（embedded 无 ColoredBox） |
| Radio 选中 | `#F1FAFE` |
| Radio 未选 | `#E8EEF2`（无 PhET Property） |
| AppBar | `#FEF7FF`（Theme，未动） |

---

## 4. 修改后

| | Flutter 新值 | 取样 |
|---|---|---|
| Chart Intro play | `#FFFFFF` | C-12 left / mid / below-appbar，`#FFFFFF` var=0 |
| Radio 选中 | `#F1FAFE` | Zoom 帧选中 `#F1FAFE` |
| Radio 未选 | `#F1FAFE` | Zoom 帧未选 Partial `#F1FAFE` |
| AppBar | `#FEF7FF` | 独立屏取样 var=0；**不改 Theme** |

Partial 帧 Radio 点落在 16–25px 缩边（`#74777C` / `#58595E`，var>20000）→ **EDGE**，不当 fill。

---

## 5. Gradient 参数（确认，未改）

禁止用截图单像素反推。下列来自 ParticleNode / ELECTRON_CLOUD / NucleonShellView。

| 项 | type | center | radius | stops | opacity |
|---|---|---|---|---|---|
| 核子球 | Radial | 球心 + (−0.4r, −0.4r) | 1.6r | 0 WHITE → 1 proton `#D14600` / neutron `#737373` | 1；fade 时整粒 ×opacity |
| 核子描边 | 无渐变 | — | — | base，宽 1 | 同球 |
| 电子云（mini-atom） | Radial | 核中心 | 云半径 | 0 `#0000FF` α=1 → 0.9 `#0000FF` α=0 | 叠在 **白** play 上 |
| 能级线 | 无渐变 | — | — | `lerp(black, p\|n, occupancy)` | 1 |
| 图格 / Focused | 无渐变 | — | — | 不透明 fill；窗外整格 ×0.65 | fill 色不变 |
| 面板 / Radio / 符号盒 | 无 LinearGradient | — | — | 实色 | 1 |

计数点球：同 ParticleNode 径向；描边宽 0.5 → [视觉近似]（P4-1 已记，不改）。

---

## 6. Screenshot sampling（C-12 · 1280×800 DPR1）

方法：5×5 中位。`var>400` 标 EDGE。只认大面积、低方差点。

| 区域 | hex | 类型 |
|---|---|---|
| play 左 / 中 / AppBar 下 | `#FFFFFF` | **base region** |
| 独立屏 AppBar | `#FEF7FF` | Theme chrome，未动 |
| 元素名 | `#FF0000` | **精确** |
| Radio（Zoom 帧，选中+未选） | `#F1FAFE` | **base fill**（中位命中源码色；周围 var 高因按钮极小） |
| Radio（Partial 帧） | `#74777C` / `#58595E` | **EDGE** 缩边/字，不当 fill |
| Accordion / 周期表区 | `#A2DAE4` / `#A5A6A7` | **EDGE** NineGrid 缩到 ~104×42，不采格 fill |
| Reset `TextButton` | `#6750A4` | Material 主色 → [视觉近似：Material] |
| Dialog 打开后 play | `#FFFFFF` | 底已白 |
| Dialog 中心取样 | `#FFFFFF` | 未稳定打到 Dialog 面；**不以该点定 Dialog 色** |

核子高光（截图上看浅橙 / 浅灰）= 径向内部，**不当** `#D14600` / `#737373`。  
云雾中环 = `#0000FF`×α 叠白，不当另写一种紫。

Focused / 格 fill：C-12 图块太小，**不能**用像素否定源码色。以 `ChartIntroVisuals` + Painter 为准。

---

## 7. mean |ΔRGB|

| 对照 | 结果 |
|---|---|
| Chart Intro C-12 vs 原版 Chart Intro | **未算**。仓库无原版 Chart Intro PNG，禁止用 Decay Fe-69 原图硬套。 |
| Chart Intro vs Fe-69 | 不适用。本屏无 Fe-69。 |

该数字只作辅助。已源码确认的色 **不得**为了降低它而改。

Decay play 的 mean |ΔRGB| 见 `decay-first/FINAL_VISUAL_P4_2.md`，本阶段不重算、不优化。

---

## 8. [源码一致]

- play `#FFFFFF`（本阶段修到）  
- Radio 全部 `#F1FAFE`（本阶段修到）  
- proton / neutron / 核子径向 / 云 0–0.9  
- 能级 black→p/n occupancy 插值  
- 图 fill：`#1B1464` / `#28D756` / `#94F5F5` / `#85CAFF` / `#F7025D` / `#FF1FFF` / unknown 白  
- 当前格八角底 = 格 fill  
- Focused：fill 不变，窗外 **0.65**，框黑 1.5  
- 格描边 `#8F8F8F`；Accordion 白  
- 周期表 disabled 白；高亮黑底白字；Z>10 格存在  
- 符号 Z `#D14600`；盒白/黑 2  
- 方程箭头白填黑边；Z `#FF5500`  
- Full Chart **按钮** 白底黑边  
- 元素名 `#FF0000`  
- 无正文 LinearGradient  

---

## 9. [视觉近似]

- Radio / Reset 的 Material 描边与字色（`black87` / `#6750A4`）  
- 壳层 fade：`saveLayer` vs scenery Node.opacity  
- 计数点描边 0.5 vs ParticleNode 1  
- 同等 hex 叠在白底上的抗锯齿边 ≠ 源码色  
- font family 仍平台默认（P3，本阶段不改）  
- NineGrid 把右栏缩到无法像素验证格 fill（几何已冻结）  

---

## 10. [有意差异]

- 全局 Theme / Material color scheme **不改**；AppBar 可仍是 `#FEF7FF`  
- Home Tab accent `#B45309` **不改**  
- Magic Numbers checkbox + 黄描边：不补功能  
- Reset / Undo：保持 Material，不换 scenery-phet 控件  
- Full Chart PNG 不重处理  

---

## 11. [待确认]（本阶段不改）

- Chart Decay 键 disabled：sun 灰化 ≠ Flutter α=0.4  
- Full Chart Dialog 底：`INFO_DIALOG_OPTIONS` 无 fill（可能白）vs Flutter `#FFFEF4`  
- sun RectangularRadioButton 的边/压下高光（已对齐 fill，边保持 Material）  

---

## 12. 回归

| 项 | 结果 |
|---|---|
| `flutter analyze lib/chemistry/build_a_nucleus` | No issues |
| `flutter test test/chemistry/build_a_nucleus` | **407/407** |
| 640×360 / 1024×768 / 1280×800 overflow | `chart_intro_viewport_test` 通过 |

---

## 13. 停止

P4-3 只完成 **Chart Intro Color / Gradient**。

**未改** Decay、Theme、Typography、NineGrid、zoom / focus 语义、Equation logic、Full Chart 行为 / PNG、Home / Tab。

未进入 P5。
