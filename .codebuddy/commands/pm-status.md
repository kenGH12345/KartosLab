---
description: "列出所有需求与当前状态"
allowed-tools: [Read, Bash, Glob]
model: sonnet
---

# /pm-status — 需求总览

## 步骤

### 1. 读取 INDEX

```

读 requirements/INDEX.md
```

### 2. 校验一致性

对每个需求条目：
- 验证目录 `requirements/<req-id>/` 存在
- 读 `meta.yaml`，对比 INDEX 里的 `status` / `phase` 是否一致
- 不一致 → 标注 `⚠️ INDEX 与 meta.yaml 不一致`

### 3. 输出表格

```md
## 需求总览（{{N}} 个）

| Req ID | 标题 | SOP | Phase | Status | 最近更新 | 备注 |
|---|---|---|---|---|---|---|
| req-foo | ... | agile-vibe | 3.iteration | in_progress | 2 天前 |  |
| req-bar | ... | deep-vibe | 5.finalizing | done | 5 天前 | ✅ |
| req-baz | ... | agile-vibe | 1.init | draft | 1 周前 | ⚠️ 长期未推进 |

## 统计
- 进行中: X
- 已完成: Y
- 待启动: Z
- INDEX 异常: K（建议跑 /doctor 修复）
```

### 4. 主动建议

如有 `⚠️` 项，建议用户跑 `/doctor` 校验。
如有"长期未推进"（updated_at > 7 天），询问是否归档或继续。
