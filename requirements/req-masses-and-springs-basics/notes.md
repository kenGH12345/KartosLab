# notes.md — req-masses-and-springs-basics

## 收尾上下文（2026-09-08）

- 用户确认 **READY FOR CLOSE**
- code-reviewer：`design/代码评审.md` 结论「有改进建议」· **0 Blocker** / 2 Major / 5 Minor
- 主会话 `verdict=approve_go`：Major（NineGridLayout / KratosSlider）功能冻结下 **notes 推迟**，不改 sim 代码
- 测试：`flutter test test/masses_and_springs_basics/` **34 PASS**；Windows runtime Final QA **PASS**（`visual-qa/runtime/RUNTIME_QA.md`）
- analyze：PASS（info-only QA harness）

---

## 已确认的发现

1. **三屏交付完整（Bounce / Stretch / Lab）**  
   证据：`COMPLETION_REPORT.md` + Final RUNTIME_QA PASS（04:55）+ 34 单测。

2. **架构分层清晰**  
   `Model → Painter` + 共享 `MasbController` ticker；closeout 未重构 Bounce 物理。

3. **L0 复用缺口属工程债，非功能回归**  
   评审：`lib/masses_and_springs_basics/**` 零 `import` 指向 `lib/common/`（NineGrid / KratosSlider 等）。L0-1/L0-3 已满足；L0-4 落为 Major 并推迟。

4. **无正式 AC-N 文档**  
   验收按 Closeout 10 维度拆分，覆盖率 10/10；缺 `test-report/ac-verification.md` 由 reviewer 等效放行。

---

## Major 推迟（用户 / 主会话已接受）

| # | 项 | 理由 | 建议后续 |
|---|---|---|---|
| M1 | 三屏未用 `NineGridLayout` | 功能冻结；RUNTIME_QA PASS；L0-1/L0-3 已满足 | 单独立项布局迁移：`center`=`SimulationWorkspace`，面板入 `midRight`/`topRight`，HUD 入 `footer` |
| M2 | Material `Slider` 未复用 `KratosSlider` | 功能冻结；PhET 青轨样式保真可接受 | 迁 `KratosSlider` 或登记本域 L1 样式控件 |

签字依据：`process.txt` · `verdict=approve_go`（2026-09-08 05:01）

---

## 踩坑 / 过程要点

- Final closeout QA 曾在 04:47 **FAIL**（`vectors_view_only: false`），04:55 复跑 **PASS** — 以最终 PASS 为准。
- 本仓无可用 git/svn diff；code-reviewer 以当日 mtime 文件盘点界定范围（32 文件）。

---

## 决策记录

| 决策 | 选 A 不选 B | 理由 |
|---|---|---|
| Closeout 不重开 NineGrid / KratosSlider 迁移 | 推迟记 notes | 用户硬约束功能冻结 + verdict=approve_go |
| 缺 ac-verification 不退回 Build | 采 RUNTIME_QA + 单测 | agile-vibe / sim 收尾等效证据（评审 §2.5） |
| PeriodTrace / DraggableRuler 本域实现 | 不上抽 L0 | 无 L0 等价物；记 L1 候选交 KM |

---

## Migration 要点（需求级 · 供 knowledge-maintainer）

1. **MASB 为首个 Masses and Springs Basics 用户** — L1 候选：`DraggableRulerOverlay`、`PeriodTrace`、PhET 风格控制条；应回写 `docs/knowledge/kratos-java-simulations/shared-abstraction-plan.md`。
2. **布局债**：后续 MASB 或同类力学 sim 开工前，优先评估 NineGrid 外壳迁移，避免再记 Major。
3. **入口**：仅改 `lib/screens/home_screen.dart` 注册；未污染其它 sim / `lib/common/`。
4. **配置化**未交付（scenario JSON / PropertyControlPanel）— 若四原则要求完整，需后续 req 跟踪。

---

## 知识沉淀（closer 收尾追加 · 2026-09-08）

### 可复用经验（建议交 KM）
- **功能冻结下 Major 处置**：checklist 阻塞级（如 L0-4）在 Final QA PASS + 用户 approve_go 时，可落 notes 推迟并进 closer，不必为布局债重开物理改动。
- **agile-vibe 测试证据链**：无 `ac-verification.md` 时，RUNTIME_QA + 专项单测 + COMPLETION_REPORT 可作为等效证据（须 reviewer 明示不打 Blocker）。
- **L1 首用户登记**：本域专用控件（尺、周期迹）勿强行塞 L0；首用户即写入 shared-abstraction-plan 候选表。

### 工具 / VCS 环境备注
- `.workflow/scripts/auto-extract-failures.ps1`（及 `.codebuddy` 镜像）**不存在** → 步骤 1.5 / 4.5.1 自动失败提取 **跳过**，以本 notes 人工沉淀替代。
- **VCS 不可用**：本工作区无 git / 无 `c:\workspace\kratos` SVN 约定路径 → **未 commit**；工作区文件即为交付态。勿伪造 revision。
- `requirements/INDEX.md` / `INDEX.yaml` **不存在** → 跳过 INDEX 更新。

### 对后续需求的提示
- 新 sim 开工自检务必过 `80-kratos-sim-checklist` L0-4（NineGrid）与滑块复用，避免收尾再 defer。
- QA harness 留在 `lib/**/masb_*_qa_main.dart` 时可考虑迁 `tool/` 或标注 `@visibleForTesting`（Nit，非本轮范围）。
