# 升级指南

> 模板会持续演进。这份文档说明如何把已落地项目从老版本同步到新版本。
>
> **核心原则**：你**不需要**升级模板才能继续用——v0.1 自洽。但新版本会带新功能 / 修 bug，按需升级即可。

## 升级前提

1. 你的项目已经 init 过了（`.vibe/.initialized` 存在）
2. 你的工作有 commit 到 SVN（升级会涉及大量文件变更）
3. 你大致知道项目里改过哪些"模板原文"——不然合并会麻烦

## 升级策略

### 策略 A：手工选择性合并（推荐 v0.x → v0.y）

适合：小版本升级、改动局部的功能

```bash
# 1. 看新版本相对旧版本改了什么
svn log -r HEAD

# 2. 选择性合并
svn merge -c <revision> ^/trunk

# 3. 解决冲突（通常在 .cursor/rules/, .codebuddy/skills/, .claude/agents/ 里；.codebuddy/ 是 sync 产物，冲突时通常接受新版本然后跑 sync-codebuddy 重生）
# 4. 跑 doctor 验证
.\scripts\doctor.ps1
```

### 策略 B：模板新建后迁移内容（推荐大版本 v0.x → v1.x）

适合：跨大版本升级、模板架构有大改动

```bash
# 1. 新建一个 v1.x 项目
svn checkout <模板仓库> my-app-v2
cd my-app-v2
.\scripts\init.ps1 -ProjectName my-app -RepoPath ../my-app

# 2. 把旧项目的"非模板文件"搬过来：
#    - requirements/req-*/        （历史需求记录）
#    - context/project/<name>/    （项目知识库）
#    - .codebuddy/skills/project/            （项目专属 skill）
#    - .vibe/svn-branch-current.txt （分支状态）
xcopy /E /I /H ..\my-app-v1\requirements\req-*  .\requirements\
xcopy /E /I /H ..\my-app-v1\context\project\my-app  .\context\project\my-app
xcopy /E /I /H ..\my-app-v1\skills\project  .\skills\project

# 3. 跑 doctor
.\scripts\doctor.ps1

# 4. 如旧项目有自定义 .cursor/rules / .claude/agents / .claude/commands —— 手工合并到新项目源后跑 sync-codebuddy 镜像到 .codebuddy/
# 5. 验证一切正常后，删除旧项目（或保留为只读归档）
```

### 策略 C：保留架构在原地、只更资产（覆盖法）

适合：你完全没改过模板原文，只想拿新版本的修复

```powershell
# 备份你的修改
svn status
svn commit -m "checkpoint before template upgrade"

# 直接把新模板的资产覆盖过来
$src = "<新模板 checkout 路径>"
$dst = (Resolve-Path .)
foreach ($p in @(".cursor", ".claude", "skills", "sop", "scripts", "docs")) {
  Copy-Item -Path "$src\$p\*" -Destination "$dst\$p\" -Recurse -Force
}
# .codebuddy/ 是 sync 产物，覆盖完源后重新跑一次 sync 即可
.\scripts\sync-codebuddy.ps1
.\scripts\sync-commands.ps1
.\scripts\sync-mcp.ps1

# 注意：context/, requirements/ 不要覆盖——那是你的数据

# 跑 doctor
.\scripts\doctor.ps1

# 看 svn diff 决定是否回滚
svn diff
```

> ⚠️ 这种方式会把你对模板原文的所有自定义都冲掉。**只对没改过模板的项目用**。

## 各版本变更说明

### v0.1.0-alpha → v0.2.0（计划中）

> 占位。v0.2 发布时此段会填实。

可能改动：
- .codebuddy/skills/core/ 新增若干
- agents 列表微调
- .codebuddy/scripts/ 加 sync-mcp.ps1
- .codebuddy/docs/ 增加 EXAMPLES.md

### v0.1.0-alpha 自身

首个版本。没有"从更老版本升级"的需求。

## 如何识别自己当前用的模板版本

看：

```powershell
Get-Content .vibe\.initialized
# template_version: 0.1.0
```

或：

```powershell
Get-Content README.md | Select-String 'v\d+\.\d+\.\d+'
```

## 数据 vs 模板：什么是你的 / 什么是模板的

升级时要清楚边界：

### 模板的（升级时可能被覆盖）

- `.cursor/rules/`（**单一源**之一）
- `.claude/agents/` `.claude/commands/` `.claude/settings.json`（**单一源**之一）
- `.mcp.json`（**单一源**，三端共享）
- `.cursor/commands/` `.cursor/mcp.json`（由 sync-commands / sync-mcp 镜像）
- `.codebuddy/rules/` `.codebuddy/agents/` `.codebuddy/commands/` `.codebuddy/settings.json`（由 sync-codebuddy 镜像，**不要手编辑**）
- `CODEBUDDY.md`（项目根，轻量手维护）
- `.codebuddy/skills/_meta/` `.codebuddy/skills/core/`
- `.codebuddy/sop/_template_sop.md` `.codebuddy/sop/agile-vibe.md` `.codebuddy/sop/deep-vibe.md` `.codebuddy/sop/INDEX.md`
- `requirements/_template/` `requirements/INDEX.md` `requirements/INDEX.yaml`（结构）
- `context/INDEX.md` `context/shared/INDEX.md` `context/team/INDEX.md`
- `.codebuddy/scripts/`
- `.codebuddy/docs/`（除你自己加的）
- `AGENTS.md` `CLAUDE.md`（**结构是模板的，但里面有 init 替换过的项目名/repo path——升级时要避免覆盖项目名相关字段**）
- `README.md` `svn:ignore`

### 你的（升级时绝对不要覆盖）

- `requirements/req-*/`（具体需求的 spec/design/tasks/process/notes/meta）
- `requirements/_archived/`
- `context/project/<your-name>/`
- `.codebuddy/skills/project/`
- `.vibe/.initialized` `.vibe/svn-branch-current.txt`
- `.vibe/cache/`（如有）
- 你自己加的任何 `.cursor/rules/<your-rule>.mdc` / `.claude/agents/<your-agent>.md` / `.claude/commands/<your-cmd>.md`（加到这些**单一源**位置，跑 sync 后自动出现在 `.codebuddy/`）

### 灰色地带（升级时小心合并）

- `AGENTS.md` / `CLAUDE.md` / `CODEBUDDY.md` —— 模板提供结构，init 时替换了 `wepop-trunk` `d:\WePop_trunk` 等。升级时合并：保留你的项目特定字段，更新结构改动。
- `requirements/INDEX.md` —— 你的需求条目不能丢，但模板可能改了表头/列。
- `context/project/<name>/INDEX.md` —— 同上。

## 升级失败怎么办

```powershell
# 回滚到升级前
svn merge -r HEAD:<pre-upgrade-revision> .

# 看 doctor 报告，确认是哪一类问题：
# - 资产缺失：检查升级是不是缺文件
# - 状态不一致：检查 INDEX.* 是否被错误覆盖
# - 链接断裂：可能是新版本改了某些路径
# - 占位符遗留：可能是新版本引入了新的占位符，需要补 init 步骤
```

## 关于"模板版本固化到哪"

`.vibe/.initialized` 里的 `template_version` 字段记录"init 时用的模板版本"。这个字段：

- **不会**自动随升级而变
- 升级完成后，**你**应该手工把它改成新版本号
- 这是为了让 `doctor` 在未来的版本里能根据 template_version 给出针对性建议

```yaml
# .vibe/.initialized 升级后手工改：
template_version: 0.2.0   # ← 从 0.1.0 改成新版本
```

---
*这份文档随每个版本演进。当前为 v0.1.0-alpha。*
