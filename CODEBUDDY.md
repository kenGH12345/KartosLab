@AGENTS.md

# CodeBuddy 专属补充

> 上方 `@AGENTS.md` 引入了所有通用规则与项目上下文。
> 如果你的工具不支持 `@import` 语法，请直接打开 `AGENTS.md` 阅读。
> 本文件仅追加 CodeBuddy 特有的内容。

---

## 项目级配置位置（CodeBuddy 视角）

| 资产 | 位置 | 说明 |
|---|---|---|
| Rules | `.codebuddy/rules/*.mdc` | 11 条规则（00-80 + 自进化协议族） |
| Agents | `.codebuddy/agents/*.md` | 精简至 kratos 适用的 7 个 agent |
| Memory | 本文件 `CODEBUDDY.md` | 缺失时自动 fallback 到 `AGENTS.md` |

---

## Subagents 使用

CodeBuddy 原生支持 sub-agents，通过 `Task` 工具调用。kratos 项目适用的 agent 清单见 `AGENTS.md` 的 Agent 委派表。

---

## 与 Claude Code 端的差异

| 维度 | Claude Code | CodeBuddy |
|---|---|---|
| Memory 文件 | `CLAUDE.md` | `CODEBUDDY.md` |
| Rules | 通过 import 间接引入 | 原生 `.codebuddy/rules/*.mdc` |
| MCP | 项目根 `.mcp.json` | 项目根 `.mcp.json`（共享） |

---

## 知识库速查（详细内容请 Read 对应文件）

> 以下是 kratos 项目知识库（`docs/knowledge/kratos/` 与 `docs/knowledge/kratos-java-simulations/`）的快速索引。
> AI 在做技术判断前，**必须先查下表定位到具体文档，Read 后引用**（见 `20-verify-before-act.mdc` 自证引用约束）。

### kratos Flutter 工程核心

| 我要做什么 | 去这里查 |
|---|---|
| 理解项目整体架构与分层 | `docs/knowledge/kratos/architecture/overview.md` |
| 理解 MVC / 组件化 / 通用化 / 配置化四原则 | `docs/knowledge/kratos/architecture/design-patterns.md` |
| 理解 App 启动链路（MaterialApp / 导航 / 主题） | `docs/knowledge/kratos/architecture/app-entry.md` |
| 理解配置体系（pubspec / 主题 / scenarios JSON） | `docs/knowledge/kratos/architecture/project-config.md` |
| 理解 AI 生成友好度框架（migration order） | `docs/knowledge/kratos/architecture/ai-generation-readiness.md` |
| 理解 UI 渲染框架（分层模型 / CustomPainter 规范 / 主题） | `docs/knowledge/kratos/frontend/ui-framework.md` |
| 理解拖拽工作区基础设施 | `docs/knowledge/kratos/frontend/drag-drop-workspace.md` |
| 查找 Dart 文件归属（哪个模块有哪个文件） | `docs/knowledge/kratos/systems/module-index.md` |
| 理解电路模块（状态模型 / CircuitSolver / 场景配置） | `docs/knowledge/kratos/systems/circuit-module.md` |
| 理解几何光学模块（OpticsWorld / OpticalSolver） | `docs/knowledge/kratos/systems/optics-module.md` |
| 理解力与运动模块（ForcesSimulation / 4 模式） | `docs/knowledge/kratos/systems/forces-module.md` |
| 理解通用交互闭环（状态→Solve→Render） | `docs/knowledge/kratos/flows/state-update-loop.md` |
| 新增 Canvas 绘制组件（构造注入 / toScreen / shouldRepaint） | `docs/knowledge/kratos/conventions/add-custom-painter.md` |
| 新增拖拽元件 | `docs/knowledge/kratos/conventions/add-draggable-component.md` |
| 新增电路元件类型（含 Sentinel 陷阱） | `docs/knowledge/kratos/conventions/add-circuit-component.md` |
| 新增交互功能（闭环 / 不可变修改） | `docs/knowledge/kratos/conventions/add-interaction.md` |
| 查看决策 / 踩坑记录 | `docs/knowledge/kratos/notes.md` |

### kratos-java-simulations 复刻蓝图

| 我要做什么 | 去这里查 |
|---|---|
| 理解 Java→Flutter 复刻总览与短名单 | `docs/knowledge/kratos-java-simulations/overview.md` |
| 理解 L0/L1/L2 三层组件复用体系 + 门禁 | `docs/knowledge/kratos-java-simulations/shared-abstraction-plan.md` |
| 查阅 EDD 模板（12 章 v2.0 · 含配置化/ AI 可生成化） | `docs/knowledge/kratos-java-simulations/edd-template.md` |
| 查阅已有 sim 的 EDD（sound / color-vision / radio-waves / wave-interference） | `docs/knowledge/kratos-java-simulations/edd/*-EDD.md` |
| 查阅 Flutter 文件到 Java 源码的映射 | `docs/knowledge/kratos-java-simulations/existing-flutter-map.md` |
| 查阅 52 个 sim 模块全景目录 | `docs/knowledge/kratos-java-simulations/module-catalog.md` |
| 查阅新 sim 开工自检表 | `.codebuddy/rules/80-kratos-sim-checklist.mdc` |
| 查看 4 个 sim 轻量 EDD 一览 | `docs/knowledge/kratos-java-simulations/4-sim-lightweight-EDD-index.md` |

> **查找优先级**：当前需求文档 → 上表（项目知识库） → 源码 grep `lib/`。
> **引用格式**：读完后在回复中用 `[来源: docs/knowledge/kratos/.../xxx.md:行号]` 标注。

---
*基于 AIVibe 框架（由 AIVibeCodingProj 模板 v0.1.0-alpha 适配）· 2026-07-30 落地于 kratos*
