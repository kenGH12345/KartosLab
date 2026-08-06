<!--
本文件是创作 Skill 时的标准模板。
使用方式：复制本文件到 .codebuddy/skills/<group>/<skill-name>/SKILL.md，按注释逐段填空，最后删掉所有注释。
所有 <尖括号> 的占位符都要替换为真实内容。

详细写作指南见 .codebuddy/skills/_meta/skill-authoring-guide.md。
-->

---
# 必填：kebab-case，与目录名一致。AI 通过此名字识别 Skill。
name: <skill-name>

# 必填：一句话讲清"何时该用这个 Skill"。
# 这是 AI 决定是否加载本 Skill 的关键依据，越具体越好。
# 反例：用于处理需求 ❌
# 正例：用于在创建新需求时按 SOP 生成符合规范的需求文档骨架 ✅
description: <一句话说清楚何时用本 Skill；80 字以内为佳>

# 可选：本 Skill 推荐使用的工具列表（白名单提示，不强制）
# 如果省略则继承当前 agent 的工具白名单
# tools: Read, Write, Edit, Bash, Glob, Grep

# 可选：本 Skill 推荐使用的模型层级
# model: claude-sonnet-4

# 可选：本 Skill 引用的其他 Skill（用于建立依赖关系）
# depends_on:
#   - other-skill-name
---

# <Skill 显示标题>

> <一段引子，2-3 句话讲清楚本 Skill 的"原理与价值"——为什么这套步骤是对的。>

## 何时使用

<列出触发本 Skill 的场景。要尽量具体，能让 AI / 人通过场景描述判断"现在是不是该用这个"。>

- 场景 1：<具体描述>
- 场景 2：<具体描述>
- 不该用的场景（避免误用）：<具体描述>

## 输入

<列出本 Skill 的输入。每项标注是否必需。>

| 输入 | 类型 | 必需 | 说明 |
|---|---|:-:|---|
| <name> | <string/path/json/...> | ✓ | <说明> |

## 步骤

<编号步骤，每步都可以独立执行。复杂步骤拆分子步骤。>

### 1. <步骤标题>

<步骤说明 + 必要时给具体命令/代码示例>

```bash
<示例命令>
```

### 2. <步骤标题>

<...>

### 3. <步骤标题>

<...>

## 输出

<本 Skill 完成后会产出什么。如果是文件，明确路径与格式。>

- 产出文件 1：`<path>` —— <说明>
- 产出摘要给主会话：

```md
## <Skill 名称> 执行结果
- 状态: completed / partial / blocked
- 产出: <path>
- 关键数据: ...
- 下一步建议: ...
```

## 边界与陷阱

<列出常见错误用法、易踩的坑、不要做什么。这一段是 Skill 的"安全护栏"，往往比正向步骤更重要。>

> [!WARNING]
> <一条最容易踩的坑>

> [!IMPORTANT]
> <一条不允许违反的硬约束>

- ❌ 不要 <...>
- ❌ 不要 <...>
- ✅ 应该 <...>

## 引用资料

<可选段落。如果本 Skill 有 references/ 目录，在此列出。>

- [<reference-name>](references/<file>) —— <说明>

## 关联 Skill

<可选段落。如果本 Skill 与其他 Skill 经常配合使用，在此说明。>

- 通常在 <skill-A> 之后调用
- 完成后通常调用 <skill-B>

## 变更历史

<可选段落。skill-architect 每次演进时追加一行。新 Skill 此段为空。>

| 日期 | 版本 | 变更 | 触发原因 | 操作者 |
|---|---|---|---|---|
| YYYY-MM-DD | 0.1.0 | 初始创建 | - | <user/agent> |
