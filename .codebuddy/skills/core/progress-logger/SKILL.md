---
name: progress-logger
description: 用于在需求过程中追加 process.txt 的标准化日志行——格式 `[YYYY-MM-DD HH:MM] event: detail`。所有 agent / command 写日志的统一入口，避免日期格式漂移与字段缺失。
tools: Bash, Read, Edit
---

# progress-logger

> 一行格式不一致，未来 grep / 解析全部失败。
> 这个 Skill 把"取真实时间 + 拼一行 + 追加到 process.txt"固化下来。

## 何时使用

- ✅ 任何 agent / command 需要在 `requirements/<req-id>/process.txt` 追加进度
- ✅ `managing-requirement` 的所有 operation 都通过本 Skill 写日志
- ❌ 写其他文件（meta.yaml / notes.md / spec / design）：不是本 Skill 范围

## 输入

| 输入 | 类型 | 必需 | 说明 |
|---|---|:-:|---|
| req_id | string | ✓ | 需求 ID |
| event | enum | ✓ | 事件类型，见下方"事件清单" |
| detail | string | ✓ | 一行简述 |
| extra | object | 可选 | 附加结构化数据，会展开为多行缩进 |

## 步骤

### 1. 取真实时间戳

```bash
date "+%Y-%m-%d %H:%M"
```

> [!IMPORTANT]
> 不要编造时间。本 Skill 的全部价值就是「真实可信的时间戳序列」。

### 2. 校验 req-id 与 process.txt 存在

```bash
test -f requirements/<req_id>/process.txt
```

如不存在 → stop + report（process.txt 应该在 init 时就由 `managing-requirement` 创建）。

### 3. 校验 event 在合法清单内

见下方"事件清单"。如不在清单内：
- 提示调用方使用 `event=other` 并把原意写进 detail
- 或建议在本 Skill 演进时扩充清单（走 `/skill-evolve`）

### 4. 拼接日志行

```
[<timestamp>] <event>: <detail>
```

如有 extra：

```
[<timestamp>] <event>: <detail>
  <key1>: <value1>
  <key2>: <value2>
```

（缩进 2 空格，每行一个 key-value）

### 5. 追加到文件

```bash
echo "<line>" >> requirements/<req_id>/process.txt
```

或用 Edit 工具在末尾追加（更安全，避免 shell 转义问题）。

### 6. 不写其他文件

仅追加 process.txt。如调用方还需要更新 meta.yaml / notes.md，那是它们各自的责任。

## 事件清单

| event | 用途 | 典型 detail |
|---|---|---|
| `init` | 初始化 | `创建需求骨架，sop=agile-vibe` |
| `phase` | 阶段切换 | `2.requirement → 3.iteration` |
| `phase_force` | 强制切换 | `⚠️ 强制 1.init → 3.iteration，理由：...` |
| `agent_start` | 委派 agent | `委派 product-manager` |
| `agent_done` | agent 返回 | `product-manager 完成 → spec/需求简述.md` |
| `agent_blocked` | agent 阻塞 | `tech-leader blocked: 协议字段冲突` |
| `add_task` | 追加任务 | `task-3 实现 token refresh 接口` |
| `complete_task` | 完成任务 | `task-3 → commits: <sha>` |
| `vibe_loop` | vibecoding 一轮 | `第 2 轮：调按钮样式 → commit <sha>` |
| `review` | 评审记录 | `code-reviewer: 通过（Major 推迟 1 项）` |
| `test` | 测试记录 | `test-runner: 通过率 96%` |
| `user_decision` | 用户决策 | `用户确认采用方案 A` |
| `note` | 普通备注 | `<任意说明>` |
| `closed` | 收尾完成 | `closer 完成 → spec/最终需求.md` |
| `archived` | 归档 | `归档到 _archived/` |
| `other` | 其他（建议扩充清单） | `<...>` |

## 输出

```md
## progress-logger 执行结果
- 状态: appended
- 写入文件: requirements/<req_id>/process.txt
- 行内容: [<time>] <event>: <detail>
- 当前 process.txt 行数: N
```

## 边界与陷阱

> [!WARNING]
> **绝不**编辑 process.txt 历史行——它是追加式日志，编辑会破坏审计链。

> [!IMPORTANT]
> detail 必须**单行**（不含换行符）。多行内容用 extra 字段。

- ❌ 不要把时间戳写成 `2026/04/29 15:00` 等不一致格式
- ❌ 不要 detail 含 markdown 链接或代码块（保持纯文本可 grep）
- ❌ 不要批量追加多行（每次调用只写一行；如需多行用 extra）
- ❌ 不要在没有 req_id 的情况下调用（process.txt 是需求级文件）
- ✅ 时间戳统一格式 `YYYY-MM-DD HH:MM`
- ✅ event 必须在清单内（清单可演进）

## 关联 Skill

- `managing-requirement` 的所有 operation 内部调用本 Skill
- `session-restorer` 反向使用：从 process.txt 读最近若干行恢复现场

## 变更历史

| 日期 | 版本 | 变更 | 触发原因 | 操作者 |
|---|---|---|---|---|
| - | 0.1.0 | 初始创建 | Phase 3 | template |
