# FINAL-VISUAL-REMEASURE

> Build a Nucleus · 最终视觉复测 · 2026-08-31  
> **本阶段 0 个实现修改。** 发现问题只记录。  
> 分类仅用：`[视觉已对齐]` / `[视觉近似]` / `[有意差异：NineGrid]` / `[有意差异：Material]` / `[待确认]`

对照机读：`final_remeasure_matrix.json`  
Decay 叠图：`decay-first/decay_first_diff_report.json`

---

## 0. 结论（先读）

| 项 | 判断 |
|---|---|
| 视觉完成度 | Decay **主锚点已对齐**；整页观感由 NineGrid + chrome + 字体决定。Chart Intro **源码几何已验**，无原版 PNG，不能宣称像素对齐。 |
| P5-2 副作用 | **无。** generator / 方程 / Close / Zoom / less-more 的 parent bounds、hit area、alignment 未变。 |
| MUST FIX | **1 项**：Chart Intro 衰变方程把 `minHeight 30` 写成固定 `height: 30`，A/Z 列会 overflow。 |
| ACCEPT | NineGrid、Material 皮肤、font family、Tab dispose、Chart 无双箭 / Magic / Energy。 |
| UNCONFIRMED | 无原版 Chart Intro 截图；disabled decay 灰化；Full Chart Dialog 底色；Focused / 衰变核素整页未拍。 |
| 下一步 | **停止。** 不要开「建议继续优化」。若进入 FINAL-FIX，只处理 MUST FIX。 |

不要读成：「与 PhET 一模一样」或「mean |ΔRGB| 下降即成功」。

---

## 1. 固定环境（与此前截图一致）

| 端 | 视口 | DPR | play | 状态 |
|---|---|---|---|---|
| 原版 Decay | 1024×672（`LAYOUT_BOUNDS` 1024×618 + joist 底栏） | 1 | 0,0 · 1024×618 | Fe-69（`original_decay_screen1.png`） |
| Flutter Decay | Pixel Tablet · 逻辑 1280×800 · 物理 2560×1600 | 2 | 0,108 · 1280×692 | 空核 + Fe-69 |
| Flutter Chart Intro | 1280×800 独立 `ChartIntroScreen`（无 Home AppBar+Tab） | 1 | 全窗 1280×800 | C-12 Partial / Zoom / Dialog |

归一化（Decay play → 1024×618）：

- `chrome_h = 108`（AppBar 56 + TabBar ≈48）
- `sx = 0.8`
- `sy = 618/692 ≈ 0.89306`

未改 orientation、browser chrome、crop、scale。截图 **复用** P5-2 已建立基准帧，未重 pump 新状态。

Chart Intro **没有**原版 PNG → **不伪造** overlay / difference / mean |ΔRGB|。

---

## 2. 复用截图

### Decay

| 文件 | 内容 |
|---|---|
| `decay-first/original_decay_screen1.png` | 原版 Fe-69 · 1024×672 |
| `decay-first/flutter_decay_empty.png` | Flutter 空核 · 1280×800 @ DPR 2 |
| `decay-first/flutter_decay_fe69.png` | Flutter Fe-69 · 同 |
| `decay-first/flutter_decay_*_rects.json` | `tester.getRect` 逻辑矩形 |

### Chart Intro

| 文件 | 内容 |
|---|---|
| `chart-intro/flutter_chart_intro_c12_partial.png` + `.json` | C-12 Partial |
| `chart-intro/flutter_chart_intro_c12_zoom.png` + `.json` | C-12 Zoom（含 Focused 格配方；**不是**独立 Focused 整页） |
| `chart-intro/flutter_chart_intro_c12_dialog.png` + `.json` | C-12 Zoom + Full Chart Dialog |

**未拍（记录为 UNCONFIRMED，不补拍以免改状态）：**

- Chart Intro 独立 Focused 整页
- 带衰变方程的有效核素全屏（Be-8 会触发已知 A/Z overflow；C-12 稳定只显示「Stable」）

---

## 3. Decay 差异矩阵

单位：归一化到 **1024×618** 的 CSS px。Flutter 先减 chrome 再 × `(sx, sy)`。

原版锚点来自 PhET 源码（`SCREEN_VIEW_ATOM_CENTER`、`X_MARGIN` 等），不是像素聚类。

| Screen | Component | Original Rect | Flutter Rect | Δx | Δy | Δw | Δh | 分类 |
|---|---|---|---|---:|---:|---:|---:|---|
| Decay | play area | 0,0 1024×618 | 0,0 1024×618 | 0 | 0 | 0 | 0 | [视觉已对齐] |
| Decay | nucleus | cx 341.3, 339.9 | cx 341.3, 388.9 | 0.0 | 49.0 | 0 | 0 | [视觉已对齐] |
| Decay | generator | 161.3,513 360×90 | 174.1,555.5 334.4×49.1 | 12.8 | 42.5 | −25.6 | −40.9 | [视觉已对齐] |
| Decay | Half-Life | 45,95 550×80 | 83.6,46.8 856.7×110.7 | 38.6 | −48.2 | 306.7 | 30.7 | [有意差异：NineGrid] |
| Decay | counters | 687,15 140×50 | 950.9,53.9 28.1×7.5 | 263.9 | 38.9 | −111.9 | −42.5 | [有意差异：NineGrid] |
| Decay | Element | 250,193 140×24 | 247.1,238.8 145.8×25.9 | −2.9 | 45.8 | 5.8 | 1.9 | [视觉已对齐] |
| Decay | Stability | 265,133 110×24 | 255.2,159.3 129.6×25.9 | −9.8 | 26.3 | 19.6 | 1.9 | [视觉已对齐] |
| Decay | symbol | 859,15 150×120 | 985.4,62.9 32.2×42.0 | 126.4 | 47.9 | −117.8 | −78.0 | [有意差异：NineGrid] |
| Decay | Available Decays | 687,145 322×360 | 943.6,117.3 77.2×233.1 | 256.6 | −27.7 | −244.8 | −126.9 | [有意差异：NineGrid] |
| Decay | Reset | 969,563 40×40 | 940.4,489.2 83.6×42.9 | −28.6 | −73.8 | 43.6 | 2.9 | [视觉近似] |
| Decay | Undo | （Fe-69 无） | （未出现） | — | — | — | — | [有意差异：Material] |
| Decay | Electron Cloud | 687,575 180×28 | 738.4,460.5 202.0×28.6 | 51.4 | −114.5 | 22.0 | 0.6 | [有意差异：NineGrid] |
| Decay | right column | 687,15 322×490 | 940.4,46.8 83.6×442.3 | 253.4 | 31.8 | −238.4 | −47.7 | [有意差异：NineGrid] |
| Decay | addProton 盒 | 28×24（源码盒） | 逻辑 28×24 | — | — | 0 | 0 | [视觉已对齐] |
| Decay | addPair 盒 | 42×24（源码盒） | 逻辑 42×24 | — | — | 0 | 0 | [视觉已对齐] |

逻辑坐标（Fe-69，未映射，1280×800 @ DPR 2）：

| 项 | 值 |
|---|---|
| chrome | 0,0 · 1280×108 |
| play | 0,108 · 1280×692 |
| nucleusCenter | 426.67, 543.47 → 映射 cx **341.3** |
| element / stability cx | **400** → 映射 **320**（半衰期冻结中心，≠ atom 341.3） |
| nucleonCreators | 217.67, 730 · **418×55** · cx 426.67 · bottom 785 |
| addProton / addPair | **28×24 / 42×24**（与 P2-5 / P5-2 前相同） |

### 已 resolved、本阶段不重开

| 项 | 证据 |
|---|---|
| nucleus X | Δcx = 0。公式 `playW/3`。 |
| nucleus Y | 公式仍 `canvasH × 0.55`。Δcy = +49 来自 NineGrid 画布变矮。 |
| generator X | 整组 cx = atomCenter。Δcx = 0。 |
| generator bottom | play 底 − 15。映射 bottom orig 603.0 / fl 604.6（Δ ≈ +1.6）。 |
| Element / Stability X | 跟半衰期冻结中心 320，不是 atom 341.3。Δcx = 0。 |

无新的直接源码证据推翻以上五项。

---

## 4. Chart Intro 差异矩阵

无原版截图 → **不写伪造 Δx/Δy**。Original = PhET 源码几何（1024×618 绝对坐标）。Flutter = C-12 Zoom 逻辑矩形（1280×800 @ DPR 1，独立 Screen）。

| Screen | Component | Original Rect | Flutter Rect | Δx | Δy | Δw | Δh | 分类 |
|---|---|---|---|---:|---:|---:|---:|---|
| Chart Intro | play / screen bg | WHITE | `#FFFFFF`（取样 var=0） | — | — | — | — | [视觉已对齐] |
| Chart Intro | ShellModelNucleus | 原点 (135, 245)；mini-atom 中心约 (341.3, 87) scale 0.75 | NineGrid `center` / `topCenter` FittedBox | — | — | — | — | [有意差异：NineGrid] |
| Chart Intro | Nuclear Chart | 周期表下方 Accordion | 1175.5, 322.9 · 104.5×114.1 | — | — | — | — | [有意差异：NineGrid] |
| Chart Intro | Periodic Table | 顶部偏右 | 1175.5, 61.5 · 104.5×41.9 | — | — | — | — | [有意差异：NineGrid] |
| Chart Intro | Isotope Symbol | 叠表 `centerX = 7.5/18` | 1213.5, 63.0 · 12.1×14.3 | — | — | — | — | [有意差异：NineGrid] |
| Chart Intro | Element | 生成器 centerX，字号 20 红 | 0, 58.5 · 104.5×13.6 | — | — | — | — | [有意差异：NineGrid] |
| Chart Intro | Zoom / Partial | 缩微核素图 Radio，fill `#F1FAFE` | 文字 Radio；fill 已齐；≈24.8×6.8 / 16.2×6.8 | — | — | — | — | [有意差异：Material] |
| Chart Intro | Focused frame | fill 不变，窗外 opacity 0.65，框 1.5 | 同配方（Zoom 帧含 focused 子图） | — | — | — | — | [视觉已对齐] |
| Chart Intro | Equation | `minHeight` 30 为**下限** | C-12 Stable：1177.8, 334.5 · 63.3×12.2；实现写成 `height: 30` | — | — | — | — | [待确认] |
| Chart Intro | Decay button | accordion 内 | 1217.4, 349.0 · 27.7×11.3 | — | — | — | — | [有意差异：NineGrid] |
| Chart Intro | Full Chart button | Magic Numbers **下方** | 与 Radio **同行**：1220.2, 425.8 · 39.4×11.3 | — | — | — | — | [有意差异：NineGrid] |
| Chart Intro | Full Chart dialog | sun INFO_DIALOG（底可能白） | title 256, 256.5 · 728×46；底 `#FFFEF4` | — | — | — | — | [待确认] |

源码几何已验（不依赖原版 PNG）：

| 参数 | Flutter | PhET | 分类 |
|---|---|---|---|
| 格 18 / 30 / 10 | `ChartIntroVisuals` | 同 | [视觉已对齐] |
| Zoom 5×5 + 夹紧 | 同 | 同 | [视觉已对齐] |
| Focused 窗外 0.65 | 同 | 同 | [视觉已对齐] |
| Radio fill `#F1FAFE` | 选中/未选都同色 | 同 | [视觉已对齐] |
| 元素名 20 / `#FF0000` | 同 | 同 | [视觉已对齐] |
| 方程箭头 长 25 / 尾 3 / 头 10×10 / 白填黑边 0.5 | P5-2 后同 | `DECAY_ARROW_OPTIONS` | [视觉已对齐] |
| Dialog Close 18.2 | `BanConstants.closeIconSize` | `closeButtonLength: 18.2` | [视觉已对齐] 尺寸；叉形 [有意差异：Material] |
| Zoom `arrowSymbol` | 仅 Zoom + 不稳定 + 已知衰变 | 同 | [视觉已对齐] |
| Partial / Focused 格内箭 | 不画 | `arrowSymbol: false` | [视觉已对齐] |
| PhetFont / Arial | 平台默认 | PhetFont | [视觉近似] |
| Radio 缩微图 | 文字 | Path | [有意差异：Material] |
| Tab 切走 dispose | 是 | Screen 常驻 | [有意差异：Material] |

C-12 稳定 → Zoom 无格内衰变箭、方程为「Stable」：**正确**。无法用本帧验收方程箭头头或 Zoom 方向箭的像素。

---

## 5. 已知差异重分类

### Decay

| 项 | 复测分类 | 说明 |
|---|---|---|
| NineGrid / canvas | [有意差异：NineGrid] | 中心格变矮；核 Y 公式不重开。 |
| footer 高度 | [有意差异：NineGrid] | 生成器映射高 49 vs 原版 90。 |
| right column 宽度 | [有意差异：NineGrid] | 映射 83.6 vs 322。 |
| Half-Life 宽度 | [有意差异：NineGrid] | 拉满中心格 856.7 vs 550；冻结中心 X 仍 320。 |
| counters | [有意差异：NineGrid] | midRight 窄列 FittedBox。 |
| symbol | [有意差异：NineGrid] | 边格压缩。 |
| Reset | [视觉近似] | 右下同槽；皮肤 Material，不是 ResetAll 橙圆。 |
| Electron Cloud checkbox | [有意差异：NineGrid] | 画布右下 vs 原版 decays.left + reset.bottom。 |
| Material skin | [有意差异：Material] | Checkbox / IconButton / Undo。 |
| font family | [视觉近似] | 字号已齐；未打包 Arial。 |

### Chart Intro

| 项 | 复测分类 | 说明 |
|---|---|---|
| NineGrid | [有意差异：NineGrid] | 绝对坐标 → 九宫格；右栏约 104.5 宽。 |
| PhetFont | [视觉近似] | 字号已齐。 |
| Material | [有意差异：Material] | Reset / Close 叉 / Radio 边。 |
| Radio visual | [有意差异：Material] | fill 已齐；图标是字。 |
| equation min height | [待确认] → 见 MUST FIX | C-12 本帧无 overflow；源码把下限写成固定高。 |
| Full Chart placement | [有意差异：NineGrid] | 与 Radio 同行；原版在 Magic 下方。 |
| Tab lifecycle | [有意差异：Material] | 切走 dispose；Dialog 卸树关闭。 |

---

## 6. P5-2 副作用检查

| 项 | parent bounds | overflow | alignment | baseline | hit area |
|---|---|---|---|---|---|
| generator | **未变** 418×55，cx 426.67，bottom 785 | 无 | 整组仍对 atomCenter | 标签行未动 | 盒仍 28×24 / 42×24 |
| equation | 长 25 / 尾 3 / HBox / `minHeight` 常量未改 | C-12 无；衰变核素见 MUST FIX（**P5-2 前已有**） | 未改 | 未改 | 未改 |
| dialog close | Dialog 尺寸 / padding 未改 | 无 | 右上未改 | — | icon 24→18.2，外层按钮壳未改 |
| Zoom icon（格内箭） | cell / highlight / 0.65 未改 | 无 | 格心→子核 | — | 画在格子内，不增 hit |
| less / more | 盒仍 30×8；HBox `spaceBetween` 未改 | 无 | 数轴底未改 | 文案未改 | 盒未改 |

取样（`p5_2_screenshot_samples.json`，Fe-69 @ DPR 2）：

| 点 | hex |
|---|---|
| 质子上箭中心 | `#D14600` var=0 |
| 质子钮白底 | `#FFFFFF` var=0 |
| 中子上箭中心 | `#737373` var=0 |
| 双箭左 / 右 | `#D55718` / `#B0B0B0`（缝，EDGE） |

**结论：P5-2 未改变布局几何。**

---

## 7. Decay mean |ΔRGB|

复跑 `decay-first/measure_decay_first.py`（同一套 crop / scale）：

| 叠图 | P4-2 | 本复测 | 文件 |
|---|---:|---:|---|
| 全画幅 空核 | 46.60 | **46.44** | `overlay_50_empty.png` / `diff_empty.png` |
| 全画幅 Fe-69 | 49.59 | **49.43** | `overlay_50_fe69.png` / `diff_fe69.png` |
| Play 区 Fe-69 | 31.81 | **31.90** | `overlay_50_play.png` / `diff_play.png` |

尺寸：全画幅 1280×800；play 1024×618。

**下降不是成功标准。** Play 区还略升 0.09，与 P5-2 生成器 Path / less-more 填色局部对比有关，不单独当回归失败。

### 分项贡献（定性，不是可加总百分比）

| 来源 | 对 mean 的作用 | 是否可修（本阶段） |
|---|---|---|
| **chrome** | 全画幅主因：顶 AppBar `#B45309` + Tab vs 原版底 joist 黑栏。空核/Fe-69 全画幅 ~46–49。 | ACCEPT。不改工程壳。 |
| **geometry（NineGrid）** | Play 区主因：右栏变窄、Half-Life 拉满、画布变矮、footer 变矮。核 X 已齐，叠核仍因 Δcy。 | ACCEPT。不改 NineGrid。 |
| **base color** | play 底 `#FFFFFF` 已齐（P4）。不再贡献主题紫底。 | 已对齐。 |
| **typography** | 字号已齐；字形/字重差仍在叠字区域。 | ACCEPT（font family）。 |
| **compositing** | 电子云 `#0000FF` 径向叠白底；核子白→base 径向。配方已齐，像素因位置/抗锯齿仍差。 | 配方 ACCEPT / 已对齐。 |
| **P5-2 Path** | 生成器白底黑边 + 三角、less/more 填黑。局部对比变化；不移动 bounds。 | 形已按源码。 |

---

## 8. 剩余差异桶

### MUST FIX

真正明确错误。有源码证据。本阶段 **只记录，不修**。

| # | 项 | 证据 |
|---|---|---|
| 1 | Chart Intro 衰变方程：`decayEquationMinHeight = 30` 被写成 `SizedBox(height: 30)` | PhET 是 **minHeight**。`DecayEquationSymbol` A/Z 列 = `15 + 2.25 + 15 = 32.25` > 30。C-12 稳定走「Stable」文案，本帧不触发。衰变核素会 overflow。P3 / P5-2 已见，**不是 P5-2 引入**。 |

无第二项达到「明确错误 + 源码证据」门槛。

### ACCEPT

| 项 | 分类 |
|---|---|
| NineGrid 画布 / 右栏 / footer / Half-Life 拉满 / counters / symbol / Electron Cloud 落位 | [有意差异：NineGrid] |
| AppBar+Tab vs joist 底栏 | [有意差异：Material]（工程壳） |
| Reset / Undo / Info / Checkbox / Radio 边 / Close 叉形 | [有意差异：Material] |
| Radio 用字代替缩微图 | [有意差异：Material] |
| IconFactory 衰变图 vs 键上 α/β/p/n | [有意差异：Material] |
| Chart Intro 无双箭 / 无 Magic / 无 Energy 虚线 | [有意差异：NineGrid]（功能范围） |
| Full Chart 与 Radio 同行 | [有意差异：NineGrid] |
| font family（字号已齐） | [视觉近似] |
| Tab 切走 dispose | [有意差异：Material] |
| 核 Y Δcy、generator 映射高 | [有意差异：NineGrid]（公式 resolved） |

### UNCONFIRMED

| 项 | 缺什么 |
|---|---|
| Chart Intro 整页像素 / mean \|ΔRGB\| | 无原版 PNG |
| Focused 整页构图 | 无独立 Focused 全屏图 |
| 衰变方程箭头头 / Zoom 格内箭的像素 | C-12 稳定不画；未拍衰变核素全屏 |
| disabled decay 灰化 | sun 配方 vs Flutter α=0.35 `#F5DCB4` |
| Full Chart Dialog 底 `#FFFEF4` vs 可能白 | 无原版 Dialog 截图 |
| less/more 是否再描 ArrowNode 默认 1px stroke | 细尾取样 EDGE，不当 base |
| 真机 / 多次进出内存 | 测试不能断言进程级无泄漏 |

---

## 9. Screenshot / overlay 结果

| 产物 | 路径 | 说明 |
|---|---|---|
| Decay 全画幅叠图 | `decay-first/overlay_50_{empty,fe69}.png` | 原版放大到 1280×800 后 50% 叠 |
| Decay 全画幅差 | `decay-first/diff_{empty,fe69}.png` | |
| Decay play 叠图 / 差 | `decay-first/overlay_50_play.png` / `diff_play.png` | 1024×618 |
| Chart Intro overlay | **无** | 禁止伪造 |
| 矩阵 JSON | `visual-qa/final_remeasure_matrix.json` | |

---

## 10. 测试结果

本阶段只跑回归，**未改** `lib/`。

| 命令 | 结果 |
|---|---|
| `flutter analyze lib/chemistry/build_a_nucleus` | **No issues found** |
| `flutter test test/chemistry/build_a_nucleus` | **407/407 All tests passed** |

视口（已有测试覆盖，本轮随 407 跑过）：

| 视口 | Decay | Chart Intro Partial / Zoom |
|---|---|---|
| 640×360 | 无 overflow | 无 overflow；Dialog 可滚关 |
| 1024×768 | 无 overflow | 无 overflow |
| 1280×800 | 无 overflow | 无 overflow |

---

## 11. 最终建议

1. **停止视觉循环。** P0–P5-2 + 本复测已把可证伪的锚点对齐，其余已进 ACCEPT / UNCONFIRMED。  
2. **不要**为 mean |ΔRGB| 再开一轮。  
3. **不要**重开 nucleus X/Y、generator X/bottom、Element/Stability X。  
4. **不要**改 NineGrid / Theme / 全局字体。  
5. 若用户明确要求 FINAL-FIX：只修 MUST FIX #1（方程 `height` → 真正的 minHeight / 允许长高）。不要顺手改 Radio、Reset、Dialog 底。  
6. Chart Intro 像素对照需要原版 1024×672 截图后另立阶段；在此之前标 UNCONFIRMED。

---

## 12. 本阶段停止

复测完成。0 个实现修改。不进入开发。
