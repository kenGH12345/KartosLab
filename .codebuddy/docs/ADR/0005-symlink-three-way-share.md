# ADR 0005 — 三端共享改用 symlink（.codebuddy 为单一源）

**Status**: Accepted
**Date**: 2026-05-06
**Supersedes (in part)**: [ADR-0004](0004-codebuddy-native-mirror.md) §1 资产布局 + §2 同步脚本（cp 模式）
**Inherits**: ADR-0004 §3-§5（doctor 升级 / CODEBUDDY.md 形态 / 平铺 vs 子目录）

## Context

ADR-0004（2026-05-03）把 CodeBuddy 升级为第三端原生时，三端共享资产（rules / agents / commands）采用了**复制（cp）模式**：

```
.cursor/rules/*.mdc   ──cp──┐
.claude/agents/*.md   ──cp──┼──→ .codebuddy/{rules,agents,commands}/
.claude/commands/*.md ──cp──┘
```

源在 `.cursor/` 与 `.claude/`，`.codebuddy/` 是 mirror。`.codebuddy/scripts/sync-codebuddy.sh` 跑一遍把源覆盖到 `.codebuddy/`。

实际使用近 1 个月暴露的痛点：

1. **三份内容三份维护成本**：编辑 `.claude/agents/closer.md` 后，必须记得跑 `sync-codebuddy.sh` 才能让 CodeBuddy 用户拿到更新；忘了就会出现"同一个 agent 三端行为不一致"。
2. **doctor 三端 symmetry 校验是巡检式的，不是预防式的**：差异可以存在数小时，到下次 `/doctor` 才暴露。
3. **commit history 噪音**：每次改 1 个 agent，`.codebuddy/` 下的 mirror 同时变更，diff 显示 2x 文件，review 时容易误以为有 2 个改动点。
4. **极端 case：忘记 sync 直接 commit + push**：CodeBuddy 用户拉到一份滞后的 mirror，与 Claude/Cursor 行为分叉。

根本原因：**这些资产在三端的语义是 100% 相同的**（ADR-0004 §1 已确认），但被强制存了 3 份。这违反了 `45-state-sync-protocol.mdc` 的"单一源"原则。

## Decision

**改用 symbolic link，让 `.codebuddy/` 成为单一源，`.cursor/` 与 `.claude/` 通过 symlink 引用**：

```
.codebuddy/rules/*.mdc       ← 真实文件（SVN 追踪）
.codebuddy/agents/*.md       ← 真实文件
.codebuddy/commands/*.md     ← 真实文件

.cursor/rules/*.mdc          → symlink → ../../.codebuddy/rules/*.mdc
.cursor/commands/*.md        → symlink → ../../.codebuddy/commands/*.md
.claude/agents/*.md          → symlink → ../../.codebuddy/agents/*.md
.claude/commands/*.md        → symlink → ../../.codebuddy/commands/*.md
```

### 1. 为什么 .codebuddy 当源（而不是 .claude/.cursor）

- CodeBuddy 的目录结构已经把 rules/agents/commands 集中在一个父目录（`.codebuddy/`）下。Claude Code 把 rules 单独放在 `.cursor/rules`，没有原生 rules 概念，结构上不如 .codebuddy 紧凑。
- ADR-0004 §1 表格已确认 `.codebuddy/` 的命名与各端原生命名 100% 一致——选它当源不增加任何映射成本。
- 命名上"`.codebuddy` 是中性容器"比"`.claude` 是真源、其他是镜像"对人类心智模型更友好（不偏向某一个 IDE 厂牌）。

### 2. settings.json 不 symlink，仍 cp

`.claude/settings.json` 与 `.codebuddy/settings.json` 当前内容相同，**但语义可能分叉**——比如未来 Claude Code 端会加 PreToolUse hooks 而 CodeBuddy 不需要。symlink 会强制内容耦合，cp 保留分叉空间。

`.codebuddy/scripts/sync-codebuddy.sh` 保留对 `settings.json` 的 cp 步骤。

### 3. 版本控制中的 symlink

SVN 把 symlink 存为特殊属性（`svn:special`）。checkout 时：

- macOS / Linux：默认还原 symlink ✓
- Windows + Developer Mode（或 Administrator）：还原 symlink ✓
- Windows w/o Developer Mode：SVN 将 symlink 还原成普通文件（内容是 link target 字符串，不可用）

针对最后一种情况，新版 `.codebuddy/scripts/sync-codebuddy.ps1` 自动检测 symlink 能力，不支持时**fallback 到 cp**——把 .codebuddy/ 内容拷成实体文件。这层 fallback 让 Windows 受限环境也能正常使用模板。

对于 git 仓库，git 把 symlink 存为 mode 120000 的特殊 blob（内容 = link target 字符串），行为与 SVN 的 `svn:special` 类似。

### 4. sync 脚本职责变了，但文件名不变

`.codebuddy/scripts/sync-codebuddy.sh` / `.ps1` 名字保留（避免 30+ 处文档失链），但语义从"复制 .cursor/.claude → .codebuddy"改为"扫 .codebuddy/ 建/重建 symlink 到 .cursor/.claude"。幂等。

调用时机：
- 新 checkout（版本控制没自动还原 symlink 时）
- 在 `.codebuddy/` 下加/删文件后
- `init.sh` / `init.ps1` 末尾自动调用（与之前相同）

### 5. 编辑哪一份都行

由于 symlink 是透明的，编辑以下任一路径效果完全相同：

```bash
# 都修改同一个 inode：
edit .claude/agents/closer.md
edit .cursor/skills-cursor/...   # （无关 example）
edit .codebuddy/agents/closer.md
```

工程纪律建议**统一编辑 `.codebuddy/` 路径**（"统一从源进"），但不强制——symlink 透明性保证不会出错。

## Consequences

- ✅ 单一源原则恢复——三端永远一致，不可能分叉
- ✅ 编辑成本下降 —— 不必跑 sync，保存即生效
- ✅ commit history 干净 —— 改 1 个 agent 只显示 1 个文件 diff
- ✅ doctor 三端 symmetry 校验从"巡检"变成"恒等"——只需要校验所有 symlink 指向有效 target
- ⚠️ Windows w/o Developer Mode 需要额外一步：跑 `.codebuddy/scripts/sync-codebuddy.ps1` 把 symlink fallback 成 cp（脚本自动判断、自动 fallback）
- ⚠️ `.codebuddy/` 入版本库的体积没变（symlink blob 远小于内容文件）—— commit history 反而轻
- ⚠️ 一次性切换成本：`svn status` 会显示大量文件变更（实体文件变为 symlink），需要在一个 commit 里完成

## Alternatives Considered

### A. 保留 cp 模式 + 加 pre-commit / pre-commit-hook 强制 sync
- ❌ pre-commit hook 增加协作复杂度（SVN hook 需要服务器端配置）
- ❌ 不解决"editing 时三端短暂不一致"的根本问题

### B. 把 settings.json 也 symlink
- ❌ 失去未来 hook 分叉的灵活性
- 当前阶段保留 cp，等真正出现分叉需求再讨论

### C. 让 .claude/ 当源、.codebuddy/ symlink 过来
- ❌ Claude Code 历史更长，但目录结构是分散的（`.claude/agents` + `.claude/commands` + `.cursor/rules`）。从 .codebuddy 的紧凑结构出发更自然
- ❌ 心智模型偏向 Claude，不利于"三端平等"

### D. 用 hardlink 取代 symlink
- ❌ Windows 对 hardlink 的支持也需要权限；hardlink 不能跨文件系统；硬链接对 SVN 是不可见的（SVN 会把两个 hardlink 当成两个独立文件）
- ❌ symlink 是 SVN 原生支持的（`svn:special`），hardlink 不是

## References

- ADR-0004（被部分 supersede）：`.codebuddy/docs/ADR/0004-codebuddy-native-mirror.md`
- 单一源原则：`.cursor/rules/45-state-sync-protocol.mdc`
- PoC 验证记录：本次需求的 process.txt（symlink 在 Cursor IDE 下被透明加载，agent description 正确读取）
- git 对 symlink 的处理：[git-scm.com/docs/gitformat-pack#_object_types](https://git-scm.com/docs/gitformat-pack)（mode 120000）
