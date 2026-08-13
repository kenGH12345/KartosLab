# kratos-java-simulations 知识库

> 本目录是 **PhET 官方 Java 版仿真源码库**的分析与索引。
> 定位：作为 [Flutter kratos 复刻项目](../kratos/INDEX.md) 的**参考蓝本 / 迁移源**。
> 创建时间: 2026-07-22 · 分析范围: A（顶层俯瞰）+ c1（复刻优先级打分）+ c3（Flutter 已复刻映射）

## 与 Flutter kartosos 项目的关系

本知识库**不是** [docs/knowledge/kkartoss/](../kratos/INDEX.md) 的一部分——两者是独立的项目知识库：

| 维度 | `docs/knowledge/kkartoss/` | `docs/knowledge/kartosos-java-simulations/`（本目录） |
|---|---|---|
| 对应工程 | `C:\workspace\kartososLab\` （Flutter/Dart） | `<PHET_JAVA_ROOT>\simulations-java\`（Java + Scala） |
| 上游 | 独立复刻 / 教学重构项目 | PhET 官方 SVN trunk（[kartos.colorado.edu](https://kartos.colorado.edu)） |
| 关系 | **复刻目标端** | **参考源端** |
| 知识形态 | 完整深度文档（52 Dart 文件级） | **顶层俯瞰 + 复刻规划辅助**（不深入代码级） |

**用途场景**（关系 c = 迁移/复刻规划）：

- 决定 Flutter 侧"下一个复刻哪个 sim" → 查 [shortlist-for-flutter-port.md](shortlist-for-flutter-port.md)
- 查 Flutter 已实现的三大模块对应 Java 源码在哪 → 查 [existing-flutter-map.md](existing-flutter-map.md)
- 想知道整体项目组织形态、技术栈、模块分布 → 查 [overview.md](overview.md)
- 想要 85 个 sim 的完整分学科清单 → 查 [module-catalog.md](module-catalog.md)

## 文档清单

| 文档 | 说明 | 状态 |
|---|---|---|
| [overview.md](overview.md) | 项目是什么 / SVN 源 / 技术栈 / 目录组织形态 / 关键事实证据 | ✅ Loop 1 |
| [module-catalog.md](module-catalog.md) | 81 个有效 sim 分 9 学科清单（Java 文件数 + 依赖标签 + 技术门槛 + ⭐ 教学价值） | ✅ Loop 2 |
| [existing-flutter-map.md](existing-flutter-map.md) | c3. Flutter 已复刻 3 模块 ↔ Java 源码定位 + 5 步复刻工作流 | ✅ Loop 2 |
| [shortlist-for-flutter-port.md](shortlist-for-flutter-port.md) | c1. Wave 0 通用基础组件 Top-8 + sim 复刻优先级 Top-15（Wave A/B/C 分组） | ✅ Loop 3 |
| [w0-2-simulation-clock-draft.md](w0-2-simulation-clock-draft.md) | W0-2 SimulationClock 蓝本草案（Java IClock/ConstantDtClock + Dart API + Forces 迁移示意） | ✅ Wave 0 深挖 |
| [w0-1-chart-draft.md](w0-1-chart-draft.md) | W0-1 Chart 图表控件蓝本草案（Java ControlGraph/GraphSuite + Dart API + CustomPainter 方案） | ✅ Wave 0 深挖 |
| [w0-3-property-control-draft.md](w0-3-property-control-draft.md) | W0-3 PropertyControl 控件族蓝本草案（Java VSliderNode/HSliderNode/RadioButtonStrip + Dart API + §C2 合规集成） | ✅ Wave 0 深挖 |
| [java-blueprint-scan-log.md](java-blueprint-scan-log.md) | Java 蓝本路径实测扫描记录（PHET_JAVA_ROOT 定位 + 依赖库盘点） | ✅ 调研 |
| [shared-abstraction-plan.md](shared-abstraction-plan.md) | **Flutter kratos 通用抽象层规划**：L0 现状 / L1 待抽候选 / L2 明确不抽象 / 4 新模块复用清单 / 架构债务 / 门禁合规 | ✅ 通用层规划 |
| [4-sim-lightweight-EDD-index.md](4-sim-lightweight-EDD-index.md) | 4 新 sim 轻量 EDD 索引（color-vision / sound / radio-waves / wave-interference） | ✅ EDD |
| [edd-template.md](edd-template.md) | EDD（工程设计文档）编写模板 | ✅ 模板 |
| [edd/color-vision-EDD.md](edd/color-vision-EDD.md) · [sound-EDD.md](edd/sound-EDD.md) · [radio-waves-EDD.md](edd/radio-waves-EDD.md) · [wave-interference-EDD.md](edd/wave-interference-EDD.md) | 分 sim EDD 明细（每 sim 工程设计文档） | ✅ EDD |
| [notes.md](notes.md) | 关键决策 / 采样局限 / 6 项 TODO 入口 / 维护提示 | ✅ Loop 3 |

## 路径占位符约定

本目录所有文档引用 Java 源码路径时**统一使用占位符** `<PHET_JAVA_ROOT>`，代表 SVN trunk 根目录。

- 占位符：`<PHET_JAVA_ROOT>/simulations-java/simulations/<sim-name>/src/edu/colorado/kartos/<sim>/...`
- 本机实际映射：`<PHET_JAVA_ROOT>` = `C:\workspace\kartosTrunk\kartosTrunk`（仅在 [overview.md](overview.md) §本机路径 节记录一次）

理由：AI 工作区文档应可移植（[00-engineering-principles.mdc §编辑优于新建 · 通用性]）；本机绝对路径只在一处固化。

## 分析局限与非目标

本知识库**明确不做**以下事情（避免膨胀 · 遵循 `50-svn-branch-safety` §AI 工作区不长业务代码 + `10-vibecoding-protocol` §30 分钟原则）：

- ❌ 每个 sim 的完整源码级文档（如需 → 触发范围 B 深挖）
- ❌ Java↔Flutter 架构模式一一对应表（如需 → 触发范围 C 或 c2 子方向）
- ❌ AI 生成就绪度评估（如需 → 触发范围 D）
- ❌ 复制或搬迁 Java 源码到 AI 工作区（禁止 · 见 `50-svn-branch-safety`）
