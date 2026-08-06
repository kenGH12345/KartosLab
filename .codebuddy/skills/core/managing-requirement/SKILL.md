---
name: managing-requirement
description: 用于在需求生命周期内（新建 / 推进阶段 / 追加任务 / 完成任务 / 归档）按统一规则维护 requirements/<req-id>/ 下的 meta.yaml / process.txt / INDEX 等状态文件。被 /pm-* 与 /req-* 命令调用。
tools: Read, Write, Edit, Glob, Bash
---

# managing-requirement

> 这个 Skill 是**所有需求级写操作的统一入口**——避免每个 command/agent 都自己手搓 meta.yaml 与 process.txt。
> 它把「先写状态再做事」「INDEX 同步」「时间戳取用」这些容易遗漏的步骤固化下来。

## 何时使用

- ✅ `/pm-new`：创建新需求骨架
- ✅ `/pm-continue`：推进到下一阶段
- ✅ `/pm-phase`：强制切换阶段
- ✅ `/req-add`：追加任务到 tasks/features.json
- ✅ `/req-done`：标记任务完成
- ✅ `/req-archive`：归档需求
- ✅ 任何需要写 meta.yaml / process.txt / INDEX 的 agent
- ❌ 修改需求产物（spec / design / tasks 文档内容）：不是本 Skill 范围
- ❌ 修改代码：不是本 Skill 范围

## 输入

| 输入 | 类型 | 必需 | 说明 |
|---|---|:-:|---|
| operation | enum | ✓ | `create` / `transition_phase` / `force_phase` / `add_task` / `complete_task` / `archive` |
| req_id | string | ✓ | kebab-case |
| extra | object | 部分必需 | 不同 operation 的额外参数 |

每种 operation 的 extra 参数：

| operation | extra 字段 |
|---|---|
| create | `title`, `sop`, `repo_path?` |
| transition_phase | `target_phase`, `target_status?` |
| force_phase | `target_phase`, `reason` |
| add_task | `task_title`, `ac?`, `files?`, `depends_on?`, `verify?`, `owner?` |
| complete_task | `task_id`, `commits?`, `verification?`, `notes?` |
| archive | `reason?` |

## 步骤

### 通用前置：取真实时间戳

```bash
date "+%Y-%m-%d %H:%M"
```

> [!IMPORTANT]
> **不要编造时间**。所有写入 `meta.yaml` / `process.txt` 的时间必须是 `date` 命令的真实输出。

### operation = create

1. 校验 req-id 不重复（`Test-Path requirements/<req-id>` 应失败）
2. 复制 `requirements/_template/` 到 `requirements/<req-id>/`（如无 _template，按 references/initial-skeleton.md 创建）
3. 替换 `meta.yaml` 占位符：
   - `{{REQ_ID}}` → req-id
   - `{{TITLE}}` → title
   - `{{SOP}}` → sop（默认 agile-vibe）
   - `2026-05-29 13:40` → 真实时间戳
   - `d:\WePop_trunk` → repo_path（如未提供，留 `d:\WePop_trunk`）
4. `process.txt` 写入第一行：`[time] init: 创建需求骨架，sop=<sop>`
5. `plan.md` 按 references/initial-skeleton.md 中的"plan.md 模板"章节初始化
6. 调用 `docs-index-updater` 同步：
   - `requirements/INDEX.md` 表格追加一行
   - `requirements/INDEX.yaml` `requirements:` 列表追加一项

### operation = transition_phase

> 这是阶段切换的**标准入口**——必须按"先写状态后做事"顺序，遵守规则 `45-state-sync-protocol.mdc`。

1. Read 当前 `meta.yaml`，记录 `prev_phase` / `prev_status`
2. 校验 `target_phase` 严格匹配 SOP 定义：
   - 解析 `target_phase` 必须形如 `<id>.<name>`（如 `4.testing`），否则 stop + report
   - 读 `.codebuddy/sop/<sop>.md` 的 phases 列表，必须存在某项同时满足 `id == 解析出的 id` 且 `name == 解析出的 name`
   - 不匹配（如 `4.coding` —— deep-vibe 中 id=4 的 name=testing 而非 coding）→ stop + report，附该 SOP 的合法 phase 全集
3. 写 `meta.yaml`:
   - `phase: <target_phase>`
   - `status: <target_status or in_progress>`
   - `updated_at: <真实时间戳>`
4. `process.txt` 追加：`[time] phase: <prev_phase> → <target_phase>，原因：<可空>`
5. **不**自动委派下游 agent（这是调用方的责任）

### operation = force_phase

> 强制切换。比 transition_phase 多一步：必须有 reason，且要追加 phase_overrides 段。

1. 与 transition_phase 相同的 1-4 步
2. 在 `meta.yaml` 的 `phase_overrides` 段追加（如不存在则创建）：
   ```yaml
   phase_overrides:
     - timestamp: "<真实时间戳>"
       from: <prev_phase>
       to: <target_phase>
       reason: "<reason>"
   ```
3. `process.txt` 追加额外标记：`[time] ⚠️ 强制切换 <prev_phase> → <target_phase>，理由：<reason>`

### operation = add_task

1. Read `requirements/<req-id>/tasks/features.json`（不存在则创建空 `{ "tasks": [] }`）
2. 取下一个 task id（已有 task 数 + 1，格式 `task-<n>`）
3. 追加任务对象：
   ```json
   {
     "id": "task-<n>",
     "title": "<task_title>",
     "ac": "<ac or n/a>",
     "files": [...],
     "depends_on": [...],
     "verify": "...",
     "owner": "<FE/BE/Full-stack>",
     "status": "pending",
     "created_at": "<真实时间戳>"
   }
   ```
4. `process.txt` 追加：`[time] add_task: task-<n> <task_title>`

### operation = complete_task

1. Read tasks/features.json，找到 task_id
2. 校验：
   - 存在
   - status != done
   - depends_on 项均已 done（如否，要求调用方确认强制完成）
3. 更新该任务：
   ```json
   {
     ...,
     "status": "done",
     "completed_at": "<真实时间戳>",
     "commits": [...],
     "verification": "...",
     "notes": "..."
   }
   ```
4. `process.txt` 追加：`[time] complete_task: task-<n> → commits: <shas>`
5. 检查是否所有任务都 done：是则在返回摘要中提示

### operation = archive

1. Read meta.yaml，校验 `status` 为 `done`（否则要求二次确认）
2. `mv requirements/<req-id> requirements/_archived/<req-id>`
3. 调用 `docs-index-updater`：
   - INDEX.md：从主表删除该行（或移到"已归档"段）
   - INDEX.yaml：标记 `archived: true` 或移到 `archived:` 列表

## 输出

按 operation 不同：

```md
## managing-requirement 执行结果
- operation: <op>
- 状态: completed / blocked
- 涉及文件: meta.yaml / process.txt / tasks/features.json / INDEX.md / INDEX.yaml
- <operation 特有数据>
- 后续建议: <如适用>
```

## 边界与陷阱

> [!WARNING]
> **绝不**编造时间戳。每次操作都要现取 `date "+%Y-%m-%d %H:%M"`。

> [!IMPORTANT]
> 阶段切换必须按"先写后做"顺序。如果在写 meta.yaml 后调用下游失败，下次 `/pm-continue` 能从 process.txt 读到"刚切换过"，避免重复切换。

- ❌ 不要直接编辑 spec / design / tasks 文档内容（那是各阶段 agent 的事）
- ❌ 不要跳过 INDEX 同步（导致 `/pm-status` 显示不一致）
- ❌ 不要在没有 reason 的情况下做 force_phase
- ❌ 不要把 INDEX.md 里的其他需求行顺手"整理"
- ✅ 每次写完 meta.yaml 都追加 process.txt
- ✅ archive 操作前必须二次确认

## 引用资料

- [initial-skeleton.md](references/initial-skeleton.md) —— 新需求骨架模板（meta.yaml / plan.md / notes.md）
- [phase-transition-checklist.md](references/phase-transition-checklist.md) —— 阶段切换检查清单

## 关联 Skill

- `docs-index-updater` —— 用于同步 INDEX.md / INDEX.yaml
- `progress-logger` —— 用于追加 process.txt（本 Skill 的部分逻辑可直接调用 progress-logger）
- `session-restorer` —— 反向操作：从 meta.yaml + process.txt 恢复现场

## 变更历史

| 日期 | 版本 | 变更 | 触发原因 | 操作者 |
|---|---|---|---|---|
| - | 0.1.0 | 初始创建 | Phase 3 | template |
| 2026-05-04 | 0.1.1 | `transition_phase` 步骤 2 强化 phase 字段校验：要求 `<id>.<name>` 严格匹配 SOP phases 同一行（拦截 `4.coding` 这类 id↔name 错位）；`phase-transition-checklist.md` 通用检查表同步 | `.codebuddy/docs/SOP-CHECKUP-2026-05-04.md` Fix-1（demo `meta.yaml:11` 实证 phase=4.coding 与 deep-vibe SOP 定义 4=testing 错位） | 主会话 (claude-opus-4.7) |
