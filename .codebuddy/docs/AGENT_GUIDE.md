# Subagent 指南

> 14 个 subagent，按"职责单一 + 边界明确"组织，覆盖 vibecoding 全链路。
>
> Subagent 是 Claude Code / CodeBuddy 原生概念（独立上下文 + 专职 prompt + tool whitelist），二者使用同一份 frontmatter schema，本模板的 `.claude/agents/*.md` 与 `.codebuddy/agents/*.md` 是镜像同步关系（详见 [ADR-0004](ADR/0004-codebuddy-native-mirror.md)）。Cursor 暂无原生 agent，通过 commands + rules 模拟同等效果。

## 角色清单

| Agent | 职责 | 何时被委派 |
|---|---|---|
| 主会话 | **路由器**——读 meta 决定下一步该委派谁，**不做任何专业判断** | 主会话遇到需求推进时 |
| `product-manager` | 需求澄清，产出 `spec/需求简述.md` 或 `spec/需求文档.md` | SOP 需求阶段 |
| `tech-leader` | 全栈技术专家，复杂度评估、协作模式选择 | SOP 设计阶段 |
| `frontend-leader` | 前端方案细化（组件、状态、UI、性能） | SOP 设计阶段 |
| `backend-leader` | 后端方案细化（数据模型、API、并发、可观测） | SOP 设计阶段 |
| `design-reviewer` | **只评审不修改**——查方案完整性、一致性、可行性、风险 | SOP 设计阶段末 |
| `frontend-dev` | 前端实现，含视觉反馈（截图） | SOP 编码阶段 |
| `backend-dev` | 后端实现，含 DB 迁移脚本与自验证 | SOP 编码阶段 |
| `test-runner` | **只跑不解释**——基线对比，识别新增失败 | SOP 测试阶段 / 编码阶段末 |
| `code-reviewer` | 三视角评审：实现质量 / 与需求一致 / 与方案一致 | SOP 收尾阶段 |
| `closer` | 需求收尾，生成最终快照 + 整理 notes | SOP 收尾阶段末 |
| `knowledge-maintainer` | 把项目级发现写回 `context/project/` | 需求收尾时；或主动维护 |
| `skill-architect` | Skill 创作/演进，遵守"提案-后修改" | `/skill-new` `/skill-evolve` |
| `cascade-orchestrator` | 复杂任务 DAG 编排（**默认禁用**） | `/cascade-run` 或主会话识别为多需求/多模块/强依赖时 |

详细 prompt 见 `.claude/agents/<name>.md` 各文件。

## 委派机制

### Claude Code

```text
(主会话) → Task(subagent_type="product-manager", description="澄清登录功能需求", prompt="...")
```

主会话**严禁**直接做阶段产物。所有阶段工作必须通过 `Task` 委派。

### Cursor

Cursor 暂无原生 subagent 机制——通过 commands + rules 模拟：

- 用户输入 `/pm-new` → Cursor 加载 `.cursor/commands/pm-new.md` 的内容
- Command 内容里会指示主会话"按 product-manager 的 persona 行事"
- `.codebuddy/rules/` 里的 `00-engineering-principles.mdc` 等约束依然生效

效果上接近 subagent，但**不是真正的独立上下文**。

## 用户回答回流规则（重要）

如果用户回答的是某 agent 的提问，**主会话必须重新委派该 agent 继续处理**，不得自己把回答写进阶段产物。

**例**：

```text
product-manager 委派结束 → 输出 5 个澄清问题给用户
↓
用户回答
↓
主会话: 不能自己改 spec/需求简述.md
        必须再次 Task(product-manager, prompt="用户回答如下：...，请整理成 spec/需求简述.md")
```

理由：保证 spec 是 product-manager 的产物，而非主会话猜测的产物。

## 五大设计原则

### 1. PM 只路由，不判断

主会话 永远不做"这个需求该用什么技术"之类判断——这类问题必须委派 `tech-leader`。
PM 的职责是：**读 meta.yaml → 按 SOP 与当前 phase 决定下一步委派谁**。

### 2. 三视角代码评审

`code-reviewer` 同时看三件事：

| 视角 | 看什么 | 数据来源 |
|---|---|---|
| 实现质量 | 代码自身的可读性、健壮性、性能 | `svn diff` |
| 需求一致 | 是否实现了所有 AC | `spec/需求文档.md` 的 AC 段 |
| 方案一致 | 是否按 design 走，偏离了哪 | `design/技术方案.md` |

任一视角不通过都标 Major / Minor。

### 3. 测试只跑不解释（基线对比）

`test-runner` 跑测试后**不分析失败原因**——只对照"上次基线"，列出"哪些是新增失败 / 哪些是历史遗留 / 哪些是新增通过"。

理由：避免 AI"为了让测试过而瞎改"。失败的解释应该交回主会话或 dev agent 处理。

### 4. 设计评审只评审不修改

`design-reviewer` 只产出"评审报告 + 建议"，**不动 design 文件**。修改由 leader（frontend/backend/tech-leader）按建议自行决定。

### 5. Skill 演进必须经用户确认

`skill-architect` 在改 Skill 前必须输出"提案 + diff"等用户回 y/n。详见 `.codebuddy/skills/_meta/self-evolution-protocol.md`。

## frontmatter 规范

```yaml
---
name: product-manager
description: |
  需求澄清专家。在用户提出新需求或需要澄清需求细节时主动调用。
  会按结构化方式提问、整理用户回答、产出 spec/需求简述.md 草稿。
  不会主动设计技术方案——那是 tech-leader 的职责。
model: claude-sonnet-4
tools: [Read, Write, Edit, Grep, Glob, AskUserQuestion]
skills: [managing-requirement, progress-logger, visual-doc-generator]
---
```

字段说明：

| 字段 | 必需 | 说明 |
|---|:-:|---|
| `name` | ✓ | kebab-case，与文件名一致 |
| `description` | ✓ | AI 用它判断"何时调用此 agent"。**写得越具体，AI 调用越准确**。 |
| `model` | ○ | 默认 `claude-sonnet-4`。计算密集型可用 opus。 |
| `tools` | ○ | tool whitelist。**不写就是全开**——建议明确写清单 |
| `skills` | ○ | 此 agent 会用的 skills。提示给主会话与 AI 自身 |

## 工具白名单建议

| Agent 类型 | 推荐工具集 |
|---|---|
| 沟通型（product-manager） | Read, Write, Edit, Glob, Grep, AskUserQuestion |
| 设计型（leader 系列） | Read, Write, Edit, Grep, Glob, AskUserQuestion |
| 评审型（design-reviewer, code-reviewer） | Read, Grep, Glob, Bash（只读型命令） |
| 实现型（dev 系列） | Read, Write, Edit, MultiEdit, Bash, Grep, Glob |
| 测试型（test-runner） | Read, Bash, Grep |
| 收尾型（closer, knowledge-maintainer） | Read, Write, Edit, Grep, Glob |
| Skill 维护（skill-architect） | Read, Write, Edit, Grep, Glob, AskUserQuestion |
| 编排型（cascade-orchestrator） | Read, Glob, Grep, Task |

`Bash` 给 dev 系列要谨慎——通常配合 `.claude/settings.json` 的 `permissions.deny`（如禁止 `svn commit`）一起用。

## 怎么新增一个 agent

1. 仿照已有 agent（如 `.claude/agents/product-manager.md`）的结构写新 agent
2. 起 kebab-case 名字
3. `description` 写清"何时调用"
4. tool whitelist 按职责最小集
5. 在本指南表格里加一行
6. 跑 `/doctor` 验证

> 别忘了：如果新 agent 在 Cursor 里也要能用，可能需要配套写一个 command 包一层。

---
*v0.1.0-alpha — Phase 4 完成时的 14 个 agent 实现。*
