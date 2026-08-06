---
description: "查看某个 SOP 的详细定义"
argument-hint: "<sop-name>"
allowed-tools: [Read, AskUserQuestion]
model: sonnet
---

# /sop-show — 查看 SOP 详情

## 步骤

### 1. 解析 sop-name

从 `$ARGUMENTS` 取。如缺失先跑 `/sop-list` 让用户选。

### 2. 读取并展示

```
Read .codebuddy/sop/<sop-name>.md
```

直接展示完整内容，并补一段"实战速查"：

```md
## 实战速查

- **如何启动**: `/pm-new`，询问时选择此 SOP
- **如何切换到此 SOP**: 修改需求 `meta.yaml` 的 `sop:` 字段
- **每阶段委派**: 见 主会话 agent 的"阶段 → Agent 映射"
- **跳过阶段**: 慎用 `/pm-phase` 强制切换
```
