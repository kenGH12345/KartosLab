# Masses and Springs: Basics — Completion Report

**Status: done**（Close 完成 · 含 Post-Close 视觉校准）  
**Date:** 2026-09-08  
**Req:** `req-masses-and-springs-basics`

## Screens

| Screen | Core | Notes |
|--------|------|--------|
| Bounce | ✅ | Feature-frozen: Physics / Animation / Drag / Clock untouched in closeout |
| Stretch | ✅ | + Draggable ruler (PhET `DraggableRulerNode`) |
| Lab | ✅ | + Period Trace + V/A vector visual polish |

## Closeout deliverables (this round)

### Stretch — Ruler
- Always visible (`Property(true)` as in StretchScreenView)
- Length = **1 m** in model → view (`modelToViewDeltaY(-1)`)
- Major ticks / labels every 10 cm, unit **cm**, yellow fill
- View-space drag; reset returns to default position

### Lab — Period Trace
- Model: `PeriodTrace` on Lab spring (`peak` / `cross` from real mass motion)
- State machine 0→4 + fade (not a pregenerated sine)
- Checkbox in vector panel (`periodTraceVisibility`)
- Painter draws equilibrium-relative path from live displacement / peaks

### Lab — Vector polish
- Filled arrows + black stroke (PhET ArrowNode look)
- Velocity green / Acceleration orange; COM-anchored, left offset
- Visibility flags only — **physics unchanged**

## Verification

| Check | Result |
|-------|--------|
| `flutter analyze` (lib/test MASB) | PASS (info-only in old QA harnesses) |
| `flutter test test/masses_and_springs_basics/` | PASS (34) |
| Windows runtime final QA | PASS — see `visual-qa/runtime/RUNTIME_QA.md` |
| Stretch screenshot | `visual-qa/runtime/final_stretch.png` (ruler visible) |

## Architecture preserved

`Model → (RenderData/state) → Painter` · shared `MasbController` ticker · no Bounce physics refactor

## Next

Hand off to Close phase (`code-reviewer` → `closer` → `knowledge-maintainer`) when approved.

---

## Close（closer · 2026-09-08 05:03）

| Item | Result |
|------|--------|
| 用户确认 | READY FOR CLOSE |
| 代码评审 | `design/代码评审.md` — 有改进建议 · **0 Blocker** · 2 Major 推迟（NineGrid / KratosSlider） |
| 主会话 verdict | `approve_go`（功能冻结 · 不改 sim 代码） |
| 最终需求快照 | `spec/最终需求.md`（含 3.1 验收项覆盖 · 10/10） |
| notes | `notes.md`（Major 推迟 · migration 要点 · VCS/脚本环境） |
| 单测 | 34 PASS（`test/masses_and_springs_basics/`） |
| Runtime QA | PASS — 见 `visual-qa/runtime/RUNTIME_QA.md`（Final closeout @ 04:55） |
| VCS | **不可用 · 未 commit** · 工作区文件即为交付态 |
| 建议下一步 | 委派 `knowledge-maintainer`（回写 `docs/knowledge/kratos-java-simulations/`） |

## Close 完成确认（主会话 · 2026-09-08）

- `status: done` · `phase: done`
- knowledge-maintainer：已回写 existing-flutter-map / shared-abstraction-plan L1 / notes / module-catalog
- `check-before-done.ps1`：**PASS**（WARNING：缺 ac-verification.md，非阻塞）
- **未 commit**：工作区无 git；交付态 = 工作区文件
- **未改** Bounce / Stretch / Lab 功能代码（Close 当时）

---

## Post-Close Visual Calibration（2026-09-08）

> 功能冻结前提下仅做 Layout / Visual。Physics / Model / Drag / Clock **未改**。

| 项 | 结果 |
|----|------|
| Round 1 · Viewport | 奶油色全幅背景；去掉灰色内嵌卡片；`mvtScale` 250→320；`fitScale` 可 >1 |
| 顶部系统控件 | 双簧：Strength 1/2 · 停振（振荡发光）· 横杆标号 1/2；按弹簧 view 锚点绝对定位 |
| 弹簧↔标号对齐 | 「1」「2」正下方悬挂 |
| Strength 面板裁切 | 控件顶边下移，标题完整可见 |
| Lab 单簧 | 横杆居中对齐弹簧 X，弹簧从杆下垂下 |
| 测试（校准后） | `flutter test test/masses_and_springs_basics/` → **36 PASS**（2026-09-08 17:21） |

### 仍属视觉债（非阻塞）

- 底部深蓝 debug HUD（Pause/Reset + telemetry）尚未按原版替换
- NineGrid / KratosSlider（Close 评审 Major，已推迟）
- Round 3–5（shelf/mass、ruler、options、底栏 PhET 控件）未完整跑完

### 证据

- Runtime：`visual-qa/runtime/RUNTIME_QA.md` · `final_stretch.png` · `round1_viewport.png`
- 评审：`design/代码评审.md`
- 快照：`spec/最终需求.md`
