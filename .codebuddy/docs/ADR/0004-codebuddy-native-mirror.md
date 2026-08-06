# ADR 0004 — CodeBuddy 升级为第三端原生（镜像 .claude/ + .cursor/rules/）

**Status**: Accepted（§3-§5 仍生效；§1-§2 cp 模式已被 ADR-0005 取代为 symlink 模式，2026-05-06）
**Date**: 2026-05-03
**Supersedes (in part)**: [ADR-0002](0002-cursor-claude-dual-native.md) 第 7 条 "CodeBuddy 通过适配层兼容"
**Superseded (in part) by**: [ADR-0005](0005-symlink-three-way-share.md) §1-§2（三端共享改用 symlink）
**Phase**: 5（Validation & Polish）阶段中发现 + 实施

## Context

ADR-0002 起草（2026-04-25）时，把 CodeBuddy 列为"通过适配层兼容"——隐含假设是 CodeBuddy 与 Cursor / Claude Code 的项目级布局差异较大、需要单独的适配脚本去转换。

但这个假设当时**没有被验证**——`.codebuddy/scripts/sync-codebuddy.ps1` 在 ADR-0002 里被点名引用，但实际上整个 v0.1.0-alpha 期间从未真正写出来过。Phase 5 验证时（详见 PHASE5-FINDINGS.md F-1.4 与 F-1.6）才发现这个空缺。

2026-05-03 调研 CodeBuddy 官方文档（[Tencent Cloud CodeBuddy IDE Rules](https://staging-codebuddy.tencent.com/docs/ide/User-guide/Rules) / [CodeBuddy CLI SDK](https://www.codebuddy.ai/docs/cli/sdk)）后发现关键事实：**CodeBuddy 的项目级布局与 Claude Code 几乎是 1:1 等价的**。

| 配置项 | Claude Code 路径 | CodeBuddy 路径 | 差异 |
|---|---|---|---|
| Settings | `.claude/settings.json` | `.codebuddy/settings.json` | 字段 schema 几乎一致（permissions / hooks / env） |
| Subagents | `.claude/agents/*.md` | `.codebuddy/agents/*.md` | frontmatter schema 完全一致（name / description / model / tools / color） |
| Slash Commands | `.claude/commands/*.md` | `.codebuddy/commands/*.md` | 完全一致（CodeBuddy 还额外支持子目录 namespace，但平铺命名同样支持） |
| MCP | 项目根 `.mcp.json` | 项目根 `.mcp.json` | **完全一致——三端共享同一份** |
| Memory | `CLAUDE.md` | `CODEBUDDY.md`（**官方文档明确：CODEBUDDY.md 不存在时自动 fallback 到 AGENTS.md**） | 名字不同但语义一致 |
| Rules | （无原生 rules，需要 import） | `.codebuddy/rules/*.mdc` | 与 Cursor `.cursor/rules/*.mdc` **同 .mdc 格式**（同样的 description / globs / alwaysApply frontmatter） |
| Skills | `~/.claude/skills/` | `~/.codebuddy/skills/` | 完全一致（用户级 junction） |

也就是说，"CodeBuddy 适配层"的工作量被严重高估——实际只需要把 `.claude/` 大部分内容 + `.cursor/rules/` 镜像到 `.codebuddy/`，加一个简短的 `CODEBUDDY.md` 即可。

## Decision

**CodeBuddy 升级为与 Cursor / Claude Code 同等的第三端原生**，并采用镜像同步策略：

### 1. 资产布局

| .codebuddy/ 内容 | 来源 | 转换 |
|---|---|---|
| `.codebuddy/rules/*.mdc` | `.cursor/rules/*.mdc` | 直接 cp（.mdc 格式相同） |
| `.codebuddy/agents/*.md` | `.claude/agents/*.md` | 直接 cp（schema 相同） |
| `.codebuddy/commands/*.md` | `.claude/commands/*.md` | 直接 cp（schema 相同；保持平铺命名 `pm-new.md` 而非 `pm/new.md`，三端命令名一致） |
| `.codebuddy/settings.json` | `.claude/settings.json` | 直接 cp（CodeBuddy 容忍未知字段如 `$schema`） |
| `.mcp.json`（项目根） | （已存在） | 不需要 sync——CodeBuddy 直接读项目根 |
| `CODEBUDDY.md`（项目根） | 手维护 | 一句 `@AGENTS.md` 引入 + 三端差异速查表 |

### 2. 同步脚本

新增 `.codebuddy/scripts/sync-codebuddy.sh` + `.codebuddy/scripts/sync-codebuddy.ps1`：
- 一键执行上述四个 cp 动作
- 带 `--dry-run` 与 `--quiet`
- 校验：每步 source/destination 数量必须相等；settings.json 字节级 hash 比对
- 在 `.codebuddy/scripts/init.sh` / `init.ps1` 末尾被调用，让新项目开箱即拥有三端

### 3. doctor 升级

`.codebuddy/scripts/doctor.sh` + `.codebuddy/scripts/doctor.ps1`：
- Asset 检查加 `.codebuddy/rules/*.mdc` `.codebuddy/agents/*.md` `.codebuddy/commands/*.md` `.codebuddy/settings.json` `CODEBUDDY.md`
- Symmetry 检查从 "commands 双写对称" 升级为 "**三端**对称：`.claude=.cursor=.codebuddy`"
- Placeholder skip 列表加 `.codebuddy/*`（避免重复报告，源在 `.claude/` / `.cursor/`）

### 4. CODEBUDDY.md 的形态

CodeBuddy 在 CODEBUDDY.md 缺失时自动 fallback 到 AGENTS.md，所以理论上**不创建** CODEBUDDY.md 也能工作。但为了与 CLAUDE.md 对称、并且明确告知用户三端差异，仍创建一份**轻量** CODEBUDDY.md：第一行 `@AGENTS.md`（与 CLAUDE.md 同模式）+ 一段端专属补充（项目级配置位置 / Subagents / Slash Commands / 与 Claude Code 端的差异）。

### 5. Rules 用平铺而非子目录化

CodeBuddy 官方文档推荐 `<rule-name>/RULE.mdc` 子目录化布局，但官方实践与 AiWorkspace 实测证明平铺 `<rule-name>.mdc` 也支持。我们选择**平铺**：
- 与 `.cursor/rules/` 100% 一致 → sync 脚本只是 cp
- 不需要"为 CodeBuddy 重命名 / 包目录"的转换逻辑
- 后续如果官方强制要求子目录化再做迁移（届时 sync 脚本里加一步 mkdir+mv 即可）

## Consequences

- ✅ CodeBuddy 用户从此获得**原生体验**，与 Cursor/Claude 平等
- ✅ 实现成本远低于"适配层"路径（约 3 小时 vs 预估 6-8 小时）
- ✅ ROADMAP.md / README.md / ARCHITECTURE.md 从"双工具原生"扩到"三端原生"
- ✅ 修复 ADR-0002 第 7 条的"幽灵脚本"问题（sync-codebuddy.ps1 现在真的存在）
- ⚠️ Commands 三端镜像比双写多一份冗余 → doctor 校验补到三端
- ⚠️ `.codebuddy/` 整层是 sync 产物 → 必须遵守"不要手编辑 `.codebuddy/`，改源 + 跑 sync"的纪律（文档化在 CODEBUDDY.md）；注意 ADR-0005 已将 cp 模式改为 symlink，当前 `.codebuddy/` 是单一源
- ⚠️ CODEBUDDY.md 与 CLAUDE.md 各自的"端专属补充"段落需要平行维护（少量重复）→ 接受

## Alternatives Considered

### A. 不支持 CodeBuddy（ROADMAP 标 deferred）
- ❌ CodeBuddy 在中文开发者中使用面广，且实现成本意外低，没必要 defer

### B. 用子目录化 RULE.mdc 布局（按官方推荐）
- ❌ 需要为 CodeBuddy 单独的 rules 目录树和 sync 转换逻辑；平铺方案与 .cursor/ 一致更简单

### C. Commands 用 namespace 子目录（pm/new.md → /pm:new）
- ❌ 三端命令名会不一致（Claude/Cursor 是 `/pm-new`，CodeBuddy 变成 `/pm:new`），用户文档与肌肉记忆都会断

### D. 不创建 CODEBUDDY.md，依赖 fallback 到 AGENTS.md
- ❌ 失去与 CLAUDE.md 的对称；用户可能不知道 CodeBuddy 是有官方 fallback 机制的，看到没有 CODEBUDDY.md 会以为不支持
- ✅ 仍然采用 fallback 机制：CODEBUDDY.md 内容**很轻**（只是引入 + 差异表），实质内容都在 AGENTS.md

### E. 把 .codebuddy/ 入版本库 vs 入 svn:ignore / .gitignore
- 当前选择：**入版本库**（与 .cursor/、.claude/ 一致）。这样即使用户没跑 sync，也能直接打开就能用
- 否决：入 svn:ignore / .gitignore 会让 checkout 出来的项目第一次启动 CodeBuddy 时空空如也，体验断裂

## References

- 官方文档：[Tencent Cloud CodeBuddy IDE Rules](https://staging-codebuddy.tencent.com/docs/ide/User-guide/Rules)
- 官方文档：[CodeBuddy CLI SDK Configuration File Locations](https://www.codebuddy.ai/docs/cli/sdk)
- 官方文档：[CodeBuddy Plugin Reference](https://www.codebuddy.ai/docs/cli/plugins-reference)
- 实践参考：`AiWorkspace/.codebuddy/`（提供了"平铺 .mdc 实际可用"的实证）
- 关联：PHASE5-FINDINGS.md F-1.4（.cursor/ 整层缺失的同类问题）+ F-1.6（CodeBuddy 适配层从未实现）
