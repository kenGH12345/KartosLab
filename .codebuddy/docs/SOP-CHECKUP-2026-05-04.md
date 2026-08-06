# SOP 体检报告 — 2026-05-04

> **背景**：在 CodeBuddy 三端镜像验证基本通过后（参见 `.codebuddy/docs/PHASE5-FINDINGS.md`），借真实跑过 deep-vibe 的 demo（`/Users/tudou/ajin/demo-todo-app/requirements/req-quickchat-init`）作为证据样本，复盘当前两套 SOP 的轻量性、完整性、闭环性。
>
> **方法**：以 SOP 定义文件（`.codebuddy/sop/agile-vibe.md`、`.codebuddy/sop/deep-vibe.md`、`.codebuddy/sop/INDEX.md`）为"应然"，以 demo 真实流水（`process.txt` 40 行 + `meta.yaml` + `quick-chat` 仓 3 个 commit）为"实然"，做差异比对。所有引用均回源到 `<file>:<line>`。

---

## TL;DR

| 维度 | 评分 | 一句话结论 |
|---|---|---|
| **轻量性**（agile-vibe） | **B+** | 设计够轻（4 阶段 / 单 agent 串联），但**至今零真实样本**——无法证伪 |
| **完整性**（deep-vibe） | **A-** | 五阶段产物链完整且 demo 全程未卡死，但 schema 层有 3 个明显缺口 |
| **闭环性** | **B** | 阶段内反馈闭环完备；**3 条长闭环断裂**（跨需求 / SOP 自身 / AC↔代码） |

**最关键的发现（如果只看一条）**：`meta.yaml:11` 的 `phase: 4.coding` 与 `.codebuddy/sop/deep-vibe.md:25-28` 定义的 `phase 4 = testing` **不一致**，process.txt:33 自承"4.coding 按 deep-vibe SOP 编号对应 coding"——明知矛盾还这么写。说明 phase 字段缺约束、缺校验，agent 各写各的。

---

## 维度 1：轻量性（agile-vibe）— B+

### ✅ 设计上够轻

`.codebuddy/sop/agile-vibe.md:46-55` 的阶段图是单链：

```
init → requirement → iteration → closing
                       ↻
```

阶段 3 明确写"主会话与用户直接迭代，不强制委派"（`.codebuddy/sop/agile-vibe.md:108`）。
阶段 2 只跑 `product-manager` 一个 agent（`:84-101`）。
强制约束 5 条（30min 反馈 / 单 commit 单改动 / state-first / 3-Time Rule …）—— 都是 vibecoding 协议本身的，没有额外重型流程（`.codebuddy/sop/agile-vibe.md:118-123`）。

### ⚠️ 实证缺失

**事实**：到 2026-05-04 为止，agile-vibe **零真实样本**。

- `requirements/INDEX.yaml:4` 仍为 `requirements: []`
- 所有真实流程都跑在 demo 仓的 `req-quickchat-init`，走的是 deep-vibe（`/Users/tudou/ajin/demo-todo-app/requirements/req-quickchat-init/meta.yaml:6`）
- ROADMAP 原计划 Phase 5 Round 1 用 agile-vibe 跑 todo 增字段，实际改成了 quick-chat（deep-vibe），agile 路径被跳过

**风险**：

- "默认 SOP" 从未被 dogfood，意味着设计假设全部未被验证
- 阶段 4 的串联 `code-reviewer → closer → knowledge-maintainer`（`.codebuddy/sop/agile-vibe.md:139-142`）—— 串联是"自动转交"还是"用户每步确认"？没跑过就不知道
- 阶段 3"主会话直撸"在没有委派的情况下，process.txt 谁来追加？（agile-vibe 没规定）

### 评分依据

设计 A，实证 D → 综合 B+。

---

## 维度 2：完整性（deep-vibe）— A-

### ✅ 五阶段产物链完整

demo 走完了 phase 1.thinking → 2.design 全程 + 进入 phase 4（实为 coding，见缺口 1）。`process.txt` 第 1-40 行是一条**没有断裂的因果链**：

| 阶段 | demo 实证 | 产物 |
|---|---|---|
| 1.thinking | `process.txt:2-7` PM 两轮（v1.0 → v1.1） | `spec/需求文档.md` 含 10 条 AC |
| 2.1 粗判 | `process.txt:10` tech-leader medium → 升 complex | 复杂度 + 协作模式确认 |
| 2.2 框架 | `process.txt:11` 架构方案 v1.0 → `:18` v1.1 | `design/架构方案.md` + `架构方案-v1.1.md` |
| 2.3 细化 | `process.txt:21-22` FE/BE leader 并行 | `前端方案.md` + `后端方案.md` |
| 2.4 评审 | `process.txt:24` design-reviewer 5 Major / 10 Minor | `方案评审.md` |
| → 修补 | `process.txt:26-28` tech-leader 补丁 + FE/BE Addendum | `方案补丁-评审响应.md` + 2 份 Addendum |
| → 任务切分 | `process.txt:30-33` 27 任务 + 4 milestone | `tasks/{frontend,backend,features}.json` |
| coding | `process.txt:34-40` 3 个任务完成 | `quick-chat` 仓 3 commits |

**反馈回路也都跑过了**：

- `process.txt:14-17` "phase 3→2 回退（用户改平台决策）" —— 阶段 2→1 回退实际触发并工作
- `process.txt:25-28` "回 tech-leader 消化 5 Major" —— 阶段 2 内部 评审→框架 回路触发并工作

### ⚠️ schema 层 3 个缺口

#### 缺口 1：phase 字段编号与 SOP 定义脱节

| 位置 | 实际写法 | SOP 应然 |
|---|---|---|
| `meta.yaml:11` | `phase: 4.coding` | `.codebuddy/sop/deep-vibe.md:13-32` 定义 `4=testing`，`3=coding` |
| `process.txt:33` | "phase 3→4 按 deep-vibe SOP 编号对应 coding" | 自承矛盾 |
| `process.txt:9` | "phase 2→3(出方案)" | 但 SOP `3=coding`，"出方案" 应是 phase 2 |

**根因**：SOP 没规定 `phase` 字段的格式约束（`<id>.<name>` 还是别的），也没有校验脚本。agent 凭直觉写。

#### 缺口 2：子阶段 phase 编号丢失

deep-vibe 阶段 2 明确有 2.1 / 2.2 / 2.3 / 2.4 子阶段（`.codebuddy/sop/deep-vibe.md:99-122`），但：

- `meta.yaml:11` 全程只写 `phase: 4.coding`（之前是 `3.design`）
- 子阶段切换只能在 `process.txt` 自然语言里看出（`:20` "phase 3.design SubAgents 细化"、`:23` "phase 3.design 评审阶段"）
- 程序无法读出"现在在 2.几"

#### 缺口 3：用户 verdict 无统一 schema

demo `process.txt` 出现 3 种 ad-hoc 写法：

| 行 | 写法 |
|---|---|
| `:9` | `verdict=approve_go` |
| `:17` | `verdict=delegate_tl_v11` |
| `:34` | "用户选 A 方案推进" |

SOP 没规定枚举值。下游程序（如 doctor）想知道"用户上一次拍板说了什么"，得 NLP 解析。

### 评分依据

产物链 A，schema A- → 综合 A-。

---

## 维度 3：闭环性 — B

### ✅ 阶段内反馈完备

deep-vibe `:55-69` 定义了 5 条阶段内回路，demo 至少触发 2 条：

| 回路 | demo 实证 |
|---|---|
| 评审 → 框架（2.4 → 2.2） | ✅ `process.txt:25-26` |
| 阶段 3 → 阶段 1 | ✅ `process.txt:14-17`（用户改平台 → PM 重写） |
| coding → design（方案漏洞回退） | 未触发，但通道存在 |
| testing → coding | demo 还没到 |
| finalizing → coding/thinking | demo 还没到 |

### ⚠️ 3 条长闭环断裂

#### 断裂 A：跨需求知识沉淀 → 下个需求不读

- deep-vibe `:209-213` `knowledge-maintainer` 把项目级发现回写 `context/project/<name>/`
- 但 SOP 没规定**下个需求开 phase 1 时必须先读 `context/project/<name>/INDEX.md`**
- 风险：每个需求都从零开始问 PM，知识库变成"只写不读"的墓地

#### 断裂 B：SOP 自身的进化协议缺失

- `30-skill-self-evolution.mdc` 给 Skill 定义了 5 步进化协议（触发 → 诊断 → 拟改 → 用户确认 → 应用 + 留底）
- **SOP 没有同等协议**
- 本次体检发现的 3 个 schema 缺口、3 条长闭环断裂—— 改进路径不明（谁来改？走 `/sop-edit` 还是 `/skill-evolve`？要不要走相同的 5 步？）
- 风险：SOP 长期只有"加新 SOP"路径（`.codebuddy/sop/INDEX.md:41-45` 只提 `_template_sop.md`），没有"改现存 SOP" 路径

#### 断裂 C：AC ↔ 代码的反向追溯

- demo `quick-chat` 仓 3 个 commit message：
  - `dfdfc40 be-task-1: init monorepo skeleton (...)`
  - `002f83c be-task-2: shared protocol source (HTTP DTO + WS envelope + error codes + constants)`
  - `3f31baf fe-task-1: frontend skeleton (...)`
- **没有任何 commit 引用 AC 编号**
- 从 commit 反查"这个改动满足哪个 AC"必须先过 `tasks/features.json` 这一层
- phase 4.testing 的完成标准（`.codebuddy/sop/deep-vibe.md:177-180`）只要求"新增失败 = 0"和"AC 有对应测试用例"，**没要求"AC 全覆盖矩阵"作为门禁**
- phase 5 closer 也没要求验 AC 覆盖（`:201-207`）

### 评分依据

阶段内 A，长闭环 D → 综合 B。

---

## 5 条最强事实证据（去重精选）

| # | 缺口 | 一句话证据 | 引用 |
|---|---|---|---|
| 1 | phase 字段编号与 SOP 定义脱节 | demo `phase: 4.coding`，但 SOP 定义 `4=testing` | `meta.yaml:11` vs `.codebuddy/sop/deep-vibe.md:25-28` |
| 2 | 子阶段编号丢失 | 2.1-2.4 子阶段切换只在自然语言里 | `meta.yaml:11` vs `.codebuddy/sop/deep-vibe.md:99-122` |
| 3 | 用户 verdict 无 schema | 3 种 ad-hoc 写法 | `process.txt:9/17/34` |
| 4 | agile-vibe 零真实样本 | INDEX.yaml 仍为 `[]` | `requirements/INDEX.yaml:4` |
| 5 | AC ↔ commit 追溯断裂 | 3 个 commit 都没引用 AC 编号 | `quick-chat svn log` |

---

## 修复建议（按优先级 + 改动量）

> **原则**：最小化方案。能不改 SOP 就不改 SOP，能小改就不大改。

### P0 必修（≤ 30 min 可完成）

#### Fix-1：phase 字段格式标准化

- **改动**：在 `.codebuddy/sop/agile-vibe.md` 与 `.codebuddy/sop/deep-vibe.md` frontmatter 加一段：

  ```yaml
  phase_field_format: "<id>.<name>"   # 例：1.thinking, 2.design, 4.coding
  ```

- **影响**：`managing-requirement` skill 的 `transition_phase` operation 加校验：phase 必须能在当前 SOP 的 `phases[]` 里匹配到 `id` 或 `name`
- **工作量**：~15 min（改 2 个 markdown + 1 个 skill operation）

#### Fix-2：用户 verdict 枚举化

- **改动**：在 `40-state-sync-protocol.mdc` 或 `.codebuddy/sop/INDEX.md` 加一节"verdict 枚举"：

  ```
  verdict=approve_go | tweak | redo | back_to_phase_<N> | delegate_<agent> | quit
  ```

- **影响**：所有 agent 在 process.txt 写 verdict 时只能用枚举值；自由文本可写在备注
- **工作量**：~10 min

### P1 应修（半小时到 2 小时）

#### Fix-3：子阶段编号在 meta.yaml 落地

- **改动**：phase 字段允许三级编号 `<id>.<sub>.<name>`，例 `2.3.refine`、`2.4.review`
- **影响**：`/pm-status` 可显示更精确的位置；agent 切换子阶段时也要写 meta.yaml
- **工作量**：~30 min（改 SOP 定义 + skill 校验 + agent 提示）

#### Fix-4：AC ↔ commit 追溯

- **改动**：dev agent（frontend-dev / backend-dev）的提示加一条强约束："commit message 第一行必须含 `[AC-N,...]` 引用"
- **可选**：commit-msg hook 校验
- **工作量**：~20 min（改 2 个 agent 提示）

#### Fix-5：phase 5 closer 加 AC 覆盖矩阵门禁

- **改动**：`.codebuddy/sop/deep-vibe.md:215-218` closer 完成标准加一行 `[ ] AC 全覆盖矩阵已生成（spec/AC-coverage.md）且无未覆盖项`
- **工作量**：~15 min

### P2 长期（1 天以上 / 涉及范式）

#### Fix-6：SOP 自进化协议

- **改动**：仿 `30-skill-self-evolution.mdc` 写 `35-sop-self-evolution.mdc`，明确"5 步走（触发 → 诊断 → 拟改 → 用户确认 → 应用 + 变更历史）"
- **工作量**：~1 h

#### Fix-7：跨需求知识库前置加载

- **改动**：在 `product-manager` 与 `tech-leader` agent 启动检查表加硬约束："启动前必须列出已读的 `context/project/<name>/` 文件"
- **可选**：脚本生成"启动报告"作为 process.txt 第一行
- **工作量**：~1 h

#### Fix-8：dogfood agile-vibe

- **改动**：在本仓选一个真实小需求（候选：上述 Fix-1 ~ Fix-2 本身打包成一个需求）走 agile-vibe 跑通
- **价值**：把"零样本"变成"≥1 样本"，验证 4 阶段 SOP 是否真能闭环
- **工作量**：~半天（含产物归档）

---

## 不属于 SOP 问题但相关的发现

1. **`.vibe/` 目录在本仓不存在**：deep-vibe `:175` 提到 `.vibe/cache/<req-id>-*.txt` 存测试日志，但本仓没有 `.vibe/` 目录，也没有 init 痕迹。需要确认这个目录是 init 时按需创建，还是被 svn:ignore / .gitignore 隐藏。
2. **demo 的 `phase_overrides`** 用得很规范（`meta.yaml:20-24`），值得作为正面样本写进 SOP_GUIDE。
3. **demo 在 phase 3.design 内部触发了 `phase 3→2` 回退**（`process.txt:14-15`），且保留了 `架构方案.md` 作为 baseline 不删——这是"回退不丢产物"的好实践，应沉淀进 deep-vibe 文档。

---

## 附录：本次体检方法

- 应然：`.codebuddy/sop/agile-vibe.md`（203 行）+ `.codebuddy/sop/deep-vibe.md`（258 行）+ `.codebuddy/sop/INDEX.md`（69 行）
- 实然：
  - 本仓 `requirements/INDEX.yaml`（4 行，empty）
  - demo `requirements/req-quickchat-init/meta.yaml`（29 行）
  - demo `requirements/req-quickchat-init/process.txt`（40 行，覆盖 5/3 11:44 → 5/4 10:12）
  - quick-chat 仓 `svn log`（3 个 commit）
- 比对方式：人工读取 + 引用回源
- 不在范围：未读 demo 的 `spec/` `design/` `tasks/` 具体内容（只读到目录列表）；未跑测试

---

*报告生成于 2026-05-04 10:17 +08，作者：Cursor 主会话（claude-opus-4.7）*
*前置：`.codebuddy/docs/PHASE5-FINDINGS.md`（CodeBuddy 三端验证）*
*下一步建议：见上方"修复建议"章节，按 P0 → P1 → P2 顺序消化*

---

## 附录 B：P1 自检追加（2026-05-04 10:55）

P0 完成后启动 P1 提案，对自己的提案做对抗性自检，发现：

### Fix-3（子阶段编号）影响面被低估，**暂缓**

- 原提案只列了 4 个文件改动（SOP frontmatter + skill 校验 + checklist）
- 自检发现至少 3 处现有工具会被误伤：
  - `.codebuddy/skills/core/session-restorer/SKILL.md:78` "找到 phases 列表中 phase == meta.yaml.phase 的项" —— 只查 phases，不查 subphases
  - `.codebuddy/skills/core/doctor/SKILL.md:63-64` phase 字符串等价比对
  - `agents/pm-orchestrator.md:125` 直接打印 `<phase>`
- 真因：**目前没有任何工具实际在用 subphases**——这是"先建机制再说"的过度设计
- **重启触发条件**：doctor / session-restorer / pm-status 任一开始有"读子阶段"的真需求时，再同步开 Fix-3，并把 3 处现有工具一起改
- 替代方案：当前仅靠 `process.txt` 的自然语言记录子阶段已能用（demo 实证 `process.txt:20/23` 写"phase 3.design SubAgents 细化"，doctor 可读取）

### Fix-4（commit↔AC）发现 2 个真 bug，已修正

- 原提案的"自检命令"用了 `svn log -r HEAD -q`，**读的是上一个 commit 不是即将写的 message**——时机错位
- 原提案的正则 `^(feat|fix|chore)\([^)]+\):\s*\S+-\d+\s+.+\s+\[AC-...\]$` 锚定 `^...$` 过严，message 末尾任何标点都会失败
- 修正：改成 commit **之前** shell 校验变量；正则缩窄到只验 `[AC-...]` 段，task-N 与 scope 留给 dev 自由排版

### Fix-5（AC 覆盖矩阵）流程闭环不完整，已补

- 原提案没说 closer 检测到 unknown/missing 时退回到哪个 agent
- 原提案 partial 项无 reviewer 签字也能通过
- 原提案没覆盖 agile-vibe（虽然 agile-vibe 也有 AC）
- 修正：明确 4 种 AC 状态对应的退回路径；partial 必须由 code-reviewer 在评审里显式签字；agile-vibe 走简化版（嵌入 spec/最终需求.md，不另起文件）

按修正版，P1 净改动从 5 文件 / ~80 行 缩到 6 文件 / ~50 行（追加本附录算 1 文件）。

---

## 附录 C：dogfood agile-vibe 复盘 (2026-05-04 12:10)

> 本附录记录 P2 Fix-8 的执行过程：用 agile-vibe 走"回溯登记"需求 `req-sop-checkup-2026-05-04`，把本体检报告 + 5 个修复 commit 反向纳管，验证 SOP 闭环。
>
> 完整产物见 `requirements/req-sop-checkup-2026-05-04/`（spec/ design/ notes.md process.txt meta.yaml）。

### C.1 dogfood 范围与方法

- **需求形式**：回溯登记（5 个 commit `7fa1bca..d6a23c9` 已存在，不再写新代码）
- **SOP**：agile-vibe（4 阶段 init → requirement → iteration → closing）
- **执行者**：主会话 + 5 个 subagent（pm-orchestrator / product-manager / code-reviewer / closer / knowledge-maintainer）
- **dogfood 价值**：把 agile-vibe 从"零样本"变为"≥1 真实样本"（对应维度 1 短板）

### C.2 dogfood 过程中发现的 SOP / 工具缺陷

| # | 发现 | 来源 | 严重性 | 处置 |
|---|---|---|---|---|
| 1 | `.codebuddy/scripts/new-requirement.sh` 只更 `INDEX.yaml` 不更 `INDEX.md`，违反 `managing-requirement` skill 步骤 6 | 阶段 1（symptom-cured-by-closer，closer 步骤 6 恰好对齐 INDEX.md，所以本次未阻断） | P2 | 已沉淀 `context/project/AIVibeCodingProj/scripts-known-issues.md`；建议后续小需求修脚本 |
| 2 | `product-manager` agent 写 `process.txt` 末尾未加换行符，下次追加会粘连 | 阶段 2（PM 写完后下一行追加日志被粘连） | P2（已闭合） | 已在过程中手工修复；属 PM agent 的输出习惯问题，建议在 PM agent prompt 加一条"writes to .txt files MUST end with newline" |
| 3 | agile-vibe SOP 没说"待确认项需先关闭才能进阶段 3"（仅 `deep-vibe.md:91` 显式说），SOP 规则不一致 | 阶段 2（PM 留下"是否纳入 7612ed7"待确认项，主会话不得不拍板） | P2 | 已沉淀 `context/project/AIVibeCodingProj/sop-known-issues.md`；建议后续小需求按 `35-sop-self-evolution.mdc` 5 步补 `agile-vibe.md:99-103` |
| 4 | 5 个回溯 commit 都没带 `[AC-N]` 标签（Fix-4 自检约束在 commit 时未生效），需要靠 `notes.md` 反向表补全 | 阶段 3 | P2（合理时序漏洞） | 已沉淀；建议后续 SOP 加"回溯需求豁免规则"或正式化"反向表"模式 |
| 5 | agile-vibe 阶段 3 在"零迭代回溯需求"场景下没有具体执行指引（SOP 假设阶段 3 一定有真代码改动） | 阶段 3 | P2 | 已沉淀 `context/project/AIVibeCodingProj/sop-known-issues.md`；建议后续小需求加"零迭代场景"分支段落 |
| 6 | `context/project/AIVibeCodingProj/INDEX.md` 不存在（按 Fix-7 协议 fallback "无项目级背景"），且模板仓自身的特殊性（本仓即模板）无任何文档记载 | 阶段 2 启动检查 | P1（已闭合） | 已由 knowledge-maintainer 建立 `context/project/AIVibeCodingProj/INDEX.md`，写明"本仓即模板，不要跑 init.sh"等关键事实 |

### C.3 P1 收尾前修复（35 协议首次完整闭环）

阶段 4 code-reviewer 发现 3 项 P1，按 `35-sop-self-evolution.mdc` 5 步走完一遍：

- **触发判定** → ✅ 命中"SOP 与实际行为不符"
- **诊断** → 写到 `design/代码评审.md` 与本附录上方
- **拟定修改** → 含 diff 与影响面
- **输出提案 + 等用户回复** → 用户回 `verdict=approve_go`（路径 A）
- **应用 + 记录变更历史** → SOP 文件升 0.1.0 → 0.1.1 + 追加变更历史段；closer.md 改 phase 示例与按 sop 分流前置；三端 sync verify 通过

修复细目：

- `.codebuddy/sop/agile-vibe.md` 0.1.0 → 0.1.1（追加变更历史段记录 7fa1bca + 6d9b294 两次创世期改动）
- `.codebuddy/sop/deep-vibe.md` 0.1.0 → 0.1.1（同上）
- `.claude/agents/closer.md:179` `phase: closing` → `phase: 4.closing`（含注释说明 deep-vibe 用 5.finalizing）
- `.claude/agents/closer.md:46-54` 步骤 1 前置加"按 meta.yaml.sop 区分前置数据来源"分流块
- `bash .codebuddy/scripts/sync-codebuddy.sh` 完成 .codebuddy 三端镜像同步

### C.4 Fix-4 commit↔AC 约束的有效性证明（间接）

- **本次 5 个 commit 全部无 `[AC-N]`**（因约束在它们之后才合入，时序合理）
- 反向证据：本次结尾的"总 commit"（需求骨架 + 各阶段产物 + P1 修复 + 知识库新建）按新约束**必须带 `[AC-N]` 或 `[AC-none]`**
- 如本次结尾 commit 自检失败，说明 Fix-4 的实施漏掉了某些场景

### C.5 维度 1 / 维度 4 评分更新

- **维度 1（轻量性）**：B+ → **A-**（agile-vibe 已有 1 个真实样本，评分支撑充分）
- **维度 4（agent 协作清晰度）**：A → **A**（5 agent 串联无冲突，但 closer 步骤 1 表的 sop 分流缺陷 P1-C 暴露后已修，整体仍稳）
- **新维度 6（dogfood 后才暴露的）**：项目知识库 INDEX 缺失 = D → 已建首版 INDEX.md = **B**（首版仅 1 项目，覆盖度待积累）

### C.6 后续 backlog（建议主会话择期开新需求）

按 `35-sop-self-evolution.mdc` 5 步协议处理：

1. 修 `.codebuddy/scripts/new-requirement.sh` 让 init 时同步追加 INDEX.md 条目
2. 给 `agile-vibe.md` 阶段 2 加"待确认项需先关闭才能进阶段 3"
3. 给 `agile-vibe.md` 阶段 3 加"零迭代回溯需求"场景指引
4. 正式化"回溯需求 commit↔AC 反向表"模式（在 SOP 或新规则中）

详细记录在 `requirements/req-sop-checkup-2026-05-04/notes.md` "P2 列表" 段。

### C.7 Fix-8 闭合标记

✅ **Fix-8（dogfood agile-vibe）已通过本附录与 `req-sop-checkup-2026-05-04` 完成交付**。SOP 体检 → 修复方案 → dogfood 验证的完整价值闭环已建立。
