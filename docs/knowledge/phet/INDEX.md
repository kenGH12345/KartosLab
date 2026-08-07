# phet 项目知识库

> 本目录由 knowledge-base-generator 自动生成。
> 单一源原则：同一事实只在一处定义，其他位置用引用。
> 来源: 首次扫描（`C:\workspace\phet`）| 创建时间: 2026-07-17
> 项目类型: web-frontend（Flutter / Dart 原生应用）

## 目录结构

```
context/project/phet/
├── INDEX.md
├── notes.md                 ← 决策 / 踩坑 / 参考链接（跨 session 沉淀）
├── architecture/            ← 全局架构（入口 / 设计风格 / 配置）
│   ├── overview.md
│   ├── app-entry.md
│   ├── project-config.md
│   └── design-patterns.md  ← MVC / 组件化 / 通用化 / 配置化 主线
├── frontend/                ← UI 框架与共享组件
│   ├── drag-drop-workspace.md
│   └── ui-framework.md      ← UI 渲染框架（原语组合 / CustomPainter 规范 / 主题）
├── systems/                 ← 模块深度文档 + 索引表
│   ├── module-index.md
│   ├── circuit-module.md
│   ├── optics-module.md
│   └── forces-module.md
├── flows/                   ← 跨模块流程
│   └── state-update-loop.md
└── conventions/             ← How-To 接入模板
    ├── add-draggable-component.md
    ├── add-circuit-component.md
    ├── add-interaction.md
    └── add-custom-painter.md  ← 新增 Canvas 绘制组件（构造注入 / toScreen / shouldRepaint）
```

## 文档清单

| 文档 | 说明 | 最近更新 |
|---|---|---|
| [notes.md](notes.md) | **决策 / 踩坑 / 参考链接**（跨 session 沉淀 · 未来 agent 首读 · 含 9宫格适配方案决策） | 2026-08-07 |
| [architecture/overview.md](architecture/overview.md) | 项目总览、三大模块、架构分层图 | 2026-07-17 |
| [architecture/app-entry.md](architecture/app-entry.md) | 启动链路、MaterialApp 主题、导航模型 | 2026-07-17 |
| [architecture/project-config.md](architecture/project-config.md) | 配置三类拆分（pubspec 依赖 / 主题 / scenarios JSON），附"无数据映射类"说明 | 2026-07-17 |
| [architecture/design-patterns.md](architecture/design-patterns.md) | **顶层设计主线**：MVC 分层 / 组件化（元件继承体系）/ 通用化（泛型共享 + 通用工厂）/ 配置化（JSON 驱动） | 2026-07-17 |
| [frontend/drag-drop-workspace.md](frontend/drag-drop-workspace.md) | 共享拖拽基础设施 + 两套坐标投影类 + 路由表 + 主题变量 + 状态管理 + 事件链路 | 2026-07-17 |
| [frontend/ui-framework.md](frontend/ui-framework.md) | **UI 渲染框架**：分层模型 / 核心原语 / CustomPainter 规范 / 主题 | 2026-07-17 |
| [systems/module-index.md](systems/module-index.md) | 52 个 Dart 文件模块归属索引表 | 2026-07-17 |
| [systems/circuit-module.md](systems/circuit-module.md) | 电路搭建：状态模型 + CircuitSolver 连通图求解 + **场景配置系统（§C1-§C3 全合规）** | 2026-07-21 |
| [systems/optics-module.md](systems/optics-module.md) | 几何光学：OpticsWorld + OpticalSolver 二光线法 + **场景配置系统（§C1-§C3 全合规）** | 2026-07-21 |
| [systems/forces-module.md](systems/forces-module.md) | 力与运动：ForcesSimulation 1D 力学引擎 + 4 模式 + **场景配置系统（§C1-§C3 全合规）** | 2026-07-21 |
| [flows/state-update-loop.md](flows/state-update-loop.md) | 通用"状态→Solve→Render"交互闭环 | 2026-07-17 |
| [conventions/add-draggable-component.md](conventions/add-draggable-component.md) | 向拖拽工作区新增元件模板 | 2026-07-17 |
| [conventions/add-circuit-component.md](conventions/add-circuit-component.md) | 新增电路元件类型（含 Sentinel 陷阱） | 2026-07-17 |
| [conventions/add-interaction.md](conventions/add-interaction.md) | 新增交互（走闭环、不可变修改） | 2026-07-17 |
| [conventions/add-custom-painter.md](conventions/add-custom-painter.md) | 新增 Canvas 绘制组件（构造注入 / `toScreen` 坐标 / `shouldRepaint` 逐项比较） | 2026-07-17 |

## 跨引用

- 业务代码: `C:\workspace\phet\lib`（52 个 .dart，约 8377 行，抽样估算）
- 外部资产: `C:\workspace\phet\assets`（SVG 图标 + `assets/scenarios/*.json` / `assets/scenarios/circuit/*.json` / `assets/scenarios/forces/*.json` 场景配置） + `docs/prompts/circuit_scenario.md` + `docs/prompts/forces_scenario.md` + `docs/prompts/optics_scenario.md` + `schemas/circuit_scenario.schema.json` + `schemas/forces_scenario.schema.json` + `schemas/optics_scenario.schema.json`（三模块 AI 生成工具链全覆盖）
- 关联命令: `/kb-gen`（本知识库由该命令生成，详见 `.codebuddy/commands/kb-gen.md`）
- 增量维护: 日常小改动用 `managing-knowledge` Skill 回写对应文档（该 Skill 已落地于 `.codebuddy/skills/core/managing-knowledge/`，`convention` 类型候选默认落 `conventions/<topic>.md`）
- 一级子目录索引: [architecture/INDEX.md](architecture/INDEX.md) · [frontend/INDEX.md](frontend/INDEX.md) · [systems/INDEX.md](systems/INDEX.md) · [flows/INDEX.md](flows/INDEX.md) · [conventions/INDEX.md](conventions/INDEX.md)
- INDEX 同步机制: 由 `managing-knowledge` Skill 步骤 5 调用 `docs-index-updater` Skill 完成（`.codebuddy/skills/core/docs-index-updater/` 已落地）；如未接入自动流程，可由 agent/主会话按 `retrieval-pattern.md` 规范手工同步

## 目录结构与 retrieval-pattern.md 的偏差

> 本项目是 **Flutter 单体教学 App**（本地状态，无后端服务、无 DB、无跨服务 API），与 `managing-knowledge` Skill 的 `references/retrieval-pattern.md` 定义的"标准通用目录结构"存在如下偏差。AI 未来跑 `managing-knowledge` 时按下表映射落点，不要按标准结构去找不存在的目录。

| retrieval-pattern.md 标准 | 本项目实际 | 说明 |
|---|---|---|
| `services/<service>/` | `systems/<module>-module.md` | Flutter 单体，无子服务；三大模块以 `systems/` 承载。`module-responsibility` 类型 candidate 落 `systems/<module>-module.md` |
| `api/` | ❌ 不存在 | 教学 App 无跨服务 HTTP/RPC 契约。`api-contract` 类型 candidate 本项目不适用 |
| `data-model/` | ❌ 不存在 | 纯本地状态（不可变对象树），无数据库表。`data-model` 类型 candidate 本项目不适用 |
| `experience/` | ❌ 不存在（未沉淀） | 暂无踩坑沉淀。若未来出现 `experience` 类型 candidate，可新建本目录 |
| `config.md`（根级） | `architecture/project-config.md` | 配置文档已内嵌 architecture 层；`config` 类型 candidate 落此处而非根级 `config.md` |
| `dependencies.md` / `performance.md`（根级） | ❌ 不存在 | 依赖清单见 `pubspec.yaml`；性能基线未沉淀。若未来需要再新建 |

**其余目录（`architecture/` / `flows/` / `conventions/`）**：与标准命名一致，直接对应。
