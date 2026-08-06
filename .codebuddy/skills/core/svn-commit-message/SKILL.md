---
name: svn-commit-message
description: 用于在准备一次 svn commit 前，按本项目约定生成符合规范的 commit message（类型 / 范围 / 简述 / 关联 req-id 与验收项），并强制用户审批后提交。替代原 git-commit-message skill。被所有 dev agents 调用。
tools: Bash
---

# svn-commit-message

> commit message 不只是给人看的——它是 `code-review-prepare`、`closer`、`/code-review` 等命令定位"本需求改了什么"的关键依据。
> message 写不规范，整条链都会失灵。
>
> **SVN 与 git 的关键差异**：SVN commit = 立即推送到服务器，不可撤销。因此本 Skill 增加强制用户审批步骤（见步骤 3-4），对应规则 `00-engineering-principles.mdc` SVN 安全红线。

## 何时使用

- ✅ 任何 dev agent 准备 svn commit 前
- ✅ 主会话在 vibecoding 迭代中提交
- ✅ closer 在收尾整理 commits 时校验格式
- ❌ 不需要本 Skill 的场景：svn merge / svn copy / svn delete（这些有独立的审批流程）

## 输入

| 输入 | 类型 | 必需 | 说明 |
|---|---|:-:|---|
| type | enum | ✓ | 见下方"类型清单" |
| scope | string | 推荐 | 范围（模块 / 服务名），如 `auth` / `user-list` |
| summary | string | ✓ | 一句话简述（≤ 60 字） |
| req_id | string | 推荐 | 关联需求 ID，如 `req-user-profile-edit` |
| ac | string | 推荐 | 关联验收项，如 `AC-1` 或 `AC-1,AC-3` |
| task_id | string | 推荐 | 关联 tasks/features.json 的任务 ID，如 `task-2` |
| body | string | 可选 | 详细说明（多行） |

## 步骤

### 1. 校验输入

- `type` 在合法清单内
- `summary` ≤ 60 字符
- `summary` 不以句号结尾
- `summary` 用动词开头（中文用"添加/修复/重构/..."；英文用 "add / fix / refactor / ..."）

如不满足，调整后再生成。

### 2. 组装 message

格式（**强制**）：

```
<type>(<scope>): <task_id?> <summary> [<ac?>] [<req_id?>]
```

> **与 git 版本的差异**：SVN commit message 推荐**单行**。如需 body（详细说明），用 `--file` 方式传递（见步骤 4）。不要在 `-m` 中拼接多行。

示例：

```
feat(auth): task-2 添加 token refresh 接口 [AC-3] [req-user-session]
```

如缺 task_id：省略此字段。
如缺 ac：省略 `[AC-...]`。
如缺 req_id：省略 `[req-...]`。
如缺 scope：写成 `<type>: ...`（不带括号）。

带 body 时的完整格式：

```
<type>(<scope>): <task_id?> <summary> [<ac?>] [<req_id?>]

- 实现 POST /api/auth/refresh 接口
- 与前端约定 401 时自动调用 refresh
- 保留 refresh_token 7 天
```

### 3. 展示变更并请求用户审批（强制）

> **此步骤不可跳过**。SVN commit = 立即推送到服务器，不可撤销。对应规则 `00-engineering-principles.mdc` SVN 安全红线。

执行：

```bash
svn status
```

展示变更文件清单。

```bash
svn diff
```

展示内容变更。

**向用户呈现**：

```
即将提交到 SVN 服务器，此操作不可撤销。

变更文件：
<svn status 输出>

内容变更：
<svn diff 输出>

Commit message:
<组装好的 message>

确认提交？(y/n)
```

**等待用户明确回复 y 或 n**：
- 用户回复 `y` → 进入步骤 4 执行提交
- 用户回复 `n` → 中止，不执行任何 svn commit
- 用户未回复 → **不允许**自动提交或假设同意

不允许：
- ❌ 不等用户回复直接执行 `svn commit`
- ❌ 用户没回复就当作"默认同意"
- ❌ 用户说"看着办"就跳过审批——必须显式 y/n

### 4. 执行提交

根据是否有 body，选择不同方式：

**无 body（单行 message）**：

```bash
svn commit -m "<type>(<scope>): <task_id?> <summary> [<ac?>] [<req_id?>]"
```

**有 body（多行 message）**：

SVN 不支持 HEREDOC 语法。使用 `--file` 从 stdin 读取：

```bash
svn commit --file /dev/stdin <<'EOF'
<type>(<scope>): <task_id?> <summary> [<ac?>] [<req_id?>]

- 详细说明行 1
- 详细说明行 2
EOF
```

> 注意：SVN 的 `-m` 参数在部分客户端对多行支持不佳，统一用 `--file /dev/stdin` + HEREDOC 传递多行 message 可避免 shell 转义问题。

### 5. 验证

```bash
svn log -rHEAD:HEAD -v
```

确认：
- message 与预期一致
- 变更文件列表与步骤 3 展示的一致
- 记录 SVN revision 号（`r<N>` 格式），用于后续追溯

## 输出

```md
## svn-commit-message 执行结果
- 状态: committed / aborted
- revision: r<N>
- message: <header>
- 关联: req=<req_id> ac=<ac> task=<task_id>
```

## 类型清单

| 类型 | 用途 | 示例 |
|---|---|---|
| `feat` | 新功能 | `feat(auth): 添加 token refresh` |
| `fix` | bug 修复 | `fix(api): 修复并发写入丢失` |
| `refactor` | 重构（不改外部行为） | `refactor(user): 抽出 service 层` |
| `perf` | 性能优化 | `perf(list): 改用虚拟列表` |
| `test` | 加/改测试 | `test(auth): 补 refresh 接口测试` |
| `docs` | 文档（含 spec/design/notes） | `docs(req-x): 补需求边界说明` |
| `style` | 格式化（不改语义） | `style: 统一缩进` |
| `chore` | 杂项（依赖/构建配置） | `chore: 升级 react 18.2 → 18.3` |
| `build` | 构建系统 | `build: 调整 webpack 配置` |
| `ci` | CI/CD | `ci: 加 lint job` |
| `revert` | 回退 | `revert: 撤销 r12345` |
| `vibe` | vibecoding 迭代提交（agile-vibe iteration 阶段） | `vibe(req-x): 第 2 轮迭代` |

## 边界与陷阱

> [!WARNING]
> **SVN commit = 立即推送到服务器，不可撤销**。必须经过步骤 3 的用户审批才能执行。这是与 git 版本最大的区别——git commit 只是本地提交，还可以 amend / reset；SVN commit 一旦执行无法回退。

> [!IMPORTANT]
> 一次 commit 对应一个**原子改动**。如本次改动跨多个 task / 多个 AC，应该拆成多个 commit。

- ❌ 不要 summary 写 "更新代码" / "修改 bug" / "wip" 这种没信息量的
- ❌ 不要 summary 末尾加句号
- ❌ 不要在一个 commit 混合 feat + refactor + chore
- ❌ 不要 commit message 含 ANSI 控制字符 / emoji（除非项目明确要求）
- ❌ 不要把临时调试代码 commit 后说"以后再删"——SVN 没有 fixup / reset
- ❌ 不要在 `-m` 中拼接多行 message——shell 转义和 SVN 客户端兼容性都不可靠，统一用 `--file /dev/stdin` + HEREDOC
- ✅ 用 `--file /dev/stdin` + HEREDOC 传递多行 message
- ✅ 关联 req-id / ac / task_id 让链路可追溯
- ✅ 记录 SVN revision 号（`r<N>`），不是 git SHA
- ✅ 提交前必须展示 `svn status` + `svn diff` 并获得用户 y/n 确认

### SVN 特有陷阱

- **不可撤销**：与 git 的核心区别。git commit 后还能 `git reset`；SVN commit 后只能用 `svn merge --reverse` 回滚（等价于新 commit，且须用户审批）。详见规则 `00-engineering-principles.mdc`。
- **无本地提交**：不存在"先 commit 再 push"的两步。SVN commit 即推送。所有审批必须在 commit 之前完成。
- **Revision 号 vs SHA**：SVN 用全局递增 revision 号（`r12345`），不是 git 的 SHA-1 hash。在 `process.txt`、`meta.yaml` 的 `svn_revision_range`、`spec/commit-AC-map.md` 中统一用 `r<N>` 格式。
- **`-m` 多行兼容性**：不同 SVN 客户端（命令行 / TortoiseSVN / IDE 插件）对 `-m "line1\nline2"` 的解析不一致。安全做法：单行用 `-m`，多行用 `--file`。

## 关联 Skill

- `progress-logger`：commit 后追加 process.txt 时引用本 commit 的 revision 号（`r<N>`）
- `managing-requirement` 的 `complete_task` operation：会把 commit revision 写回 tasks/features.json
- `use-svn-branch`：分支创建 / 切换 / 合并的 SVN 操作规范

## 变更历史

| 日期 | 版本 | 变更 | 触发原因 | 操作者 |
|---|---|---|---|---|
| - | 0.1.0 | 基于 git-commit-message 改写为 SVN 版本，增加强制用户审批步骤 | 项目从 git 迁移到 SVN | template |
