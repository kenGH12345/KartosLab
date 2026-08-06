---
description: "触发 Skill 自进化协议（30-skill-self-evolution）：诊断→提案→用户确认→应用→记录变更历史。被 /improve 命令和 self-improving-agent 调用。"
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion]
model: sonnet
---

# /skill-evolve — 触发 Skill 自进化协议

## 何时使用

- `/improve` 扫描出的 Skill 改进提案，用户确认 `y` 后
- 用户直接发现 Skill 问题，要求走 5 步协议
- `self-improving-agent` 的「重复踩坑」证据指向某 Skill

## 入参

| 输入 | 类型 | 必需 | 说明 |
|---|---|:-:|---|
| skill_name | string | ✓ | 目标 Skill 名称（如 `managing-knowledge`） |
| trigger_source | string | ✓ | 触发来源（`improve-scan` / `user-feedback` / `dogfood`） |
| evidence | string | ✓ | 证据引用（如 `req-aaa/notes.md:45`，至少 2 条） |

## 步骤

### 1. 加载现状（诊断）

Read `.codebuddy/skills/core/<skill_name>/SKILL.md`

在 process.txt 写诊断摘要：
```
[time] /skill-evolve <skill_name>: 触发诊断
- 当前版本: <version>
- 变更历史条目数: N
- 触发证据: <evidence>
```

### 2. 拟定修改（提案）

分析证据与 Skill 现状的差距，生成诊断 + 拟修：

```md
## Skill 演进提案: <skill_name>

### 诊断
- 现状: 当前 Skill 怎么写的（引用 file:line）
- 现象: 实际跑出来什么问题（引用 evidence）
- 根因: 为什么会这样

### 拟定修改
- diff: before / after
- 影响面: 哪些 agent/skill/command 引用了这部分
- 兼容性: 旧产物是否仍可读

### 建议动作
- [ ] 修改 SKILL.md 具体段落
- [ ] 是否需要同步更新 references/
- [ ] 是否需要通知关联 agent
```

### 3. 等待用户确认

用 `AskUserQuestion` 向用户展示诊断 + 拟修，等待 `y/n`。

### 4. 应用修改（用户回 y）

- 修改 `.codebuddy/skills/<category>/<skill_name>/SKILL.md`
- 在末尾追加变更历史（blockquote 风格，与 30/35/40 协议族同构）：
  ```
  > YYYY-MM-DD by <trigger_source>: 一句话摘要。
  > - 改动 1（含 file:line）
  > - 改动 2
  > - 实证触发: <evidence>
  ```
- 如影响面涉及其他 agent/skill：同步更新引用

### 5. 同步镜像

如需修改 `.claude/` 侧内容：**必跑** `sync-codebuddy` 脚本，确保三端一致。

## 输出

```md
## /skill-evolve 执行结果
- 状态: completed（用户 y）/ rejected（用户 n）
- 目标 Skill: <skill_name>
- 变更历史已追加: ✓
- 同步: <sync 结果>
- 报告: .vibe/cache/skill-evolve-<skill_name>-<date>.md
```

## 硬性约束（来自 `30-skill-self-evolution.mdc`）

- ❌ **绝对禁止**直接 Edit SKILL.md 不走此协议
- ❌ 禁止在没获得用户确认前应用任何修改
- ❌ 禁止瞒报影响面（必须 grep 所有引用方）
- ✅ 每条变更历史必须含实证引用
- ✅ 修改后 SKILL.md 依然能被 Read 工具正确加载
