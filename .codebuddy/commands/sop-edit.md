---
description: "编辑或创建 SOP（先提案后修改）"
argument-hint: "<sop-name>"
allowed-tools: [Read, AskUserQuestion, Task]
model: sonnet
---

# /sop-edit — 编辑 SOP

> [!IMPORTANT]
> SOP 是流程结构资产，**不允许静默修改**。本命令会先收集变更意图，输出提案，等用户确认后才应用。

## 步骤

### 1. 解析 sop-name

从 `$ARGUMENTS` 取。新 SOP → 提示 "将基于 .codebuddy/sop/_template_sop.md 创建"；现有 SOP → 读取展示。

### 2. 收集变更意图

用 `AskUserQuestion`：
- 新增阶段 / 修改阶段 / 删除阶段 / 改阶段委派的 Agent / 改回退规则 / 其他
- 变更原因

### 3. 输出变更提案

```md
## SOP 变更提案

**SOP**: .codebuddy/sop/<name>.md
**原因**: <用户填的原因>

### 变更点
- 阶段 N 委派改为 <new-agent>（原 <old-agent>）
- 新增回退路径：阶段 X → 阶段 Y（条件：...）
- ...

### 影响面
- 涉及的 agent: ...
- 涉及的 commands: ...（如需同步改）
- 历史已 done 的需求: 不影响（SOP 变更不追溯）
- 进行中的需求: 受影响（建议跑完当前阶段再切换）

### 是否应用？(y/n)
```

### 4. 等待确认

- `y` → 用 Edit 工具应用变更，并更新 `.codebuddy/sop/INDEX.md`
- `n` → 取消

### 5. 应用后建议

如变更涉及 agent 委派关系，提醒用户 review 对应 agent 的 frontmatter description（可能需同步调整）。
