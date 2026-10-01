# Build a Nucleus · 一期完成报告

> 需求：`req-build-a-nucleus`  
> 阶段：FINAL-VISUAL-REMEASURE（只测不改）  
> 日期：2026-08-31  
> 诚实标记：`[源码一致]` / `[行为一致]` / `[视觉已对齐]` / `[视觉近似]` / `[有意差异]` / `[待确认]`

**结论：**  
Build a Nucleus 的 Decay Screen 与 Chart Intro Screen 已完成一期 Flutter 移植；核心模型、状态转换和主要交互行为均依据原 PhET 源码实现。视觉层已走完 P0–P5-2，并完成最终只读复测：

- Decay **主锚点已对齐**（nucleus X、generator X/bottom、Element/Stability X、play 映射、字号、play 底白、局部 Path）。
- Decay **整页观感**仍由 NineGrid + chrome + 字体决定，不是像素级复刻。
- Chart Intro **源码几何已验**；无原版 PNG，不伪造叠图。
- MUST FIX **1 项**（方程 `minHeight` 写成固定高）。本阶段未修。

最新复测：`visual-qa/FINAL_VISUAL_REMEASURE.md`。

**禁止读成：** 「与 PhET 一模一样」或「100% 复刻」。

对照底稿：`BUILD_A_NUCLEUS_FINAL_REPORT.md`（Decay FINAL-1）、`CHART_INTRO_ANALYSIS.md` §21（Chart Intro 视觉）。本文件覆盖两屏一期收口。

---

## 1. 项目范围

| 项 | 内容 |
|---|---|
| 原版 | PhET `build-a-nucleus`（HTML5 / TypeScript，非 Java 遗留） |
| 工程 | `lib/chemistry/build_a_nucleus/` · 包名 `kratos` |
| 本期屏 | Decay + Chart Intro |
| 入口 | Home「化学 → 原子核 → 构建原子核」→ `BuildANucleusHome`（Tab：衰变 \| Chart Intro） |
| 不做 | joist 多语言 / PDOM / 键盘帮助全文；Magic Numbers checkbox；Energy 轴字与虚线；Forces 挂起修复 |

数据：shred ENSDF 2022 → `assets/data/nuclide_table.json`。上限 Decay **94p / 146n**；Chart Intro **10p / 12n**。[源码一致]

---

## 2. Decay Screen 完成功能

| 功能 | 标记 | 证据 |
|---|---|---|
| 质子 / 中子生成器 | [行为一致] 排法；[视觉近似] Material | footer `_CreatorNode` |
| 箭头加减 | [源码一致] enable 规则 | `NucleonCreatorsNode` ↔ State |
| 生成器拖出 | [行为一致] | `startTrayDrag` / tray 测试 |
| 核内再拖 | [源码一致] 捕获半径 100 | `endNucleonDrop` |
| 圆形核排布 | [源码一致] 公式；[视觉近似] 像素 | `NucleusLayout` |
| 核素查表 | [源码一致] | `NuclideRepository` |
| 无效核素展示 | [行为一致] | does not form |
| 无效 1s 回退 | [源码一致] | `TIME_TO_SHOW_DOES_NOT_EXIST` |
| α / β− / β+ / n / p | [源码一致] 计数变化 | `applyDecay` |
| β 换色 0.5s | [源码一致] | `betaColorAnimationTime` |
| Be-6 特例 | [源码一致] | `build_a_nucleus_be6_alpha_test.dart` |
| Undo | [行为一致]（见 §13 有意差异） | 1G-1 矩阵 |
| Reset | [源码一致] 清到 0p0n | `BANModel.reset` 语义 |
| 半衰期数轴 / 指针 | [源码一致] 映射；[视觉近似] 箭头 Path | Half-Life 测试簇 |
| less / more stable | [行为一致] | legend |
| Half-Life info dialog | [行为一致]；dispose 关 Dialog [有意差异] | viewport ×5 |
| 电子云 + checkbox | [源码一致] 半径公式；[有意差异] 落位 | `ElectronCloudReading` |
| 生命周期 | [行为一致] 卸树干净 | FINAL-1 viewport |

---

## 3. Chart Intro 完成功能

| 功能 | 标记 | 证据 |
|---|---|---|
| p/n 箭头 | [行为一致]；无生成器拖 / 无双箭 [有意差异] | `ChartIntroNucleonControls` |
| ShellModelNucleus | [源码一致] 座位 / 绑定 / n2=6 | `shell_layout_test` |
| Nuclear Chart | [源码一致] 18/30/10、稀疏格 | `nuclide_chart_render_test` |
| 同位素符号 | [源码一致] 几何；[视觉近似] 字体 | `chart_intro_symbol_test` |
| 周期表 90 格 | [源码一致] 高亮只看 Z | `periodic_table_*_test` |
| Zoom / Focused | [源码一致] 5×5、窗外 0.65、夹紧 | `chart_zoom_focus_test` |
| 壳层 fade 1s | [源码一致] LINEAR | `shell_fade_test` |
| α / β 壳层 fade | [行为一致] 非 Decay 飞出 | `chart_intro_decay_fade_test` |
| Decay Equation | [行为一致] 仅 Zoom、`availableDecays[0]`、不可点 | `decay_equation_test` |
| Decay + Undo | [行为一致] 非五键 | 同上 |
| Full Chart | [源码一致] 静态 PNG 481.5 | `full_chart_dialog_test` |
| Dialog 生命周期 | [行为一致] Reset 不关；dispose 关 [有意差异] | viewport / 2I-2 ×5 |
| Reset | [行为一致] 0p0n + partial | interact / zoom 测试 |
| Tab / Home | [有意差异] 无 KeepAlive | `build_a_nucleus_home_nav_test` |

未做：Magic Numbers、Accordion 折叠、Energy 标题、mini-atom 虚线（§13）。

---

## 4. Model / State / Controller / Render

```
assets/data/nuclide_table.json
        │ NuclideDataLoader
        ▼
NuclideRepository          ← 两屏共用，只查表
        ▲
        ├── BuildANucleusState + BuildANucleusController     Decay
        └── ChartIntroState + ChartIntroController           Chart Intro
                 │ 独立 SimulationClock / State.dispose
                 ▼
        BuildANucleusHome → KratosTabbedScreen
                 ├── BuildANucleusScreen（NineGrid）
                 └── ChartIntroScreen（NineGrid）
```

规则：Painter / Widget 不查 Repository 做衰变决策；Chart Intro 的 mini-atom **由壳层计数派生**，不复制原版双 `ParticleAtom` step（不复制 issue #220）。

2I-2 **未改** State / Controller / Repository / Decay / Home 业务。

---

## 5. 原 PhET → Flutter 映射

| PhET | Flutter |
|---|---|
| `DecayModel` + `BANModel` + `ParticleAtom` | `BuildANucleusState` |
| `ChartIntroModel` + `ShellModelNucleus` | `ChartIntroState` + `ShellModelNucleus` |
| `AtomInfoUtils` | `NuclideRepository` |
| `DecayScreenView` / `BANScreenView` | `BuildANucleusScreen` |
| `ChartIntroScreenView` | `ChartIntroScreen` |
| joist 双 Screen 常驻 | `KratosTabbedScreen`（切走 dispose） |
| `NuclideChartAccordionBox` | `ChartIntroChartPanel`（不可折叠） |
| `FullChartTextButton` + PNG | `FullChartButton` + `Image.asset` |
| `PeriodicTableAndIsotopeSymbol` | `PeriodicTableAndSymbolView` |
| `HalfLifeInformationNode` | `HalfLifeInformationView` |
| `NineGridLayout` | 工程强制；原版绝对坐标 |

---

## 6. Assets

| 资源 | 路径 | pubspec | 运行时？ |
|---|---|---|---|
| 核素表 | `assets/data/nuclide_table.json` | `assets/data/` | 是 |
| Full Chart PNG | `assets/images/full_nuclide_chart.png`（335284 bytes，1948×1367） | `assets/images/` + 显式一行 | 是 |
| Schema | `schemas/nuclide_table.schema.json` | 否 | 文档 |
| 参考 TS | `requirements/.../reference/` | 否 | **不是** Flutter asset |
| SVG / JPEG / 音效 | BAN 未使用 | 工程其它 sim 用 | BAN 程序绘制核子与云 |

版权：`fullNuclideChart.png` — Copyright 2023 energyeducation.ca；联系 phethelp@colorado.edu。

---

## 7. 动画参数

| 项 | 值 | 标记 |
|---|---|---|
| 箭头飞入 | 距离 / **0.6 s** | [源码一致] |
| 回栈 / 衰变飞出 | **300 px/s** | [源码一致] |
| 卡位 settle | **200 px/s** | [源码一致] |
| β 换色 | **0.5 s** 线性 | [源码一致] |
| 无效回退 | **1 s** | [源码一致] |
| 半衰期指针 X | **0.7 s** quadratic | [源码一致] |
| 指针旋转 | **0.1 s** | [源码一致] |
| Be-6 再射 | α 飞满 `1s × 300` 后 | [源码一致] |
| 壳层 fade | **1 s** LINEAR | [源码一致] Chart Intro |
| 电子云 / 核素图高亮 | 无缓动 | [源码一致] |
| 计数 0.1s 淡入 | 未做 | [有意差异] |

---

## 8. 测试结果

本阶段未发现需改业务的行为错误。新增 1 条 Chart Intro 进/出 ×5 生命周期测试。

| 命令 | 结果 |
|---|---|
| `flutter analyze lib/chemistry/build_a_nucleus test/chemistry/build_a_nucleus` | **No issues found** |
| `flutter test test/chemistry/build_a_nucleus` | **407/407** |

### Decay 行为回归（自动化）

| 场景 | 覆盖 | 标记 |
|---|---|---|
| 0p0n / H-1 / H-3 / C-14 / Be-8 / Be-6 | state / nuclide / be6 / half-life | [行为一致] |
| Unknown 半衰期（H-4） | `nuclide_status_test` | [行为一致] |
| nonexistent + 1s rollback | state / controller tick | [行为一致] |
| stable | H-1 / N-14 等 | [行为一致] |
| generator add/remove / addPair | screen / FINAL-1 | [行为一致] |
| drag in / out | drag / tray | [行为一致] |
| 多指针托盘拖 | tray 同时多 `startTrayDrag` | [行为一致] |
| Reset during drag / incoming / outgoing / β 色 / invalid / Be-6 | `reset_undo` + be6 | [行为一致] |
| 飞入 0.6s / 回 300 / settle 200 / β 0.5s / 指针 / outgoing | flyin / decay / beta / pointer | [源码一致] 参数 |

### Chart Intro 行为回归（自动化）

| 场景 | 覆盖 | 标记 |
|---|---|---|
| 0p0n / 1p0n / 1p1n / 6p6n / 6p8n / 2p0n / 上限 10/12 | state / zoom / equation | [行为一致] |
| Partial / Zoom / Focused / 5×5 / 不存在 retain focus | `chart_zoom_focus_test` | [源码一致] |
| 周期表 H He C Ne；Z>10 仍画不高亮；2p0n 仍 He | periodic tests | [源码一致] |
| 符号 A/Z/符号；0p0n `-`；无效仍跟 Z | symbol tests | [源码一致] |
| 方程 Stable / α / β− / hidden；仅 Zoom | `decay_equation_test` | [行为一致] |
| β+ / p / n 方程 | Render 按 `availableDecays[0]`；类型枚举已覆盖数据层 | [行为一致] |
| Full Chart 开/关/不改 state/Reset 仍开 | `full_chart_dialog_test` | [行为一致] |
| 卸树关 Dialog；Tab 可切 | viewport 2I-1/2I-2 | [有意差异] 实现 |

方程 β+ / p / n 的 **Widget 金句**少于 α / β−，但同一 `DecayEquationRender` + Repository 排序。[待确认] 未为每种衰变各写一条 Widget 文案断言。

---

## 9. 生命周期

| 路径 | 测试 | 结果 |
|---|---|---|
| Decay 进入 → 开 Half-Life Dialog → 卸树 ×5 | `build_a_nucleus_final_viewport_test` | Dialog / canvas 不残留 |
| Chart Intro 进入 → fade → Full Chart → 卸树 ×5 | `chart_intro_viewport_test` 2I-2 | Dialog 无残留；卸树后 fade 不再推进 |
| Home → Tab 切换 → 返回 → 再进 | `build_a_nucleus_home_nav_test` | 默认 Decay Tab；新实例 0p0n |
| Clock | 每屏独立；`State.dispose` pause+dispose | 无跨屏共享 Clock |

未使用独立 `Timer` 做衰变（State elapsed + clock dt）。指针为纯 Dart tween。

不能从测试断言到进程级「无重复 Ticker / 无泄漏」。[待确认] 真机多次进出与 DevTools 内存。

---

## 10. 构建结果

| 构建 | 结果 | 分类 |
|---|---|---|
| Android **debug** APK | 成功 `build/app/outputs/flutter-apk/app-debug.apk` | — |
| Android **release** | **失败** | **[已有工程问题]** |

Release 失败点：`GeneratedPluginRegistrant` 注册 `integration_test`，release 编译找不到 `dev.flutter.plugins.integration_test`。`integration_test` 在 `pubspec.yaml` 的 `dev_dependencies`。与 BAN 业务无关。**未改** pubspec / Android 工程来绕过。

Kotlin Gradle Plugin 迁移警告：Flutter 未来版本提示，[已有工程问题]。

---

## 11. 全仓测试

**Build a Nucleus 专项测试：通过（407/407）。**

排除 `test/forces/forces_scenario_test.dart` 后：`flutter test` 选定目录 **664 passed + 1 skipped**。

`flutter test test/forces/forces_scenario_test.dart`：加载后在后续用例挂起（本机等待 90s 后终止）。与 notes 1A 既有问题一致。**未改 Forces。**

**全仓测试：由于既有 Forces 挂起，无法完整结束。**  
不要声称全仓测试通过。

---

## 12. 视觉差异（复测后）

分类与矩阵见 `visual-qa/FINAL_VISUAL_REMEASURE.md`。摘要：

- **已对齐：** Decay 核 X、生成器 X/bottom、Element/Stability X、play 底 `#FFFFFF`、字号、核子/云渐变配方、P5-2 局部 Path（方程头 10×10、Close 18.2、less/more 填黑、生成器白底黑边+三角、Zoom `arrowSymbol`）。
- **ACCEPT：** NineGrid 边格、AppBar+Tab vs joist、Material Reset/Undo/Checkbox/Radio 文字、font family、Chart Intro 无 Magic / Energy / 双箭。
- **MUST FIX（未修）：** Chart Intro 方程 `height: 30` 对 A/Z 列 overflow。
- **UNCONFIRMED：** 无原版 Chart Intro 截图；disabled decay 灰化；Full Chart Dialog 底。

详见 `BUILD_A_NUCLEUS_FINAL_REPORT.md` §6、`CHART_INTRO_ANALYSIS.md` §21.4。

---

## 13. 有意差异

1. **NineGrid**（中心 ≥70%）vs 原版 1024×618 绝对坐标；不声称像素级一致  
2. **Tab 无 KeepAlive**：切走 dispose；原版 Screen 常驻  
3. Dialog 在 Tab dispose 时关闭（barrier 盖住 TabBar）  
4. 计数 / 生成器 **中文**「质子 / 中子」  
5. Chart Intro **无**生成器拖拽、**无**双箭头  
6. **无** Magic Numbers、Energy 轴字、Nuclear Shell Model 标题、mini-atom 虚线  
7. Full Chart 与 Radio **同行**（原版在 Magic 下方）  
8. 手风琴 **不可折叠**  
9. 不复制原版 Undo / listener dispose / issue #220  
10. ∞ 用字符；符号盒不配 Decay Accordion 折叠  

---

## 14. [待确认]

| 项 | 说明 |
|---|---|
| Chart Intro 与官网 HTML5 截图叠图 | 无原版 PNG，未做、不伪造 |
| Chart Intro Be-6 α 可观察结果 | 无 Hollywood；1s 纠正是否与原版 Chart 屏一致 |
| 方程 β+ / p / n 的独立 Widget 金句 | 数据层有，UI 断言少 |
| 中文本地化是否改为全英 | |
| PhetFont 文件 | 未接入 |
| 真机 / 性能剖析 | 未跑 profiler |
| `protonsLevelProperty` vs issue #8749 | 绑定条件细节 |
| Chart Intro 2A–2H-2 实际工时 | notes 未系统登记 |

未为了「报告好看」删掉待确认项。

---

## 15. 已知问题

| 问题 | 归属 |
|---|---|
| `forces_scenario_test.dart` 挂起 | 既有，非 BAN |
| Android release + `integration_test` 插件 | 既有工程 |
| `NucleusPainter.shouldRepaint == true`，空核也 60fps 重绘 | Decay 定性，未测 |
| 原版 Full Chart 外链曾报 Broken | 本实现只展示 URL 文本 |

---

## 16. 主页入口

`lib/screens/home_screen.dart`：学科化学 →「构建原子核」→ `BuildANucleusHome`。

Tab 文案：`衰变` | `Chart Intro`。默认第一屏 Decay。[已确认] 原版 `new Sim(..., [Decay, ChartIntro])`。

---

## 17–19. 工时

**阶段工时累计 ≠ 墙钟总工时。** 重叠会话窗口不得相加当日历时间。

### 理论

| 来源 | 小时 | 备注 |
|---|---|---|
| `BUILD_A_NUCLEUS_ANALYSIS.md` §21 Decay | **78–86** | 中位 82；含探索任务上浮 |
| `CHART_INTRO_ANALYSIS.md` §18 | **64.5** | 比早期 40–56 更细；**不与 40–56 再加** |
| 两屏合计（82 + 64.5） | **≈146.5** | 分析文档早期全量 118–142 用了较低 Chart 估计 |

探索任务（理论，已含在上表）：数据表 8、Decay Painter 8、壳层 8、核素图 8、周期表 6。

### 实际（notes 登记，可加总）

Decay 有表阶段（1A–1G-3B-5 + FINAL-1）：

0.5+1+0.7+0.7+0.5+0.7+0.6+0.7+0.5+1.5+0.7+0.6+0.5+0.6+0.8+0.4+1.2 = **12.2 h**

FINAL-1 报告另列、notes 无独立表（分析 / Be-6 / 1G-1 / 电子云）约 **+3.8 h** → Decay 合计约 **16 h**（估计项 [待确认]）。

Chart Intro notes **仅 2I-1 有文字、无工时表**。近期会话可引用：

| 阶段 | 实际 | 来源 |
|---|---|---|
| 2H-3 Full Chart | ≈2 h | 会话报告 |
| 2I-1 视觉对齐 | ≈2.5 h | 会话报告 |
| 2I-2 回归 + 本报告 | ≈1.5 h | 本阶段 |
| 2A–2H-2 | — | **notes 未登记** [待确认] |

Chart Intro **已登记/可引用小计 ≈6 h**，不是全屏实际。

### 比例

| 口径 | 实际 / 理论 |
|---|---|
| Decay 登记 12.2 / 82 | ≈ **0.15** |
| Decay 含估计 16 / 82 | ≈ **0.20** |
| Chart 可引用 6 / 64.5 | ≈ **0.09**（分母全屏、分子不全，**不能**当完成效率） |
| 两屏精确总比 | **无法计算**（Chart 中段缺表） |

这是 AI 辅助对照源码实现的结果，**不是**「人可以按该比例排期」的证明。

### 墙钟

- Decay 主要墙钟：**2026-08-28** 一日多阶段（notes 时间戳）  
- Chart Intro 收尾墙钟：**2026-08-31**  
两日并行阶段小时之和 **大于** 两日日历小时；勿把 16+6 当成 22 小时连续劳动。

---

## 20. 后续工作

视觉复测已结束。**不要**再开无证据的优化轮次。

若用户明确要求 FINAL-FIX：只修 MUST FIX（方程 `minHeight` 误写成固定 `height`）。不要顺手改 NineGrid / Theme / Reset / Radio。

其余：

1. 不在本期开新的 Chart Intro 功能（Magic Numbers、Energy 轴、虚线等）  
2. Chart Intro 像素对照需要原版 1024×672 截图后另立阶段  
3. 工程：Android release / `integration_test`；`forces_scenario_test` 挂起 — **独立立项**

---

## A–E 分类总表

### A. [源码一致]

核素表与查表；Decay 上限与捕获半径；飞入/飞出/settle/β/回退/Be-6/指针时长；壳层几何与 fade 1s；格子 18/30/10 与 Focused 0.65；周期表 90 格与符号盒几何；Full Chart PNG 与 481.5。

### B. [行为一致]

生成器与拖拽可观察结果；五衰变计数；Undo/Reset 已测矩阵；Chart 图/方程/Radio/Tab 再进入空核；Full Chart 不改 chart state。

### C. [视觉近似]

字体、Material 皮肤、自绘球/箭头、紧凑衰变键、手风琴铬。

### D. [有意差异]

NineGrid；Tab dispose；中文计数；Chart 无拖核/无 Magic/无 Energy 虚线；Dialog 卸树关闭；不复制 #220。

### E. [待确认]

§14 表。保留。

---

---

## Visual QA

完整复测：`visual-qa/FINAL_VISUAL_REMEASURE.md`（2026-08-31，**0 个实现修改**）。

已完成阶段：P0 主坐标 → P2 布局 → P3 Typography → P4 Color/Gradient → P5-1 取证 → P5-2 局部 Path → **FINAL-VISUAL-REMEASURE**。

### 验证环境

| 端 | 视口 | DPR | 状态 |
|---|---|---|---|
| 原版 Decay | 1024×672（play 1024×618） | 1 | Fe-69 |
| Flutter Decay | Pixel Tablet · 1280×800 逻辑 · 2560×1600 物理 | 2.0 | 空核 + Fe-69 |
| Flutter Chart Intro | 1280×800 独立 Screen | 1.0 | C-12 Partial / Zoom / Dialog |

归一化：`sx=0.8`，`sy=618/692`，chrome 108。Chart Intro **无原版 PNG，不伪造叠图**。

### 复测摘要

| 桶 | 内容 |
|---|---|
| 已对齐 | Decay 核 X、生成器 X/bottom、Element/Stability X、play 底白、字号、渐变配方、P5-2 Path |
| ACCEPT | NineGrid、Material、font family、Tab dispose |
| MUST FIX | Chart Intro 方程固定 `height: 30`（A/Z 列 32.25）— **未修** |
| UNCONFIRMED | Chart Intro 像素、Focused 整页、disabled 灰化、Dialog 底 |

mean \|ΔRGB\|（复测）：全画幅空核 **46.44** · Fe-69 **49.43** · Play Fe-69 **31.90**。数字只辅助，不是成功标准。主因是 chrome + NineGrid，不是未对齐的主锚点。

P5-2 副作用：generator 仍 418×55 / 28×24 / 42×24。无 overflow。视口 640×360 / 1024×768 / 1280×800 通过。测试 **407/407**。

**不要**重开 nucleus X/Y、generator X/bottom、Element/Stability X。

---

*FINAL-VISUAL-REMEASURE 结束。停止，不改实现。*
