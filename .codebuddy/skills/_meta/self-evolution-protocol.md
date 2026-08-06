# Skill 自进化协议

> Skill 不是一次性写完就放着的——它会被使用、会被踩坑、会被发现遗漏。
> 这份协议规定了「**Skill 怎么进化才不会失控**」。

## 核心原则

> [!IMPORTANT]
> **绝不允许 AI 静默修改 Skill 文件**。
> 所有 Skill 改动必须走「**诊断 → 提案 → 用户确认 → 应用 → 记录**」五步。

为什么？因为 Skill 是协作的标准操作手册，如果 AI 可以随手改，几个 session 后没人知道为什么 Skill 变成现在这样、变更是基于哪次实践——这套体系就废了。

## 何时触发演进

四类触发原因：

| 类型 | 描述 | 典型来源 |
|---|---|---|
| **执行报错** | 按 Skill 跑下来发生了错误 | 命令失败、路径不存在、工具不支持 |
| **逻辑修正** | Skill 步骤本身有逻辑漏洞或顺序错误 | 应该先 X 再 Y，结果写成先 Y 再 X |
| **用户反馈** | 用户明确说"这个 Skill 应该改成 ..." | 评审、回顾会、聊天 |
| **低效路径** | Skill 能跑通但有更简洁/可靠的方法 | 通过 3 次实践发现的优化 |

**不触发演进的情况**：

- 单次特殊场景的特殊处理 → 写在需求 `notes.md`，不污染 Skill
- 用户希望大改方向 → 通常应该新建 Skill 而非演进现有的
- AI 自己"觉得不对"但没具体证据 → 不演进

## 5 步流程

### 步骤 1：诊断（Diagnosis）

由调用方（主会话或 `/skill-evolve` 命令）告诉 `skill-architect` agent：

- 哪个 Skill 有问题
- 触发原因（上面四类之一）
- 具体证据（错误信息 / 用户反馈原文 / 实际成功的做法）

`skill-architect` 在脑中精确定位：

- 是哪一节？哪一行？
- 是文档**写错了**、**过时了**，还是**遗漏边缘情况**？

### 步骤 2：拟定优化（Drafting）

`skill-architect` **在脑中**生成优化后的版本（**不直接 Write/Edit**）。

- 保持原 Skill 的章节结构
- 只改受影响部分
- 加 `> [!WARNING]` 或 `> [!IMPORTANT]` 标注踩过的坑
- 替换错误命令而非追加（不留两个版本让读者选）

### 步骤 3：输出提案（Proposal）

`skill-architect` 用以下**标准格式**输出提案：

```md
## Skill 优化提案

**Skill**: .codebuddy/skills/<group>/<name>/SKILL.md
**触发原因**: [执行报错 / 逻辑修正 / 用户反馈 / 低效路径]
**根因**: <一句话说清楚问题在哪>

### 变更点

- **第 N-M 行**:
  ```
  - 原文: <old>
  + 新文: <new>
  ```
  （理由：...）

- **新增 Attention 段**（建议加在第 X 行后）:
  ```markdown
  > [!WARNING]
  > <内容>
  ```

### 预期效果

<这次变更能避免什么具体问题>

### 是否应用？(y/n)
```

### 步骤 4：用户确认与应用

主会话把提案展示给用户：

- 用户回复 `y` → `skill-architect` 用 `Edit` 工具按提案应用
- 用户回复 `n` → `skill-architect` 把提案存到 `.vibe/cache/skill-evolution-pending.md`
- 用户提修改意见 → 调整提案，再次确认

### 步骤 5：记录变更

应用后：

1. 在 SKILL.md 末尾的「变更历史」表追加一行
2. （可选）维护项目级 `.codebuddy/skills/CHANGELOG.md`，集中记录跨 Skill 演进

```md
| YYYY-MM-DD | 0.2.0 | 修正第 3 步命令；新增 Warning 段 | 用户反馈 / req-xxx | skill-architect |
```

## 反模式

| 反模式 | 为什么不行 |
|---|---|
| AI 直接 Edit Skill 文件 | 失去可追溯性、用户失控 |
| 一次提案改 5 处不相关的事 | 评审困难、回滚困难 → 拆成多次提案 |
| 演进时改了引用的 references/scripts | 应该在提案里明确"同步改 references X" |
| "顺手"加新 Skill | 有 3-Time Rule 才能新建（见 `10-vibecoding-protocol.mdc`），单次特殊处理不算 |
| 在 description 里加版本号或 changelog | description 是给 AI 看的"何时用"，不是版本说明 |

## 与其他规则的关系

- **`30-skill-self-evolution.mdc`**（Cursor rule）：在 IDE 层面的硬约束，禁止主会话静默改 Skill；本协议是详细操作手册
- **`/skill-evolve` 命令**：演进的常规入口
- **`skill-architect` agent**：演进的执行者
- **`.codebuddy/skills/_meta/skill-authoring-guide.md`**：Skill 创作指南（演进与创作的写作规范一致）

## 触发演进的"小红旗"清单

主会话或用户在以下情况应主动想到要不要演进 Skill：

- [ ] 上一次按 Skill 操作时报了错，且不是 Skill 引用的资源问题
- [ ] 用户在 review 中说"这步应该 / 不应该 ..."
- [ ] 同样的 Skill 已经被用了 3 次以上，且每次都有人手动调整某一步
- [ ] 跑 `/doctor` 报告 Skill 引用的资源缺失
- [ ] 项目知识库中出现了 Skill 应该知道但没写的约定
