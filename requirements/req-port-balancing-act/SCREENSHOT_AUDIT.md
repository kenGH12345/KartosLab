# Balancing Act — Screenshot Audit

> Phase 0 · 2026-09-23  
> 用户提供的原版截图 ×3；截图确认视觉/布局/状态；**Model/物理以源码为准**。

截图文件（Cursor workspace assets）：
1. `image-31cc7745-0a40-4d34-9eaf-79b9e8625157.png`
2. `image-c6237b10-5d82-4ea6-8504-e030c059fbea.png`
3. `image-3018825a-86dc-4027-a554-c893d978515c.png`

---

## Screenshot 1 — Intro (initial)

| Field | Value |
|-------|-------|
| Screenshot | #1 |
| Corresponding Screen | **Intro** (`BAIntroScreen`) |
| Viewport | PhET standard layout（源码 768×504 设计空间；截图为运行时缩放） |
| Visible Controls | Show: Mass Labels ✓, Forces ✗, Level ✗；Position: None；Column toggle LEFT (supports on)；Reset All bottom-right |
| Visible Objects | 2× fire extinguisher labeled **5 kg**；1× trash can labeled **10 kg**；on grass right of plank |
| State | Plank empty & level；`DOUBLE_COLUMNS`（两灰柱可见）；mass labels on |
| Important Layout Evidence | Sky + green ground；yellow A-frame fulcrum；tan plank with ticks；controls top-right stacked panels；column ABSwitch bottom-center |
| Source Cross-reference | `BAIntroModel` seeds 2×`FireExtinguisher`(5kg) + `SmallTrashCan`(10kg) at x=2.7/3.2/3.7；`massLabelsVisibleProperty` default true；`columnState` default DOUBLE；`BasicBalanceScreenView` Show+Position panels — **MATCH** |

**Conflicts**: 无。

---

## Screenshot 2 — Balance Lab (initial)

| Field | Value |
|-------|-------|
| Screenshot | #2 |
| Corresponding Screen | **Balance Lab** (`BalanceLabScreen`) |
| Viewport | 同上 |
| Visible Controls | Show + Position（同 Intro）；**Bricks** carousel：5/10/15/20 kg stacks + `<` `>`；Column toggle LEFT；Reset All |
| Visible Objects | 无地面预置 mass（与 Intro 不同）；plank 空 |
| State | DOUBLE_COLUMNS；Mass Labels on；Position None；carousel on Bricks page |
| Important Layout Evidence | 第三块控制面板为 MassCarousel；砖块为红色堆叠（PROCEDURAL BrickStack，非 PNG） |
| Source Cross-reference | `BalanceLabScreenView` adds `MassCarousel`；`BrickStackCreatorNode` 1–4 bricks × 5 kg；default column DOUBLE — **MATCH** |

**Conflicts**: 无。  
注：砖块视觉为程序绘制红色矩形堆，与截图一致。

---

## Screenshot 3 — Game Select Level

| Field | Value |
|-------|-------|
| Screenshot | #3 |
| Corresponding Screen | **Game** — state `choosingLevel` (`StartGameLevelNode`) |
| Viewport | 同上 |
| Visible Controls | Title “Select Level”；4 level cards；TimerToggleButton bottom-left（timer off：时钟+红斜杠）；Reset All bottom-right |
| Visible Objects | 四张关卡缩略图（gameLevel1–4Icon.svg 内容）：砖块/桶花盆/岩石植物木桶/轮胎消防栓狗黄桶等 |
| State | 未开始；每关 **6 空星**（`CHALLENGES_PER_PROBLEM_SET=6`，`ScoreDisplayStars`） |
| Important Layout Evidence | 选关页无 plank 实景；背景仍 sky+ground；无 Intro/Lab 控制面板 |
| Source Cross-reference | `MAX_LEVELS=4`；`StartGameLevelNode` + vegas LevelSelectionButtonGroup + TimerToggleButton + ResetAllButton；stars=6 — **MATCH** |

**Conflicts**: 无。  
注：缩略图内物体为 icon SVG 预渲染，不等于实时 scene graph。

---

## Cross-cutting visual confirmations

| Visual element | Screenshot evidence | Source |
|----------------|---------------------|--------|
| Reset All orange circular | #1 #2 #3 | `ResetAllButton`；Flutter → `KratosResetAllButton` |
| Supports toggle icons | #1 #2 | `ColumnControlIcon` PROCEDURAL（非 assets SVG） |
| Mass labels “N kg” | #1 | Mass Labels checkbox + mass value |
| No rulers/marks initially | #1 #2 | PositionIndicatorChoice.NONE |
| Game 6 stars empty | #3 | ScoreDisplayStars / challenges per set |

---

## Screenshot ≠ Source 规则应用

本轮 **无冲突**。  
若未来出现差异：Model/behavior → Source；Visual state → Screenshot + Source；无法解释 → OPEN QUESTION。

---

## Coverage gap (screenshots)

用户未提供：
- Intro/Lab：NO_COLUMNS 倾斜中
- Forces / Level / Rulers / Marks 开启态
- Lab People / Mystery carousel 页
- Game 挑战进行中 / 反馈 Face / Level complete

这些状态以源码为准，不阻塞 Phase 0；后续视觉 Phase 需补截图或对照官方 runtime。
