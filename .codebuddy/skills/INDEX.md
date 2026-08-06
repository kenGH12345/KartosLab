# Skills 索引

> Skill 是可被 AI 加载执行的「能力包」。一处定义，工具端通过 junction 链入复用。
>
> 想创建/演进 Skill？用 [`/skill-new`](../commands/skill-new.md) 与 [`/skill-evolve`](../commands/skill-evolve.md) 命令——它们会委派 [`skill-architect`](../agents/skill-architect.md) agent 走标准流程。

## 目录约定

```
skills/
├── _meta/      # Skill 创作模板与协议（怎么写 Skill）
├── core/       # 框架自带的通用 Skill（不可移除）
└── project/    # 用户自添加的项目专属 Skill
```

## Skill 文件结构

每个 Skill 是一个目录，必须包含：

```
skills/<group>/<skill-name>/
├── SKILL.md           # 必需。含 YAML frontmatter（name / description）
├── references/        # 可选。Skill 引用的资料（schema、示例、说明文档等）
├── .codebuddy/scripts/           # 可选。Skill 调用的脚本（PowerShell / Bash / Python）
└── assets/            # 可选。图片、模板等静态资产
```

## _meta/ —— Skill 创作元资产

| 文件 | 用途 |
|---|---|
| [SKILL_TEMPLATE.md](_meta/SKILL_TEMPLATE.md) | 标准模板，复制即可填空 |
| [skill-authoring-guide.md](_meta/skill-authoring-guide.md) | 写作指南：命名、description、章节、反模式 |
| [self-evolution-protocol.md](_meta/self-evolution-protocol.md) | 自进化协议：诊断→提案→确认→应用→记录 |

详细见 [_meta/README.md](_meta/README.md)。

## Core Skills（框架自带，13 个）

| Skill | 用途 | 主要被谁调用 |
|---|---|---|
| [`skill-creator`](core/skill-creator/SKILL.md) | 创建新 Skill 的标准 6 步流程 | `skill-architect` agent / `/skill-new` |
| [`managing-requirement`](core/managing-requirement/SKILL.md) | 需求生命周期所有写操作的统一入口 | `/pm-*` `/req-*` 命令、主会话（PM 角色） |
| [`managing-knowledge`](core/managing-knowledge/SKILL.md) | 项目级发现回写到 context/，单一源原则 | `knowledge-maintainer` agent |
| [`knowledge-base-generator`](core/knowledge-base-generator/SKILL.md) | 扫描源码生成结构化项目知识库（architecture/flows/conventions/systems/uictrl/gameplay 六大类） | 主会话 / `/kb-gen` 命令 |
| [`self-improving-agent`](core/self-improving-agent/SKILL.md) | 主动检测协作流程瓶颈，触发自进化协议（WA 集成） | `/improve` 命令、`knowledge-maintainer` |
| [`code-review-prepare`](core/code-review-prepare/SKILL.md) | 评审前的 diff/AC/方案数据准备 | `code-reviewer` agent / `/code-review` |
| [`svn-commit-message`](core/svn-commit-message/SKILL.md) | 按规范生成 commit message（含 task / AC / req-id） | 所有 dev agents |
| [`use-svn-branch`](core/use-svn-branch/SKILL.md) | SVN 分支创建/切换/列出/清理 | 用户 / dev agent / best-of-n |
| [`visual-doc-generator`](core/visual-doc-generator/SKILL.md) | 6 类 mermaid 图模板 | 所有写文档的 agent |
| [`docs-index-updater`](core/docs-index-updater/SKILL.md) | INDEX.md 自动重建（rebuild-index.sh） | 文档变更后调用 |
| [`progress-logger`](core/progress-logger/SKILL.md) | process.txt 标准化追加 | 所有写日志的 agent |
| [`session-restorer`](core/session-restorer/SKILL.md) | 从 meta.yaml + process.txt + plan.md 恢复现场 | `/pm-continue` 第一步 |
| [`doctor`](core/doctor/SKILL.md) | 仓库健康检查（资产/状态/链接/占位符） | `/doctor` 命令 |

## Project Skills（用户自添加）

`.codebuddy/skills/project/` 默认为空。以下情形可考虑创建项目 Skill：

- 同一类操作做了 3 次以上（**3-Time Rule**，参见规则 `10-vibecoding-protocol.mdc`）
- 项目特有的工具调用 / 部署流程 / 数据迁移模式
- 团队约定但未沉淀到 conventions/ 的操作

通过 [`/skill-new`](../commands/skill-new.md) 创建。

## 加载机制

- **Cursor 端**：通过 `.codebuddy/rules/` 中的引用让 Skill 被纳入上下文（见规则 `30-skill-self-evolution.mdc` 的「何时加载」表）
- **Claude Code 端**：agent 的 frontmatter `skills:` 字段或主会话直接 Read SKILL.md

## 演进与维护

- 创建：`/skill-new`
- 演进：`/skill-evolve <name>`（**必走"提案-确认-应用"**，禁止静默修改）
- 列表：`/skill-list`
- 健康检查：`/doctor` 会检查 SKILL 引用的 references/scripts 是否真实存在

---
*索引最后更新：v0.1.1 (2026-05-28: 新增 self-improving-agent Skill + .workflow 工作流引擎)*
