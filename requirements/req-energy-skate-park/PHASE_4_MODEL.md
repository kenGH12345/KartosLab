# Phase 4 — Model / Physics Math Layer

> req-energy-skate-park · 2026-09-03

## 范围

从本地 PhET `energy-skate-park` 1.6.0-dev.2 移植 **核心物理/数学层** 到
`lib/energy_skate_park/`，不发明教材公式。

## 已移植

| 模块 | 源 | Dart |
|---|---|---|
| 常量 | `EnergySkateParkConstants.ts` + ScreenView scale | `esp_constants.dart` |
| 自然三次样条 | `numeric.spline` + `SplineEvaluation.ts` | `solver/hermite_spline.dart`, `spline_evaluation.dart` |
| 向量 | PhET `Vector2` 子集 | `model/esp_vec.dart` |
| 控制点 / 轨道 | `ControlPoint.ts`, `Track.ts` 关键 API | `control_point.dart`, `track.dart` |
| 滑板状态 | `SkaterState.ts` 能量 + update helpers | `skater_state.dart` |
| 滑板 | `Skater.ts` Properties 子集 | `skater.dart` |
| 预制轨道 | `PremadeTracks.ts` CP 坐标 | `premade_tracks.dart` |
| 动力学 | `EnergySkateParkModel.ts` stepEuler/Track/FreeFall/Ground/correctEnergy… | `solver/physics_solver.dart` |
| 时钟模型 | EventTimer 60 Hz + slow 每 3 帧 | `model/esp_model.dart` |

## 约定

- `thrust = 0`（Phase 4）
- 默认 `isStickingToTrack = true`（与 PhET 默认一致）
- 样条端点为 natural；`Thomas` ≡ `numeric.cLU`+`cLUsolve` 三对角情形
- `correctEnergy` / 离轨 / 摩擦 / 法向力按 TS 语义移植（含已知 heuristic / quirk）

## 测试

- `hermite_spline_test.dart` — 直线 / 抛物样条 / 端点 / 导数
- `premade_tracks_test.dart` — 抛物 CP = (−4,6),(0,0),(4,6)
- `energy_conservation_test.dart` — 无摩擦抛物轨长跑，总能量 |ΔE| &lt; 1e-2
