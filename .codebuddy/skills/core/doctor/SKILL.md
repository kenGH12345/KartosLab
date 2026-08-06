---
name: doctor
description: 用于在用户触发 /doctor 命令或定期保健时，对仓库做健康检查——资产完整性 / 状态一致性 / 链接有效性 / 占位符遗留。**只诊断不修复**。被 /doctor 命令调用。
tools: Read, Glob, Grep, Bash
---

# doctor

> 工程时间长了一定会漂——INDEX 漏改、链接断、状态文件不一致。
> 这个 Skill 把"四类检查"标准化，给一份可读的健康报告。

## 何时使用

- ✅ `/doctor` 命令触发
- ✅ 用户主动请求"体检一下"
- ✅ 重大重构后
- ✅ 长期未触碰的项目（≥ 1 个月）启动前
- ❌ 想自动修复：本 Skill 只诊断，修复由用户根据报告决定

## 输入

| 输入 | 类型 | 必需 | 说明 |
|---|---|:-:|---|
| scope | enum | 默认 `all` | `assets` / `state` / `links` / `placeholders` / `all` |
| target_req_id | string | 可选 | 仅检查某需求（默认全部需求） |

## 步骤

### 1. 资产完整性（scope ∋ assets）

按"必需资产清单"检查：

| 资产 | 通过条件 |
|---|---|
| `.codebuddy/rules/*.mdc` | ≥ 8 个文件 |
| `.claude/agents/*.md` | ≥ 14 个文件 |
| `.claude/commands/*.md` | ≥ 16 个文件 |
| `.cursor/commands/*.md` | 数量 = `.claude/commands/` |
| `.codebuddy/rules/*.mdc` | ≥ 8 个（镜像自 .codebuddy/rules/） |
| `.codebuddy/agents/*.md` | ≥ 14 个（镜像自 .claude/agents/） |
| `.codebuddy/commands/*.md` | 数量 = `.claude/commands/`（三端对称） |
| `.codebuddy/settings.json` | 存在（镜像自 .claude/settings.json） |
| `CODEBUDDY.md` | 存在 |
| `.codebuddy/skills/_meta/{SKILL_TEMPLATE,skill-authoring-guide,self-evolution-protocol}.md` | 三个都存在 |
| `.codebuddy/skills/INDEX.md` | 存在 |
| `.codebuddy/skills/core/self-improving-agent/SKILL.md` | 存在（WA 集成 Skill） |
| `.workflow/INDEX.md` | 存在（工作流引擎入口） |
| `.workflow/fingerprints/INDEX.md` | 存在 |
| `.workflow/index/keyword-index.md` | 存在 |
| `.workflow/scripts/fingerprint-gen.sh` | 存在 |
| `.workflow/scripts/fingerprint-gen.ps1` | 存在（Windows 镜像） |
| `.workflow/scripts/fingerprint-diff.sh` | 存在 |
| `.workflow/scripts/fingerprint-diff.ps1` | 存在（Windows 镜像） |
| `.workflow/scripts/index-rebuild.sh` | 存在 |
| `.workflow/scripts/index-rebuild.ps1` | 存在（Windows 镜像） |
| `context/shared/experiences/INDEX.md` | 存在（结构化经验库） |
| `context/shared/experiences/*/` | 至少包含 `coding/` / `workflow/` / `debugging/` 子目录 |
| `.codebuddy/sop/INDEX.md` | 存在 |
| `.codebuddy/sop/{agile-vibe,deep-vibe,_template_sop}.md` | 三个都存在 |
| `requirements/INDEX.md` | 存在 |
| `requirements/INDEX.yaml` | 存在（如不存在，INDEX.md 必须有） |
| `AGENTS.md` / `CLAUDE.md` / `CODEBUDDY.md` | 存在 |
| `svn:ignore` 属性配置 | 已设置（可选检查） |

#### Phase 1 新增资产（失败提取、经验注入、质量门禁）

| 资产 | 通过条件 |
|---|---|
| `.workflow/scripts/auto-extract-failures.sh` | 存在（Linux/Mac 失败提取脚本） |
| `.workflow/scripts/auto-extract-failures.ps1` | 存在（Windows 镜像） |
| `.workflow/scripts/experience-injector.sh` | 存在（Session 经验注入脚本） |
| `.workflow/scripts/experience-injector.ps1` | 存在（Windows 镜像） |
| `.workflow/quality-gate-state.json` | 存在（质量门禁状态记录） |
| `.workflow/instincts.json` | 存在（高频经验预加载清单） |
| `context/shared/experiences/instincts/` | 目录存在 |
| `context/shared/experiences/auto-extracted/` | 目录存在 |
| `.codebuddy/commands/improve.md` | 存在，`/improve` 命令已注册 |

每项失败 → 加入"资产缺失"清单。 | `AGENTS.md` / `CLAUDE.md` / `CODEBUDDY.md` | 存在 |
| `svn:ignore` 属性配置 | 已设置（可选检查） |

每项失败 → 加入"资产缺失"清单。

#### 1.1 三端镜像内容一致性

按 `.codebuddy/scripts/sync-codebuddy.sh` 的镜像约定（`.claude` / `.cursor` 是源，`.codebuddy/` 是镜像）逐文件校验内容相同：

```bash
# 对每对镜像跑 diff，记录所有不一致
diff -q .codebuddy/rules/<f>.mdc       .codebuddy/rules/<f>.mdc
diff -q .claude/agents/<f>.md       .codebuddy/agents/<f>.md
diff -q .claude/commands/<f>.md     .codebuddy/commands/<f>.md
diff -q .claude/settings.json       .codebuddy/settings.json
```

任一对 diff 非空 → 加入"镜像不一致"清单，附建议：`跑 ./.codebuddy/scripts/sync-codebuddy.sh`。

> 为什么单独检查：数量正确 ≠ 内容一致。历史教训见 P0 commit `7fa1bca` —— 改了 `.codebuddy/rules/45-state-sync-protocol.mdc` 但忘跑 sync-codebuddy，doctor 当时数量校验通过但内容落后 27 行。

### 2. 状态一致性（scope ∋ state）

对每个需求：

| 检查 | 通过条件 |
|---|---|
| `meta.yaml` 存在 | ✓ |
| `process.txt` 存在 | ✓ |
| `meta.yaml.phase` 与 `process.txt` 最近 phase 事件一致 | ✓ |
| `INDEX.yaml` 中该需求的 `status` / `phase` 与 `meta.yaml` 一致 | ✓ |
| `INDEX.md` 表格中该需求行的 status 与 `meta.yaml` 一致 | ✓ |
| 如 `status=done`：`spec/最终需求.md` 存在 | ✓ |
| 如 `phase` ≥ 2.design（deep-vibe）：`design/技术方案.md` 存在 | ✓ |
| 如 `phase` ≥ 5.finalizing（deep-vibe）：`design/{代码评审,测试报告}.md` 存在 | ✓ |
| 如 `status=done` 且 done 时间 > 5 个需求前：`.vibe/cache/self-improving-scan-<最近日期>.md` 存在 | ⚠️ 建议（非阻塞） |
| `.workflow/fingerprints/snapshots/` 下快照文件 | 存在且非空（至少一个需求有指纹快照） |
| 最新快照与代码现状的一致性 | ⚠️ 建议（非阻塞）：运行 `fingerprint-gen.sh` 生成新快照，与最新快照 `fingerprint-diff.sh` 比对，差异过大（≥5 个 breaking change）则告警 |

### 3. 链接有效性（scope ∋ links）

对所有 `.md` 文件：

```
Grep 'markdown link 模式' = '\[([^\]]+)\]\(([^)]+)\)'
对每个链接：
  - 跳过 http(s):// 链接（不远程校验）
  - 跳过锚点链接 #...（同文档锚点不校验）
  - 校验本地相对路径目标存在
```

加入"断链"清单：`<source_file>:<line>` → `<broken_target>`。

特别检查：

- .codebuddy/skills/ 下 SKILL.md 引用的 `references/*.md` / `.codebuddy/scripts/*.{ps1,sh}` 都存在
- context/ 下 INDEX.md 列出的子文档都存在
- .codebuddy/docs/ 下文档间链接

### 4. 占位符遗留（scope ∋ placeholders）

```
Grep -r 'd:\WePop_trunk' --glob '*.md' --glob '*.yaml' --glob '*.json'
Grep -r 'wepop-trunk' --glob '*.md' --glob '*.yaml' --glob '*.json'
Grep -r '{{REQ_ID}}' --glob '*.md' --glob '*.yaml'
Grep -r '{{TITLE}}' --glob '*.md' --glob '*.yaml'
Grep -r '2026-05-29 13:40' --glob '*.md' --glob '*.yaml'
```

排除以下"应保留占位符"的位置：

- `**/_template/**`
- `.codebuddy/skills/_meta/SKILL_TEMPLATE.md`
- `.codebuddy/sop/_template_sop.md`
- `requirements/_template/**`（如有）

剩余 hit 加入"占位符遗留"清单——通常 AGENTS.md / CLAUDE.md / 已 done 的需求里仍有占位符意味着 init 流程没跑完。

### 5. 输出报告

```md
## 健康检查报告（YYYY-MM-DD HH:MM）

### ✓ 资产完整性
- Rules: X / 8
- Agents: Y / 14
- Commands: Z / 16
- 全部必需资产: 存在 / 缺 N 项
- 三端镜像一致性: ✓ / 不一致 M 项（建议跑 `./.codebuddy/scripts/sync-codebuddy.sh`）

### ⚠️ 状态不一致（N 项）
- req-foo: meta.yaml 显示 phase=2.design，但 process.txt 末尾事件为 vibe_loop（属于阶段 3）
  - 建议: 跑 /pm-continue 让主会话重新对齐

### ❌ 链接断裂（M 项）
- .codebuddy/docs/ARCHITECTURE.md:42 → .codebuddy/docs/legacy.md (不存在)

### ⚠️ 占位符遗留（K 项）
- AGENTS.md:15 — `wepop-trunk` 未替换
- CLAUDE.md:8 — `d:\WePop_trunk` 未替换

### 建议修复优先级
1. ❌ 链接断裂 → 立即修（影响导航）
2. ⚠️ 状态不一致 → 跑 /pm-continue 或手工核对
3. ⚠️ 占位符遗留 → 用户填值（可能 init 未跑完）
4. ⚠️ 资产缺失 → 看是否项目刻意删除
5. ℹ️ 经验库状态 → 若 `experiences/` 为空或长期未更新，建议运行 `/improve` 扫描
6. ⚠️ 经验质量门禁 → `auto-extracted/` 中有未审核条目需人工复核（详见下方）
7. ⚠️ 结构漂移 → 指纹快照与代码现状差异过大（≥5 个 breaking change），建议在下次迭代前运行 `fingerprint-gen.sh` 重新生成基线

### ⚠️ 经验质量门禁（experiences/）
| 检查项 | 结果 | 详情 |
|---|---|---|
| frontmatter 完整 | ✓ / ✗ | N 个文件缺 type/source_req/extracted_at |
| 内容结构完整 | ✓ / ✗ | N 个文件缺「场景/问题分析/解决方案」段 |
| 未审核条目 | ✓ / ⚠️ | N 个 auto-extracted 待审核（status=draft） |
| 重复条目 | ✓ / ⚠️ | N 组标题或内容重复 |
| source_req 上限 | ✓ / ✗ | N 个需求超 5 条经验上限 |
| 过期条目 | ✓ / ⚠️ | N 条超过 30 天未审核 |

> 未审核条目处理：在 `context/shared/experiences/auto-extracted/` 查看，补充「问题分析」「解决方案」段后改 `status: final`。 | 建议修复优先级
1. ❌ 链接断裂 → 立即修（影响导航）
2. ⚠️ 状态不一致 → 跑 /pm-continue 或手工核对
3. ⚠️ 占位符遗留 → 用户填值（可能 init 未跑完）
4. ⚠️ 资产缺失 → 看是否项目刻意删除
5. ℹ️ 经验库状态 → 若 `experiences/` 为空或长期未更新，建议运行 `/improve` 扫描
6. ⚠️ 结构漂移 → 指纹快照与代码现状差异过大，建议重新生成基线
```

### 6. 不自动修复

> [!IMPORTANT]
> **本 Skill 不修复任何问题**——只输出报告。修复由用户根据报告决定优先级与方式。

如用户希望"自动修复某类问题"，应：
- 占位符 → 跑 init 脚本（`.codebuddy/scripts/init.ps1`，Phase 4 提供）
- 状态不一致 → 跑 `/pm-continue` 让 PM 重新对齐
- 断链 → 用户人工修
- 资产缺失 → 重新跑 init / 从 SVN 历史恢复

## 输出

```md
## doctor 执行结果
- 状态: completed
- 报告: <如上格式>
- 总结:
  - 资产: ✓ / 缺 N
  - 状态: ✓ / 不一致 M
  - 链接: ✓ / 断裂 K
  - 占位符: ✓ / 遗留 J
- 健康度: 健康 / 亚健康 / 不健康
```

健康度判定：
- 全部 ✓ → 健康
- 仅占位符遗留 → 亚健康
- 镜像不一致 / 有断链 / 状态不一致 → 不健康（建议立即修）

## 边界与陷阱

> [!IMPORTANT]
> **不修复**。即使发现明显的"加一行就好"的问题，也只报告不动手。

- ❌ 不要因为"看起来排序乱"标记为问题（人工排序是合法的）
- ❌ 不要远程校验 http(s) 链接（不可靠 + 太慢）
- ❌ 不要 grep 二进制文件
- ❌ 不要把 `.vibe/cache/` 与 `node_modules/` 等纳入扫描
- ✅ 报告必须可定位（`<file>:<line>`）
- ✅ 区分"严重不健康（断链）"与"亚健康（占位符）"

## 关联 Skill

- `managing-requirement` / `docs-index-updater`：用户根据报告手动调用这些 Skill 来修复
- 与规则 `45-state-sync-protocol.mdc` 配合：状态不一致是该规则被违反的信号

## 变更历史

> YYYY-MM-DD by 主会话（用户确认「按完整生产方案执行」Phase 1）：
> 全面增强 doctor 为「经验质量门禁」执行者。
> - 资产清单新增 Phase 1 全部基础设施（`auto-extract-failures.sh/ps1`、`experience-injector.sh/ps1`、`quality-gate-state.json`、`instincts.json`、目录结构）
> - 输出报告新增「经验质量门禁」段：frontmatter 完整性 / 内容结构 / 未审核 / 重复 / 上限 / 过期 6 维检查
> - 建议优先级新增第 6 项「经验质量门禁」
> - 触发原因：Phase 1 三大能力从蓝图到投入生产，需要 doctor 作为「质量门禁」的独立检查入口
> - 与 `knowledge-maintainer` 步骤 6.5 的质量门禁检查形成互补（KM 在 closing 时检查，doctor 在 /doctor 时全量检查）

| 日期 | 版本 | 变更 | 触发原因 | 操作者 |
|---|---|---|---|---|
| 2026-05-28 | 0.1.2 | 集成 `.workflow/` 与 `experiences/` 资产 | 生产就绪集成要求 | 主会话 |
| - | | - 资产清单新增：`.ps1` 脚本镜像（`fingerprint-gen.ps1` / `fingerprint-diff.ps1` / `index-rebuild.ps1`） | | |
| - | | - 资产清单新增：`experiences/` 子目录完整性检查 | | |
| - | | - 状态检查新增：done 需求超 5 个前的 self-improving-agent 扫描建议 | | |
| - | | - 建议优先级新增：经验库状态检查（ℹ️ 级别） | | |
| 2026-05-04 | 0.1.1 | 步骤 1 加子节 1.1 三端镜像内容一致性校验（diff -q 而非数量比对）；报告输出与健康度判定同步 | 实证：P0 commit `7fa1bca` 改 `.codebuddy/rules/45-state-sync-protocol.mdc` 未跑 sync-codebuddy，doctor 当时数量校验通过但内容落后 27 行；详见 `.codebuddy/docs/SOP-CHECKUP-2026-05-04.md` | 主会话 (claude-opus-4.7) |
| - | 0.1.0 | 初始创建 | Phase 3 | template |
