# architecture 索引

> 全局架构层：入口 / 设计风格 / 配置 / 顶层设计主线
> 创建时间: 2026-07-17

## 文档清单
| 文档 | 说明 | 最近更新 |
|---|---|---|
| [overview.md](overview.md) | 项目总览、三大模块、架构分层图 | 2026-07-17 |
| [app-entry.md](app-entry.md) | 启动链路、MaterialApp 主题、导航模型 | 2026-07-17 |
| [project-config.md](project-config.md) | 配置三类拆分（pubspec 依赖 / 主题 / scenarios JSON） | 2026-07-17 |
| [design-patterns.md](design-patterns.md) | **顶层设计主线**：MVC / 组件化 / 通用化 / 配置化（**含 §C1-§C4 硬约束**，2026-07-20 起生效） | 2026-07-20 |
| [refactor-baseline-plan.md](refactor-baseline-plan.md) | ⚠️ **proposal_needs_rework**：Step 1 已尝试并 git revert，核心假设被证伪待重调研（详见文档 §0 教训与勘误） | 2026-07-20 |
| [ai-generation-readiness.md](ai-generation-readiness.md) | ✅ **adopted-framework-standard**（2026-07-20 采纳为项目基本框架 · 3 模块分批迁移锁项 · 详见 migration order） | 2026-07-20 |
| [proposed-gitignore.md](proposed-gitignore.md) | ✅ 已 apply（phet baseline `c2d47c2` 前置）：`.gitignore` 改良（+30 行，untracked 从 130+ 降至 24） | 2026-07-20 |

## 跨引用
- 上级索引: [../INDEX.md](../INDEX.md)
- 主线贯穿模块: [../systems/circuit-module.md](../systems/circuit-module.md) · [../systems/optics-module.md](../systems/optics-module.md) · [../systems/forces-module.md](../systems/forces-module.md)
- UI 框架承载: [../frontend/ui-framework.md](../frontend/ui-framework.md)
- 回写机制: `managing-knowledge` Skill（`architecture-pattern` 类型候选默认落 `overview.md` 或本 INDEX）

