# Phase 5 实战发现日志

> 这是 Phase 5（端到端验证）期间的运行笔记，记录每一个 Round 中暴露出的真实问题。
> Round 5 收尾时会把这里的内容**有选择地**整理成 `.codebuddy/docs/EXAMPLES.md`（带 transcript 摘录），并提炼可能的 ADR-0004 / ADR-0005。
>
> 写法：每条记一个 finding，包含【发现时机】【现象】【根因】【处置】【后续】五段。

---

## Round 1 — agile-vibe 全流程

### F-1.1 `init.sh` 用了 bash 4 的 `mapfile`（macOS 默认 bash 3.2 跑不动）

- **发现时机**：Round 1 步骤 ②，第一次在 demo-todo-app/ 跑 `bash .codebuddy/scripts/init.sh -n demo-todo-app -r ""` 时直接报 `mapfile: command not found` 中断
- **现象**：脚本走到 step "Replacing placeholders..." 立刻死掉，占位符一个没换；`.vibe/.initialized` flag 也没建
- **根因**：`.codebuddy/scripts/init.sh:114` 与 `.codebuddy/scripts/new-requirement.sh:108` 都用了 `mapfile -t files < <(find ...)`。`mapfile` 是 bash 4+ 内置；macOS 自带 `/bin/bash` 是 GNU bash 3.2.57（GPLv2 那版，Apple 不会升）。QUICKSTART.md 第 13 行写的前置条件是 "Bash 4+"，但很多 macOS 用户根本不会装 brew bash —— 这违反了 "out-of-box" 的承诺
- **处置**：把两个脚本里的 `mapfile -t files < <(...)` 改成 bash 3.2 兼容的 `files=(); while IFS= read -r -d '' f; do files+=("$f"); done < <(... -print0)`。改完语法 `bash -n` 通过；重铺 demo + 重跑 init 成功（modified 27 files）
- **后续**：
  - `.codebuddy/docs/QUICKSTART.md` "前置条件" 里 "Bash 4+" 应改为 "Bash 3.2+"（macOS 默认就够了）
  - 写一个 ShellCheck CI（或 doctor 的扩展）扫描 `.codebuddy/scripts/*.sh` 是否引入 bash 4 only 特性
  - 候选 ADR：跨平台脚本兼容性的最低基线

### F-1.2 `init.sh` 不替换 `2026-05-29 13:40`、`cursor,claude` 等占位符

- **发现时机**：Round 1 步骤 ③，init 成功后跑 `bash .codebuddy/scripts/doctor.sh`，placeholder 数仍有 26 项
- **现象**：`init.sh` 跑完后，`AGENTS.md:5`、3 个 ADR 文件、`.codebuddy/docs/CONVENTIONS.md:107` 等仍残留 `2026-05-29 13:40`；`AGENTS.md:4` 的 `cursor,claude` 也没换
- **根因**：`.codebuddy/scripts/init.sh` 只替换 `wepop-trunk` 和 `d:\WePop_trunk` 两个占位符（init.sh:126 那个 `grep -E '\{\{(PROJECT_NAME\|REPO_PATH)\}\}'`），其他模板占位符没处理。但 `requirements/_template/README.md` 说占位符体系应包含 `{{REQ_ID}} {{TITLE}} {{SOP}} 2026-05-29 13:40 d:\WePop_trunk`，且 doctor 的扫描列表（`doctor.sh:264`）也包含这 6 个 —— **doctor 的检查范围 ⊃ init 的填充范围**，这本身就是不一致
- **处置**：暂未修。属 init.sh 的改进，不阻塞 Round 1 推进
- **后续**：
  - init.sh 至少应该处理 `2026-05-29 13:40`（用 `date` 取当前时间）和 `cursor,claude`（询问或默认 `cursor,claude`）
  - 设计权衡：3 个 ADR 文件里的 `**Date**: 2026-05-29 13:40` 是不是合理？ADR 的 Date 应该是**写 ADR 那天**，不是用户 init 项目那天。可能这些 ADR 不该带 `2026-05-29 13:40`，而是直接写真实日期 `2026-04-25` 之类
  - 候选 ADR：模板占位符的"who fills in"语义边界

### F-1.4 `.cursor/` 端整层从未真正建出来 —— 模板只是 Claude Code 单原生

- **发现时机**：Round 1 步骤 ④，准备让用户在 Cursor 窗口里跑 `/pm-new` 时排查环境
- **现象**（**这条是本次最大发现**）：
  - 全仓 `*.mdc` 文件数 = **0**（应有 8 个 `.cursor/rules/*.mdc`，对应 AGENTS.md 第 28-37 行表格列的 8 条规则）
  - 全仓 `rules/` 目录数 = **0**
  - demo（与模板）`.cursor/` 目录**根本不存在**
  - `.cursor/commands/*.md` = 0（应同步自 `.claude/commands/*.md`，去 frontmatter）
  - `.cursor/mcp.json` 不存在（CLAUDE.md L49 提到的 `.codebuddy/scripts/sync-mcp.ps1` 也不存在）
- **根因链**：
  1. **Phase 1 漏交**：ROADMAP 第 18 行宣称 Phase 1 交付了"8 条 `.cursor/rules/*.mdc`"，但这 8 个文件**从未被创建**。doctor 自第一轮起就报 `INSUFFICIENT: .cursor/rules/*.mdc: 0 (expected >= 8)`，但被当作"模板未 init 的正常状态"而忽视
  2. **Phase 2 双写假象**：ARCHITECTURE.md L21 写"Commands 是双写的——同名同用途，分别在 .cursor/commands/ 与 .claude/commands/，由脚本自动同步"，但**同步脚本** `.codebuddy/scripts/sync-commands.ps1` / `.codebuddy/scripts/sync-mcp.ps1` 一行没写——它们都被推迟到了 v1.1/v1.2 的 todo 里（ROADMAP L113-114）
  3. **AGENTS.md 与 CLAUDE.md 都引用了不存在的文件**：CLAUDE.md L49 显式写 "不要编辑 .cursor/mcp.json——它由 .codebuddy/scripts/sync-mcp.ps1 从 .mcp.json 同步而来"，但被引用的脚本不存在；AGENTS.md L26-37 整张规则表的 8 条规则**全是死链**
- **真实影响**：
  - **当前模板严格意义上只是"Claude Code 原生 + Cursor 待施工"**，不是 ARCHITECTURE 所述的"双工具原生"
  - 在 Cursor 窗口里打开 demo 项目，**slash commands 全部不可用**（Cursor 读 `.cursor/commands/*.md`，目录都没有）
  - L1 约束层（rules）是**纯概念性的**——AI agents 从未真正"加载"过这 8 条规则，因为它们不存在；agents 实际遵守的，是 AGENTS.md 中的"核心规则索引"表格里那一句话描述（这只是**导航文字**，不是**真正的规则内容**）
- **处置**：暂未修。这是一个 Phase 1 + Phase 2 联合的大坑，需要专门用一段时间补：
  1. 把 8 条 `.cursor/rules/*.mdc` 真正写出来（每条 200~500 字内容，参考 AGENTS.md 表格里描述的主题）
  2. 写 `.codebuddy/scripts/sync-commands.ps1` + `.sh` 把 `.claude/commands/*.md` 去 frontmatter 同步到 `.cursor/commands/`
  3. 写 `.codebuddy/scripts/sync-mcp.ps1` + `.sh` 把 `.mcp.json` 同步到 `.cursor/mcp.json`
  4. 修 doctor —— 三个 sync 缺失的话应直接报 unhealthy，不该被忽视
- **后续**：
  - 这是**模板等级的可信度问题**——发布 v1.0 之前必须修。否则 Cursor 用户克隆下来一上手就发现命令不能用
  - **候选 ADR-0004**：rules 层的物理实现策略（写成 `.mdc` 直接用？还是写在 `.codebuddy/skills/_meta/rules/*.md` 然后由 init 同步？）
  - **候选 ADR-0005**：sync 脚本的运行时机（init 时一次性？每次启动 Cursor 自动？git pre-commit？）
  - 把 ROADMAP Phase 1/2 的"已完成"标记部分回退为"部分完成"，避免误导

---

### F-1.3 doctor 的占位符检查可能过度报告

- **发现时机**：Round 1 步骤 ③，看 doctor 的 26 个 placeholder remnant
- **现象**：26 项里有不少是"文档 ABOUT 占位符"，不是"应该被替换的占位符"。例如：
  - `.claude/commands/pm-new.md:41` 列举 pm-new 替换的占位符 `{{REQ_ID}} {{TITLE}} {{SOP}} 2026-05-29 13:40` —— 是说明文，不该被 init 替换
  - `.codebuddy/skills/core/doctor/SKILL.md:90-91` 含 `{{REQ_ID}} {{TITLE}}` —— 是 doctor 自己的检查项示例
  - `.codebuddy/docs/CONVENTIONS.md:107` 含 `2026-05-29 13:40` —— 是占位符约定的说明表格
- **根因**：doctor 用纯文本匹配，无法区分"代码里残留的占位符"与"文档里描述的占位符"。当前 exclude 列表只排除了 `.codebuddy/scripts/*` 和 `_template/*`，但 SKILL/command/docs 里的"自描述"内容没有被排除
- **处置**：暂未修。属于 doctor 的改进
- **后续**：
  - 选项 A：改 doctor，让占位符检查只看代码块外的内容（要解析 markdown）—— 复杂
  - 选项 B：用更明显的"逃逸语法"标记文档里的占位符，例如 `\{\{REQ_ID\}\}` 或 `&#123;&#123;REQ_ID&#125;&#125;` —— 但是不直观
  - 选项 C：扩 doctor 的 exclude 路径白名单，把 `.claude/commands/*` `.codebuddy/skills/core/*/SKILL.md` `.codebuddy/docs/CONVENTIONS.md` 加进去 —— 简单粗暴但有用
  - 候选 ADR：占位符检查的精度 vs 简单度权衡

---

## Round 2 — deep-vibe 全流程

_（未开始）_

---

## Round 3 — self-evolution 验证

_（未开始）_

---

## Round 4 — doctor 自校验循环

_（未开始）_

---

## Round 5 — 整理 + 发布

_（未开始；本日志会在这一轮被 distill 进 .codebuddy/docs/EXAMPLES.md 与 ADR）_

---

## 索引：当前 Phase 5 finding 总数

- 已记录：7
- **已修复（patch 已落地）：6**（F-1.1、F-1.2、F-1.3、F-1.4、F-1.6、F-1.7）
- 部分缓解：1（F-1.5 — 版本控制层 `.gitattributes` 已强制 sh→LF；工作树层未防护）
- 候选 ADR：6 个方向（F-1.6 已落地为 ADR-0004）

### 严重程度评估

| ID | 严重 | 修复状态 | 是否阻塞 v1.0 |
|---|---|---|---|
| F-1.1 mapfile 兼容性 | 高 | ✅ 已修 + 验证 | 已解 |
| F-1.2 init 不替换 CREATED_AT/PRIMARY_TOOL | 中 | ✅ 已修 + 验证 | 已解 |
| F-1.3 doctor 占位符过度报告 | 低 | ✅ 已修（Perl + 文件白名单） | 已解 |
| **F-1.4 .cursor/ 整层缺失** | **致命** | **✅ 已修：8 rules + 4 sync 脚本 + doctor 升级** | 已解 |
| F-1.5 Write 工具产出 CRLF | 低 | ½ 版本控制层已防护（`.gitattributes:10`）；工作树层仍需手动 `tr -d '\r'`；workaround 已写入 `.codebuddy/docs/TROUBLESHOOTING.md` | 不阻塞 |
| **F-1.6 CodeBuddy 适配层从未实现** | **高** | **✅ 已修：sync-codebuddy + CODEBUDDY.md + doctor + ADR-0004** | 已解 |
| **F-1.7 模板源仓自身未 git init** | **高** | ✅ 已修：用户自行 `git init` + initial commit `8645f73` | 已解 |

### F-1.4 修复成果（2026-05-03 完成）

**新增文件**：
- `.cursor/rules/00-engineering-principles.mdc` ~ `70-progressive-output.mdc`（共 8 条，约 642 行）
- `.cursor/commands/*.md`（16 条，由 sync 脚本从 .claude/commands/ 生成）
- `.cursor/mcp.json`（由 sync 脚本从 .mcp.json 生成）
- `.codebuddy/scripts/sync-commands.sh` + `.ps1`（剥离 frontmatter 后同步）
- `.codebuddy/scripts/sync-mcp.sh` + `.ps1`（直接拷贝）

**修改的脚本**：
- `.codebuddy/scripts/init.sh` + `.ps1`：增加 `2026-05-29 13:40` `cursor,claude` `wepop-trunk` 替换；用 Perl 的 lookbehind/lookahead 跳过反引号包裹；排除 `.codebuddy/skills/**` 和 `.codebuddy/docs/PHASE5-FINDINGS.md`
- `.codebuddy/scripts/doctor.sh` + `.ps1`：加 `.cursor/mcp.json` asset 检查；排除 `.cursor/*` `.codebuddy/scripts/sync-*` `.codebuddy/skills/*` `.codebuddy/docs/PHASE5-FINDINGS.md` 的 placeholder 检查；用 Perl regex 实现"反引号任一侧即跳过"

**验证结果**：
- 模板自身：subhealthy（38 占位符，全部是模板未 init 的预期状态）
- demo 项目（init+sync 后）：**healthy**（0 资产缺失 / 0 链接断裂 / 0 占位符 / exit=0）

### F-1.5 Write 工具产出 CRLF（新增）

- **发现时机**：F-1.4 修复过程中写第一个 sync 脚本时
- **现象**：通过 Write 工具创建的 `.sh` 脚本带 CRLF 行尾，bash 解析时把 `pipefail\r` 当 invalid option name 拒绝
- **根因**：在当前 macOS 环境下，Write 工具有时输出 CRLF 而非 LF。原因不确定，可能与编码自动检测有关
- **当前绕开**：每次 Write `.sh` 文件后立即 `tr -d '\r' < f > f.tmp && mv f.tmp f && chmod +x f`
- **2026-05-03 19:10 复核**（部分缓解）：
  - **版本控制层已防护**：`.gitattributes:10` 早就有 `*.sh text eol=lf` 规则；本仓 `.codebuddy/scripts/*.sh` 全 6 个均为 LF（`file .codebuddy/scripts/*.sh` 验证通过）；commit 时版本控制会 normalize CRLF → LF
  - **工作树层未防护**：Write 工具新写的 `.sh` 在 commit 之前 / 不 commit 直接 `bash xxx.sh` 仍可能因 CRLF 死。这是上游工具问题，不是项目侧能根治
  - **已新增 workaround 文档**：`.codebuddy/docs/TROUBLESHOOTING.md` 在 "SVN / 分支" 段加了 `### Write 工具新建的 .sh 脚本跑起来报 invalid option name "pipefail\r"` 条目
  - **未做（推到 v1.1）**：doctor 加 line-ending 检查（`.sh` 含 CR 则 unhealthy）——这是兜底，价值偏低，因版本控制层已 normalize；先记入 v1.1 backlog
- **后续**：
  - 验证是否所有 Write 调用都受影响（其他 .md / .ps1 看起来 OK）
  - 候选 v1.1：doctor line-ending 检查作为兜底防御

### F-1.6 CodeBuddy 适配层从未实现 —— ADR 与代码不一致

- **发现时机**：F-1.4 修完后，用户提出"现在要支持 CodeBuddy"，开始动手时发现 ADR-0002 第 7 条已经写了 `.codebuddy/scripts/sync-codebuddy.ps1`，但脚本不存在
- **现象**：
  - ADR-0002（2026-04-25）"Decision" 第 7 条："**CodeBuddy** 由 `.codebuddy/scripts/sync-codebuddy.ps1` 从 `.cursor/` + `.claude/` 自动生成"
  - 但 `.codebuddy/scripts/sync-codebuddy.ps1` / `.sh` 文件不存在
  - `.codebuddy/` 目录也不存在
  - 没有 `CODEBUDDY.md`
  - doctor.sh / doctor.ps1 不检查任何 `.codebuddy/*` 资产
  - ROADMAP / README / ARCHITECTURE 都说"双工具原生 + CodeBuddy 通过适配层兼容"，但适配层根本没建
- **根因链**：与 F-1.4 是**同类问题**——ADR / ROADMAP 写得早，但 Phase 1-3 的实际产物没跟上，Phase 4 没做交叉验证，到 Phase 5 才暴露
  1. ADR-0002 起草时没做 CodeBuddy 调研，凭直觉假设"需要复杂的适配层"，于是把它列为 v1.x 的 todo
  2. 但 ADR 文本却把它当作既定事实写进 Decision 条目（"由 .codebuddy/scripts/sync-codebuddy.ps1 自动生成"），制造"已实现"的假象
  3. ROADMAP / README 沿用了这个假象表述
- **真实影响**：
  - CodeBuddy 用户克隆仓库后**完全不可用**（没有 .codebuddy/ 任何资产）
  - "三端兼容"的承诺**全是文档**，实际只是 Cursor + Claude 双端
  - 信任损耗（与 F-1.4 同——ADR 与实现脱节）
- **处置**（2026-05-03，本日完成）：
  1. 调研 CodeBuddy 官方文档（[Tencent Cloud CodeBuddy IDE Rules](https://staging-codebuddy.tencent.com/docs/ide/User-guide/Rules) + [CodeBuddy CLI SDK](https://www.codebuddy.ai/docs/cli/sdk) + Plugin Reference）
  2. **关键发现**：CodeBuddy 与 Claude Code 项目级布局**几乎 1:1 等价**（详见 ADR-0004 的对比表）——之前预估的"适配层"工作量被严重高估
  3. 写 `.codebuddy/scripts/sync-codebuddy.sh` + `.ps1`：
     - `.cursor/rules/*.mdc` → `.codebuddy/rules/*.mdc`（直接 cp，.mdc 格式相同）
     - `.claude/agents/*.md` → `.codebuddy/agents/*.md`（直接 cp）
     - `.claude/commands/*.md` → `.codebuddy/commands/*.md`（直接 cp）
     - `.claude/settings.json` → `.codebuddy/settings.json`（直接 cp）
     - `.mcp.json` 不需要 sync，三端共享
  4. 写 `CODEBUDDY.md`（轻量，第一行 `@AGENTS.md` 引入共享内容 + 端专属补充）
  5. 升级 `.codebuddy/scripts/init.sh` / `init.ps1`：在版本控制初始化之前调用所有 sync 脚本（sync-commands / sync-mcp / sync-codebuddy 三件套），让初始化即三端可用
  6. 升级 `.codebuddy/scripts/doctor.sh` / `doctor.ps1`：加 `.codebuddy/rules/*.mdc` `.codebuddy/agents/*.md` `.codebuddy/commands/*.md` `.codebuddy/settings.json` `CODEBUDDY.md` 检查；commands symmetry 从双端升级为三端；placeholder 检查跳过 `.codebuddy/*`
  7. **修订 ADR-0002**：第 7 条由"虚拟引用"改为"真实存在的脚本 + 指向 ADR-0004"；标注被 ADR-0004 部分超越
  8. **新增 ADR-0004**（CodeBuddy 第三端原生 + 镜像策略）：详细记录决策过程、备选方案、与 ADR-0002 的关系
  9. 更新 ROADMAP / README / .codebuddy/docs/ARCHITECTURE.md：从"双工具原生"扩到"三端原生"
- **验证**：
  - 本仓 doctor：assets 0 missing（含 .codebuddy/ 全部资产）；commands 三端对称 16=16=16
  - demo 仓（cp 新脚本 + 跑 sync-codebuddy）：.codebuddy/rules/agents/commands/settings 全部齐全；CODEBUDDY.md present；placeholder 0；broken links 0
- **后续**：
  - 候选：把"ADR 与实现一致性"做成 doctor 的一项检查（ADR 中提到的脚本/路径必须真实存在）
  - 候选：CodeBuddy 端的 hook / permissions 字段是否需要 .claude/settings.json 之外的端专属覆写？（当前直接 cp，假设字段完全兼容；待用户实测）
  - 文档化：CODEBUDDY.md / ADR-0004 已就绪；docs/ 下其他文档（QUICKSTART / INSTALL / CONVENTIONS / COMMAND_GUIDE / AGENT_GUIDE）的"双端"叙述还需扫一遍升级到"三端"

### F-1.7 修复说明（2026-05-03 完成）

- **修复方式**：用户在上次会话末尾自行执行 `git init` + 单 initial commit，把 v0.1.0-alpha 的全部状态作为发布快照固化
- **commit**：`8645f73 chore: initial commit (v0.1.0-alpha)`
- **副作用**：选择了"单 commit"方案（原选项 A1），未做 phase 级别的逻辑切分（A2）；后续从此 commit 起做渐进式 commit
- **tag**：`v0.1.0-alpha` 也已同步打上（指向 `8645f73`），相当于走的是 A1+A3。本会话一度误报"tag 未做"，已校正
- **后续**：
  - 候选：本仓 `.gitignore` 是否还需补充（如 `terminals/` `.cursor/projects/` 等本地状态目录），目前未审计
  - 候选：模板被 clone 后用户跑 `init.sh` 时，要不要顺便建议 "请在你的项目仓 `git init`"（已在 init.sh 里执行 `git init`，但未确认是否给用户提示）

---
*最后更新：2026-05-03 19:10*
