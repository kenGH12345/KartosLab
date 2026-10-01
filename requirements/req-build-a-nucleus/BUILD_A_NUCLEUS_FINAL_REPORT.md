# Build a Nucleus · Decay Screen 最终对照报告

> 需求 ID：`req-build-a-nucleus`  
> 阶段：FINAL-1（Decay Screen 最终视觉与行为对齐）  
> 日期：2026-08-28  
> Chart Intro：**不在本期**，见 §16。

诚实标记：

| 标记 | 含义 |
|---|---|
| [源码一致] | 算法/数值与 PhET TS 源码逐项对应 |
| [行为一致] | 自动化测试覆盖的用户可见行为与原版语义一致 |
| [视觉近似] | 观感接近，但未做像素级对照 |
| [有意差异] | 已知且保留（布局约束、缺陷不复制、本地化等） |
| [待确认] | 证据不足，不能写成事实 |

**质量结论（先说清楚）：**  
Decay Screen 的 **模型、交互与动画参数** 按原版源码落地，并用 244 项测试约束。  
**不能**声称与 PhET HTML5 屏「一模一样」。布局受工程 `NineGridLayout`（中间格 ≥70%）约束，半衰期区、Checkbox、面板宽度与原版绝对坐标不是同一套。视觉属 **[视觉近似]**。

---

## 1. Decay Screen 功能清单

| 功能 | 状态 | 证据 |
|---|---|---|
| 核子生成器（拖出 + 上/下箭头） | 已完成 | Screen footer；`addProton` / `removeProton` 等 |
| 双箭头同时增减一对 p+n | FINAL-1 补上 UI | 原版 `DoubleArrowButton`；Controller 原先已有 `addPair`/`removePair` |
| 核内拖拽进出（捕获半径 100） | 已完成 | `endNucleonDrop` |
| 箭头飞入 0.6s | 已完成 | `flyInAnimationTime` |
| 卡位 settle 200 px/s | 已完成 | `repositionSpeed` |
| 五种衰变 α / β- / β+ / p / n | 已完成 | `applyDecay` |
| β 换色 0.5s 后发射 | 已完成 | `betaColorAnimationTime` + holdTime |
| Be-6 特例（4p2n → 2p0n → 延迟射质子 → 0p0n） | 已完成 | `build_a_nucleus_be6_alpha_test.dart` |
| Undo / Reset | 已完成 | 见 §7 有意差异 |
| 核素名 / 稳定 / 符号 / 计数 | 已完成 | `nuclide_status.dart` |
| 半衰期数轴 + 读数 + less/more + Timescale dialog | 已完成 | `HalfLifeInformationView` |
| 电子云 + Checkbox | 已完成 | `ElectronCloudReading` + Painter |
| 无效核素 1s 回退 | 已完成 | `timeToShowDoesNotExist` |
| Chart Intro | **未做** | §16 |
| HomeScreen 入口 | **未注册** | §17 |

上限：94 质子 / 146 中子。[源码一致] `DECAY_MAX_NUMBER_OF_*`

---

## 2. Model / State / Controller / Render 架构

```
assets/data/nuclide_table.json
        │ NuclideDataLoader
        ▼
NuclideRepository（只查表，不推演）
        ▲
BuildANucleusState（可变世界：核子、incoming/outgoing、undo、invalid 计时）
        ▲ 命令
BuildANucleusController（ChangeNotifier；逃逸点 / creator 坐标由视图注入）
        ▲ ListenableBuilder + SimulationClock.tick
BuildANucleusScreen（NineGridLayout）
        ├── HalfLifeInformationView（Reading → 数轴/dialog）
        ├── NucleusPainter（核子 / 云 / 发射粒子）
        └── 边格读数、衰变面板、生成器、Reset
```

规则：Painter / Widget **不**查 `NuclideRepository`，不改 State 业务字段。半衰期与电子云都从 State 派生 Reading。

FINAL-1 **未改** Model / State / Controller / Repository / decay / drag / Undo / Reset 业务逻辑。只改了 Screen 生成器排法、衰变按钮色/标题，以及对照测试。

---

## 3. PhET → Flutter 映射

| PhET | Flutter |
|---|---|
| `DecayModel` + `BANModel` + `ParticleAtom` | `BuildANucleusState` |
| `BANScreenView` / `DecayScreenView` | `BuildANucleusScreen` |
| `NuclideRepository` 语义 ← `AtomInfoUtils` | `NuclideRepository` + JSON 表 |
| `ParticleAtomNode` | `NucleusPainter` |
| `HalfLifeInformationNode` | `HalfLifeInformationView` |
| `ShowElectronCloudCheckbox` | `ShowElectronCloudCheckbox`（Material Checkbox） |
| `NucleonCreatorsNode` | footer `_CreatorNode` + `_ArrowColumn` |
| `AvailableDecaysPanel` | `_DecayPanel`（边格紧凑版） |
| `ResetAllButton` | `IconButton(Icons.restart_alt)` |
| `ReturnButton` | `Icons.undo` |
| joist Screen 壳 / 语言 / a11y | **未做** |

---

## 4. 资源清单

| 资源 | 位置 | 说明 |
|---|---|---|
| 核素表 | `assets/data/nuclide_table.json` | 从 shred `AtomData.ts` 提取（稳定/半衰期/衰变/电子云半径） |
| Schema | `schemas/nuclide_table.schema.json` | 有则沿用 |
| 位图 / 音效 | 无 | 原版 Decay 屏核子与云为程序绘制；`fullNuclideChart.png` 属 Chart Intro |
| 字符串 | 硬编码 | 工程无 arb；计数/生成器为中文，核素名/半衰期为英文 |

---

## 5. 动画参数

| 项 | 值 | 标记 |
|---|---|---|
| 箭头飞入 | 距离 / **0.6 s**（定时长） | [源码一致] `ANIMATION_TIME` |
| 衰变飞出 / 回栈 | **300 px/s** | [源码一致] `PARTICLE_ANIMATION_SPEED` |
| 卡位归位 | **200 px/s** | [源码一致] `DEFAULT_PARTICLE_SPEED` |
| β 换色 | **0.5 s** 线性 | [源码一致] |
| β 发射滞留 | 换色完成后再飞 | [源码一致] |
| 指针 X | **0.7 s** quadratic in-out | [源码一致] |
| 指针旋转 | **0.1 s**；稳定先 X 后转 | [源码一致] |
| 无效核素展示 | **1 s** 后回退 | [源码一致] |
| Be-6 强制射质子 | α 飞满 `1s × 300px/s` 后 | [源码一致]（测试覆盖） |
| 电子云 | **无动画** | [源码一致] |
| 计数 0.1s 淡入 | **未做** | [有意差异] |

---

## 6. 视觉对照结果

未建 golden，也没有对 PhET 在线版做逐像素截图叠图。  
验证方式：源码参数对照 + Widget 多视口泵送（1024×768 / 1280×800 / 1366×1024 / 640×360）检查 overflow 与关键控件存在。

| 项目 | 原版 | Flutter | 状态 | 依据 |
|---|---|---|---|---|
| **布局 Nucleus** | `atomCenter = (width/3, height×0.55)`，全屏绝对坐标 | 中间格画布 `CanvasProjection.origin = (W/2, H×0.55)` | [有意差异] NineGrid | `BANConstants.SCREEN_VIEW_ATOM_*` vs `drag_drop_workspace.dart` |
| **Half-Life area** | 屏顶绝对定位，宽 550，`left = minX+15+30`，`y = minY+15+80` | 中间格**顶部**、核画布之上 | [有意差异] 顶行格子高度不够 | `DecayScreenView.ts`；notes 1G-3B-5 |
| **Electron Cloud** | 径向渐变圆，半径公式见 1G-3B-6 | 同公式；`atomCenter.x`→`origin.dx` | [源码一致] 公式；[视觉近似] 像素 | `ParticleAtomNode.updateCloudSize` |
| **Cloud Checkbox** | 衰变面板左、与 Reset 底对齐，文案宽可到 197 | 画布右下叠放（边格 ~65px 放不下） | [有意差异] | `ShowElectronCloudCheckbox.ts` |
| **Nuclide info** | 元素名在稳性下方居中；计数面板与衰变面板左对齐 | topCenter 名+稳性；topLeft 计数 | [有意差异] 边格映射 | `DecayScreenView` Positioning |
| **Decay controls** | 右中 `AvailableDecaysPanel`，橙按钮 + 粒子图标 | midRight 紧凑 α/β-/β+/p/n 文字按钮，橙底 | [视觉近似] 图标未复刻 | `BANColors.decayButtonColor` FINAL-1 已用 |
| **Generator** | `[↑↓p][p球][双箭][n球][↑↓n]` 底栏居中 | 同序；Material 箭头 | [行为一致] 排法；[视觉近似] 皮肤 | `NucleonCreatorsNode` HBox |
| **Reset** | 右下 `ResetAllButton` | bottomRight `restart_alt` | [视觉近似] | |
| **Undo** | `ReturnButton`，贴所点衰变按钮左 | 面板底部 `Icons.undo` | [视觉近似] 位置不同 | |
| particle size | 核子 r=10；e± r=8 | 同 | [源码一致] | `NUCLEON_RADIUS` / `ELECTRON_RADIUS` |
| particle color | p `#D14600`；n gray×0.9；e `Color.BLUE` | 同常量 | [源码一致] | `PARTICLE_COLORS` |
| nucleon gradient | 中心偏左上 -0.4r、半径 1.6r、白→基色 | 同 | [源码一致] | `ParticleNode` |
| cloud gradient | stop 0 α=1，0.9 α=0 | 同 | [源码一致] | `ELECTRON_CLOUD_FILL_GRADIENT` |
| arrows | sun `ArrowButton`，fill=核子色 | `arrow_drop_*` / double arrow，核子色 | [视觉近似] FINAL-1 已改色与上下方向 | |
| panels | fill rgb(241,250,254)，圆角 6 | 符号盒白底；边格无完整 Panel | [有意差异] | |
| typography | `REGULAR_FONT` 20 | 元素名 16 红；边格缩小 | [视觉近似] | |
| icons | 程序绘制衰变图标、info、Reset | Material icons | [有意差异] | |
| spacing | 绝对 px | NineGrid + FittedBox | [有意差异] | |
| InfinityNode | Path 无穷符 | 字符 `∞` | [有意差异] | notes 1G-3B-3 |
| info icon | 原版 info 按钮 | Material info | [有意差异] | |
| 计数标签 | `Protons:` / `Neutrons:` | `质子:` / `中子:` | [有意差异] 本地化 | 测试依赖中文 |
| Symbol Accordion | 可折叠 scale 0.3 | 不可折叠紧凑盒 | [有意差异] | |
| AppBar | joist 标题栏 | `构建原子核 · 衰变` | [有意差异] | |

FINAL-1 实际修改（仅 UI）：

1. 生成器改为原版 HBox 顺序，并露出双箭头（调用已有 `addPair`/`removePair`）。  
2. 衰变面板标题 `Available Decays`，启用按钮底色 `#FBB240`。  
3. footer `FittedBox`，窄横屏缩放。

---

## 7. 已知差异（非故意、但未在 FINAL-1 改业务）

无新的「对照后必须改 State」项。  
此前已记录、本阶段仍成立：

- 原版 β Undo 质量数不变，`hideUndoButton` 的 multilink 可能不藏按钮；本实现 Undo 后一律藏按钮。[有意差异] 不复制粗糙边缘（notes 1G-1）。
- 原版 `clearAnimations` 后核子可能保持不可拖；本实现冻结后恢复可拖。[有意差异]
- 电子云半径依赖 `atomCenter.x`（原版约 1024/3）。Flutter 用画布中心 x，云的**屏上像素**与原版不同。[视觉近似]

---

## 8. 有意差异

见 §6 表中 [有意差异] 行。摘要：

1. **NineGrid 强制中间格 ≥70%** → 半衰期不能放在原版屏顶绝对坐标。  
2. **边格约 57–65px** → 计数 FittedBox；Checkbox / 完整衰变面板无法按原版宽度放边格。  
3. **中文计数与生成器标签**（测试与现有 sim 惯例）。  
4. **Material 控件皮肤**（Checkbox、Reset、Undo、info、箭头）。  
5. **∞ 字符** 代替 InfinityNode Path。  
6. **不计 0.1s 计数淡入**、**符号盒不折叠**。  
7. **不复制** 原版 Undo/inputEnabled 已知缺陷。

---

## 9. [待确认]

| 项 | 说明 |
|---|---|
| 与官网 HTML5 的观感叠图 | 本机未开 PhET 在线版做截图叠加 |
| Checkbox 图标半径 = 文字高×0.82 | 现用 16px |
| 数轴箭头 Path 轮廓 | 自绘近似 |
| Dialog 内 A–J 蓝色短箭头 | 现为字母 |
| 科学计数是否等同 `ScientificNotationNode` | 用 `toStringAsExponential` 一类格式 |
| 性能剖析（CPU/GPU/内存） | 未跑 profiler，见 §12 |
| Home 入口与横屏真机 | BAN 未注册 HomeScreen；无真窗口截图 |

---

## 10. 测试结果

| 命令 | 结果 |
|---|---|
| `flutter test test/chemistry/build_a_nucleus` | **244/244**（原 241 + FINAL-1 视口/生命周期/双箭头 3） |
| `flutter analyze lib/chemistry/build_a_nucleus test/chemistry/build_a_nucleus` | No issues found |

行为回归（**自动化，非手工点玩官网**）：

| 场景 | 覆盖 | 标记 |
|---|---|---|
| Generator 箭头 → fly-in → settle | screen / flyin / state 测试 | [行为一致] |
| 双箭头 addPair | FINAL-1 新测：空核 → 1p1n | [行为一致] |
| Drag tray / 核内 / rollback | drag / tray / reset-undo widget | [行为一致] |
| α β- β+ n p | decay animation + controller | [行为一致] |
| β 换型 → 0.5s 色 → 发射 | beta_color 测试 | [行为一致] |
| Be-6 全路径 | be6_alpha 测试 | [行为一致] |
| invalid → 1s → rollback | state / controller tick | [行为一致] |
| Reset → 0p0n（含动画中） | reset_undo | [行为一致] |
| Undo 语义 | reset_undo（含有意差异） | [行为一致] 在已确认语义内 |

与本功能无关的既有问题（**未修**）：

- `test/forces/forces_scenario_test.dart` 单独运行会挂起（notes 1A）。未跑全仓 `flutter test`。

---

## 11. 生命周期验证

证据：`build_a_nucleus_final_viewport_test.dart`「进入→退出→再进入 ×5」。

每次：泵 `BuildANucleusScreen` → 打开 Half-Life Timescale dialog → 整树换成 `SizedBox.shrink()`。

结果：dialog 不残留；canvas 卸掉。`SimulationClock.dispose()` 释放 Ticker；`HalfLifeInformationView.dispose` 会 `Navigator.pop` 开着的 dialog。

**未用**独立 `Timer` 做衰变（用 State 内 elapsed + clock dt）。指针动画是纯 Dart tween，跟 Widget `AnimationController` 无关。

不能从测试断言「无后台计算」或「无重复 Ticker」到进程级；只能断言卸屏后 Widget 树干净。[待确认] 真机/Windows 窗口多次进出。

---

## 12. 性能观察

未做 Timeline / DevTools 采样。

定性（[待确认] 非测量值）：

- `NucleusPainter.shouldRepaint` 恒为 true，clock 60fps 空核也在重绘。  
- 核子数量 Decay 上限很大时排布与渐变球绘制会变重；本期无压力测试。  
- 电子云为单圆径向渐变，开销应低于离散电子。

---

## 13. 实际总工时

`notes.md` 已登记的实际工时合计 **≈11.0 h**（1A–1G-3B-5 有表的阶段）。

下列阶段 **notes 未单独列表**，按会话规模估计，**不与 11.0 混成精确值**：

| 阶段 | 估计实际 |
|---|---|
| 原项目分析 + 工程映射（分析文档） | ≈1 h |
| 1F-2B-2 Be-6 | ≈0.8 h |
| 1G-1 Reset/Undo | ≈0.8 h |
| 1G-3B-6 电子云 | ≈1.2 h |
| FINAL-1 对照 / 生成器 UI / 报告 | ≈1.2 h |

**Decay 屏实际合计（登记 + 估计）≈ 16 h。**  
其中估计项标 [待确认]，不是工时系统记录。

---

## 14. 理论总工时

分析文档 §21 **Decay 屏小计约 78–86 h**（不含 Chart Intro 40–56 h）。

取中位 **82 h** 作分母。  
Widget/UI 在 notes 里又拆过一轮，与 §21 的 12h 有重叠，**不以 notes 拆分再加总**，以免双计。

---

## 15. Actual / Theory 比例

16 / 82 ≈ **0.20**（若只用已登记 11 h，则为 11/82 ≈ 0.13）。

这是 AI 辅助单日多阶段对照源码实现的结果，**不是**「理论估高了所以人可以 16h 做完」的证明。视觉像素对齐与 Chart Intro 仍在理论工时之外。

---

## 16. Chart Intro 是否作为二期

**是。** 本期明确不开始。

Chart Intro 含：核壳层能级、部分/放大核素图、衰变方程、周期表、幻数、全图 Dialog。上限 10p/12n，与 Decay 不是同一套 UI。分析文档 §21 单列 40–56 h。

---

## 17. 后续工作

1. **Chart Intro（二期）**  
2. **HomeScreen 注册** Decay 入口（分析文档步骤 7；现只能测里注入 Screen）  
3. 若要视觉更近：在不改 NineGrid 合同的前提下微调字号/面板底色；或单独讨论是否允许 Decay 屏例外布局  
4. 真机/Windows 窗口截图与 PhET 在线版对照（§9）  
5. 可选：空闲时降低 Painter 重绘频率（需测量后再动）  
6. 不顺手修 `forces_scenario_test` 挂起  

---

*FINAL-1 结束。未开始 Chart Intro。*
