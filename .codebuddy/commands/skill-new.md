---
description: "创建新的 Skill：按模板生成 SKILL.md、references/、INDEX 同步，不走自进化协议（首次创建 vs 演进有本质区别）"
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
model: sonnet
---

# /skill-new — 创建新 Skill

## 何时使用

- 同一类操作做到第 3 次时（3-Time Rule，`10-vibecoding-protocol.mdc` 第 5 条）
- 用户明确说"把这个封装成 Skill"
- 已有 2 个以上需求踩了同样的坑，需要标准化处理流程

## 入参

| 输入 | 类型 | 必需 | 说明 |
|---|---|:-:|---|
| skill_name | string | ✓ | Skill 名称（kebab-case） |
| category | enum | ✓ | `core` / `workflow` / `domain` |
| source_req_id | string | 可选 | 触发本次封装的需求 ID（留档用） |
| description | string | ✓ | 一句话描述 |

## 步骤

### 1. 读取模板

Read `.codebuddy/skills/_meta/SKILL_TEMPLATE.md` 作为蓝本。

### 2. 生成 Skill 文件

Write 新文件到 `.codebuddy/skills/<category>/<skill_name>/SKILL.md`：

1. frontmatter：`name` / `description` / `tools`（根据场景推断）
2. 正文：按模板结构填写
   - 何时使用（用户场景）
   - 输入（参数表）
   - 步骤（逐条）
   - 输出（结果格式）
   - 边界与陷阱
   - 关联 Skill（引用已有 Skill）
   - 引用资料（默认 references/level-classification.md、references/retrieval-pattern.md）
3. 如需要 references/ 目录：同时创建并写入默认值

### 3. 同步索引

更新 `.codebuddy/skills/INDEX.md`：
- 在对应 category 下新增条目
- 确保总数正确

### 4. 写变更历史

在 SKILL.md 末尾追加：

```
## 变更历史

| 日期 | 版本 | 变更 | 触发原因 | 操作者 |
|---|---|---|---|---|
| 2026-XX-XX | 0.1.0 | 初始创建 | <source_req_id> 触发 / 3-Time Rule | <agent-name> |
```

## 与 skill-evolve 的区别

| | /skill-new | /skill-evolve |
|---|---|---|
| 场景 | 首次创建新 Skill | 改进已有 Skill |
| 来源 | 3-Time Rule / 用户要求 | self-improving-agent 扫描 / 用户要求 |
| 协议 | **不走**自进化协议（没有旧版可比较） | **必须走** `30-skill-self-evolution` 5步协议 |
| 产物 | 全新 SKILL.md | SKILL.md diff + 变更历史追加 |

## 输出

```md
## /skill-new 执行结果
- 状态: completed
- 新 Skill: `.codebuddy/skills/<category>/<skill_name>/SKILL.md`
- INDEX 同步: ✓
- 变更历史: 已写入（v0.1.0）
- 下一步: 新 Skill 可立即被 `managing-requirement` 或 `/doctor` 调用
```
