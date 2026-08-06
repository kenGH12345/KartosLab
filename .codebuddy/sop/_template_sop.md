<!--
SOP 模板。
新建 SOP 的步骤：
  1. 复制本文件为 .codebuddy/sop/<sop-name>.md
  2. 替换所有 <尖括号> 占位符
  3. 删掉本注释块
  4. 在 .codebuddy/sop/INDEX.md 表格里加一行
  5. 用 /sop-list 验证可被识别

SOP 是流程结构资产，修改与新建应通过 /sop-edit 命令走"先提案后修改"流程。
-->

---
# 必填
name: <sop-name>           # kebab-case，与文件名一致
version: 0.1.0
adopts_from:               # 可选：基于哪个 SOP 演化而来
  - agile-vibe

# 必填：一句话讲清楚适用场景
description: <一句话>

# 必填：阶段总数
phase_count: <N>

# 可选：标签，便于 /sop-list 过滤
tags:
  - lightweight
  - <other>

# 必填：每个阶段的概览（详细定义在正文）
phases:
  - id: 1
    name: <阶段名>
    short: <一行说明>
    primary_agent: <agent-name>
  - id: 2
    name: <...>
    short: <...>
    primary_agent: <...>
---

# <SOP 显示标题>

> <一段引子，2-3 句话讲清楚本 SOP 的核心理念与适用场景。>

## 适用场景

- ✅ <场景 A>
- ✅ <场景 B>
- ❌ <不适用场景 X>

## 阶段总览

```mermaid
flowchart LR
  A[阶段 1: 名称] --> B[阶段 2: 名称]
  B --> C[阶段 3: 名称]
  C --> D[阶段 N: 名称]
```

## 阶段详解

### 阶段 1：<名称>

**主要 Agent**: `<agent-name>`
**目标**: <一句话>
**入参**: <从上一阶段或主会话获取什么>
**产出**: <文件路径列表>
**完成标准**:
- [ ] <可勾选的明确条件>
- [ ] <...>

**子步骤**:

1. <步骤 1>
2. <步骤 2>
3. <步骤 N>

**回退条件**: <在什么情况下应回退到哪个阶段>

---

### 阶段 2：<名称>

<同上结构>

---

### 阶段 N：<名称>

<同上结构>

---

## 状态机

每个需求在本 SOP 下的状态在 `meta.yaml` 中通过两个字段表达：

| 字段 | 含义 | 取值 |
|---|---|---|
| `phase` | 当前阶段（数字或带名字） | `1.init` / `2.<name>` / ... |
| `status` | 当前阶段内的状态 | `draft` / `in_progress` / `awaiting_user_input` / `blocked` / `done` |

阶段切换时**必须**按规则 `45-state-sync-protocol.mdc` 的"先写状态后做事"顺序：

1. 改 `meta.yaml`（phase / status / updated_at）
2. 追加 `process.txt`
3. 调用下游 agent

## 与其他 SOP 的关系

- <相对于其他 SOP 的差异点>
- <何时切换到其他 SOP>

## 自定义建议

- <用户可以在本 SOP 上做什么样的微调而不破坏框架>
