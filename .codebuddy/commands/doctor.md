---
description: "工程健康检查（state 一致性 / 资产完整性 / 链接有效性）"
allowed-tools: [Read, Bash, Glob, Grep]
model: sonnet
---

# /doctor — 工程健康检查

## 步骤

### 1. 调用 doctor 脚本（如已有）

```bash
./.codebuddy/scripts/doctor.ps1
```

如脚本未实现，按以下手工检查：

### 2. 资产完整性

| 检查 | 通过条件 |
|---|---|
| `.codebuddy/rules/*.mdc` ≥ 8 个 | ✓ |
| `.claude/agents/*.md` ≥ 14 个 | ✓ |
| `.claude/commands/*.md` ≥ 16 个 | ✓ |
| `.cursor/commands/*.md` 与 `.claude/commands/*.md` 数量一致 | ✓ |
| `.codebuddy/rules/*.mdc` ≥ 8 个（镜像自 .codebuddy/rules/） | ✓ |
| `.codebuddy/agents/*.md` ≥ 14 个（镜像自 .claude/agents/） | ✓ |
| `.codebuddy/commands/*.md` 与 `.claude/commands/*.md` 数量一致（三端对称） | ✓ |
| `CODEBUDDY.md` 存在 | ✓ |
| `.codebuddy/skills/INDEX.md` 列出的 Skill 都存在 | ✓ |
| `requirements/INDEX.md` 列出的需求都存在 | ✓ |

### 3. 状态一致性（需求维度）

对每个需求：
- `meta.yaml` 的 `phase` / `status` 与 `process.txt` 最近一行一致
- 如 `status=done`：`spec/最终需求.md` 存在
- 如 `phase` 在 design 之后：`design/技术方案.md`（deep-vibe）或 `design/` 非空（agile-vibe）存在

### 4. 链接有效性

| 检查 | 通过条件 |
|---|---|
| .codebuddy/docs/ 下所有 `[文字](路径)` 链接的目标存在 | ✓ |
| .codebuddy/skills/ 下 SKILL.md 引用的 references / scripts 存在 | ✓ |
| context/ 下 INDEX.md 列出的子文档都存在 | ✓ |

### 5. 占位符遗留

```
Grep "../trunk/" --glob "**/*.md"
Grep "WepopAIVibeCodingProj" --glob "**/*.md"
```

模板内的占位符正常；但 AGENTS.md / CLAUDE.md / 已 done 的需求里仍有占位符需提示。

### 6. 输出报告

```md
## 健康检查报告

### ✓ 资产
- Rules: X / 8
- Agents: Y / 13
- Commands: Z / 16

### ⚠️ 状态不一致（N 项）
- req-foo: meta.yaml 显示 phase=2.design，但 process.txt 显示已完成 task → 建议跑 /pm-continue 重新对齐

### ❌ 链接断裂（M 项）
- .codebuddy/docs/ARCHITECTURE.md → .codebuddy/docs/legacy.md (不存在)

### ⚠️ 占位符遗留（K 项）
- AGENTS.md: WepopAIVibeCodingProj 未替换

### 建议修复优先级
1. ❌ 链接断裂 → 立即修
2. ⚠️ 状态不一致 → 跑 /pm-continue 或手工核对
3. ⚠️ 占位符 → 用户填值
```

### 7. 不自动修复

`/doctor` **只诊断不修复**。修复由用户根据报告决定。
