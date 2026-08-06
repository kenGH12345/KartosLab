---
description: "强制切换需求到指定阶段（慎用，仅在状态文件与实际不符时修复用）"
argument-hint: "<req-id> <phase>"
allowed-tools: [Read, Edit, Write, AskUserQuestion]
model: sonnet
---

# /pm-phase — 强制切换阶段

> [!WARNING]
> 这是**修复性命令**，不是常规推进。常规推进用 `/pm-continue`。
>
> 强制切换会：
> - 跳过当前阶段的产物校验
> - 可能让需求处于不一致状态
> - 必须有充分理由

## 步骤

### 1. 解析参数

从 `$ARGUMENTS` 取 `<req-id>` 与 `<phase>`。
如缺失，用 `AskUserQuestion` 收集。

### 2. 列出可达阶段

读 `meta.yaml` 中的 `sop` 字段，加载对应 SOP 定义，列出所有阶段。
让用户从合法阶段中选。

### 3. 二次确认

显示：
```
⚠️ 强制切换警告

需求: <req-id>
当前阶段: <current>
目标阶段: <target>
理由: （让用户填）

这会跳过当前阶段的产物校验。
是否继续？(yes/no)
```

只有用户输入完整的 `yes`（不接受 `y`）才继续。

### 4. 执行切换

按规则 `45-state-sync-protocol.mdc` 的"先写后做"顺序：

1. `meta.yaml`: 改 `phase`、`status`、`updated_at`，**追加 `phase_overrides` 段**记录强制切换历史：
   ```yaml
   phase_overrides:
     - timestamp: "..."
       from: <current>
       to: <target>
       reason: "<用户填的理由>"
   ```
2. `process.txt` 追加：`[time] ⚠️ 强制切换阶段 <current> → <target>，理由：...`

### 5. 不自动委派下游 agent

强制切换后**不主动**委派下游。让用户自己用 `/pm-continue` 决定怎么走。

### 6. 提醒

明确告知用户：
- 已切换
- 建议跑 `/doctor` 校验需求一致性
- 如发现产物缺失，可以补做或退回
