# Kratos 仿真实验室 · 项目完整需求与技术总览

> 整理日期: 2026-08-18（含做中学阶段转换交互 § 十）
> 数据来源: `requirements/<req-id>/`（meta.yaml / spec / 最终需求）· `docs/knowledge/` 知识库 · `docs/reviews/` 交互问题汇总 · `lib/` 源码
> 本文件是**跨需求、跨模块的项目级需求与技术索引**，非单一需求产物。单一需求的完整细节见对应 `requirements/<req-id>/`。
> 做中学阶段转换交互的完整设计见 § 十；6 项历史修复（A 类）见 `docs/reviews/interaction-issues-2026-08.md`。

---

## 一、项目概述

**kratos-java-simulations** 是把 PhET Java 科学模拟逐批复刻到 Flutter 的现代化交互模拟平台。

| 项 | 值 |
|---|---|
| 项目代号 | kratos-java-simulations（Flutter Port） |
| 代码工程 | `c:\workspace\kratosLab`（Flutter · Git 管理） |
| 技术栈 | Flutter / Dart（SDK `^3.11.1`）· 原生 `CustomPainter` 渲染 |
| 第三方依赖 | 极简：`flutter_svg` / `audioplayers` / `cupertino_icons`（零重型引擎） |
| 运行目标 | Web / Android / iOS / Windows / macOS / Linux（强制横屏） |
| 完成 sim 数 | **8 个**（光学 / 电路 / 力学 / 色觉 / 声波 / 电磁波 / 波的干涉 / 摩尔浓度） |
| 知识库 | `docs/knowledge/kratos/`（工程）+ `docs/knowledge/kratos-java-simulations/`（PhET 蓝本） |

**项目定位**：面向初中—高中物理 / 化学教学的交互式仿真实验合集（"Kratos 仿真实验室"），主界面按**物理 / 化学**两大学科卡片化分组展示。

---

## 二、项目四原则（架构主线）

所有 sim 模块必须遵守的四条统一设计原则（详见 `docs/knowledge/kratos/architecture/design-patterns.md`）：

### 1. MVC 分层
- **Model**：不可变状态对象（`@immutable` + `copyWith` + Sentinel 模式）
- **Solver**：纯函数 `solve(state) → result`，无副作用、不持有状态
- **View**：只读 Model/Solver 结果做 `CustomPainter` 绘制 + 手势交互
- **Controller**：场景编排（加载 JSON → 建 Model → 校验约束 → 判目标）

### 2. 组件化
- 一元件一 Painter，禁止 God Painter
- 光学用抽象基类 + 模板方法（`OpticalElement`）；电路用枚举 + 数据类
- 新增元件只需加枚举/子类 + `ScenarioManager` switch case

### 3. 通用化（L0/L1/L2 三层 + 3-Time Rule）
- **L0**：`lib/common/` 已有通用组件（见 §五），复用强制
- **L1**：待抽象候选（≥2 使用者证据才抽）
- **L2**：模块专属（solver / 域特化模型 / 渲染细节 / 场景 schema 不抽象）
- **3-Time Rule**：第 1 个 sim 自建 + 登记；第 2 个相似 ≥70% 改造为公共版；第 3 个强制上抽

### 4. 配置化（JSON Scenario + AI 可生成化）
- **§C1** 模块启动路径：所有 Screen 走 ScenarioManager 加载 JSON，禁止硬编码初始化
- **§C2** 元件规格来源：defaultValue/min/max/step 优先从 scenario JSON 读取
- **§C3** AI 可生成性：每模块提供 `docs/prompts/<module>_scenario.md` + `schemas/<module>_scenario.schema.json` + ≥3 个样本
- **§C4** 豁免流程：未合规模块须登记豁免（当前全部模块合规）

---

## 三、功能模块总览（8 个 sim）

### 3.1 三大原始模块（复刻自 PhET Java）

| 模块 | 入口 | 物理域 | 核心能力 |
|---|---|---|---|
| **几何光学** | `OpticsScreen` | 几何光学 | 透镜/平面镜/凹面镜成像 · 光线追迹（`OpticalSolver` 二光线法）· 场景化教学 |
| **电路搭建** | `CircuitScreen` | 电学 | 拖拽搭建电路 · 图论求解通电状态与灯泡亮度（`CircuitSolver`）· 导线折线编辑 |
| **力与运动** | `ForcesHome` | 力学 | 1D 牛顿力学（`ForcesSimulation`）· 4 模式：合力 / 运动 / 摩擦 / 加速度 |

### 3.2 四新波动 sim（复刻自 PhET Java · EDD v2.0 全流程）

| 模块 | 入口 | 物理域 | 核心能力 | 蓝本规模 |
|---|---|---|---|---|
| **色觉** | `ColorVisionHome` | 光学·色觉 | 双子屏：RGB 三色加色合成 + 单光源滤光片 · 光子/光束双表征 · 挑战模式 | 33 Java 文件 |
| **声波** | `SoundScreen` | 声波 | 5 子屏：单源聆听 / 测量 / 真空盒 / 双源干涉 / 反射墙 · 波前传播 | 111 文件 |
| **电磁波** | `RadioWavesScreen` | 电磁波 | 天线电子振荡 → EM 场辐射 → 接收电子感应 · 场/波双视图 | 57 文件 |
| **波的干涉** | `WaveInterferenceScreen` | 通用波动 | 3 子屏：水波 / 声波 / 光波 · Lattice2D 波场演化 · 单/双缝衍射干涉 | 196 文件 |

### 3.3 化学模块首个

| 模块 | 入口 | 物理域 | 核心能力 |
|---|---|---|---|
| **摩尔浓度** | `MolarityScreen` | 化学·溶液 | 9 溶质数据 JSON 驱动 · 浓度/沉淀双 Derived 公式 · 3D 烧杯 + 渐变浓度条 · 饱和挑战场景 |

---

## 四、完整需求清单（13 项）

> 状态字段：`done` = 已验收完成 · `in_progress` = 进行中 · `phase` 为 SOP 阶段号。

### 4.1 已完成（8 项）

| # | 需求 ID | 标题 | 性质 | 完成日期 |
|---|---|---|---|---|
| 1 | `req-nine-grid-layout` | 9宫格强制屏幕适配方案（中间格面积 ≥70% · 周边 8 格贴边 · 全部 7 sim 强制迁移） | 通用布局基础设施 | 2026-08-07 |
| 2 | `req-inquiry-learning` | 从"可视化可操作"到"做中学"——探究工作流整体升级（通用组件 + 2 pilot sim） | 交互层升级 | 2026-08-07 |
| 3 | `req-inquiry-extend` | 做中学探究工作流推广——optics/forces/sound/radio_waves/wave_interference 5 sim 接入 | 推广接线 | 2026-08-07 |
| 4 | `req-inquiry-chart-extend` | 记录数据图表化推广——7 sim 图表适配确认 + snapshotColumns 校验 + 全量回归 | 推广接线 | 2026-08-10 |
| 5 | `req-port-molarity` | molarity 摩尔浓度 sim 复刻——Flutter 化学模块首个（24 文件最小蓝本） | 新 sim 复刻 | 2026-08-11 |
| 6 | `req-ui-interaction-polish` | 主界面交互优化与实验引导通用化——学科编排 + ExperimentIntroPanel + 操作面板统一布局试点 | UI 交互优化 | 2026-08-11 |
| 7 | `req-panel-bottom-migrate` | 操作面板底部横排推广——其余 8 屏底部迁移 | UI 布局推广 | 2026-08-12 |
| 8 | `req-home-screen-overflow-fix` | 修复 HomeScreen → ColorVisionHome 导航链 1600×900 视口 overflow 49px | 布局债务修复 | 2026-08-11 |

### 4.2 进行中（5 项）

| # | 需求 ID | 标题 | 当前阶段 | 关键内容 |
|---|---|---|---|---|
| 9 | `req-ai-scenario-toolchain-lite` | AI 场景生成工具链闭环（A 任务） | phase 2.requirement | Schema+Dart 语义校验 / 自动落盘+manifest 更新 / DeepSeek OpenAI 兼容 API 模型名可配置。脚手架 `scripts/ai_scenario_gen/` 已实测跑通 |
| 10 | `req-color-vision-layout-fix` | 修复 color_vision single_bulb 屏窄视口下主图消失（L0-2/L0-3 违规） | phase 3.iteration | 由 req-verify-selftest-color-vision 衍生发现的布局回归 |
| 11 | `req-inquiry-chart-poc` | 记录数据图表化 POC——SnapshotChart 公共组件 + ExperimentLogger 数据暴露 + circuit 单 sim 验证 | phase 4.closing | POC 已通过（57/57 + No issues），推广已由 extend 承接 |
| 12 | `req-predictive-inquiry` | 探究预测题（猜测→验证）功能——InquiryTask.predictions + PredictionPanel + circuit/molarity 试点 | phase 3.iteration | 已实现：InquiryPrediction 模型 + PredictionPanel + InquiryDrawer 集成；circuit 2 题 / molarity 3 题 |
| 13 | `req-verify-selftest-color-vision` | 验证 agile-vibe v0.2.1 第 9 条 AI 自主功能测试闭环（靶子 = color_vision sim） | phase 3.iteration | 元验证需求 · 不产出业务代码 |

---

## 五、技术基础设施（L0 通用组件 · `lib/common/`）

### 5.1 控件族（`lib/common/controls/`）

| 组件 | 用途 |
|---|---|
| `kratos_slider.dart` | 通用滑块（支持 compact 紧凑模式 / vertical 垂直） |
| `kratos_combo_box.dart` | 通用下拉框 |
| `kratos_radio_group.dart` | 通用单选组 |
| `kratos_number_field.dart` | 数值输入框 |
| `spectrum_slider.dart` | 光谱波长选择滑块 |
| `arrow_painter.dart` / `game_timer.dart` | 箭头绘制 / 游戏计时 |

### 5.2 图表族（`lib/common/chart/`）

| 组件 | 用途 |
|---|---|
| `kratos_chart.dart` / `chart_painter.dart` / `chart_series.dart` / `graph_suite.dart` | 通用图表（力学等模块曲线） |
| `snapshot_chart.dart` | 实验记录快照散点关系图（零 sim 依赖 · 默认选轴：x=第一个 param 列 · y=第一个 reading 列） |

### 5.3 通用组件（`lib/common/widgets/`）

| 组件 | 用途 |
|---|---|
| `nine_grid_layout.dart` | **九宫格强制布局**（中间格面积 ≥70% · 8 边格贴边 · footer 底部操作条） |
| `drag_drop_workspace.dart` | 泛型拖拽工作区（`DragDropWorkspace<T>` · optics/circuit 复用） |
| `property_control_panel.dart` | 参数面板（`fromScenarioParams` 场景驱动生成） |
| `time_control_bar.dart` / `simulation_clock.dart` | 播放/暂停/步进 + 时间轴 |
| `scenario_menu_button.dart` | 场景切换菜单（3 sim 复用上抽） |
| `kratos_tab_bar.dart` / `game_scoreboard.dart` / `game_over_dialog.dart` / `celebration_dialog.dart` | Tab 栏 / 计分板 / 结算 / 达成庆祝 |
| `knowledge_panel.dart` | 知识点面板 |
| `experiment_intro_panel.dart` | 实验引导（常驻一行说明 + 点击弹 Dialog · 10 屏接入） |

### 5.4 做中学探究组件族（`lib/common/widgets/` · 7 sim 全量接入）

| 组件 | 用途 |
|---|---|
| `inquiry_models.dart` | 纯数据模型（`InquiryTask` / `InquiryStep` / `InquirySnapshotColumn` / `InquiryPrediction`） |
| `inquiry_task_panel.dart` | 探究任务卡（task==null 不渲染） |
| `experiment_logger.dart` | 实验记录器（maxRows 20 · 记录/删除/清空 · `onRowsChanged` 可选回调） |
| `conclusion_panel.dart` | 结论归纳面板（两阶段状态机 · "结论先消失" · 提交后不可收回） |
| `inquiry_drawer.dart` | 探究抽屉容器（Offstage 常驻保 State · 右侧 280px · 含图表区块） |
| `prediction_panel.dart` | 预测题面板（选项式猜测 → 操作后对照判定 · req-predictive-inquiry） |

### 5.5 其他

| 路径 | 组件 |
|---|---|
| `lib/common/elements/position_element.dart` | `PositionElement<TType>` 位置元件基类（optics/circuit 共用） |
| `lib/common/scenario/scenario_manager_base.dart` | `ScenarioManagerBase<TScenario, TState>` 场景管理器基类 |
| `lib/common/widgets/kratos_tab_bar.dart` 等 | 见上 |

---

## 六、配置化体系（场景 JSON + AI 工具链）

### 6.1 场景资产分布（`assets/scenarios/`）

| 模块 | 场景目录 | 场景数 |
|---|---|---|
| optics | `assets/scenarios/optics/` | ≥3 |
| circuit | `assets/scenarios/circuit/` | ≥7 |
| forces | `assets/scenarios/forces/` | ≥5 |
| color-vision | `assets/scenarios/color-vision/` | ≥10 |
| sound / radio-waves / wave-interference / molarity | 各自目录 | 各 ≥4（含 manifest） |

### 6.2 AI 生成工具链（三模块全覆盖 · 7 sim 就绪）

| 资产 | 数量 | 说明 |
|---|---|---|
| `docs/prompts/<module>_scenario.md` | 8 | AI 生成 system prompt + few-shot 样本 |
| `schemas/<module>_scenario.schema.json` | 8 | JSON Schema 校验（draft-07） |
| `scripts/ai_scenario_gen/` | 1 套 | 生成/校验/落盘/更新 manifest 闭环（A 任务 · 进行中） |

---

## 七、屏幕适配标准（九宫格布局 · 阻塞级）

依据 `.codebuddy/rules/80-kratos-sim-checklist.mdc` §七，所有 sim 主屏幕必须满足：

| 条款 | 要求 |
|---|---|
| **L0-1** | 主图/舞台水平居中 · 禁止 `Positioned(left:)` 绝对定位 |
| **L0-2** | 响应式无溢出（320px~1920px 宽 · 480~1080px 高无横向滚动） |
| **L0-3** | 主图尺寸随视口缩放（LayoutBuilder / MediaQuery）· 禁止硬编码固定像素 |
| **L0-4** | **强制使用 `NineGridLayout`**（中间格面积 ≥70% · 中心格只放实验画面 · 禁止平行布局方案） |

**操作面板规范**：交互控件统一放**底部横排**（`NineGridLayout.footer` · 高 `min(96, 屏高×0.16)`）· 固定宽子控件在 320px 下必溢出，须改 `Expanded` 自适应。

---

## 八、测试与质量

| 项 | 基线 |
|---|---|
| 全量单元/组件测试 | 231/231 通过（除 forces 基线超时 1 · 非本需求） |
| 集成测试 | `integration_test/` 各 sim ≥2 场景冒烟 |
| 静态分析 | `flutter analyze` No issues（历史参考文档 error 非运行代码） |
| 性能 | 帧率 ≥60fps（纯响应式 / 粒子池化 / 静态渲染） |
| 可访问性 | 色觉 sim 色盲替代表征（文字标签 + 图案编码 + 数值显示）· 滑块 Semantics 播报 |

**已知遗留**：
- forces `netforce-tug` 测试死循环超时（独立任务）
- circuit AppBar 11 按钮在 320 屏溢出（待布局层方案）
- 探究工作流 Export / 分关挑战评估等为后续迭代

---

## 九、协作流程框架（SOP）

开发采用精简 3 阶段流程（`agile-vibe`）：

```
1. Intake（接收）→ 2. Build（建造 · Vibe Loop）→ 3. Close（收尾）
```

- **Close 阶段**串联 3 agent：`code-reviewer`（质量 + L0 复用 + 布局合规）→ `closer`（收尾文档 + commit）→ `knowledge-maintainer`（知识库回写）
- 新 sim 开工必须通过 `80-kratos-sim-checklist.mdc` 自检表（四原则 + L0 复用 + 布局 + EDD v2.0 12 章）
- 状态同步四件套：`meta.yaml` / `process.txt` / `INDEX.md` / `notes.md`

---

## 十、做中学阶段转换交互（Inquiry Workflow Stages）

> ICAP 框架（Chi & Wylie 2014）探究闭环：`猜测 → 任务 → 操作 → 记录 → 归纳`。
> 7 sim 全量接入（circuit/optics/forces/color_vision/sound/radio_waves/wave_interference/molarity）。
> 组件源码：`lib/common/widgets/{inquiry_drawer, prediction_panel, inquiry_task_panel, experiment_logger, conclusion_panel, experiment_intro_panel, inquiry_models}.dart`

### 10.1 阶段模型与组件映射

| 阶段 | 教学意图 | 载体组件 | 抽屉位置 |
|---|---|---|---|
| ① 猜测 | 操作前预测答案，建立认知冲突（"先猜后验"） | `PredictionPanel` | 顶部（有 predictions 时） |
| ② 任务 | 明确探究问题与分步指引 | `InquiryTaskPanel` | 第 2 位 |
| ③ 操作 | 在 sim 画布上动手实验 | 各 sim 画布（不在抽屉内） | — |
| ④ 记录 | 快照当前参数/读数，累积对比 | `ExperimentLogger` + `SnapshotChart` | 第 3/4 位 |
| ⑤ 归纳 | 先自主写结论，再对照参考结论 | `ConclusionPanel` | 第 5 位 |

**入口**：`ExperimentIntroPanel`（边格常驻一行 + 点击弹 Dialog）→ 弹窗含任务概览 +「去猜一猜」跳转按钮 → 打开 `InquiryDrawer`。

### 10.2 抽屉默认开合策略（§ A4 统一）

**统一规则**：`_inquiryOpen = scenario.inquiryTask != null`（有探究任务即默认展开，进入即见任务/预测题；无任务时抽屉自动不渲染）。

| sim 类别 | 行为 |
|---|---|
| circuit / molarity（有预测题） | 进入即展开 · 预测题置顶 |
| 其余 6 sim（有 inquiryTask 无预测题） | 进入即展开 · 任务卡可见 |
| 无 inquiryTask 的 scenario | 抽屉与入口按钮自动隐藏，无副作用 |

场景切换时按新场景的 `inquiryTask` 同步重置。

### 10.3 阶段进度条（§ A3 · 数据驱动）

抽屉顶部 `_ProgressBar` 3 节点（无预测题时降为 2 节点），**按数据自动点亮、无需手动点击**：

| 节点 | 点亮条件 | 数据回调 |
|---|---|---|
| 猜测 | 已验证题数 == 预测题总数 | `PredictionPanel.onVerifiedChanged(int)` |
| 记录 | 记录行数 ≥ 1 | `ExperimentLogger.onRowsChanged(rows)` |
| 归纳 | 结论已提交 | `ConclusionPanel.onSubmittedChanged(bool)` |

**视觉**：已完节点 = 蓝色实心圆 + check；进行中 = 空心蓝圈；未到 = 灰圈。

### 10.4 关键阶段转换交互

| 转换 | 机制 | 已修复 |
|---|---|---|
| 猜测 → 验证 | `PredictionPanel` 选项式 `onSelect`/`onVerify`；**改答案即重置验证状态**（`onSelect` 同步从 `_verified` 移除该题，强制重新验证） | A2 |
| 猜测 → 抽屉（弹窗入口） | `ExperimentIntroPanel` 弹窗内 PredictionPanel **改跳转入口**：有预测题时显示"去猜一猜"按钮，点击关闭弹窗并调 `onOpenInquiry` 打开抽屉。预测题统一在抽屉内做（单一入口，状态不共享） | A1 |
| 记录 → 图表联动 | `SnapshotChart` 实时消费 `_rows`（Offstage 保持 State） | — |
| 归纳 → 防抄 | `ConclusionPanel` 两阶段状态机：未提交时参考结论**不可见**（"结论先消失"），空文本有 SnackBar 防呆；提交后参考结论**不可收回** | — |
| 归纳 → 编辑防抄 | 点「修改结论」进入编辑态时**参考结论临时隐藏**，杜绝"边抄边改"；取消/更新按钮 | A5 |
| 抽屉 → 操作 | sim 画布在抽屉外独立（drawer 不遮挡实验操作） | — |
| 抽屉状态保持 | `Offstage(offstage: !open)` 常驻 widget 树，关闭再开不丢记录/结论 State | — |

### 10.5 完整用户路径

```
进入 sim（有 inquiryTask）
  → 抽屉默认展开 · 进度条：○猜测 ○记录 ○归纳
  → ① 预测题：选答案 → 验证 → 进度条"猜测"✓
  → ② 任务卡：读问题 + 分步
  → ③ 画布操作（SimulationClock play/pause/step）
  → ④ 点「记录本次实验」≥1 次 → 进度条"记录"✓ → 关系图出现
  → ⑤ 写结论 → 提交 → 进度条"归纳"✓ → 对照参考结论
  → 全部点亮 = 探究闭环完成
```

### 10.6 已完成修复（A 类 6 项 · 全部 done）

| # | 问题 | 修复 | Commit |
|---|---|---|---|
| A1 | 预测题状态不共享（弹窗 vs 抽屉双实例） | 弹窗移除内嵌预测题，改「去猜一猜」跳转，单一入口 | `d1d4c4c` |
| A2 | 验证后改答案判定结果不更新 | `onSelect` 重置 `_verified`，强制重新验证 | `9a43c8e` |
| A3 | 阶段切换无进度指示 | 抽屉顶部 3 节点进度条（数据驱动自动点亮） | `644923c` |
| A4 | `_inquiryOpen` 默认值割裂 | 8 sim 统一"有 inquiryTask 即默认展开" | `2788522` |
| A5 | 结论"修改"绕过防抄 | 编辑态隐藏参考结论 | `2788522` |
| A6 | 任务卡弹窗/抽屉冗余 | A1 方案 B 顺带解决（弹窗只留任务概览） | `d1d4c4c` |

**测试基线**：common 47 测试（含 prediction_panel 6 / conclusion_panel 6 / snapshot_chart 9 / intro_panel 2）全过；molarity 5；wave/radio 布局 7。详见 `docs/reviews/interaction-issues-2026-08.md`。

### 10.7 后续可优化（非阻塞）

- **导出**：`ExperimentLogger.onExport` 已留接口未实现（可导出 CSV）
- **进度持久化**：当前进度仅内存（session 级），关闭 App 丢失
- **预测题推广**：预测题目前仅 circuit/molarity 试点，其余 6 sim 无 predictions（进度条自动降为 2 节点）

---

*整理自 `requirements/` 13 项需求 + `docs/knowledge/` 知识库 + `docs/reviews/interaction-issues-2026-08.md` · 单一需求明细请查对应 `requirements/<req-id>/spec/`*
