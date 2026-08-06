# 故障排查

> 按"症状 → 可能原因 → 解决步骤"组织。如果没找到匹配，跑 `/doctor` 看四类检查报告。

## 安装与初始化

### `init.ps1` 报"无法加载脚本"（Windows）

**原因**：PowerShell 执行策略默认禁止脚本运行。

**解决**：

```powershell
# 推荐：当前用户级放开
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# 或单次执行：
powershell -ExecutionPolicy Bypass -File .\scripts\init.ps1
```

### `init.ps1` 输出中文乱码（Windows）

**原因**：终端编码不是 UTF-8。

**解决**：

```powershell
# 临时改 console 输出编码：
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001

# 永久改：在 PowerShell profile 里加：
# Add-Content $PROFILE '[Console]::OutputEncoding = [System.Text.Encoding]::UTF8'
```

或换 PowerShell 7+（默认 UTF-8）。

### `init.sh` 报 "syntax error near unexpected token"（macOS）

**原因**：macOS 自带 `/bin/bash` 是 3.2 版本，太老。

**解决**：

```bash
brew install bash
/opt/homebrew/bin/bash ./.codebuddy/scripts/init.sh
```

### `init` 完成后跑 `doctor` 仍显示"104 处占位符"

**原因**：init 没真正修改文件。可能是只读文件系统、权限问题、或 `-Force` 误把替换跳过了。

**解决**：

```powershell
# 查看 .vibe/.initialized 是否存在
Test-Path .vibe\.initialized

# 强制重做
.\scripts\init.ps1 -Force

# 再跑 doctor
.\scripts\doctor.ps1
```

如果还有占位符，看具体在哪：

```powershell
.\scripts\doctor.ps1 -Json | ConvertFrom-Json | Select -ExpandProperty placeholders | Select -ExpandProperty remaining | Group source | Sort Count -Descending
```

如果出现在 `_template/` 或 `SKILL_TEMPLATE.md`：**正常**——这些是模板文件，应保留占位符（doctor 已排除这些路径，如果还报告说明 doctor 的排除清单需要更新）。

## 命令与 Agent

### 在 Cursor 中输入 `/pm-new` 没反应

**可能原因 A**：Cursor 版本太老，不支持 commands。
**解决**：升级到 Cursor v0.40+。

**可能原因 B**：`.cursor/commands/` 没被识别。
**解决**：

```powershell
# 检查文件存在且可读
Get-ChildItem .cursor\commands\*.md
# 重启 Cursor
```

### 在 Claude Code 中调用 agent 时说"agent not found"

**可能原因 A**：`.claude/agents/<name>.md` 不存在或 frontmatter `name` 字段与文件名不匹配。

**解决**：

```bash
# 用 doctor 检查资产
./.codebuddy/scripts/doctor.sh --scope assets
# 看 agents 数 < 14 就是缺文件
```

**可能原因 B**：Claude Code 版本太老。
**解决**：升级到 v0.5+。

### 主会话报"找不到对应阶段的 agent"

**原因**：`meta.yaml` 的 `phase` 字段值与 SOP 定义的阶段标识不一致（可能被手工改过）。

**解决**：

```powershell
# 检查需求状态一致性
.\scripts\doctor.ps1 -Scope state

# 如不一致，可以：
# 1. 手工把 meta.yaml 改回合法 phase
# 2. 用 /pm-phase 强制切换到合法 phase（会留 phase_overrides 痕迹）
```

### Agent 在做与角色不符的事（如 product-manager 在写代码）

**原因**：违反了 agent 的边界定义。这通常是 frontmatter `description` 写得不够具体，或主会话误用 Task 工具。

**解决**：
- 提醒主会话："请按 agent 的边界，product-manager 只定义需求，不应改代码"
- 检查 `.claude/agents/product-manager.md` 的"关键约束"段落是否完整
- 如发现是 agent 定义本身的漏洞，触发 `/skill-evolve`（虽然 agent 不是 skill，但同样的演进思路适用——开 issue 或人工调整 agent 文件）

## 状态与一致性

### `doctor` 报告"状态不一致"

例如：

```text
req-foo:
  - meta.phase=2.requirement 与 process.txt 末次 phase 事件目标=3.iteration 不一致
```

**最常见原因**：阶段切换中途崩溃——`process.txt` 写了，`meta.yaml` 没写（或反之）。

**解决**：

```powershell
# 1. 看具体是哪个文件落后
Get-Content requirements\req-foo\meta.yaml | Select-String 'phase|status'
Get-Content requirements\req-foo\process.txt -Tail 5

# 2. 决定权威方：
#    - 如果 process.txt 是新的（你刚做了某动作） → 改 meta.yaml 跟上
#    - 如果 meta.yaml 是新的（你手工改过） → 在 process.txt 追加一行说明
```

### 多个需求同时进行，互相串了改动

**原因**：可能是没用 SVN 分支隔离。

**解决**：用 `use-svn-branch` Skill 给每个进行中的需求建独立分支。

```powershell
# 假设主仓库在 ../my-app
# 为 req-foo 建 SVN 分支:
svn copy ^/trunk ^/branches/vibe/req-foo -m "create branch for req-foo"
svn switch ^/branches/vibe/req-foo

# 在本 vibe 仓库记录当前分支
echo "branches/vibe/req-foo" > ../my-app-vibe/.vibe/svn-branch-current.txt
```

详见 `.codebuddy/skills/core/use-svn-branch/SKILL.md`。

### `INDEX.md` 与 `INDEX.yaml` 显示的需求不一致

**原因**：`new-requirement` 脚本只更新了一个，或人工改过。

**解决**：

```powershell
# 用 doctor 报告差异
.\scripts\doctor.ps1 -Scope state -Json | ConvertFrom-Json | Select-Object -ExpandProperty state

# 手工对齐：以 meta.yaml 为权威源，更新 INDEX.md / INDEX.yaml
```

## Skill 与文档

### 修改了某个 Skill，下次 AI 没用上新版本

**可能原因**：Cursor / Claude Code / CodeBuddy 缓存了上次会话上下文。

**解决**：开新会话。Cursor 用 `Cmd/Ctrl+L` 新建对话；Claude Code 与 CodeBuddy 用 `/clear`。

### `/skill-list` 列出的 Skill 比目录里少

**原因**：Skill 的 frontmatter `name` 与目录名不一致，或者 SKILL.md 缺失。

**解决**：

```powershell
# 检查所有 SKILL.md
Get-ChildItem skills -Recurse -Filter SKILL.md | ForEach-Object {
  $name = (Select-String -Path $_.FullName -Pattern '^name:\s*(.+)' | Select-Object -First 1).Matches.Groups[1].Value
  $dirName = $_.Directory.Name
  if ($name -ne $dirName) {
    Write-Host "MISMATCH: dir=$dirName, frontmatter name=$name"
  }
}
```

### 想演进某个 Skill 但每次 AI 都直接 Edit 了

**原因**：违反 `self-evolution-protocol.md`——AI 应该输出"提案"等用户确认。

**解决**：
- 在主会话明确说："**先输出提案**，按 self-evolution-protocol.md 走，不要直接 Edit"
- 检查 `.codebuddy/rules/30-skill-self-evolution.mdc` 是否被加载（看 Cursor 状态栏 / `@import` 是否完整）

### 文档间链接失效

**症状**：`/doctor` 报告"链接断裂"。

**解决**：
- 看具体哪个文件 + 哪一行 + 目标
- 修复方式：要么补上缺失的目标文件，要么改链接指向正确路径

## SVN / 分支

### `svn commit` 被拒绝（AI 自动执行）

**原因**：`.claude/settings.json` 的 `permissions.deny` 包含 `Bash(svn commit:*)`——这是模板的安全策略。

**解决**：人工执行 `svn commit`（不通过 AI），或临时修改 `.claude/settings.json`（不推荐）。

### 分支冲突 / 路径问题

**解决**：

```bash
# 查看当前工作副本信息
svn info

# 查看当前所在分支
svn info | grep URL

# 切回主干
svn switch ^/trunk

# 查看分支列表
svn list ^/branches/vibe
```

详见 `.codebuddy/skills/core/use-svn-branch/SKILL.md`。

### Write 工具新建的 `.sh` 脚本跑起来报 `invalid option name "pipefail\r"`

**症状**：用 AI 的 Write 工具刚生成一个 `.sh` 脚本，立即跑就报：

```text
xxx.sh: line 2: set: pipefail
: invalid option name
```

或类似 `\r` 出现在错误信息里的情形。

**原因**：Write 工具在某些环境下偶发输出 **CRLF** 行尾（而非 LF），bash 把 `set -o pipefail\r` 当成无效选项名。这是上游工具的已知问题（详见 `.codebuddy/docs/PHASE5-FINDINGS.md` F-1.5）。

**SVN 层已防护**：`svn:ignore` 属性可排除临时文件。但**工作副本中未提交的文件**仍可能受影响。

**解决**（commit 前的 workaround）：

```bash
# 写完后立刻 normalize
f=scripts/your-new.sh
tr -d '\r' < "$f" > "$f.tmp" && mv "$f.tmp" "$f" && chmod +x "$f"

# 或一次性扫所有 .sh
find scripts -name '*.sh' -exec sh -c 'tr -d "\r" < "$1" > "$1.tmp" && mv "$1.tmp" "$1" && chmod +x "$1"' _ {} \;
```

**或者**：写完先 `svn add` 一次，再检查文件编码是否正确。

**根治**：升级 Write 工具，或在工具配置层强制 LF 输出。当前是已知 workaround，待上游修。

## MCP

### MCP server 启用了但 agent 用不了

参见 [MCP_SETUP.md](MCP_SETUP.md) 的"故障排查"段。

## 通用排查清单

按顺序跑：

1. `./.codebuddy/scripts/doctor.ps1`（或 `.sh`）——看四类检查
2. `./.codebuddy/scripts/doctor.ps1 -Json | ConvertFrom-Json` ——结构化看具体问题
3. 看 `.vibe/cache/` 有无最近的错误日志
4. 看 `requirements/<id>/process.txt` 末尾，理解上次 AI 在做什么时中断
5. 看 `.vibe/.initialized` 确认 init 已经跑过
6. 重启 AI 客户端（清缓存）
7. 实在不行：`./.codebuddy/scripts/init.ps1 -Force` 强制重新初始化（**不会**删 requirements/ 与 context/project/）

## 我没找到匹配的问题

提 issue 时请附：

- `./.codebuddy/scripts/doctor.ps1 -Json` 的输出
- 操作系统 + AI 客户端版本
- 复现步骤
- 期望行为 vs 实际行为
