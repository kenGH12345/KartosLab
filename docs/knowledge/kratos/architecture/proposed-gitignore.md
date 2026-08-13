# `.gitignore` 改良提案（kartosos 项目仓）

> **状态**：🟡 提案（未 apply）
> **产出时间**：2026-07-20
> **目标仓库**：`c:\workspace\kratos\.gitignore`
> **前置需求**：为 `refactor-baseline-plan.md` 建立干净 baseline commit
> **决策依据**：Q1=甲-gitignore + Q2=a + Q3=a（详见主会话记录）

---

## 1. 背景

`c:\workspace\kratos` 是本地 Git 仓库（无远程），当前只有 1 个 commit `8c83051` 且仅包含 3 个文件；其余 130+ 个文件全部 untracked。为执行 `refactor-baseline-plan.md`（死代码清理 + 电路模块目录重构），必须先建立完整 baseline commit——但直接 `git add -A` 会把大量非业务文件（AI 框架资产、vibe-loop 遗留物、第三方参考代码）一并纳入，污染后续 diff review。

本文档产出改良版 `.gitignore` 追加规则，让 baseline commit 只包含**真正的业务代码 + 场景资产 + Flutter 脚手架**。

---

## 2. 现状 `.gitignore`（39 行，Flutter 标准模板）

保留不动。当前规则覆盖：`*.log` / `.DS_Store` / `.idea/` / `.dart_tool/` / `/build/` / `.pub-cache/` / `app.*.symbols` / `/android/app/debug|profile|release` 等 Flutter 生成产物。

---

## 3. 建议追加的规则（按类别分组）

### 3.1 vibe-loop 临时产物（根目录散落 + `output/` 目录内）

**Rationale**：这些是历次 `/wf` / `analyze` / `execution-validation` 等命令的中间产物。当前工作区已有 `analyze_*.txt`（8 个）、`test_*.txt`（8 个）、`final_analysis.txt` 等散落根目录；`output/` 内有 100+ 个 `execution-validation-*.md/json`、`analysis-*.md`、`architecture-*.md`、`code-graph-*.json`、`knowledge-*.json` 等。这些不该进业务仓 baseline。

```gitignore
# --- vibe-loop 临时产物（根目录）---
/analyze*.txt
/analyze*.json
/analysis*.txt
/analysis*.json
/test_*.txt
/test_output*.txt
/final_analysis.txt

# --- vibe-loop 产物目录 ---
/output/
```

**⚠️ 权衡**：`output/` 整体忽略会导致 `output/review-output.md` 和 `output/test-report.md`（当前 modified 状态）也被忽略。但这两个文件本身也是 vibe-loop 产物，忽略是合理的——它们的信息应该被沉淀到 `docs/knowledge/kkartoss/` 而不是留在业务仓。

**替代方案**：若你希望保留 `output/review-output.md` 和 `output/test-report.md`（作为历史 review 快照），用更精细规则：
```gitignore
/output/*
!/output/review-output.md
!/output/test-report.md
```

### 3.2 AI 框架资产（不进业务仓）

**Rationale**：`.claude/` / `.codebuddy/` / `.workflow/` / `AGENTS.md` / `workflow.config.js` / `init.sh` 是 kartosos 工程**自体集成**的 AIVibe 协作框架资产（单一源就在本仓库根目录），非外部 AI 工作区的镜像。是否进版本库需权衡：进库则框架升级随业务仓走；忽略则需另建机制同步框架更新。

```gitignore
# --- AI 协作框架资产（源在 AI 工作区）---
.claude/
.codebuddy/
.cursor/
.workflow/
AGENTS.md
init.sh
workflow.config.js
```

### 3.3 第三方参考代码

**Rationale**：`circuit-construction-kit-black-box-study-main/` 目录名带 `-main` 后缀是标准 GitHub zip download 命名，是外部参考代码；`kratos-common-reference/` / `kratos-reference/` 也是同类"参考资料"目录。

```gitignore
# --- 第三方参考代码（外部下载/复制的原始项目）---
/circuit-construction-kit-black-box-study-main/
/kratos-common-reference/
/kratos-reference/
```

**⚠️ 假设**：我基于目录命名做的推断。若这些目录中**有实际被业务代码 `import`/`require` 的文件**（不太可能，但可能），本规则会导致 baseline 无法构建。**apply 前你自己确认一下：**

```powershell
Select-String -Path 'c:\workspace\kratos\lib\**\*.dart' -Pattern 'circuit-construction-kit-black-box-study|kratos-common-reference|kratos-reference' -SimpleMatch
```

如果无输出则安全 apply。

---

## 4. 完整追加片段（供复制粘贴）

**apply 位置**：追加到 `c:\workspace\kratos\.gitignore` 末尾。

```gitignore

# ==== 以下为 refactor-baseline 前置的追加规则 · 2026-07-20 ====

# --- vibe-loop 临时产物（根目录）---
/analyze*.txt
/analyze*.json
/analysis*.txt
/analysis*.json
/test_*.txt
/test_output*.txt
/final_analysis.txt

# --- vibe-loop 产物目录 ---
/output/

# --- AI 协作框架资产（源在 AI 工作区）---
.claude/
.codebuddy/
.cursor/
.workflow/
AGENTS.md
init.sh
workflow.config.js

# --- 第三方参考代码（外部下载/复制的原始项目）---
/circuit-construction-kit-black-box-study-main/
/kratos-common-reference/
/kratos-reference/
```

---

## 5. Apply 步骤（由你手动执行）

### Step 1：追加规则

打开 `c:\workspace\kratos\.gitignore`，把第 4 节的完整片段追加到文件末尾，保存。

### Step 2：验证过滤效果

```powershell
cd c:\workspace\kratos
git status --short --branch
```

**期望结果**：untracked 数量从 130+ 降到 ~30-50（只剩 Flutter 脚手架 `android/` `ios/` `linux/` `macos/` `windows/` `web/` + 业务代码 `lib/` `assets/` `test/` `integration_test/` + 项目配置 `pubspec.yaml` `pubspec.lock` `.metadata` `README.md` `analysis_options.yaml` `.gitignore` + `docs/`）。

⚠️ **如果 output/*.md 里有你想保留的文件**：先按 3.1 节的"替代方案"改精细规则，再走 Step 2。

### Step 3：处理 3 个 modified 文件

```powershell
git diff lib/screens/circuit_screen.dart
git diff output/review-output.md
git diff output/test-report.md
```

对每个 modified 决定：**保留 commit** / **丢弃**（`git checkout -- <file>`）/ **部分保留**（`git add -p <file>`）

⚠️ **`output/review-output.md` 和 `output/test-report.md`**：如果 3.1 节走了"整体忽略 output/"路线，这两个文件的 modified 状态会消失（git 认为它们该被 ignore）。你需要决定：**保留旧 baseline 到 commit 里？还是干脆 `git rm --cached output/review-output.md output/test-report.md` 让它们完全脱离 git 管理？**

### Step 4：Baseline commit

```powershell
git add -A
git status --short
# 检查即将 commit 的文件清单（约 30-50 项）
git commit -m "chore: baseline snapshot before refactor-baseline-plan execution"
git log --oneline
# 期望：出现 2 个 commit（原 8c83051 + 新 baseline）
```

### Step 5：确认 clean 状态

```powershell
git status --short --branch
# 期望输出：## master（无 modified / 无 untracked）
```

---

## 6. Apply 后的下一步

回到主会话报告 **"kartosos 工作区已 baseline"**，我立即启动 `refactor-baseline-plan.md` §3.1 死代码清理（Step 1）。

---

## 7. 未决问题（apply 前你需要拍板）

| # | 问题 | 选项 |
|---|---|---|
| U1 | `output/` 整体忽略 vs 保留 `review-output.md` + `test-report.md` | (a) 整体忽略（推荐——它们本就是 vibe-loop 产物）/ (b) 保留这 2 个 |
| U2 | `docs/` 目录是业务文档还是 vibe-loop 产物？| 我没看内容——你决定。若是业务文档，不加忽略；若是 vibe-loop 产物，追加 `/docs/` |
| U3 | `.metadata` 文件？| Flutter 项目脚手架标准文件，**保留**（不追加忽略） |
| U4 | 第 3.3 节 3 个参考目录是否真无 import 依赖？| 跑 Step 3 的 grep 命令确认 |

---

## 变更历史

> 2026-07-20 · 首版
> - 基于 Q1=甲-gitignore + Q2=a + Q3=a 决策产出
> - 涵盖 3 类追加规则：vibe-loop 临时产物 / AI 框架资产 / 第三方参考代码
> - 未 apply，等待用户 review + 拍板 U1-U4
