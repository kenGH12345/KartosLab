# AIVibeCodingProj Roadmap

> 模板自身的开发计划。与 `.codebuddy/docs/`（面向使用者）不同，本文件追踪**模板的演进**。
>
> 下次接续开发时，从这里看「上次到哪」「下一步做什么」。

## 当前版本

**v0.2.2** — SOP 实战优化版。在 v0.2.0 基础上完成 3 个真实需求的全流程验证（连连看 MVP / 排行榜 / 每日签到），据此优化了 SOP 流程设计与工程纪律。

详细架构与设计原则见 [`.codebuddy/docs/ARCHITECTURE.md`](.codebuddy/docs/ARCHITECTURE.md)。

### v0.2.0 相比 v0.1.0-alpha 的重大变更（2026-05-08）

| 变更 | 说明 |
|---|---|
| **删除 pm-orchestrator** | PM 职责移至主会话直接执行，消除"误判 agile vs deep-vibe"问题 |
| **根目录极简化** | `docs/` `scripts/` `skills/` `sop/` `ROADMAP.md` 物理移入 `.codebuddy/`（profiles/ 已在 v0.2.2 删除） |
| **废弃 INDEX.yaml** | 新增 `rebuild-index.sh` 从 meta.yaml 自动生成 INDEX.md，彻底消除双写问题 |
| **init.sh 大幅修复** | 清理模板残留（.legacy/旧知识库/cache）、修复占位符替换（反引号包裹的）、sync 后清理 .legacy、rebuild-index.sh 空数组兼容 |
| **文档引用统一** | 所有用户入口文档统一指向 `.codebuddy/`（不再引导到 `.cursor/` 或 `.claude/`） |
| **PRIMARY_TOOL 更新** | 默认值改为 `codebuddy,claude,cursor` |
| **game-design SOP** | 新增第 3 个内置 SOP，专用游戏策划细化（3 阶段，只产出文档不编码）+ `game-designer` agent |
| **game-design 实战验证** | req-game-concept-01（连连看进化版）5 轮策划讨论，10 条决策，概念图出图，流程跑通 |
| **`/pm-dev` 命令** | 从已完成策划需求快速创建开发需求（自动引用策划案 + 关联 related_requirements） |

### v0.2.1 工程纪律增强（2026-05-09 AM）

| 变更 | 说明 |
|---|---|
| **>500 行拆分规则** | `frontend-dev` / `backend-dev` 新增行为准则：业务代码文件超 500 行必须先拆分（白名单可豁免 + notes.md 留痕） |
| **done 门禁脚本** | 新增 `check-before-done.sh`：标 done 前硬检查 closer 三项产物，exit 1 拦截未收尾就标完成 |
| **状态同步约束升级** | `45-state-sync-protocol.mdc` 追加：标 done 前必跑门禁脚本 |
| **closer 日志格式约定** | closer.md 步骤 4 首行改为"closer 完成收尾"，与门禁脚本正则对齐 |

### v0.2.2 SOP 流程优化（2026-05-09 AM，当前）

| 变更 | 说明 | 参考设计思想 |
|---|---|---|
| **agile-vibe: Mini-Plan 预检** | 阶段 3 首轮必须先输出 3-5 行策略让用户确认再动手 | Cursor Agent plan 模式 |
| **agile-vibe: Mini-Task 列表** | 功能点 > 3 时推荐先列 3-7 个 task 再逐个执行 | Cursor step-by-step |
| **agile-vibe: 轻量 closing** | 小需求（≤3 文件/无架构变更）可跳过 knowledge-maintainer，不要求独立评审文件 | 减少小需求的流程税 |
| **deep-vibe: 快速方案模式** | simple 复杂度可跳过 leader/reviewer，tech-leader 直接出精简方案 | Cursor plan 确认后执行 |
| **deep-vibe: 轻量 testing** | 无测试套时用 code+verify 循环代替独立 test-runner | Cursor 无 test 时用 build 代替 |
| **deep-vibe: 阶段 5 门禁** | 完成标准追加 `check-before-done.sh` 与 agile-vibe 对齐 | 双 SOP 一致性 |
| **agile-vibe: 约束 #5 去歧义** | 明确 Mini-Plan（首轮大策略）vs 每轮小目标的区别 | 消除理解混淆 |

### 实战验证记录（v0.2.x 期间）

| 需求 | SOP | 关键验证点 | 结果 |
|---|---|---|---|
| req-game-concept-01-dev | deep-vibe | 完整 5 阶段 + 80 关 H5 游戏交付 | ✅ 通过 |
| req-score-leaderboard | agile-vibe | 前后端混合 + 排行榜 API | ✅ 通过 |
| req-daily-checkin | agile-vibe | **完整 4 阶段含 closer 收尾 + 门禁脚本验证** | ✅ 通过 |

## 已完成 Phase（v0.1.0-alpha）

| Phase | 完成日期 | 交付 | 大小 |
|---|---|---|---|
| **Phase 0** | 2026-04-25 | 目录骨架 + README + .gitignore + 各层 INDEX 占位 + docs 骨架 | ~25 KB |
| **Phase 1** | 2026-04-25 → **Phase 5 补齐 2026-05-03** | 8 条 `.cursor/rules/*.mdc` + AGENTS.md + CLAUDE.md（**Phase 1 当时只交了 AGENTS/CLAUDE，8 个 mdc 文件被 Phase 5 实际写出来**，详见 .codebuddy/docs/PHASE5-FINDINGS.md F-1.4） | ~52 KB |
| **Phase 2** | 2026-04-29 → **Phase 5 补齐 2026-05-03** | 14 个 `.claude/agents/*.md` + 16 个 commands 双写 + `.claude/settings.json` + `.mcp.json`（**`.cursor/commands/` 与 `.cursor/mcp.json` 也是 Phase 5 通过新增 sync 脚本生成的**） | ~135 KB |
| **Phase 3** | 2026-04-29 | 11 个 core skills + 5 references + 4 `_meta` 元资产 + 3 个 SOP（agile-vibe / deep-vibe / 模板） | ~93 KB |
| **Phase 4** | 2026-04-29 → **Phase 5 增量 2026-05-03** | 6 个脚本（init / new-requirement / doctor，PS+bash 双写）+ requirements/_template/ 填实 + 11 篇完整文档（**Phase 5 又加了 4 个 sync-* 脚本 + 修了 init 的 mapfile 兼容性 + 升级 doctor 的占位符检测**） | ~155 KB |
| **总计 v0.1** | | 22+ 个目录 / 200+ 个文件 | ~460 KB |

### Phase 完成时的关键决策

- **Phase 0**：目录树用「五层架构 + 单一源原则」，每层单独有 INDEX
- **Phase 1**：rules 不互相依赖（独立加载），AGENTS.md/CLAUDE.md 通过 `@import` 复用 .mdc
- **Phase 2**：commands 必须双写（`.cursor/commands/` + `.claude/commands/`），用 PowerShell 一键剥离 frontmatter；agents 用 Claude 原生（subagent），Cursor 通过 commands+rules 模拟
- **Phase 3**：Skill 单一源（`.codebuddy/skills/<group>/<name>/SKILL.md`），自进化协议必须人机确认；2 个 SOP 都明确写「何时切换到另一个」
- **Phase 4**：所有 PS 脚本必须 UTF-8 BOM（解决 PowerShell 5.1 ANSI 解析中文问题）；所有 sh 脚本 LF 行尾；doctor 双平台输出一致（71 链接 0 断 / 108 占位符 / subhealthy / exit=1）

### Phase 1-4 经验沉淀（已在文档体现）

- **架构**: [`.codebuddy/docs/ARCHITECTURE.md`](.codebuddy/docs/ARCHITECTURE.md)
- **设计决策**: [`.codebuddy/docs/ADR/`](.codebuddy/docs/ADR/)（0001-0003）

---

## 待办：Phase 5 — End-to-End 验证 + v1.0 发布

**目标**：把 v0.2 的「实战验证模板」升级为「正式发布版本」，打 v1.0 标签。

### ✅ 已完成的验证（v0.2.0 期间）

- [x] agile-vibe 完整流程验证（testproj / testV5 / testV8 / testV9）
- [x] deep-vibe 完整流程验证（testHuangli / testV6 / testV9）
- [x] 两条 SOP 在同一项目并行（testV6 / testV9）
- [x] init.sh 从零创建项目验证（5+ 次）
- [x] rebuild-index.sh 空/非空需求列表验证
- [x] 主会话当 PM 委派链验证（product-manager → tech-leader → frontend-dev）
- [x] 占位符替换全覆盖验证
- [x] .legacy 文件清理验证

### 剩余待做

### ~~Round 1: demo 项目走 agile-vibe 全 4 阶段~~ ✅ 已完成

通过 testproj / testV5 / testV8 / testV9 多次验证。

### ~~Round 2: demo 项目走 deep-vibe 完整 5 阶段~~ ✅ 已完成

通过 testHuangli（老黄历 5 阶段）/ testV6（连连看）/ testV9（倒计时器）/ testV10（连连看 完整 deep-vibe 3 阶段）验证。

### ~~Round 3: 触发 self-evolution~~ ✅ 已完成

在 testV10 验证：
- 故意改坏 `git-commit-message` skill 的 `tools` 字段
- 主会话按 5 步协议输出提案 → 用户回 y → 修复 + 追加变更历史
- 再次改坏 agent 名 → 提案 → 用户回 n → 文件未修改，诊断记录到 notes.md

### ~~Round 4: doctor 自校验循环~~ ✅ 已完成

在 testV10 制造 4 类问题：
- 资产缺失（删 agent）→ ✅ 检出
- 状态不一致（meta=done 缺产物）→ ✅ 检出
- 链接断裂（commands 不对称）→ ✅ 检出
- 占位符遗留（`wepop-trunk`）→ ✅ 检出
- 精度 100%，误报 0

### Round 5: 整理踩坑 + 发布（~1 小时）

- [ ] 把 Phase 5 全程踩的坑整理成 `.codebuddy/docs/EXAMPLES.md`（带真实 transcript 摘录）
- [ ] 提炼出 ADR-0004 / ADR-0005（如适用）
- [ ] 更新 `.codebuddy/ROADMAP.md`：Phase 5 标记完成
- [ ] 更新各 `.codebuddy/docs/*.md` 末尾的 `*v0.1.0-alpha*` 标记为 `*v1.0.0*`
- [ ] 写 `CHANGELOG.md`（v0.1.0 → v1.0.0 变更）
- [ ] 写 release notes
- [ ] git tag `v1.0.0`

### Phase 5 验收标准

| 维度 | 标准 |
|---|---|
| 全流程 | agile-vibe 与 deep-vibe 各走通 1 次完整需求，中途无需"打补丁" |
| Self-evolution | 触发 1 次真实演进，5 步协议未被绕过 |
| Doctor | 4 类问题的检测精度 ≥ 95% |
| 文档 | EXAMPLES.md 含真实 transcript；CHANGELOG.md 完整 |
| 可重复 | 删 demo 项目重跑一遍，结果一致 |

---

## v1.0 之后想法（未排期）

### 短期（v1.1 / v1.2）

- [x] **`sync-mcp.sh`**：自动同步 `.mcp.json`（已实现）
- [x] **`sync-commands.sh`**：自动同步 commands（已实现，通过 `sync-codebuddy.sh` 统一处理）
- [x] **`rebuild-index.sh`**：INDEX.md 自动从 meta.yaml 生成（v0.2.0 新增）
- [x] **`.codebuddy/docs/EXAMPLES.md`**：真实流程 transcript 摘录（v1.0.0 新增）
- [x] **CRLF 彻底消除**：已 renormalize
- [x] **CI 集成**：`.github/workflows/doctor.yml`（v1.0.0 新增）
- [x] **pm-continue 主动推进**：编码完成后自动推进到收尾阶段（v1.0.0 新增）
- [x] **create-vibe-project 脚手架**：`npx create-vibe-project my-app`（v1.0.0 新增）
- [x] **项目名放宽**：允许大写字母，不再限制纯 kebab-case（v1.0.0 新增）

### 中期（v1.3 / v1.4）

- [ ] **完整的 `cascade-orchestrator` 实现**：当前 cascade-orchestrator agent 已存在但默认禁用；实际跑通一个 DAG 编排场景
- [ ] **MCP 配置预设**：把 5 个预置 MCP server 中的 `_filesystem` `_browser` `_postgres` 各做一个完整启用 demo
- [ ] **多语言 Skill 库**：Python / TypeScript / Go 等语言的常用 skills（如 `python-pyproject-init` `ts-tsconfig-strict`）
- [ ] **更详细的 `.codebuddy/docs/EXAMPLES.md`**：5+ 真实场景 transcript

### 长期（探索性）

- [ ] **多用户协作**：多人同时跑同一个需求时的 worktree / 状态合并策略
- [ ] **跨 repo 复用 skills**：用 git submodule 还是 npm 包还是 junction 哪个更好？做个对比 ADR
- [ ] **AI agent 间的上下文压缩**：当 agent 委派链 ≥ 3 层时如何压缩 context
- [ ] **可视化 dashboard**：起一个本地 web，可视化看所有 requirements 状态、SOP 走到哪、哪些 skill 被用得最多

---

## 接续工作的最短路径

> 下次打开项目时按这个顺序就能立刻接续。

1. 读本文件「待办：Phase 5」段看剩余 Round
2. 跑 `bash .codebuddy/scripts/doctor.sh` 确认仓库状态
3. 看 `git log -5` 回忆上次提交了什么
4. 选一个待做 Round 开始做

---

## 历史总结

### v0.1.0-alpha 的设计权衡（重要决策）

详细 ADR 见 `.codebuddy/docs/ADR/`，这里是一句话版本：

| 决策 | 理由 |
|---|---|
| **Cursor + Claude Code + CodeBuddy 三端原生**，不做抽象层 | 抽象层维护成本高；CodeBuddy 与 Claude Code 高度兼容（详见 ADR-0004），三端共用同一组源 + 镜像同步即可 |
| **Skill 单一源**（不为各端各写一份） | 同一份 SKILL.md 通过引用/junction 就能在三端都用；避免多向同步噩梦 |
| **PM 由主会话直接担任** | 去掉 pm-orchestrator 中间层，决策链更短，避免误判 |
| **三视角代码评审** | 实现质量 / 与需求一致 / 与方案一致 ——单视角必漏 |
| **测试只跑不解释（基线对比）** | 防 AI 为通过测试瞎改；解释失败应交给 dev 或主会话 |
| **Skill 演进必须人机确认** | 防止协作标准被静默改动；这是体系长期能用的根本保证 |
| **Doctor 只诊断不修复** | 修复决策权在用户；诊断报告应足够详细让用户能选修复方式 |
| **agile-vibe + deep-vibe 双 SOP** | 80% 场景 agile 够用；20% 复杂场景才需要 deep |
| **PowerShell + bash 双脚本** | 不强求用户装 WSL / git-bash；Windows / macOS / Linux 都是一等公民 |

### 待回答问题（v1.0 决策前需想清楚）

- **是否需要 npm package 形态**：当前是 git template 形态。如果想做成 `npx create-vibe-project` 这样体验，需要重构
- **Skills 的版本管理**：当 skill 演进时，已用旧 skill 的需求怎么办？要不要 skill 也有 version？
- **多个项目共享 skills 的边界**：junction 方案够用还是要做更正式的 skill 包？

---
*最后更新：2026-05-09（v0.2.2 SOP 流程优化：mini-plan / 快速方案 / 轻量 testing&closing / 门禁对齐）*
