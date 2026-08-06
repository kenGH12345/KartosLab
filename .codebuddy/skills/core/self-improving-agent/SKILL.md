---
name: self-improving-agent
description: 用于在需求完成后或定期维护时，主动检测协作流程中的性能瓶颈和重复模式，触发自进化协议。补足 WV 自进化协议族的"主动触发"缺口。被 /improve 命令和 knowledge-maintainer agent 调用。
tools: Read, Write, Edit, Glob, Grep, Bash
---

# self-improving-agent

> WV 的自进化协议族（30/35/40）提供了被动触发机制（报错/用户反馈时才进化）。
> 本 Skill 补足**主动触发**能力：扫描需求历史、检测重复模式、识别效率瓶颈，自动触发 Skill/SOP/Agent 的演进提案。
> 灵感来自 WA 的 self-improving-agent，但适配了 WV 的 Markdown + Shell 架构。

## 何时使用

- ✅ 需求 closing 阶段，`knowledge-maintainer` 完成后追加调用
- ✅ 用户执行 `/improve` 命令
- ✅ 定期维护时（建议每 5 个需求或每月一次）
- ✅ 用户反馈"同样的问题反复出现"
- ❌ 单个需求的普通执行（不是本 Skill 的场景）
- ❌ 想要跳过自进化协议直接修改 Skill/SOP/Agent（绝不许可）

## 输入

| 输入 | 类型 | 必需 | 说明 |
|---|---|:-:|---|
| scan_scope | enum | ✓ | `recent`（最近 5 个需求）/ `all` / `target:<req-id>` |
| target_type | enum | 可选 | `skill` / `sop` / `agent` / `all`（默认 `all`） |
| dry_run | bool | ✓ | true = 只输出诊断不触发演进提案 |

## 步骤

### 1. 加载历史数据

```
1. Read requirements/INDEX.md（获取需求列表与状态；如果存在 INDEX.yaml 优先用 yaml）
2. 按 scan_scope 过滤出目标需求集合
3. 对每个目标需求：
   - Read meta.yaml（获取 phase / sop / updated_at）
   - Read process.txt（获取操作历史与时间线）
   - Read notes.md（获取踩坑与变通记录）
4. Read .workflow/fingerprints/INDEX.md（检查结构指纹状态）
5. Read context/shared/experiences/INDEX.md（检查已有经验）
```

### 2. 检测重复模式

#### 2a. 重复踩坑检测

扫描所有 `notes.md` 中的踩坑记录，寻找跨需求重复出现的模式：

```
1. Grep 所有 notes.md 中的关键词：变通/workaround/临时/踩坑/问题/报错
2. 按关键词聚合，出现 ≥ 2 次的标记为"重复踩坑"
3. 对每个重复踩坑：
   - 提取：问题描述、涉及的 Skill/SOP/Agent、出现频率
   - 判断：是否应由 Skill/SOP/Agent 演进来永久解决
```

#### 2b. 效率瓶颈检测

分析 `process.txt` 的时间线，识别效率问题：

| 信号 | 检测方法 | 暗示 |
|---|---|---|
| 单阶段耗时过长 | 同一 phase 跨度 > 3 天 | SOP 步骤可能冗余 / Agent 能力不足 |
| 重复手动操作 | process.txt 中出现 3 次以上相同操作 | 应封装为 Skill |
| 频繁阶段回退 | phase_overrides 条目多 | 需求澄清不充分 / SOP 门槛过低 |
| Agent 失败重试 | 同一 Agent 连续 2 次失败 | Agent prompt 有缺陷 |

#### 2c. 经验盲区检测

对比 `context/shared/experiences/` 与实际踩坑记录，识别未被沉淀的经验：

```
1. 对每个 notes.md 中的踩坑，检查 context/shared/experiences/ 是否有对应条目
2. 无对应条目 → 标记为"经验盲区"
3. 已有条目但内容过期 → 标记为"经验需更新"
```

#### 新增 2d. 自动失败提取（Phase 1 集成）

扫描完成后，自动触发 `auto-extract-failures.sh` 提取结构化失败模式：

```bash
# 对 scan_scope 内的每个需求执行失败提取
for req_id in $target_req_ids; do
  if [ -f "requirements/$req_id/process.txt" ]; then
    bash .workflow/scripts/auto-extract-failures.sh "$req_id"
  fi
done
```

提取结果写入 `context/shared/experiences/auto-extracted/`，自动标记为 `status: draft`，等待人工审核。

> 与 `knowledge-maintainer` 步骤 6 的区别：
> - `knowledge-maintainer` 只处理**本需求**的立即沉淀
> - `self-improving-agent` 处理**批量需求**的跨需求模式检测 + 自动提取

### 3. 生成改进提案

对每个检测到的问题，按 target_type 分类生成提案：

#### Skill 演进提案（走 `30-skill-self-evolution` 协议）

```md
## Skill 改进提案 #N

**触发来源**: self-improving-agent 扫描
**检测模式**: [重复踩坑 / 效率瓶颈 / 经验盲区]
**涉及 Skill**: <skill-name>
**证据**:
  - req-aaa/notes.md:XX — <踩坑描述>
  - req-bbb/notes.md:YY — <同类踩坑>
**建议动作**: <具体改进方向>
**是否触发演进协议？(y/n)**
```

#### SOP 演进提案（走 `35-sop-self-evolution` 协议）

```md
## SOP 改进提案 #N

**触发来源**: self-improving-agent 扫描
**检测模式**: [频繁回退 / 阶段耗时过长]
**涉及 SOP**: <sop-name>
**证据**:
  - req-aaa: phase X→Y 耗时 N 天（正常 < M 天）
  - req-bbb: phase_overrides N 条
**建议动作**: <具体改进方向>
**是否触发演进协议？(y/n)**
```

#### Agent 演进提案（走 `40-agent-self-evolution` 协议）

```md
## Agent 改进提案 #N

**触发来源**: self-improving-agent 扫描
**检测模式**: [Agent 失败重试 / commit 范围遗漏]
**涉及 Agent**: <agent-name>
**证据**:
  - req-aaa: <agent> 连续失败 N 次
  - req-bbb: <agent> 漏 commit 目标文件
**建议动作**: <具体改进方向>
**是否触发演进协议？(y/n)**
```

### 4. 输出改进报告

写入 `.vibe/cache/self-improving-scan-<date>.md`：

```md
# 自改进扫描报告（YYYY-MM-DD）

## 扫描范围
- 需求数: N
- 扫描模式: [重复踩坑 / 效率瓶颈 / 经验盲区]

## 检测结果摘要

| 类型 | 问题数 | 高优先 | 中优先 | 低优先 |
|---|---|---|---|---|
| Skill 改进 | X | Y | Z | W |
| SOP 改进 | X | Y | Z | W |
| Agent 改进 | X | Y | Z | W |
| 经验沉淀 | X | Y | Z | W |

## 提案清单

### 提案 #1: <标题>
- 类型: Skill / SOP / Agent
- 优先级: High / Medium / Low
- 证据: <引用>
- 建议: <具体动作>

*(后续提案...)*

## 未触发演进的事项
- <事项> — 理由: <为何不触发>
```

### 5. 等待用户确认后触发演进

> [!IMPORTANT]
> **绝不**直接修改任何 Skill / SOP / Agent 文件。本 Skill 只生成提案，用户确认后才走对应自进化协议。

对每个提案：
1. 展示给用户
2. 用户回复 `y` → 触发对应的自进化协议（`/skill-evolve` / 手动走 SOP 协议 / 手动走 Agent 协议）
3. 用户回复 `n` → 记录到 `notes.md` 备查
4. 用户回复"批量处理" → 按"高→中→低"优先级依次走

## 输出

```md
## self-improving-agent 执行结果
- 状态: completed / partial
- 扫描需求数: N
- 检测到问题: M 项
  - Skill 改进: X
  - SOP 改进: Y
  - Agent 改进: Z
  - 经验沉淀: W
- 已触发演进: K 项
- 报告: .vibe/cache/self-improving-scan-<date>.md
- 后续建议: 查看报告并逐一确认提案
```

## 边界与陷阱

> [!WARNING]
> **绝不绕过自进化协议**。即使用户说"你看着改"，也必须走"提案→确认→应用"流程。

> [!IMPORTANT]
> 扫描结果只是"建议"，不是"必须执行"。用户有权选择不改进。

- ❌ 不要直接 Edit 任何 Skill / SOP / Agent 文件
- ❌ 不要把单次踩坑标记为"需要演进"（需 ≥ 2 次重复证据，遵循 3-Time Rule）
- ❌ 不要在 dry_run=true 时触发任何演进
- ❌ 不要批量自动确认所有提案——每条必须独立确认
- ✅ 优先级排序：高（重复踩坑 ≥ 3 次）> 中（效率瓶颈）> 低（经验盲区）
- ✅ 每条提案必须有 ≥ 2 条实证引用
- ✅ 与 `managing-knowledge` 协同：经验盲区可同时触发 `managing-knowledge` 的回写

## 与 WA self-improving-agent 的关键差异

| 维度 | WA | WV（本 Skill） |
|---|---|---|
| 运行时 | Node.js 进程 | Shell + AI 读取文件 |
| 检测机制 | 自动监控 + 阈值触发 | 扫描历史文件 + 模式匹配 |
| 存储格式 | experiences.json | Markdown（context/shared/experiences/） |
| 演进执行 | 自动修改 prompt | 提案→用户确认→走自进化协议 |
| 生态集成 | 独立系统 | 与 30/35/40 协议族深度集成 |

## 引用资料

- [30-skill-self-evolution.mdc](../../.codebuddy/rules/30-skill-self-evolution.mdc) — Skill 自进化规则
- [35-sop-self-evolution.mdc](../../.codebuddy/rules/35-sop-self-evolution.mdc) — SOP 自进化规则
- [40-agent-self-evolution.mdc](../../.codebuddy/rules/40-agent-self-evolution.mdc) — Agent 自进化规则
- [self-evolution-protocol.md](../_meta/self-evolution-protocol.md) — 自进化详细操作手册

## 关联 Skill

- `managing-knowledge` — 经验沉淀的执行者。**扫描出的「经验盲区」candidate 应移交 `managing-knowledge` 写入 `context/shared/experiences/<category>/`**。走法：将 candidate 的 `cross_project: true` + `type: "shared-experience"`，由 `managing-knowledge` 步骤 5 负责 INDEX 同步与写入。
- `doctor` — 健康检查可发现部分相同问题
- `progress-logger` — 扫描 process.txt 时的辅助工具

## 变更历史

> 2026-05-28 by 主会话（用户确认「按完整生产方案执行」Phase 1）：
> 集成 `auto-extract-failures.sh` 自动失败提取能力（能力 #1）。
> - 步骤 2 新增 2d「自动失败提取」子步骤：扫描完成后批量执行 `auto-extract-failures.sh`
> - 明确与 `knowledge-maintainer` 步骤 6 的职责边界
> - 触发原因：Phase 1 三大能力从蓝图到投入生产

> 2026-05-28 by 主会话（用户确认「按完整生产方案执行」）：
> 关联 Skill 段增加 `managing-knowledge` 的显式衔接说明。
> - 明确「经验盲区」candidate 的移交路径：`cross_project: true` + `type: "shared-experience"` → `managing-knowledge` 步骤 5
> - 与 `managing-knowledge` v0.1.1 的变更加持「经验沉淀」同步联动

| 日期 | 版本 | 变更 | 触发原因 | 操作者 |
|---|---|---|---|---|
| 2026-05-28 | 0.1.1 | 关联 Skill 增加 managing-knowledge 显式衔接路径 | 生产就绪集成 | 主会话 |
| 2026-05-28 | 0.1.0 | 初始创建：从 WA self-improving-agent 适配到 WV Skill 体系 | 用户要求集成 WA 特性 | main-session |
