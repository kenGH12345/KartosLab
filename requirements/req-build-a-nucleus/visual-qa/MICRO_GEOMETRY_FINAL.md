# MICRO_GEOMETRY_FINAL（P5-2）

> Chart Intro / Decay 局部 Icon · Path · 微几何 · 2026-08-31  
> 每项只改一次。未改 Theme / Typography / NineGrid / State / Controller / Reset·Undo·Info 控件体系。

截图：`decay-first/flutter_decay_{empty,fe69}.png`（1280×800 @ DPR 2）  
`chart-intro/flutter_chart_intro_c12_{partial,zoom,dialog}.png`（1280×800 @ DPR 1）  
取样：`p5_2_screenshot_samples.json`

---

## 0. 总表

| Component | Before | After | PhET | Classification |
|---|---:|---:|---:|---|
| Equation arrow head | 7（翼 ±4） | **10 × 10** | ArrowNode 默认 headW/H 10 | [源码一致] |
| Equation length / tail / fill / stroke | 25 / 3 / 白 / 黑 0.5 | 未改 | `DECAY_ARROW_OPTIONS` | [源码一致] |
| Dialog Close glyph | 24 | **18.2** | `closeButtonLength: 18.2` | [源码一致] 尺寸；叉形仍 Material |
| less / more 箭 | 空心 V 描边 | **填黑** Arrow 形（长 30，头 6×10，尾 1） | `ArrowNode` 同参 | [源码一致] 形；未加默认 1px stroke |
| 单箭 Path | `Icons.arrow_drop_*` | **14×14 三角**，质子/中子色 | `ArrowButton` 三角 | [源码一致] Path |
| 双箭 Path | `keyboard_double_arrow` 叠尖、单色 | **并排** 左 `#D14600` 右 `#737373` | `DoubleArrowButton` | [源码一致] Path |
| 生成器钮 chrome | 无底无边 | **白底黑边 1，r=4** | 同 | [源码一致] |
| 生成器盒 | 28×24 / 42×24 | **同**（未改） | margin+glyph 估 | 锚点冻结 |
| Zoom 格内衰变箭 | 未画 | Zoom + 不稳定 + 已知衰变 → 白填黑边方向箭 | `arrowSymbol: true` 仅 Zoom | [源码一致] |
| Partial / Focused 格内箭 | 无 | 仍无 | `arrowSymbol: false` | [源码一致] |
| Radio fill | `#F1FAFE` | 未改 | 全部 `#F1FAFE` | [源码一致] |
| Reset / Undo / Info | Material | 未改 | sun / scenery-phet | [视觉近似：Material] |
| Radio 缩微图 | 文字 Partial/Zoom | 未改 | 核素图 Path | [有意差异] |
| IconFactory 衰变图 | 键上 α/β/p/n | 未改 | 叠球 / 运动线 | [有意差异] |
| Chart Intro 双箭 | 无 | 未补 | `NucleonCreatorsNode` 有 | [有意差异] |

---

## 1. 修改项（修前记录）

| # | 原值 | 文件 |
|---|---|---|
| 1 | `head = 7.0`，翼 `y±4` | `decay_equation_view.dart` |
| 2 | `Icons.close` 默认 24 | `half_life_info_dialog.dart` / `full_chart_dialog.dart` |
| 3 | stroke 折线 + 开叉头 | `half_life_stability_legend.dart` |
| 4 | Material drop / double-chevron | `build_a_nucleus_screen.dart` `_ArrowColumn` |
| 5 | 格内无方向箭 | `nuclide_chart_painter.dart` |

---

## 2–5. 五项对照

### 1. Equation arrow head

| | |
|---|---|
| PhET | 长 25，尾 3，白填，黑边 0.5，**head 10×10** |
| 修前 | 头长 7，翼半宽 4 |
| 修后 | `decayEquationArrowHeadWidth/Height = 10` |
| Δ | 头 +3，翼半宽 +1 |
| 未改 | 长、尾、填、描边、HBox、minHeight 30 |

C-12 稳定，方程行是「Stable」，**本帧无方程箭**。衰变式才画该 Path。  
Be-8 全屏会踩上既有 `DecayEquationSymbol` A/Z > 30（P3 已记），本阶段不改方程布局，故未用 Be-8 全屏验收。

### 2. Dialog Close

| | |
|---|---|
| PhET | `closeButtonLength: 18.2` |
| 修前 | 24 |
| 修后 | `BanConstants.closeIconSize = 18.2` |
| Δ | −5.8 |
| 未改 | Dialog 尺寸 / padding / barrier / pop 语义 |

叉仍是 Material `Icons.close` → 形 [视觉近似：Material]，尺寸 [源码一致]。

### 3. less / more

| | |
|---|---|
| PhET | 填黑 `ArrowNode`，长 30，headW 6，tail 1，左右 |
| 修前 | 空心 V |
| 修后 | 同盒 30×8 的填黑 Path |
| Δ | 描边 → 填充 |
| 未改 | 文案、HBox、`spaceBetween`、数轴宽 |

尾仅 1px，未再描 1px 边（否则尾会被描边吃掉）。取样落在细箭上 var 高 = EDGE，不当 base。

### 4. Generator 内部 Path

| | 单质子 | 单中子 | 双箭 |
|---|---|---|---|
| PhET | 白底黑边，橙三角 14 | 灰三角 14 | 并排两色，朝下旋转并换色 |
| 修前 | drop icon，无 chrome | 同 | 叠双尖，`black87` |
| 修后 | 白 `#FFFFFF` var=0；中心 `#D14600` var=0 | 中心 `#737373` var=0 | 左偏橙 / 右偏灰（EDGE，两三角缝） |
| 盒 | 28×24 / 42×24 **未变** | 同 | 同 |

未改：generator X、bottom、HBox spacing 5、`minContentWidth` 150。  
仍用 `IconButton` 壳，只换 icon Path + 本地白底黑边。

### 5. Zoom 格内衰变小箭

**不是 IconFactory。** 原版是 `ArrowNode` + `DECAY_ARROW_OPTIONS`，从当前格心指向子核格心。

| 屏 | `arrowSymbol` | Flutter |
|---|---|---|
| Partial | **false** | 不画 |
| Zoom | **true** | 不稳定 + 已知衰变才画 |
| Focused | **false** | 不画 |

方向（Δn, Δp）：n 发射 (−1,0)；p 发射 (0,−1)；β+ (+1,−1)；β− (−1,+1)；α (−2,−2)。  
八角标签仍盖住箭尾。未改 cell size / highlight / 0.65。

C-12 稳定 → Zoom 帧无此箭，**正确**。  
IconFactory 叠球 vs 键上 α/β/p/n：**未改**，仍 [有意差异]。

---

## 6. Screenshot sampling（只测这 5 项）

Fe-69 · 逻辑×2：

| 点 | hex | 说明 |
|---|---|---|
| 质子上箭中心 | `#D14600` | 三角 fill，精确 |
| 质子钮空白 | `#FFFFFF` | 白底，精确 |
| 中子上箭中心 | `#737373` | 精确 |
| 双箭左 / 右 | `#D55718` / `#B0B0B0` | 两色并排；var 高=缝 |
| less/more 箭 | 灰 EDGE | 1px 尾，不当 base |

C-12：play 白；稳定无格内箭。未重测整页 mean |ΔRGB|。

---

## 7. 可修复项（本阶段已做）

1. 方程头 7→10  
2. Close 24→18.2  
3. less/more 填黑  
4. 生成器三角 + 并排两色 + 白底黑边  
5. Zoom 格内方向箭  

---

## 8. 保留的 [视觉近似：Material]

- Reset / Undo / Info 整控件  
- Close 的 Material 叉形（只齐了尺寸）  
- Radio 边 `black87` / `black26`  
- Checkbox  
- Full Chart `OutlinedButton` 壳  

---

## 9. 保留的 [有意差异]

- Partial / Zoom **文字** 代替缩微核素图  
- IconFactory 衰变图 vs 短符号  
- Chart Intro 无双箭列  
- Energy 竖箭、zoom 虚线、Magic checkbox  
- Available Decays Info 钮  
- Home Tab Material 图标  

---

## 10. [待确认] / 未硬塞

- less/more 是否要再描 ArrowNode 默认 1px stroke  
- 双箭缝像素（盒内已放下 14+14，未撑破 42）  
- 不稳定核素全屏 Chart Intro：方程符号仍可能 overflow 30（P3 已知，不在本阶段修）  
- sun Panel / Radio gap 等 P5-1 待确认项  

未出现「双箭放不下」→ 未标 `[视觉近似：NineGrid / Material constraint]`。

---

## 11. 回归

| 项 | 结果 |
|---|---|
| `flutter analyze lib/chemistry/build_a_nucleus` | No issues |
| `flutter test test/chemistry/build_a_nucleus` | **407/407** |
| 640×360 / 1024×768 / 1280×800 | viewport 无 overflow |

---

## 12. 停止

P5-2 只完成上述 5 项局部修正。

**未改** 布局、字体、颜色体系、generator Y、Half-Life 几何、counters、Reset、Electron Cloud。

等待最终 Visual QA。
