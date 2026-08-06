# 安装与前置条件

> AIVibeCodingProj 是一个 SVN 仓库模板，**不是**软件包。安装本质上就是 checkout + init。
> 这份文档列出"用之前需要把什么装好"。

## 必需

### 1. AI 客户端（任选其一或全部）

#### Cursor

- **下载**: https://cursor.com
- **版本**: 最新稳定版即可（v0.40+ 起 commands 与 rules 体系趋于稳定）
- **配置**: 不需要额外配置；`.cursor/rules/*.mdc` 与 `.cursor/commands/*.md` 会被自动识别

#### Claude Code

- **下载**: https://claude.ai/code
- **版本**: 最新稳定版即可（v0.5+ 起 subagents 体系趋于稳定）
- **配置**: `.claude/agents/*.md` 与 `.claude/commands/*.md` 会被自动识别；`.claude/settings.json` 已预置安全权限策略

#### CodeBuddy（Tencent Cloud Code Assistant）

- **下载**: https://codebuddy.ai
- **版本**: 最新稳定版（CodeBuddy IDE 或 CodeBuddy CLI）
- **配置**: `.codebuddy/agents/*.md`、`.codebuddy/commands/*.md`、`.codebuddy/rules/*.mdc` 会被自动识别；`.codebuddy/settings.json` 已预置；`CODEBUDDY.md` 缺失时会自动 fallback 到 `AGENTS.md`

> 三端任选其一，或同时装并混用——本模板用「三端原生」设计：同一组 commands / agents / rules 在三端各自的官方目录都有一份，由 `.codebuddy/scripts/sync-commands.{sh,ps1}` 与 `.codebuddy/scripts/sync-codebuddy.{sh,ps1}` 保持镜像一致。详见 [ARCHITECTURE.md](ARCHITECTURE.md) 第 1 节与 [ADR-0004](ADR/0004-codebuddy-native-mirror.md)。

### 2. SVN

- **版本**: ≥ 1.9
- **检查**: `svn --version`

```bash
# Windows: https://tortoisesvn.net/ 或用 winget
winget install --id TortoiseSVN.TortoiseSVN -e

# macOS:
brew install svn

# Linux (Debian/Ubuntu):
sudo apt-get install subversion
```

### 3. Shell

模板的初始化脚本有两套等价实现，选其一即可：

| 平台 | 推荐 |
|---|---|
| Windows | **PowerShell**（5.1+ 自带，7+ 跨平台） |
| macOS | **Bash 4+**（系统自带 3.2 太老，推荐 `brew install bash`） |
| Linux | **Bash 4+**（绝大多数发行版自带） |

> Windows 用户**也可**用 WSL2 跑 bash 版本，但 PowerShell 版本是 first-class 支持。

## 可选

### Node.js

**何时需要**：

- 启用 `_browser` MCP（用 puppeteer/playwright 做截图与 E2E）
- 启用 `_filesystem` `_github` 等 npm 分发的 MCP server
- 你的代码项目本身是 Node 项目

**版本**: ≥ 18 (LTS)

```bash
# 推荐用 nvm 管理：
# Windows: nvm-windows (https://github.com/coreybutler/nvm-windows)
# macOS/Linux: https://github.com/nvm-sh/nvm
nvm install --lts
```

### Python 3

**何时需要**：

- 启用 `_postgres` MCP 或其他 Python 分发的 MCP server
- 你的代码项目本身是 Python 项目
- 跑某些自定义 hooks

**版本**: ≥ 3.10

```bash
# Windows: https://www.python.org/downloads/ 或 winget
winget install --id Python.Python.3.12 -e
# macOS:
brew install python@3.12
# Linux:
sudo apt-get install python3 python3-pip
```

### 代码项目仓库

模板**本身**是工作流仓库，不是代码仓库。建议另外开一个目录放真实代码：

```text
parent-folder/
├── my-app-vibe/       ← AIVibeCodingProj 实例（工作流）
└── my-app/            ← 真实代码仓库
```

`init.ps1` 时把 `RepoPath` 设为 `../my-app` 即可。

也可以两者合一（vibe 工作流与代码同仓），看团队偏好。

## 平台特定注意事项

### Windows

#### PowerShell 执行策略

如果运行 `.ps1` 报"无法加载脚本"，先放开执行策略：

```powershell
# 当前用户级（推荐）
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# 或者只对单次执行放开
powershell -ExecutionPolicy Bypass -File .\scripts\init.ps1
```

#### PowerShell 版本与编码

- **PowerShell 5.1（Win10/11 默认）**：脚本必须 UTF-8 BOM 才能正确解析中文字符（已处理，模板里 `.ps1` 都带 BOM）
- **PowerShell 7+**：默认 UTF-8（无 BOM），更现代，**推荐**

PowerShell 7 安装：

```powershell
winget install --id Microsoft.PowerShell -e
# 之后用 pwsh 而非 powershell
pwsh
```

### macOS

#### 系统 Bash 太老

macOS 自带 `/bin/bash` 是 3.2（License 原因）。脚本里用了 `mapfile -d` 等 4+ 语法。

```bash
brew install bash
# 之后跑脚本前
PATH="/opt/homebrew/bin:$PATH" ./.codebuddy/scripts/init.sh
```

或者直接显式调用新版 bash：

```bash
/opt/homebrew/bin/bash ./.codebuddy/scripts/init.sh
```

### Linux

无特殊要求。常见发行版（Ubuntu 20.04+ / Debian 11+ / Fedora 36+）开箱即用。

## 验证安装

checkout + init 完成后，跑：

```powershell
.\scripts\doctor.ps1     # 或 ./.codebuddy/scripts/doctor.sh
```

期望看到 `Health: healthy`（或仅 `subhealthy`，如果你刚创建了需求但还没填完整）。

## MCP 服务器（可选）

模板预置了 5 个 MCP server 模板（默认全部 `_disabled`）：

- filesystem / github / browser / postgres / custom-internal

如要启用，见 [MCP_SETUP.md](MCP_SETUP.md)。

## 升级模板

模板会持续演进。从老版本升级，见 [UPGRADE.md](UPGRADE.md)。

## 还需要什么？

- 想理解整体架构 → [ARCHITECTURE.md](ARCHITECTURE.md)
- 想立刻开始用 → [QUICKSTART.md](QUICKSTART.md)
- 出问题了 → [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
