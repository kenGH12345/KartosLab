---
description: "续接某个需求，恢复现场并推进到下一步"
argument-hint: "<req-id>"
allowed-tools: [Read, Edit, Write, Bash, Glob, Grep, AskUserQuestion, Task]
model: sonnet
---

# /pm-continue — 续接需求

**主会话直接执行 PM 职责**——读状态、判断阶段、委派执行者、回写状态。不委派 主会话。

## 步骤

### 1. 解析 req-id

从 `$ARGUMENTS` 取 req-id；如未提供，列出 `requirements/INDEX.md` 中所有 `status != done` 的需求让用户选。

### 2. 现场恢复

读取以下文件，建立上下文：

1. `requirements/req-<req-id>/meta.yaml`（当前 phase / status / sop）
2. `requirements/req-<req-id>/process.txt`（最近 20 行）
3. `requirements/req-<req-id>/plan.md`（目标与里程碑）
4. 根据 `sop` 字段加载 SOP 定义：`.codebuddy/sop/agile-vibe.md` 或 `.codebuddy/sop/deep-vibe.md`

用一段话总结："当前需求 X 处于阶段 Y，上次停在 Z，下一步应该 W"，展示给用户。

### 3. 判断下一动作

| 情况 | 行动 |
|---|---|
| 上一阶段已完成、未启动下一阶段 | 委派下一阶段的执行者 |
| 上一阶段进行中 | 续接同一执行者（带上次中断处的上下文） |
| 上一阶段被报告阻塞 | 判断退回哪个阶段，用 `AskUserQuestion` 确认 |
| 用户主动跳到某阶段 | 用 `AskUserQuestion` 确认是否真的要跳过中间阶段 |

### 4. 阶段 → 执行者映射

> ⚠️ **phase 格式必须是 `N.name`**（如 `1.init` `2.requirement` `3.iteration` `4.closing`），禁止写 `phase-1` 等非标格式。

#### agile-vibe（4 阶段）

| 阶段 | 执行者 |
|---|---|
| 1. 初始化 | （脚本生成，不需 Agent） |
| 2. 需求定义 | 委派 `product-manager` |
| 3. 迭代开发 | **主会话直接执行，禁止委派 `frontend-dev` / `backend-dev`**。即使存在 `tasks/features.json`，也由主会话逐条实现 |
| 4. 收尾沉淀 | **必须按顺序串联 3 个 agent**：`code-reviewer` → `closer` → `knowledge-maintainer`。三个都跑完才算 done |

> ⚠️ **阶段 4 硬约束**：不可只跑 code-reviewer 就停。closer 产出 `spec/最终需求.md`，KM 回写 `context/project/`。缺任何一个 = 阶段未完成。

#### deep-vibe（5 阶段）

| 阶段 | 执行者 |
|---|---|
| 1. 想清楚 | 委派 `product-manager` |
| 2. 出方案 | 委派 `tech-leader`（会进一步派发 `frontend-leader` / `backend-leader`）→ `design-reviewer` |
| 3. 写代码 | 委派 `frontend-dev` / `backend-dev`（按需） |
| 4. 跑通它 | 委派 `test-runner` |
| 5. 收个尾 | **必须按顺序串联 3 个 agent**：`code-reviewer` → `closer` → `knowledge-maintainer` |

#### game-design（3 阶段，游戏策划）

| 阶段 | 执行者 |
|---|---|
| 1. 初始化 | 脚本生成 |
| 2. 策划细化 | 委派 `game-designer`（多轮迭代，可调用 `image_gen` 出概念图） |
| 3. 定稿沉淀 | `closer` → `knowledge-maintainer` |

> ⚠️ **game-design 无编码阶段**：产出都是 `spec/` 下的策划文档。如后续需要开发，新建 agile-vibe/deep-vibe 需求衔接。
>
> 💡 **game-design 收尾委派 closer 时**：不要把所有 spec/*.md 全文塞进 prompt。只传：① 需求目录路径 ② 要求产出 `spec/最终策划案.md`（一页纸摘要 + 决策时间线）③ 让 closer 自己 read_file 按需读取。这能避免 token 超限。

### 5. 状态写入（先写后做）

委派前**必须**按以下顺序写入（参见 `45-state-sync-protocol.mdc`）：

1. `meta.yaml`: phase 改为目标阶段（格式 `N.name`），status 改为 in_progress，updated_at 改为现在
2. `process.txt`: 追加 `[YYYY-MM-DD HH:MM] N-1.old → N.new: <原因>，委派 <agent-name>`
3. 跑 `bash .codebuddy/scripts/rebuild-index.sh`（自动从 meta.yaml 重建 INDEX.md）
4. 调用 `Task` 工具委派执行者，传入必要上下文

> ⚠️ process.txt 的阶段切换格式必须是 `N-1.old → N.new`（如 `2.requirement → 3.iteration`），不可写 `phase-1 → phase-2` 等非标格式。

### 5.5 用户确认后写 verdict

当用户回复确认"进入下一阶段"或"接受当前产出"时，**必须**在 process.txt 追加：

```
[YYYY-MM-DD HH:MM] verdict=approve_go / 备注: <用户原话摘要>
```

不允许跳过 verdict 直接切阶段——这是 `/pm-status` 和 `/doctor` 追溯决策链的依据。

### 6. 接收结果，回写状态

执行者返回后：

1. 读取返回摘要
2. `process.txt`: 追加 `[YYYY-MM-DD HH:MM] X 阶段完成，产物: → <path>`
3. `meta.yaml`: 更新 phase 与 updated_at
4. 跑 `bash .codebuddy/scripts/rebuild-index.sh`
5. 向用户汇报：当前完成了什么、下一步打算做什么
6. **立即推进到下一阶段**——不可停留等用户提示"继续"

> ⚠️ **硬约束**：编码阶段（3.coding/3.iteration）完成后，主会话必须主动推进到收尾阶段（4.closing/5.closing），不可停在编码阶段等用户手动触发。

### 7. 上下文复用（强制）

主会话已做过的探查、用户已回答过的问题，**禁止让下游 Agent 再做一次**。委派 `Task` 时必须把已有结论作为 prompt context 传入：

```
传给下游的 prompt 应包含：
- 当前需求的 ID 与目录路径
- meta.yaml / process.txt 关键摘要（不是全文）
- 主会话本轮已收集的关键事实（用 "已知:" 列出）
- 用户已确认的决策（用 "用户已确认:" 列出）
- 当前任务的明确目标（一句话）
```
