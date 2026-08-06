# 快速开始

> 目标：从 clone 到第一个需求被 `product-manager` agent 接管，**5 分钟内完成**。
>
> 已经有 Cursor / Claude Code / CodeBuddy 任一，对 vibecoding 心里有数？跳到 [3 分钟最短路径](#3-分钟最短路径)。

## 前置条件

- **Cursor** / **Claude Code** / **CodeBuddy** 至少装一个（见 [INSTALL.md](INSTALL.md) 详细要求）
- **SVN** ≥ 1.9
- 操作系统二选一：
  - **Windows**：PowerShell 5.1+（Win10/11 自带）
  - **macOS / Linux**：Bash 4+

> 如缺前置条件，去看 [INSTALL.md](INSTALL.md)。

## 步骤

### 1. Checkout 模板

```bash
svn checkout <模板仓库地址> my-project
cd my-project
```

### 2. 初始化

**Windows (PowerShell)：**

```powershell
.\scripts\init.ps1
```

**macOS / Linux (bash)：**

```bash
./.codebuddy/scripts/init.sh
```

脚本会问 2 个问题：

```text
项目名（kebab-case，会用作目录名）[my-project]: my-app
代码仓库路径（绝对或相对，可空表示暂不绑定）[]: ../workspace/my-app
```

完成后会自动：

- 把全仓 `wepop-trunk` 与 `d:\WePop_trunk` 占位符替换为你给的真实值
- 在 `context/project/<your-name>/` 建知识库骨架（含 INDEX.md）
- 在 `.vibe/.initialized` 写入初始化标记（防重跑）

> 加 `-InitSvn`（PS）/ `--init-svn`（sh）会顺便执行 `svn add` 并提交首个 commit。

### 3. 健康检查（可选但推荐）

```powershell
.\scripts\doctor.ps1     # Windows
./.codebuddy/scripts/doctor.sh      # macOS/Linux
```

预期输出：

```text
  Stats:
    Assets missing:      0
    State inconsistent:  0
    Broken links:        0 / 60+
    Placeholders:        0    ← init 跑过应该是 0

  Health: healthy
```

如果占位符不为 0，说明 init 没跑完——重跑一次。

### 4. 用 Cursor / Claude Code / CodeBuddy 打开

```bash
cursor .
# 或
claude
# 或
codebuddy .
```

### 5. 创建第一个需求

在 AI 对话中输入：

```text
/pm-new
```

会问你 5 个问题：

```text
? req-id（短标识，kebab-case）：       my-first-feature
? 标题：                              我的第一个功能
? SOP（默认 agile-vibe）：              （回车默认）
? 代码工程位置（默认用 init 时设的）：  （回车）
? 是否需求来自外部链接（TAPD/PRD 等）： n
```

`pm-new` 会：

1. 调用 `.codebuddy/scripts/new-requirement.ps1` 创建 `requirements/req-my-first-feature/` 骨架
2. 同步 `requirements/INDEX.md` 与 `INDEX.yaml`
3. 委派 `product-manager` agent 开始需求澄清

### 6. 进入 product-manager 的提问

`product-manager` 会用 `AskUserQuestion` 问你需求细节（一次性 ≤ 5 个问题）。回答后它整理成 `spec/需求简述.md`（agile-vibe）或 `spec/需求文档.md`（deep-vibe）。

完成后流程进入下一阶段（agile-vibe 是 iteration / deep-vibe 是 design）。

## 3 分钟最短路径

```bash
svn checkout <repo> my-project && cd my-project
./.codebuddy/scripts/init.sh -n my-app -r ../my-app --init-svn --non-interactive
cursor .
# 在 AI 对话:
/pm-new
```

完成。

## 接下来怎么走？

| 想做什么 | 看哪 |
|---|---|
| 看下一步该用什么命令 | [COMMAND_GUIDE.md](COMMAND_GUIDE.md) |
| 理解 SOP 流程是怎么走的 | [SOP_GUIDE.md](SOP_GUIDE.md) |
| 理解 14 个 Agent 各自的职责 | [AGENT_GUIDE.md](AGENT_GUIDE.md) |
| 看 11 个 Skill 都做什么 | [SKILL_GUIDE.md](SKILL_GUIDE.md) |
| 整体架构与设计权衡 | [ARCHITECTURE.md](ARCHITECTURE.md) |
| 出问题了 | [TROUBLESHOOTING.md](TROUBLESHOOTING.md) |
| 想接入数据库/浏览器/GitHub MCP | [MCP_SETUP.md](MCP_SETUP.md) |

## 常用命令速查

| 命令 | 用途 |
|---|---|
| `/pm-new` | 创建新需求 |
| `/pm-continue <req-id>` | 续接某个需求 |
| `/pm-status` | 查看所有需求当前状态 |
| `/req-add <req-id> <task>` | 给需求加任务 |
| `/req-done <req-id> <task-id>` | 标记任务完成 |
| `/sop-list` | 列出可用 SOP |
| `/skill-new` | 创建新 Skill |
| `/skill-list` | 列出所有可用 Skill |
| `/vibe-loop` | 进入快速迭代（agile-vibe iteration 阶段用） |
| `/code-review` | 触发代码评审 |
| `/doctor` | 仓库一致性体检 |

完整命令清单见 [COMMAND_GUIDE.md](COMMAND_GUIDE.md)。

## 出问题了？

1. 跑 `./.codebuddy/scripts/doctor.ps1`（或 `.sh`），看是否有 **链接断裂** / **状态不一致** / **占位符遗留** / **资产缺失**
2. 看 `.vibe/cache/` 里 doctor 的最近 JSON 报告
3. 详细排查清单见 [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
4. 重新初始化：`.\scripts\init.ps1 -Force`（会重新替换占位符；**不会**删 requirements/ 与 context/project/）

---
*v0.1.0-alpha — Phase 4 完成。脚本已落地可用。*
