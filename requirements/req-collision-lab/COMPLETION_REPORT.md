# COMPLETION_REPORT · Collision Lab

> **结论：移植成功 · `status: done`**  
> 需求：`req-collision-lab`  
> 结项日期：2026-09-03  
> 源码：本地 `phet sourses/collision-lab-main/collision-lab-main` @ **`1.2.0-dev.0`**（不以 GitHub / 官网 latest 替换）  
> 验收：用户确认可 report；Phase 0–12 + Gap Closure + P0 Visual QA 修复已完成

---

## 1. 结项结论

PhET **Collision Lab**（Intro / Explore 1D / Explore 2D / Inelastic）已成功迁入 KARTOSLAB Flutter，可作为已完成 sim 交付。

| 验收项 | 结果 |
|---|---|
| AC-1 Home 进出 / 四 Tab | ✅ |
| AC-2 Ball · Constant Size · Border · Grid · Keypad · More Data | ✅ |
| AC-3 碰撞 / stick 旋转 / 负步进 `e←1/e` | ✅ **[源码一致]** / **[物理一致]** |
| AC-4 Momenta · Δp · Paths · Reset/Restart/Step | ✅ |
| Gap: Tip Drag · ScaleBar · bump/repel | ✅ |
| P0: PlayArea clip · Grid 拖拽 | ✅ |
| AC-5 analyze + 专项测试 | ✅ 0 issues · **39+** passed |
| Home | ✅ 物理 → **力学** → Collision Lab |

**未声称「完全一模一样」。**

---

## 2. 最终状态一览

| 维度 | 状态 | 说明 |
|---|---|---|
| 碰撞 / stick / 负步进 / mass-radius | **[源码一致]** | 对照本地 CollisionEngine 族 |
| 守恒测试 | **[物理一致]** | 球-球守恒；球-边动量可变 |
| Tip drag / Grid snap / bump | **[行为一致]** | |
| PlayArea ball clipping | **[视觉已对齐]** | PhET `clipArea` |
| ScaleBar / Momenta 微几何 | **[视觉近似]** | 非阻塞 |
| 字体 / AppBar+Tab+NineGrid | **[有意差异]** | KARTOSLAB 壳 |
| Leader-lines | **[待实现]** | 非阻塞，不挡结项 |
| 本机 runtime 像素 overlay | **[待确认]** | 有 assets + Flutter capture |
| BLOCKED | 无 | — |

---

## 3. 交付物

### 代码

- `lib/collision_lab/` — Model / Solver / Controller / Render / Painters / Widgets / Screens  
- Home：`lib/screens/home_screen.dart` → 力学 → Collision Lab  
- 测试：`test/collision_lab/`（physics / gap / clip_drag / visual_capture）  
- **未改**其他已完成 sim；**未改** common API / Theme / 全局导航

### 文档（`requirements/req-collision-lab/`）

| 文件 | 用途 |
|---|---|
| `PROJECT_DISCOVERY.md` | Phase 0 |
| `SOURCE_ANALYSIS.md` | Phase 1 |
| `ARCHITECTURE_PLAN.md` | Phase 3 |
| `FUNCTIONAL_GAP_CLOSURE.md` | Tip / ScaleBar / bump |
| `PHYSICS_VALIDATION.md` | 守恒与公式 |
| `visual-qa/BASELINE.md` | 截图与 P0 修复记录 |
| `visual-qa/GEOMETRY_CALIBRATION.md` | clip / hit-test |
| `PHASE_12_CLEANUP.md` | 无 legacy |
| `COMPLETION_REPORT.md` | 本文件 |
| `meta.yaml` / `process.txt` | 状态 |

---

## 4. 已知非阻塞项（不挡结项）

1. Leader-lines（拖球辅助线）**[待实现]**  
2. Momenta / ScaleBar 像素级精校 **[视觉近似]**  
3. 本机浏览器 runtime 全页 overlay **[待确认]**

---

## 5. 结项声明

用户确认 **可以 report**。  
`status: done` · `acceptance: user-confirmed-report` · 项目关闭。
