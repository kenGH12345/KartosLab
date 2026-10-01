# FINAL REPORT — Projectile Motion Flutter Native Migration

```
Simulation: Projectile Motion
Source Version: local PhET projectile-motion 1.1.0-dev.41
  (PRIMARY; published latest 1.0.34 used only for ORIGINAL screenshots)

Tests: 31 PASS / 0 FAIL
  (physics 19 + interaction 9 + widget/lifecycle 3;
   visual capture is a separate pipeline and times out after writing PNGs by design)
Analyze: CLEAN (lib/projectile_motion + test/projectile_motion)

Physics: PASS
Behavior: PASS
Interaction: PASS
Visual: PASS (20-state matrix; version diffs documented; P1 chrome 已修)
Assets: PASS (Substituted = 0) [原版资源一致]
Lifecycle: PASS (open / dispose / reopen)
Reset: PASS (unit FIRE-4 + capture 01↔06 / 07↔10 / 11↔14 / 15↔20;
  ResetAll 按钮 3D + 弹性动效已对齐 scenery-phet)
Browser Cross Validation: PASS
  (Playwright on published HTML: angle/speed/fire/pause/reset/tools;
   行为以本地源码为准，发布版差异见 PHASE_5 V1–V7)

P0: 0
P1: 0
P2: 字体度量、发布版外壳、Lab keypad、探针盒微对齐

Final Status: DONE
Closed: 2026-09-15
```

## Architecture

```
SimulationClock (60 fps)
  → ProjectileMotionModel.step(wallDt)
      → accumulator → stepModelElements(0.012)
          → PmTrajectory.step  (p' = p+v t+½a t²; v' = v+a t; quadratic drag)
  → PmScene painters (no physics inside paint)
  → PmScreenLayout tools overlay (MeasuringTape / DataProbe 在右侧面板之上)
```

四屏：Intro / Vectors / Drag / Lab（Stats 源码未挂入口，不迁移）。
Home：物理 → 力学 → Projectile Motion。

## Physics（本地 Trajectory.ts 逐行）

- 发射点 `(0, cannonHeight)`，`v = v0 (cosθ, sinθ)`；炮管 4 m 仅视图
- 二次阻力 `Fd = ½ ρ A Cd |v| v`；ρ = NASA 标准大气或 0
- 落地 y≤0 二次截断；vx 反号保护；apex 插值
- 真空锚点 Lab 默认：range/time/apex 相对解析解 1% 内

## Interaction（收尾前 polish）

| 能力 | 状态 |
|---|---|
| 炮管改角 / 炮座改高（含黑十字近区）/ 靶水平 | PASS |
| Toolbox 探针 + 卷尺：按住即拖出、自由移动、拖回吸附 | PASS |
| 卷尺壳体 `measuringTape.png` + 灰线/橙十字 | PASS [原版资源一致] |
| 工具叠层在右侧面板之上（PhET 图层序） | PASS [布局已对齐] |
| ResetAll：球面 3D + ResetShape + 按下弹性回弹 | PASS [动态绘制已对齐] |

## Visual QA Results

20/20 ORIGINAL ↔ FLUTTER ↔ DIFF。第二轮 01：mean_abs 27.65、Δ>32 占 18.16%
（第一轮 39.99 / 30.13%）。剩余主要为 V1–V6 版本差 + KartosLab 无 PhET 底栏。

## Delivered

- `lib/projectile_motion/` Model → Clock → View → Interaction
- Home 力学组入口
- `assets/simulations/projectile_motion/` 原版 PNG（含 measuringTape）
- `requirements/req-projectile-motion/` Phase 0–5 + ASSET_MAP + Visual QA 矩阵
- 测试：`test/projectile_motion/*`（31）
- 工具链：`tool/capture_projectile_*.js`、`tool/build_visual_manifest_projectile.py` 等

## Modified Files（本需求）

- `lib/projectile_motion/**`（model / view / painters / widgets / screens）
- `lib/screens/home_screen.dart`（入口）
- `assets/simulations/projectile_motion/`
- `test/projectile_motion/**`
- `tool/capture_projectile_*.js`、`tool/build_visual_manifest_projectile.py`、`tool/probe_projectile_*.js`
- `requirements/req-projectile-motion/**`
- `pubspec.yaml`（asset 目录）

## Remaining Limitations（P2 / 明确不迁）

1. Lab `KeypadLayer` 未移植（滑条/拖拽改同一 Property）
2. 本地 HTML 未 grunt 构建，ORIGINAL 来自发布版；以 1.1.0-dev.41 源码为准
3. Stats 屏不在默认入口
4. 无声音资源（源码无 `sounds/`）
5. Home 目录图标沿用工程统一 Material 入口风格（sim 内禁用 Material 冒充 PhET）

## Close Checklist

- [x] 用户确认项目结束并可 report
- [x] 单元/交互/生命周期测试 31 PASS
- [x] `dart analyze` CLEAN
- [x] ASSET_MAP Substituted = 0
- [x] FINAL_REPORT 定稿 · status → done
