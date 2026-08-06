# ADR 0003 — Skills 采用单一源 + Junction 链入

**Status**: Accepted
**Date**: 2026-05-12 14:32
**Last revised**: 2026-05-03（ADR-0004 补入 CodeBuddy 后扩展为三端 junction）

## Context

Cursor / Claude Code / CodeBuddy 三端都期望 Skills 在自己的目录下（`.cursor/skills/`、`.claude/skills/`、`.codebuddy/skills/`，或对应的用户级 `~/.cursor/`、`~/.claude/`、`~/.codebuddy/skills/`）。
直接物理三写会导致：

- 升级一个 Skill 需要改三份
- 容易漂移（一边改了忘了同步另两边）
- 增加 SVN 噪音

## Decision

**Skills 单一源放在项目根的 `.codebuddy/skills/` 目录**，工具端通过 **junction (Windows) / symlink (*nix)** 链入：

```
skills/                      ← 物理位置（SVN 跟踪）
├── _meta/
├── core/
└── project/

.cursor/skills     →  junction → ../skills/
.claude/skills     →  junction → ../skills/
.codebuddy/skills  →  junction → ../skills/
```

`.gitignore` 或 `svn:ignore` 中排除 `.cursor/skills`、`.claude/skills` 与 `.codebuddy/skills`，确保版本控制只跟踪一份。

`.codebuddy/scripts/init.ps1` 在初始化时自动创建 junction。
`.codebuddy/scripts/doctor.ps1` 校验 junction 存在且指向正确。

## Consequences

- ✅ 单一源，零漂移
- ✅ 升级一处生效
- ✅ SVN 只跟踪一份，干净
- ⚠️ Junction 在 Windows 限同盘符 → init.ps1 校验
- ⚠️ 部分 SVN client 处理 junction 不佳 → 通过 `svn:ignore` 或 `.gitignore` 排除三个工具端目录规避
- ⚠️ 用户跨设备 checkout 时 junction 不会自动建立 → init.ps1 必跑

## Alternatives Considered

### A. 物理三写 + 同步脚本
- ❌ 易漂移，需要 hook 守护，SVN 噪音大

### B. 把 Skills 直接放在某一个工具的目录下，另两个工具放符号链接
- ❌ "权威方" 不平衡，违背三端原生原则

### C. 让用户在 svn:ignore / .gitignore 之外自己 cp -r
- ❌ 体验差，违背 "Bootstrap 即体验" 原则
