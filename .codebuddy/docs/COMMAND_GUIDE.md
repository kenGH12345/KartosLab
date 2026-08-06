# Slash Command 指南

> 16 个内置 commands，分 6 组。**Cursor / Claude Code / CodeBuddy 三端镜像、同名同义**。
>
> 每个命令都是"一次用户触发 → 编排好的多步动作"——把常用工作流封装为一句指令。

## 命令总览

### PM 组（需求生命周期）

| 命令 | 用途 | 委派给 |
|---|---|---|
| `/pm-new` | 新建需求（询问标题/SOP/repo path → 调用 `new-requirement` 脚本 → 委派 product-manager） | product-manager |
| `/pm-continue <req-id>` | 续接某个需求（恢复现场、加载上下文、按当前 phase 委派对应 agent） | 主会话（PM 角色） |
| `/pm-dev <source-req-id>` | 从已完成的策划需求快速创建开发需求（自动引用策划案） | 主会话 |
| `/pm-status` | 列出所有需求与当前阶段 | 主会话（read-only） |
| `/pm-phase <req-id> <phase>` | **强制**切换需求阶段（修复命令，需要用户确认与说明理由） | managing-requirement Skill |

### Req 组（需求内任务）

| 命令 | 用途 | 委派给 |
|---|---|---|
| `/req-add <req-id> <task>` | 给需求添加一个任务（写 `tasks/features.json`） | managing-requirement Skill |
| `/req-done <req-id> <task-id>` | 标记任务完成 | managing-requirement Skill |
| `/req-archive <req-id>` | 归档需求到 `requirements/_archived/` | managing-requirement Skill |

### SOP 组（流程定义）

| 命令 | 用途 | 委派给 |
|---|---|---|
| `/sop-list` | 列出可用 SOP | （直接读 `.codebuddy/sop/INDEX.md`） |
| `/sop-show <name>` | 查看某个 SOP 的详细定义 | （直接读 `.codebuddy/sop/<name>.md`） |
| `/sop-edit <name>` | 编辑或创建 SOP（**proposal-then-modify**） | skill-architect 同款流程 |

### Skill 组

| 命令 | 用途 | 委派给 |
|---|---|---|
| `/skill-new` | 创建新 Skill | skill-architect |
| `/skill-evolve <name>` | 触发 Skill 自进化协议 | skill-architect |
| `/skill-list` | 列出所有可用 Skill | （直接读 `.codebuddy/skills/INDEX.md`） |

### Vibe 组（核心循环）

| 命令 | 用途 | 委派给 |
|---|---|---|
| `/vibe-loop` | 进入快速迭代（agile-vibe iteration 阶段用）：编码 → 验证 → 记录 → 决策 | 主会话直接做（不委派 dev agent，节省切换） |
| `/code-review` | 触发代码评审 | code-reviewer |

### 维护组

| 命令 | 用途 | 委派给 |
|---|---|---|
| `/doctor` | 仓库健康体检 | doctor Skill（**只诊断不修复**） |

## Command 文件格式

### Cursor 端：`.cursor/commands/<name>.md`

**无 frontmatter**——整个文件就是 prompt 正文。

```markdown
# 创建一个新需求

请按以下步骤推进：

1. 询问需求短标识（kebab-case，如 user-edit）
2. 询问标题（中英文均可）
3. 询问 SOP（默认 agile-vibe）
4. 询问代码工程位置（如有）
5. 调用 .codebuddy/scripts/new-requirement.ps1 生成骨架
6. 委派 product-manager 开始需求澄清
7. 把新需求追加到 requirements/INDEX.md 与 INDEX.yaml
```

### Claude Code 端：`.claude/commands/<name>.md`

**带 frontmatter**：

```markdown
---
description: "创建一个新需求"
argument-hint: "[req-id?]"
allowed-tools: ["Bash(./.codebuddy/scripts/new-requirement.ps1:*)", "Bash(./.codebuddy/scripts/new-requirement.sh:*)", "Read", "Write", "Edit", "Task"]
model: claude-sonnet-4
---

# 创建一个新需求

（命令正文同 Cursor 端）
```

frontmatter 字段：

| 字段 | 必需 | 说明 |
|---|:-:|---|
| `description` | ✓ | 命令简介，会显示在 `/help` 列表 |
| `argument-hint` | ○ | 用户输入命令时的参数提示 |
| `allowed-tools` | ○ | 此命令可调用的工具白名单（覆盖 settings.json 全局） |
| `model` | ○ | 用什么模型执行 |

## 三端一致性保证

`.codebuddy/scripts/doctor.sh` / `doctor.ps1` 在 `assets` 检查里强制：

- 三端文件**同名**：`.cursor/commands/X.md` 必有 `.claude/commands/X.md` 必有 `.codebuddy/commands/X.md`
- 数量对称：三端 `*.md` 计数相等（symmetry 行：`.claude=N .cursor=N .codebuddy=N`）

正文同义性目前**不强制校验**——靠人工评审与"同步脚本"维持。

### 同步脚本（已落地）

`.claude/commands/` 是**单一源**，其他两端通过脚本镜像生成：

| 目标 | sync 脚本 | 转换 |
|---|---|---|
| `.cursor/commands/*.md` | `.codebuddy/scripts/sync-commands.sh` / `.ps1` | 剥 frontmatter（Cursor 命令体不带 frontmatter） |
| `.codebuddy/commands/*.md` | `.codebuddy/scripts/sync-codebuddy.sh` / `.ps1` | 直接 cp（CodeBuddy 与 Claude Code 同 frontmatter schema） |

`.codebuddy/scripts/init.sh` / `init.ps1` 在初始化时已自动调这两个脚本，新克隆即三端可用。

**改动 command 时的标准流程**：

1. 编辑 `.claude/commands/<name>.md`（带 frontmatter 的单一源）
2. 跑 `./.codebuddy/scripts/sync-commands.sh && ./.codebuddy/scripts/sync-codebuddy.sh`（macOS/Linux）或 `.\scripts\sync-commands.ps1; .\scripts\sync-codebuddy.ps1`（Windows）
3. 跑 `/doctor` 验证三端对称

## 委派 vs 直接做

某些命令"重"，会委派 agent；某些"轻"，主会话自己做：

| 直接做（轻） | 委派（重） |
|---|---|
| `/pm-status` | `/pm-new` |
| `/sop-list` | `/sop-edit` |
| `/skill-list` | `/skill-new` `/skill-evolve` |
| `/vibe-loop`（一次循环） | `/code-review` |
| `/doctor` | （doctor Skill 是 in-context 调用，不是 Task 委派） |

> `/vibe-loop` 是个有意为之的例外——agile-vibe iteration 阶段强调"用户与主会话直撸"，不切换上下文。如果一次循环里发现要做大改，再触发 dev agent。

## 怎么新增一个命令

1. 在 `.claude/commands/<name>.md` 写一份带 frontmatter 的版本
2. 跑同步脚本（或手工去掉 frontmatter）写到 `.cursor/commands/<name>.md`
3. 在本指南表格里加一行
4. 跑 `/doctor` 验证对称

## 命令调试

### 命令"没反应"

- 看 [TROUBLESHOOTING.md](TROUBLESHOOTING.md) 的"在 Cursor 中输入 /pm-new 没反应"段

### 命令执行了但产出不对

- 看 `.cursor/commands/<name>.md` 与 `.claude/commands/<name>.md` 内容是否同义
- 看是不是缺了某个 Skill / Agent（命令引用了不存在的资源）
- 跑 `/doctor` 看是否有断链

### 命令导致状态损坏

- 看 `requirements/<id>/process.txt` 末尾，了解出错时在做什么
- 用 `/doctor -Scope state` 检查
- 必要时用 `/pm-phase` 强制回退阶段

---
*v0.1.0-alpha — Phase 4 完成时的 16 个命令。*
