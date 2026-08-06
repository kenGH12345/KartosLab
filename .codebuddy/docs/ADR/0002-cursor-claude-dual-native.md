# ADR 0002 — Cursor 与 Claude Code 双原生

**Status**: Accepted（关于 CodeBuddy 的部分被 [ADR-0004](0004-codebuddy-native-mirror.md) 升级超越——不再是"通过适配层兼容"，而是与 Claude Code 同等的第三端原生）
**Date**: 2026-05-12 14:32
**Last revised**: 2026-05-03（修正第 7 条与 Context；新决策见 ADR-0004）

## Context

主流 AI 编码工具中，Cursor 与 Claude Code 是当前最现代、最具代表性的两端：

- **Cursor**：以 IDE 插件形态深度集成，使用 `.cursor/` 与 `AGENTS.md`
- **Claude Code**：CLI 形态，使用 `.claude/` 与 `CLAUDE.md`

CodeBuddy 等内网/企业工具也在用，但本 ADR 起草时（2026-04-25）以为它生态与 Cursor/Claude 差距较大、需要单独适配。**2026-05-03 的调研发现**：CodeBuddy 的项目级布局（`.codebuddy/agents/` `.codebuddy/commands/` `.codebuddy/rules/*.mdc` `.codebuddy/settings.json` + 项目根 `.mcp.json` + 自动 fallback `AGENTS.md`）与 Claude Code 几乎 1:1 等价 → 升级为三端原生（详见 [ADR-0004](0004-codebuddy-native-mirror.md)）。

## Decision

**Cursor + Claude Code + CodeBuddy 三端原生**（CodeBuddy 部分在 2026-05-03 升级，详见 ADR-0004）：

1. 所有资产同时按三端官方约定组织
2. `.cursor/rules/`、`.cursor/commands/`、`.cursor/mcp.json` 完整保留
3. `.claude/agents/`、`.claude/commands/`、`.claude/settings.json`、`.mcp.json` 完整保留
4. **AGENTS.md / CLAUDE.md / CODEBUDDY.md 同源**：CLAUDE.md 与 CODEBUDDY.md 各自第一行 `@AGENTS.md` 引入共享内容，再追加端专属补充；CodeBuddy 还会在 CODEBUDDY.md 缺失时自动 fallback 到 AGENTS.md
5. **Skills 单一源**：物理放在 `.codebuddy/skills/`，工具端用 junction 链入
6. **Commands 三端镜像**：`.cursor/commands/<name>.md` ≡ `.claude/commands/<name>.md` ≡ `.codebuddy/commands/<name>.md`，同名同义，doctor 校验三端数量对称
7. **CodeBuddy 由 `.codebuddy/scripts/sync-codebuddy.sh` / `.ps1`** 从 `.cursor/rules/` + `.claude/agents/` + `.claude/commands/` + `.claude/settings.json` 自动镜像（**该脚本在 2026-05-03 实际写出**——之前的 ADR 草案声称存在但实际缺失，详见 PHASE5-FINDINGS.md F-1.6）

## Consequences

- ✅ Cursor / Claude Code / CodeBuddy 用户都获得**原生体验**，无需手动配置
- ✅ Skills 升级一处生效
- ✅ CodeBuddy 也是原生而非适配层（这是 ADR-0004 的关键升级点）
- ⚠️ Commands 三端镜像有冗余（每个命令三份文件）→ doctor 校验三端数量对称
- ⚠️ Subagents 在 Claude/CodeBuddy 端原生；Cursor 端通过 Slash Command 间接调用 → 可接受

## Alternatives Considered

### A. 只 Cursor 原生，Claude Code 通过适配
- ❌ Claude Code 用户体验降级（subagent 无法原生触发）

### B. 只 Claude Code 原生，Cursor 通过适配
- ❌ Cursor 用户面更广，降级影响更大

### C. 自创目录约定，所有工具适配
- ❌ 增加学习成本，违背 "Convention over Configuration"

### D. CodeBuddy 走"适配层"路径（本 ADR 原方案）
- ❌ 2026-05-03 调研后发现 CodeBuddy 与 Claude Code 项目级布局几乎 1:1 → 当作适配层是过度设计；改为镜像同步即可。详见 ADR-0004
