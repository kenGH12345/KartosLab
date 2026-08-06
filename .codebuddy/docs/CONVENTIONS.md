# 约定速查

> Cursor / Claude Code / CodeBuddy 三端的官方约定与本框架如何映射。

---

## Cursor

| 资产 | 路径 | 格式 |
|---|---|---|
| 项目记忆 | `AGENTS.md`（项目根） | Markdown |
| 规则 | `.codebuddy/rules/*.mdc` | YAML frontmatter + Markdown |
| 命令 | `.cursor/commands/*.md`（文件名 = `/cmd-name`） | Markdown |
| MCP | `.cursor/mcp.json` | JSON |
| Hooks | `.cursor/hooks.json` | JSON |
| Skills（用户级） | `~/.cursor/skills-cursor/<name>/SKILL.md` | YAML frontmatter |
| Skills（项目级） | `.cursor/skills/<name>/SKILL.md` | YAML frontmatter |

### `.mdc` frontmatter 字段

```yaml
---
description: "供 Cursor 在 description 模式下决定何时引入此规则"
globs: "**/*.go,**/*.proto"     # 仅在匹配的文件被打开/编辑时激活
alwaysApply: true                # 是否每次都加载
---
```

### Slash Command 触发

文件 `.cursor/commands/pm-new.md` → 用户输入 `/pm-new`，Cursor 把文件内容当作 prompt 注入。

---

## Claude Code

| 资产 | 路径 | 格式 |
|---|---|---|
| 项目记忆 | `CLAUDE.md`（项目根） | Markdown，支持 `@import path` |
| 设置 | `.claude/settings.json` | JSON（含 hooks、permissions） |
| Subagents | `.claude/agents/<name>.md` | YAML frontmatter + Markdown |
| 命令 | `.claude/commands/<name>.md` | YAML frontmatter + Markdown |
| Skills | `.claude/skills/<name>/SKILL.md` | YAML frontmatter |
| MCP | `.mcp.json`（项目根） | JSON |

### Subagent frontmatter 字段

```yaml
---
name: product-manager
description: "需求澄清专家。在用户提出新需求或需要澄清时主动调用。"
tools: [Read, Write, Edit, Grep, Glob]   # 可选：限制工具白名单
model: claude-sonnet-4                    # 可选：指定模型
---
```

### Slash Command frontmatter 字段

```yaml
---
description: "创建一个新需求"
argument-hint: "[req-id]"
allowed-tools: [Bash, Write, Read]
model: claude-sonnet-4
---
```

---

## CodeBuddy（第三端原生）

CodeBuddy 与 Cursor / Claude Code 同等的一等公民。布局与 Claude Code 几乎 1:1（仅目录名 `.claude/` → `.codebuddy/` 和 memory 文件 `CLAUDE.md` → `CODEBUDDY.md`，详见 [ADR-0004](ADR/0004-codebuddy-native-mirror.md)）。

| 资产 | 路径 | 格式 |
|---|---|---|
| 项目记忆 | `CODEBUDDY.md`（项目根；缺失时自动 fallback `AGENTS.md`） | Markdown，支持 `@import path` |
| 设置 | `.codebuddy/settings.json` | JSON（含 hooks、permissions） |
| Subagents | `.codebuddy/agents/<name>.md` | YAML frontmatter + Markdown（与 `.claude/agents/` 同 schema） |
| 命令 | `.codebuddy/commands/<name>.md` | YAML frontmatter + Markdown（与 `.claude/commands/` 同 schema） |
| 规则 | `.codebuddy/rules/<name>.mdc` | YAML frontmatter + Markdown（与 `.codebuddy/rules/` 同 .mdc 格式） |
| Skills（用户级） | `~/.codebuddy/skills/<name>/SKILL.md` | YAML frontmatter |
| MCP | `.mcp.json`（项目根，**与 Claude Code 共享同一份**） | JSON |

`.codebuddy/` 整层是 sync 产物（由 `.codebuddy/scripts/sync-codebuddy.{sh,ps1}` 生成），**不要手编辑**。要改请改源（`.claude/agents/`、`.claude/commands/`、`.claude/settings.json`、`.codebuddy/rules/`），再跑 sync 脚本。

---

## 跨工具一致性

下表是 **AIVibeCodingProj 强制一致**的字段对应：

| 概念 | Cursor | Claude Code | CodeBuddy | 本框架要求 |
|---|---|---|---|---|
| 命令名 | 文件名 | 文件名 | 文件名 | 三端必须**同名同义**（doctor 校验：`.claude=.cursor=.codebuddy`） |
| Skill 描述 | `description` | `description` | `description` | 三端共用同一字段（来自单一源 `.codebuddy/skills/`） |
| Agent 描述 | — | `description` | `description`（由 sync-codebuddy 镜像自 .claude） | Cursor 端不原生支持 agent，通过 command 间接调用 |
| 规则触发 | `description` / `globs` / `alwaysApply` | `@import` 引入 | `description` / `globs` / `alwaysApply`（与 Cursor 同 .mdc 格式） | Cursor 与 CodeBuddy 端原生加载，Claude 端通过 `CLAUDE.md` 桥接 |
| MCP 配置 | `.cursor/mcp.json`（由 sync-mcp 镜像 .mcp.json） | `.mcp.json`（项目根） | `.mcp.json`（项目根，与 Claude 共享） | 单一源在项目根 `.mcp.json` |

---

## 占位符规范

模板里所有项目特定值用 `{{...}}` 包裹，init.ps1 时替换：

| 占位符 | 含义 | 示例 |
|---|---|---|
| `wepop-trunk` | 英文标识 | `MyApp` |
| `wepop-trunk` | 展示名 | `我的应用` |
| `d:\WePop_trunk` | 代码工程相对路径 | `../workspace/MyApp` |
| `2026-05-29 13:40` | 初始化时间戳 | `2026-04-25 17:30` |
| `cursor,claude` | 主 AI 工具 | `cursor` / `claude` / `cursor,claude` |

**doctor.ps1** 会扫描所有非 `_template/` 目录下的占位符残留，未替换的报错。

---
*下一步阅读*：[ARCHITECTURE.md](ARCHITECTURE.md) · [SKILL_GUIDE.md](SKILL_GUIDE.md)
