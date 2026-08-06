---
description: "给某需求追加一个任务（task）"
argument-hint: "<req-id> <task-title>"
allowed-tools: [Read, Edit, Write, AskUserQuestion]
model: sonnet
---

# /req-add — 追加任务

## 步骤

### 1. 解析参数

从 `$ARGUMENTS` 取 `<req-id>` 与 `<task-title>`。如缺失用 `AskUserQuestion`。

### 2. 收集任务元数据

```
- 对应验收项: AC-N（必填，如该需求无 AC 体系则填 "n/a"）
- 涉及文件: 路径列表（可空）
- 依赖任务: task-N（可空）
- 验证方式: 一句话（可空）
- 责任端: FE / BE / Full-stack
```

### 3. 写入 tasks 文件

读取 `requirements/<req-id>/tasks/features.json`（如不存在则创建）。
追加一条任务记录：

```json
{
  "id": "task-<auto-incr>",
  "title": "<task-title>",
  "ac": "<AC-N>",
  "files": [...],
  "depends_on": [...],
  "verify": "...",
  "owner": "FE/BE/Full-stack",
  "status": "pending",
  "created_at": "<time>"
}
```

### 4. 追加 process.txt

```
[time] 追加任务 task-N: <title>
```

### 5. 输出

向用户汇报：
- 新任务 ID
- 当前 pending 任务数
- 提醒：如要立即开始，可委派对应 dev agent
