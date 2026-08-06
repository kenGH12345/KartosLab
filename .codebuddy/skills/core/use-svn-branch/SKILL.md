---
name: use-svn-branch
description: 用于在需要并行处理多需求 / 隔离 AI 实验性改动 / 避免污染主干时，按规范创建 / 切换 / 清理 SVN 分支。替代 git worktree 方案，强制分支命名与路径解析协议，避免 AI 在错误分支改文件。
tools: Bash, Read
---

# use-svn-branch

> AI 在多需求并行时最容易犯的错：在错误的分支里改文件、把 SVN 分支当本地分支用、忘记合并回主干导致代码丢失。
> 这个 Skill 把 SVN 分支的"何时用 / 怎么命名 / 怎么切换 / 何时清理"固化下来。
>
> **关键差异**：SVN 没有 git 那样的"本地 commit"——每一个 `svn commit` 都是立即推送到服务器、不可撤销。
> 因此所有服务器端操作（`svn copy` / `svn delete` / `svn commit`）都必须获得用户明确审批。

## 何时使用

- ✅ 用户/主会话明确要求在隔离分支跑实验性改动
- ✅ 同时有 ≥ 2 个需求在编码阶段，担心相互污染
- ✅ AI agent 需要并行尝试多个方案
- ❌ 单需求正常开发：不需要分支，直接在主干即可
- ❌ 想做版本切换看历史代码：用 `svn switch` 切版本号即可，不需要分支

## 输入

| 输入 | 类型 | 必需 | 说明 |
|---|---|:-:|---|
| operation | enum | ✓ | `create` / `switch` / `list` / `cleanup` |
| repo_path | string | ✓ | SVN 工作副本路径（绝对路径） |
| branch_purpose | string | 部分必需 | create / cleanup 时必填：`req-<id>` |
| svn_repo_url | string | 部分必需 | create 时必填：SVN 仓库根 URL（如 `svn://server/repo`） |

## 步骤

### operation = create

1. 校验 repo_path 是有效的 SVN 工作副本：
   ```bash
   cd <repo_path>
   svn info
   # 必须有输出，否则不是有效工作副本
   ```
2. 校验主干工作副本是干净的（未提交的改动会随 switch 一起走）：
   ```bash
   svn status
   # 如有输出，提示用户先 commit 或 stash 后再创建分支
   ```
3. 命名规则：
   - 需求分支：`branches/vibe/<req-id>`（如 `branches/vibe/req-user-edit`）
4. 校验分支不存在：
   ```bash
   svn list ^/branches/vibe/ | grep <req-id>
   # 无输出才继续
   ```
5. 创建分支（**需要用户审批**——这是服务器端操作）：
   ```bash
   svn copy ^/trunk ^/branches/vibe/<req-id> -m "[req-xxx] chore: create branch for <req-id>"
   ```
   审批流程（详见 `00-engineering-principles.mdc` SVN 安全红线）：
   - 展示即将执行的完整命令
   - 明确告知用户："**即将提交到 SVN 服务器，此操作不可撤销**"
   - 获得用户明确的 y/n 确认
   - 仅在用户回复 y 后才执行
6. 切换工作副本到新分支：
   ```bash
   svn switch ^/branches/vibe/<req-id>
   ```
7. 验证切换成功：
   ```bash
   svn info | grep "URL:"
   # 应显示 ^/branches/vibe/<req-id>
   ```
8. 写入"当前活跃分支标记"到 `.vibe/svn-branch-current.txt`（本仓库）：
   ```
   branches/vibe/<req-id>
   ```
   后续 dev agent 解析 `d:\WePop_trunk` 时优先读此文件确认当前分支。

### operation = switch

1. 读取 `.vibe/svn-branch-current.txt`，记录上一个分支
2. 校验当前工作副本状态：
   ```bash
   svn status
   # 如有未提交改动，提示用户先 commit 或处理
   ```
3. 切换到目标分支：
   ```bash
   svn switch ^/branches/vibe/<req-id>
   # 或切回主干：
   svn switch ^/trunk
   ```
4. 验证切换成功：
   ```bash
   svn info | grep "URL:"
   ```
5. 写新值到 `.vibe/svn-branch-current.txt`

### operation = list

```bash
svn list ^/branches/vibe/
```

输出所有 `vibe/` 下的分支名。

可选：显示当前工作副本所在分支：
```bash
svn info | grep "URL:"
```

### operation = cleanup

1. 切回主干：
   ```bash
   svn switch ^/trunk
   ```
2. 合并分支改动到主干：
   ```bash
   svn merge ^/branches/vibe/<req-id>
   ```
3. 检查合并结果：
   ```bash
   svn status
   svn diff
   ```
4. 提交合并结果（**需要用户审批**——SVN commit 不可撤销）：
   - 展示 `svn status` 输出（变更文件清单）
   - 展示 `svn diff` 输出（内容变更）
   - 明确告知用户："**即将提交到 SVN 服务器，此操作不可撤销**"
   - 获得用户明确的 y/n 确认
   - 仅在用户回复 y 后才执行：
   ```bash
   svn commit -m "[req-xxx] feat: merge branch vibe/<req-id> back to trunk"
   ```
5. 删除已合并的分支（**需要用户审批**——服务器端操作，不可逆）：
   - 展示即将执行的完整命令
   - 明确告知用户："**即将从 SVN 服务器删除分支，此操作不可撤销**"
   - 获得用户明确的 y/n 确认
   - 仅在用户回复 y 后才执行：
   ```bash
   svn delete ^/branches/vibe/<req-id> -m "cleanup: <req-id> done"
   ```
6. 如清理的是当前活跃分支，清空或更新 `.vibe/svn-branch-current.txt`

## 输出

```md
## use-svn-branch 执行结果
- operation: <op>
- 状态: completed / blocked / pending_approval
- 当前活跃分支: <branch-path 或 trunk>
- 现有 vibe 分支列表:
  - branches/vibe/<req-1>
  - branches/vibe/<req-2>
- 后续建议: <如适用>
```

## 路径解析协议（重要）

dev agent 在解析 `d:\WePop_trunk` 时按以下顺序：

1. 读 `.vibe/svn-branch-current.txt`，如存在且分支有效 → 用当前工作副本路径 + 确认分支
2. 否则用 `meta.yaml` 的 `repo_path` 字段
3. 否则用 AGENTS.md 中的全局默认 `d:\WePop_trunk`

**所有 dev agent 必须遵守这个协议**——见规则 `50-worktree-safety.mdc`。

## 边界与陷阱

> [!WARNING]
> **绝不**未经用户审批执行 `svn commit` / `svn copy` / `svn delete`——这些都是服务器端操作，立即生效且不可撤销（详见 `00-engineering-principles.mdc` SVN 安全红线）。

> [!IMPORTANT]
> 分支创建/切换后必须更新 `.vibe/svn-branch-current.txt`。否则 agent 不知道当前在哪个分支。

- ❌ 不要在有未提交改动时 `svn switch`（改动会跟随切换，可能导致冲突）
- ❌ 不要分支命名不带 `vibe/` 前缀（容易与项目正式分支混淆）
- ❌ 不要在没有合并回主干的情况下 `svn delete` 分支（代码会丢失）
- ❌ 不要让分支长时间不合并回主干（≥ 1 个月，merge 冲突风险剧增）
- ✅ 创建/切换分支后必须写 `.vibe/svn-branch-current.txt`
- ✅ 完成需求后建议立即合并并清理对应分支
- ✅ cleanup 的 merge + commit + delete 每步都必须用户确认
- ✅ `svn commit` 前必须展示 `svn status` + `svn diff`，让用户审查变更

## 何时该用 / 不该用

| 场景 | 用 SVN 分支？ |
|---|---|
| 单人单需求开发 | ❌ |
| 同时进行 2+ 需求且互相影响 | ✅ |
| 临时切换看历史版本 | ❌ 用 `svn switch` 切版本号 |
| AI 跑实验性方案 | ✅ |
| 想做不可逆操作前留备份 | ✅ |
| 跨分支引用代码 | ❌ 用 `svn cat` 或 `svn merge --ignore-ancestry` |

## SVN 与 git worktree 的关键差异

| 维度 | git worktree | SVN 分支 |
|---|---|---|
| 物理位置 | 每个工作树是独立目录 | 同一工作副本，`svn switch` 切换 |
| commit 性质 | 本地提交，可撤销 | **立即推送到服务器，不可撤销** |
| 并行开发 | 可同时打开多个目录 | 同一时刻只能在一个分支上 |
| 分支存储 | 本地 `.git` | 服务器端（`^/branches/`） |
| 删除分支 | `git branch -d`（本地操作） | `svn delete`（**服务器端操作，需审批**） |

## 关联 Skill

- 与规则 `50-worktree-safety.mdc` 配合：规则定义"不能越界"，本 Skill 定义"怎么开/关"
- 与规则 `00-engineering-principles.mdc` SVN 安全红线配合：所有服务器端操作必须用户审批
- `managing-requirement` 在 create 阶段可触发本 Skill（如用户希望每需求一个分支）

## 变更历史

| 日期 | 版本 | 变更 | 触发原因 | 操作者 |
|---|---|---|---|---|
| - | 0.1.0 | 初始创建，替代 use-worktree（git → SVN） | SVN 项目适配 | template |
