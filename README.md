# kratos · AIVibe 协作框架

> 本工程（kratos Flutter 复刻）已自体集成 AIVibe 协作框架，由 **AIVibeCodingProj 模板 v0.1.0-alpha** 适配而来。
> **Cursor / Claude Code / CodeBuddy 三端原生**：所有资产以原生约定组织，三端通过 symlink 共享单一源（详见 [ADR-0005](.codebuddy/docs/ADR/0005-symlink-three-way-share.md)）。
> 以 **git 仓库**形式管理：`clone → init → 30 秒后开始 vibecoding`。

---

## 这是什么

kratos 工程内集成的 AIVibe 协作框架不是一个库，也不是一个产品。它是一个**协作脚手架**——由 AIVibeCodingProj 模板 clone 并适配到本项目，跑 `init.ps1` 后即得到本工程自带的 AI 工作区，里面已经配好：

- 一套完整的**规则**（`.codebuddy/rules/*.mdc`）：工程原则、追问原则、技能自进化、状态同步、SVN 分支安全
- 一组**Subagents**（`.codebuddy/agents/*.md`）：PM / Tech Leader / Frontend / Backend / Reviewer / Tester / Closer / Knowledge Maintainer / Skill Architect
- 一组**Slash Commands**（`.codebuddy/commands/*.md`）：`/pm-new` `/req-add` `/sop-list` `/skill-new` `/vibe-loop` `/code-review` `/doctor` 等
- 一个**Skill 库**（`.codebuddy/skills/`，单一源，工具端用 junction 链入）
- 两个**SOP**：`agile-vibe`（默认轻量 4 阶段）/ `deep-vibe`（备选 5 阶段含正式评审）
- **需求工程骨架**（`requirements/_template/`）：每个需求独立目录、状态可追溯
- **知识库骨架**（`context/`）：项目/团队/共享三层
- **Bootstrap 脚本**（`.codebuddy/scripts/init.ps1`）：占位符替换、junction 配置、SVN 检出一气呵成

---

## 谁该用它

- 你想用 **Cursor / Claude Code / CodeBuddy** 中任一做主要 AI 工具（也可以混用）
- 你希望 AI 协作有**最小可用的 SOP**：能管住 AI、能追溯历史、能沉淀知识，但不要瀑布式重型流程
- 你接受**vibecoding 风格**：意图先于实现、小步快跑、可视反馈、可回滚先行
- 你愿意**fork 这个模板**作为你项目的起点（而不是把它当作 npm 依赖）

---

## 快速开始

> 详见 [docs/QUICKSTART.md](.codebuddy/docs/QUICKSTART.md)

```powershell
# 1. Clone 本工程
git clone <this-repo-url> my-project
cd my-project

# 2. 初始化（替换占位符、配 junction）
./.codebuddy/scripts/init.ps1

# 3. 用 Cursor / Claude Code / CodeBuddy 中任一打开当前目录，开始第一个需求
#    在对话中输入：/pm-new
```

---

## 目录结构

```
项目根/
├── AGENTS.md                      # 主记忆入口（三端共享）
├── CLAUDE.md / CODEBUDDY.md       # Claude Code / CodeBuddy 各自的补充入口
├── README.md                      # 本文件
├── context/                       # 知识库（shared / team / project）
├── requirements/                  # 需求工程产物（_template / req-*）
│
├── .codebuddy/                    # ← 框架资产单一源（日常不需关注）
│   ├── agents/                    # Subagent 定义（.claude/agents/ symlink 至此）
│   ├── commands/                  # Slash Commands（.cursor/commands/ symlink 至此）
│   ├── rules/                     # 规则（.cursor/rules/ symlink 至此）
│   ├── skills/                    # Skill 库
│   ├── sop/                       # SOP 定义（agile-vibe / deep-vibe）
│   ├── scripts/                   # 辅助脚本（init / doctor / rebuild-index / sync）
│   ├── docs/                      # 框架文档（QUICKSTART / CONVENTIONS / ADR）
│
├── .cursor/                       # Cursor 端（rules/commands 为 symlink）
├── .claude/                       # Claude Code 端（agents/commands 为 symlink）
├── .mcp.json                      # MCP 配置（三端共享）
└── .vibe/                         # 运行时（缓存 / 初始化标记）
```

完整说明见 [docs/ARCHITECTURE.md](.codebuddy/docs/ARCHITECTURE.md)。

---

## 设计原则（按优先级）

1. **Convention over Configuration** — 工具官方约定优先于自创结构
2. **Single Source of Truth** — Skills 一处定义，工具端 junction 链入
3. **Vibecoding 第一** — 默认 SOP 是轻量 4 阶段，重型流程仅作备选
4. **Bootstrap 即体验** — `init.ps1` 是第一接触点，必须丝滑
5. **零硬编码** — 所有项目特定值用 `{{PLACEHOLDER}}`
6. **诚实可追溯** — 引用先行、`[待确认]` 标注、不知道就说不知道
7. **可演进** — vendor branch 或 SVN externals 升级 harness

---

## 升级 harness

```powershell
# 合并核心目录的更新（rules / agents / skills / docs）
# 通过 git remote / vendor branch 管理（本框架由 AIVibeCodingProj 模板适配）
git pull origin main
./.codebuddy/scripts/upgrade.ps1
```

---

## License

待定（建议 MIT）。

---

**当前版本**：v0.1.0-alpha · Phase 0-4 已完成，模板可用（可 clone + init + 跑通核心流程）。

**开发进度与下一步**：见 [ROADMAP.md](.codebuddy/ROADMAP.md)。
