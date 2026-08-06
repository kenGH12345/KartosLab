# 文档中心

> AIVibeCodingProj 框架文档。新手从 [QUICKSTART](QUICKSTART.md) 开始。

## 阅读路径

### 5 分钟上手
- [QUICKSTART.md](QUICKSTART.md) — 从 clone 到第一个 `/pm-new`
- [INSTALL.md](INSTALL.md) — 前置依赖与平台特定注意事项

### 理解架构
- [ARCHITECTURE.md](ARCHITECTURE.md) — 五层架构、三端原生设计（Cursor / Claude Code / CodeBuddy）、单一源原则、关键设计决策
- [CONVENTIONS.md](CONVENTIONS.md) — Cursor / Claude Code / CodeBuddy / 命名 / 编码约定速查

### 怎么用
- [SOP_GUIDE.md](SOP_GUIDE.md) — agile-vibe / deep-vibe 选型与切换
- [SKILL_GUIDE.md](SKILL_GUIDE.md) — 怎么用 / 怎么写 / 怎么演进 Skill
- [AGENT_GUIDE.md](AGENT_GUIDE.md) — 14 个 Subagent 体系与委派机制
- [COMMAND_GUIDE.md](COMMAND_GUIDE.md) — 16 个 Slash Command 全清单

### 配置与运维
- [MCP_SETUP.md](MCP_SETUP.md) — 5 个预置 MCP server 启用方法
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) — 故障排查清单
- [UPGRADE.md](UPGRADE.md) — 模板版本升级策略

### 设计决策
- [ADR/](ADR/) — Architecture Decision Records
  - [0001](ADR/0001-record-decisions.md) — 用 ADR 记录决策
  - [0002](ADR/0002-cursor-claude-dual-native.md) — 双工具原生 vs 抽象层（关于 CodeBuddy 的部分已被 ADR-0004 升级）
  - [0003](ADR/0003-skill-single-source.md) — Skill 单一源（不为 Cursor / Claude Code / CodeBuddy 各写一份）
  - [0004](ADR/0004-codebuddy-native-mirror.md) — CodeBuddy 升级为第三端原生（镜像 .claude/ + .cursor/rules/）

## 我该先看哪份？

| 我是 | 推荐阅读顺序 |
|---|---|
| 第一次接触本模板 | QUICKSTART → AGENT_GUIDE → SOP_GUIDE |
| 想搞懂底层设计 | ARCHITECTURE → ADR/0002 |
| 准备给团队推广 | QUICKSTART → SOP_GUIDE → COMMAND_GUIDE → CONVENTIONS |
| 出问题了 | TROUBLESHOOTING → 跑 `/doctor` |
| 想加 MCP / 集成数据库 | MCP_SETUP |
| 准备升级到新版本 | UPGRADE |
| 想自己写新 Skill | SKILL_GUIDE → `.codebuddy/skills/_meta/skill-authoring-guide.md` |

## 给文档贡献者

- 新增文档：放本目录，更新本 README 的 "阅读路径" 段
- 链接断裂：跑 `/doctor -Scope links` 检查
- 文档之间用相对路径互链（用 `[文字](X.md)` 这种 markdown 链接语法；上一级用 `../`）
- 用 `visual-doc-generator` Skill 生成 mermaid 图（避免每次现想图怎么画）

---
*文档版本：v0.1.0-alpha (Phase 4 完成)*
