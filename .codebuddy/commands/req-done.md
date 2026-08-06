---
description: "标记某任务完成"
argument-hint: "<req-id> <task-id>"
allowed-tools: [Read, Edit, Bash, AskUserQuestion]
model: sonnet
---

# /req-done — 标记任务完成

## 步骤

### 1. 解析参数

从 `$ARGUMENTS` 取 `<req-id>` 与 `<task-id>`。

### 2. 校验前置

读 `tasks/features.json`：
- 任务存在 → 继续
- 任务不存在 → 报错并列出所有 task 让用户选
- 任务已 done → 提示并取消

如有 `depends_on`，校验依赖项均已 `done`；否则警告并要求用户确认强制完成。

### 3. 收集完成证据（可选但推荐）

```
- 关联 commit(s): 如可定位
- 验证结果: 测试通过 / 截图 / 日志
- 备注: 与计划的偏离（如有）
```

### 4. 更新 tasks/features.json

```json
{
  ...,
  "status": "done",
  "completed_at": "<time>",
  "commits": ["<sha>", ...],
  "verification": "...",
  "notes": "..."
}
```

### 5. 追加 process.txt

```
[time] 完成任务 task-N: <title>
  → commits: <shas>
  → 验证: <verification>
```

### 6. 检查是否全部完成

如所有任务都 done，提示用户：
- 可以进入下一阶段（按 SOP，通常是 test-runner 或 code-reviewer）
- 询问是否触发 `/code-review`
