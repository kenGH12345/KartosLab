# MCP 配置指南

> Model Context Protocol（MCP）让 AI 客户端能调用外部工具。
> 本模板预置了 5 个常用 MCP server 模板，**默认全部禁用**。
>
> 全部配置都在 `.mcp.json`（项目根）。**Claude Code 与 CodeBuddy 共用同一份**（都直接读项目根 `.mcp.json`，无需任何转换）；Cursor 通过 `.codebuddy/scripts/sync-mcp.{sh,ps1}` 镜像到 `.cursor/mcp.json`。

## 当前预置

| MCP server | 用途 | 默认状态 | 启用方式 |
|---|---|---|---|
| `_filesystem_disabled` | 让 AI 读写指定文件夹 | 禁用 | 改名为 `filesystem` |
| `_github_disabled` | GitHub API（issue/PR/code search） | 禁用 | 改名为 `github` + 设 token |
| `_browser_disabled` | Puppeteer/Playwright 浏览器自动化 | 禁用 | 改名为 `browser` + 装依赖 |
| `_postgres_disabled` | 直连 PostgreSQL 数据库 | 禁用 | 改名为 `postgres` + 改 connection string |
| `_custom_internal_disabled` | 自家内部 MCP 服务器示例 | 禁用 | 改名 + 改 endpoint |

> **命名约定**：模板里所有 server 都用 `_*_disabled` 后缀。**移除后缀即生效**。

## 启用步骤（通用）

### 1. 编辑 `.mcp.json`

```jsonc
{
  "mcpServers": {
    // 把：
    "_filesystem_disabled": { ... },
    // 改为：
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/allowed/dir"]
    }
  }
}
```

### 2. 装依赖

大部分官方 MCP server 是 npm 包，会用 `npx` 自动拉取。需要 Node.js ≥ 18。

特殊依赖：
- **browser**：需要 `npx playwright install chromium`
- **postgres**：需要安装 `@modelcontextprotocol/server-postgres` 全局或本地
- **github**：需要 GITHUB_PERSONAL_ACCESS_TOKEN 环境变量

### 3. 重启 AI 客户端

Claude Code：会在重启时自动加载 `.mcp.json`。
Cursor：见下方「Cursor 配置位置」。

### 4. 验证

在 AI 对话中输入：

```text
列出当前可用的 MCP 工具
```

应该能看到新启用的 server 提供的工具。

## 各 MCP 详解

### filesystem

**用途**：让 AI 读写指定文件夹，比 Cursor/Claude 自带的工具更灵活。

**典型场景**：
- 让 AI 读取 `RepoPath` 之外的素材（设计稿、需求文档源文件）
- 跨多个仓库搬运代码

**配置**：

```jsonc
"filesystem": {
  "command": "npx",
  "args": [
    "-y",
    "@modelcontextprotocol/server-filesystem",
    "C:\\Users\\you\\Documents\\design-assets",
    "D:\\workspace\\related-project"
  ]
}
```

**安全建议**：只暴露明确需要的目录；**不要**暴露整个用户目录或盘符。

### github

**用途**：让 AI 直接读 issue、创建 PR、搜代码。

**配置**：

```jsonc
"github": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-github"],
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
  }
}
```

**Token 申请**：https://github.com/settings/tokens
- 最小权限：`repo:status` + `public_repo`（私有仓库选 `repo`）
- **不要**用 admin 级 token

**典型用法**：

```text
查一下 owner/repo 仓库里 #123 issue 的最新评论。
然后基于这些评论的反馈，给我 review 一下当前需求的方案。
```

### browser

**用途**：让 AI 操作浏览器——截图、点击、填表、爬数据。

**配置**：

```jsonc
"browser": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-puppeteer"]
}
```

**安装**：

```bash
# 第一次会很慢（下载 Chromium）
npx -y @modelcontextprotocol/server-puppeteer
```

**典型用法**：
- frontend-dev 改完 UI 后让 AI 跑预览截图
- code-reviewer 看 PR 时看部署预览
- 数据采集 / 表单测试

**安全建议**：
- 默认 sandbox 模式，限制对本地文件的访问
- **不要**让 AI 自动登录敏感账号——把登录态预先准备好（cookie 文件）

### postgres

**用途**：让 AI 直接查数据库（结构 + 数据）。

**配置**：

```jsonc
"postgres": {
  "command": "npx",
  "args": [
    "-y",
    "@modelcontextprotocol/server-postgres",
    "postgresql://user:pass@host:5432/dbname"
  ]
}
```

**或用环境变量**（推荐）：

```jsonc
"postgres": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-postgres", "${POSTGRES_URL}"]
}
```

**典型用法**：
- backend-dev 设计表前查现有 schema
- backend-leader 评估某个查询的成本
- closer 收尾时验证写入数据正确性

**强烈建议**：
- **只用只读账号**——MCP 默认会拦截 DDL，但 ALTER/DELETE 仍可能执行
- **绝不**给生产数据库的写权限到 AI——出事可逆性极低
- 用本地或 staging 环境的副本

### custom_internal

**用途**：接入团队/公司内部 MCP server。

**配置示例**：

```jsonc
"team_internal": {
  "command": "npx",
  "args": [
    "-y",
    "tsx",
    ".codebuddy/scripts/mcp/team-internal-server.ts"
  ],
  "env": {
    "API_BASE": "https://internal.team.com/api",
    "API_TOKEN": "${TEAM_API_TOKEN}"
  }
}
```

**典型场景**：
- TAPD/Jira 等内部需求管理系统接入
- 内部 wiki 检索
- 公司私有部署的 LLM 网关

可参考 `.mcp.json` 里 `_custom_internal_disabled` 的注释。

## 三端配置位置

| 工具 | MCP 配置位置 | 维护方式 |
|---|---|---|
| **Claude Code** | 项目根 `.mcp.json` | 直接读单一源，无需 sync |
| **CodeBuddy** | 项目根 `.mcp.json` | 直接读单一源（与 Claude Code 共享），无需 sync |
| **Cursor**（项目级） | `.cursor/mcp.json` | 由 `.codebuddy/scripts/sync-mcp.{sh,ps1}` 从 `.mcp.json` 镜像（init 时自动跑） |
| **Cursor**（用户全局，可选） | macOS: `~/.cursor/mcp.json` / Windows: `%USERPROFILE%\.cursor\mcp.json` | 手工维护 |

**改动 MCP 配置时的标准流程**：

1. 编辑项目根 `.mcp.json`（单一源）
2. 跑 `./.codebuddy/scripts/sync-mcp.sh`（macOS/Linux）或 `.\scripts\sync-mcp.ps1`（Windows）镜像到 `.cursor/mcp.json`
3. 在使用该 MCP 的工具里重启会话（让 MCP server 重新连接）

Claude Code 与 CodeBuddy 不需要任何 sync——它们都会直接读项目根的 `.mcp.json`。

## 故障排查

### MCP server 启用了但 AI 看不到工具

1. 检查 JSON 语法：`Get-Content .mcp.json | ConvertFrom-Json`（PS）或 `cat .mcp.json | jq .`（bash）
2. 重启 AI 客户端（**完全关闭进程**再开，不只关窗口）
3. 看 server 是否真的启动：`npx -y @modelcontextprotocol/server-filesystem .` 单独跑试试
4. 看 AI 客户端的日志：
   - Claude Code：`~/.claude/logs/`
   - Cursor：`Help > Toggle Developer Tools > Console`

### MCP 工具调用超时

- 大概率是 server 启动慢（首次 npx 下载）。手工跑一次 `npx -y <package>`（让缓存生效），再回 AI 客户端
- 如果是 `browser`，确保 Chromium 已下载（`npx playwright install chromium`）

### MCP 报"权限被拒绝"

- 检查 `.claude/settings.json` 的 `permissions.allow`/`deny` 没有把 MCP 工具屏蔽
- 注意：模板的 settings.json 默认拒绝 `Bash(svn commit:*)` 等，但 MCP 工具调用不走 Bash，不受影响

## 安全要点

1. **MCP server 跑在你本地**，能访问文件系统、网络、数据库——以你的权限身份
2. **Token / 密码用环境变量**，不要硬编码到 `.mcp.json`
3. **`.mcp.json` 是会被 SVN 跟踪的** —— 不要把秘密放进去
4. 数据库 MCP **只用只读账号**
5. browser MCP **不要自动登录敏感账号**
6. 团队共享时，把 MCP 配置 review 当作新增依赖来对待

---
*更多 MCP server 列表：https://github.com/modelcontextprotocol/servers*
