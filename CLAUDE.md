@AGENTS.md

# Claude Code 专属补充

> 上方 `@AGENTS.md` 引入了所有通用规则与项目上下文。本文件仅追加 Claude Code 特有的内容。

---

## Subagents 使用

**常用委派**（kratos 适用 agent 清单见 `AGENTS.md` 委派表）：

| 场景 | 委派给 |
|---|---|
| 新 sim 需求澄清 | `product-manager` |
| 方案设计 | `tech-leader` |
| 代码评审 | `code-reviewer` |
| 收尾 / 知识沉淀 | `closer` / `knowledge-maintainer` |
| 测试执行 | `test-runner` |
| 创建 / 演进 Skill | `skill-architect` |

**委派规则**：
- 主会话遇到属于某 Subagent 职责范围的工作时，用 `Task` 工具委派
- 主会话不得越界直接做阶段产物
- 用户回答某 Subagent 的提问时，**必须**重新委派该 Subagent 继续整理

---
*基于 AIVibe 框架（由 AIVibeCodingProj 模板 v0.1.0-alpha 适配）· 2026-07-30 落地于 kratos*
