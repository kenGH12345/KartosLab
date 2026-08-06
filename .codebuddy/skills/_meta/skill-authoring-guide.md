# Skill 写作指南

> 写 Skill 不是写文档——是写「**让 AI 能照做的标准操作手册**」。
> 这份指南给出 6 条核心原则、命名约定、章节模板、常见反模式。

## 核心原则

### 1. description 决定加载

Claude Code 读到 frontmatter 的 `description` 后才决定要不要把这个 Skill 拉进上下文。
**description 写不好 = Skill 永远不会被用上**。

| 反例 | 问题 | 正例 |
|---|---|---|
| `用于处理需求` | 太宽泛，几乎所有需求场景都会误命中 | `用于在创建新需求时按 SOP 生成符合规范的需求文档骨架` |
| `git 相关操作` | 没说何时用 | `用于在准备一次 git commit 时生成符合本项目约定的 commit message` |
| `工具集合` | 像袋子 | `用于在数据库 schema 变更后生成可回滚的 migration 脚本` |

**写 description 的公式**：

> 用于在 [何种触发场景] 时 [做什么具体动作]，产出 [什么]。

### 2. 步骤可被照做

Skill 的步骤段落必须能让"刚加入的人"（或一个不了解上下文的 AI 实例）照做。

- 给具体命令，不给抽象描述
- 给文件路径模板，不只说"对应位置"
- 给输入/输出示例，不只描述格式

### 3. 边界是护栏，不是装饰

「边界与陷阱」段落往往比正向步骤更重要——AI 倾向于「合理化偏离」，护栏要写明：

- 不要做什么（具体到操作）
- 易踩的坑（带具体场景）
- 必须满足的硬约束（用 `> [!IMPORTANT]`）

### 4. 单一职责

一个 Skill 只解决一个问题。复杂任务拆成多个 Skill 互相调用，不要写"全能 Skill"。

> 反例：一个叫 `do-everything-with-git` 的 Skill 同时管 commit / branch / worktree / merge / rebase。
> 正例：拆成 `git-commit-message` / `use-worktree` / `git-rebase-safely` 等。

### 5. 自包含

Skill 的步骤里需要的资料，要么写在 SKILL.md 里，要么放在自己的 `references/` 与 `.codebuddy/scripts/` 子目录。
**不要假定** AI 会自动读取项目其他文档——如果需要先读 X，明确写"步骤 1：先读 X"。

### 6. 自进化触发要明确

如果 Skill 在使用中发现遗漏或错误，应通过 `/skill-evolve` 走演进协议（见 `self-evolution-protocol.md`）。
**不允许 AI 静默修改 Skill 文件**。

## 命名约定

- **目录与 frontmatter `name` 一致**：`.codebuddy/skills/core/git-commit-message/SKILL.md` 中 `name: git-commit-message`
- **kebab-case**：`use-worktree`、`run-tests-with-baseline`
- **动宾或名词短语**：`git-commit-message`（名词短语）/ `update-knowledge-base`（动宾）
- **避免缩写**：`req-doc-writer` ❌ → `requirement-doc-writer` ✅
- **避免范围词**：`general-helper` / `utils` ❌

## 目录结构

```
skills/<group>/<skill-name>/
├── SKILL.md           # 必需，含 frontmatter
├── references/        # 可选：模板、schema、说明文档（被 SKILL.md 引用）
│   ├── template.md
│   └── schema.json
├── .codebuddy/scripts/           # 可选：可执行脚本（PowerShell / Bash / Python）
│   ├── do-thing.ps1
│   └── do-thing.sh
└── assets/            # 可选：图片、示例文件、静态资产
```

**何时需要 references / scripts / assets**：

- 步骤里要写一段 100 行的模板？→ 抽到 `references/`
- 步骤里要跑一段命令组合？→ 抽到 `.codebuddy/scripts/`
- 用到截图/图标/示例文件？→ 放 `assets/`

如果 SKILL.md 内 ≤ 200 行就够说清楚，不要硬塞 references。

## 章节模板（按 SKILL_TEMPLATE.md 的顺序）

| 章节 | 必填？ | 说明 |
|---|:-:|---|
| frontmatter (`name` / `description`) | ✓ | 加载关键 |
| 引子（一段话） | ✓ | 让人秒懂"原理与价值" |
| 何时使用 | ✓ | 触发场景 + 不该用场景 |
| 输入 | ✓ | 表格列出 |
| 步骤 | ✓ | 编号步骤，可执行 |
| 输出 | ✓ | 文件路径 + 摘要格式 |
| 边界与陷阱 | ✓ | 护栏 |
| 引用资料 | 可选 | 列 references/ |
| 关联 Skill | 可选 | 与其他 Skill 的协作关系 |
| 变更历史 | 可选 | 追加式 |

## 常见反模式

| 反模式 | 后果 | 改法 |
|---|---|---|
| description 写成"用于 XXX 相关的操作" | 永远不被加载（太宽泛） | 改成"用于在 [场景] 时 [动作]" |
| 步骤里写"按需调整" / "根据情况而定" | AI 会胡乱"调整" | 给具体判断条件与对应动作 |
| 没有"边界与陷阱"段 | AI 会编造合理但错误的扩展 | 至少列 3 条不要做的事 |
| 引用一堆外部链接 | 链接失效 / 上下文断 | 把关键内容内联或放 references/ |
| 一个 Skill 想覆盖整个流程 | 既不精准也难维护 | 按 6 条核心原则的"单一职责"拆 |
| 把过程性指令写进 description | description 应是"何时用"而非"怎么用" | 怎么用放正文 |

## 演进 vs 重写

| 情况 | 选 |
|---|---|
| 步骤里某条命令过期 | 演进（`/skill-evolve`） |
| 发现一个边缘场景没考虑 | 演进 |
| 整个 Skill 的前提已变（如换技术栈） | 重写为新 Skill，旧的归档 |
| Skill 与新需求模式根本不匹配 | 创建新 Skill，老的保留 |

> 演进时**保留原有结构**，只改受影响的部分；重写时建议旧 Skill 在 frontmatter 加 `deprecated: true`。

## 创作完成后的检查清单

- [ ] frontmatter `name` 与目录名一致
- [ ] `description` 通过"何时用 + 何时不该用"测试
- [ ] 步骤至少 3 步，每步可独立执行
- [ ] 至少有 3 条"不要做"
- [ ] 引用的 references / scripts 都真实存在
- [ ] `.codebuddy/skills/INDEX.md` 已加入新 Skill 行
- [ ] 第一次实际触发后，没有发现明显遗漏（如有则走 `/skill-evolve`）
