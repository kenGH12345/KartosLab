---
description: "对当前需求或指定 revision 范围跑代码评审"
argument-hint: "[<req-id>] [r<base>:r<head>]"
allowed-tools: [Task, Bash, AskUserQuestion]
model: sonnet
---

# /code-review — 代码评审

## 步骤

### 1. 解析参数

从 `$ARGUMENTS`：
- 如有 `<req-id>` → 评审范围 = 该需求关联的 revisions
- 如有 `r<base>:r<head>` → 评审范围 = 该 SVN revision 范围
- 都没有 → 用 `AskUserQuestion` 让用户选 / 输入

### 2. 校验 revision 范围

```bash
svn log -r<base>:<head>
svn diff -r<base>:<head> --summarize
```

向用户展示范围，确认无误。

### 3. 委派 code-reviewer

用 `Task` 工具委派 `code-reviewer` agent，prompt 包含：
- req-id（如有）
- revision 范围（r<base>:r<head>）
- 提示："按三视角评审：实现质量 / 需求一致性 / 方案一致性"

### 4. 等待返回

按返回的 `当前状态` 处理：
- `passed` → 通知用户，建议进入 `closer`
- `has_blockers` → 列出 Blocker，问用户是否退回 dev 修复
- `has_majors_only` → 让用户决定是否接受 Major 项推迟
