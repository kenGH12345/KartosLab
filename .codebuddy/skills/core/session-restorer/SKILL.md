---
name: session-restorer
description: 用于在续接需求时（/pm-continue 或会话被打断后），从 meta.yaml + process.txt + plan.md 三个文件快速恢复"现场"——当前阶段、上次中断处、下一步预期。被 /pm-continue 第一步调用。
tools: Read, Bash
---

# session-restorer

> AI 没有连续记忆，每次新会话都从零开始。
> 这个 Skill 把"读三个文件 → 形成现场摘要"标准化，避免每次手搓上下文恢复逻辑。

## 何时使用

- ✅ `/pm-continue` 调用时第一步
- ✅ 任何 agent 接手某需求前，需要快速理解"现在在哪"
- ✅ 用户问"我们这个需求现在做到哪了？"
- ❌ 新建需求：用 `managing-requirement` 的 create operation
- ❌ 想看完整历史：直接 Read process.txt 全文

## 输入

| 输入 | 类型 | 必需 | 说明 |
|---|---|:-:|---|
| req_id | string | ✓ | 需求 ID |
| process_tail_lines | int | 可选（默认 20） | 读 process.txt 末尾多少行 |

## 步骤

### 1. Read meta.yaml

```
Read requirements/<req_id>/meta.yaml
提取关键字段：
  - req_id, title, sop
  - phase, status, updated_at
  - repo_path
  - phase_overrides（如有，标注"曾被强制切换"）
```

校验：文件不存在 → stop + report "需求不存在"。

### 2. Read process.txt 末尾 N 行

```bash
tail -n <process_tail_lines> requirements/<req_id>/process.txt
```

解析每行（按 `[<time>] <event>: <detail>` 格式），形成事件序列。

### 3. Read plan.md（仅"本轮目标"段）

```
Read requirements/<req_id>/plan.md
定位 "## 3. 本轮目标" 段
提取内容
```

如不存在该段：跳过。

### 4. 推导"上次中断处"

按以下优先级判定：

1. process.txt 最后一行的 event 是否表明"未完成"：
   - `agent_blocked` → 上次因阻塞中断
   - `agent_start`（无对应 agent_done） → 上次某 agent 中途中断
   - `phase` 切换后无后续 → 刚切换阶段未推进
2. meta.yaml status 字段：
   - `awaiting_user_input` → 等用户回答
   - `blocked` → 等阻塞解除
   - `in_progress` → 上次未完成
   - `done` → 阶段完成，可推进下一阶段

### 5. 加载对应 SOP 阶段定义（用于"下一步预期"）

```
Read .codebuddy/sop/<sop>.md
找到 phases 列表中 phase == meta.yaml.phase 的项
读取该阶段的"下一步"与"回退条件"
```

### 6. 形成"现场摘要"

```md
## 现场摘要：req-<id>

- **标题**: <title>
- **SOP**: <sop>
- **当前阶段**: <phase> (<status>)
- **最近更新**: <updated_at>
- **本轮目标**（来自 plan.md）: <如有>
- **上次中断处**: <推导结论>

### 最近 N 条事件
[<time>] <event>: <detail>
[<time>] <event>: <detail>
...

### 下一步预期（按 SOP 定义）
- 如继续推进 → <下一阶段或下一动作>
- 如需回退 → <回退条件提示>

### 注意事项
- 如 phase_overrides 不为空：标注"此需求曾被强制切换 N 次"
- 如 status = blocked：列出上次阻塞原因
- 如 updated_at > 7 天：标注"长期未推进"
```

## 输出

返回结构化数据 + markdown 摘要给调用方：

```json
{
  "req_id": "...",
  "title": "...",
  "sop": "agile-vibe",
  "phase": "3.iteration",
  "status": "in_progress",
  "last_event": "agent_start: 委派 frontend-dev",
  "interruption_inference": "frontend-dev 启动后未返回",
  "recent_events": [...],
  "next_action_hint": "重新委派 frontend-dev，传入上次未完成任务",
  "warnings": ["status=in_progress 但 14 小时未更新，可能确实中断"]
}
```

并在主会话输出 markdown 摘要（如上模板）。

## 边界与陷阱

> [!IMPORTANT]
> **不**修改任何文件。本 Skill 是只读的。

> [!WARNING]
> "上次中断处"是**推断**——不是事实。如推断不确定，必须在摘要中明确标注 `[推断]`，让调用方决定是否需要先和用户确认再行动。

- ❌ 不要假装比 process.txt 知道得多
- ❌ 不要替用户做决策（"建议委派 X"是 hint，最终由主会话/用户决定）
- ❌ 不要 N 设得太大（默认 20 已够；过多会让摘要噪音）
- ❌ 不要忽略 phase_overrides（这是重要信号——曾被强制切换的需求可能状态不一致）
- ✅ 如 SOP 文件不存在（用户改名了？），明确报告并跳过"下一步预期"
- ✅ 不确定时偏保守：标注 `[推断]` 让上层判断

## 关联 Skill

- `managing-requirement` 的反向操作：本 Skill 读，managing-requirement 写
- `/pm-continue` 的标配前置 Skill

## 变更历史

| 日期 | 版本 | 变更 | 触发原因 | 操作者 |
|---|---|---|---|---|
| - | 0.1.0 | 初始创建 | Phase 3 | template |
