# PHASE_1_MODEL_PHYSICS_REPORT.md

> Phase: **1 — Model + Physics**  
> Date: 2026-09-18  
> Source: bending-light `1.3.0-dev.0` / SHA `a85e9507…`  
> Flutter UI: **0**（本 Phase 禁止）

---

## 1. Model mapping

见 `PHASE_1_MODEL_MAPPING.md`。三屏 Model 分离：`IntroModel` / `PrismsModel` / `MoreToolsModel`。

## 2. Physics mapping

| Module | Dart | Notes |
|---|---|---|
| Fresnel s-pol | `physics/fresnel.dart` | R,T 公式原样 |
| Intro scalar Snell | `physics/intro_snell.dart` | **独立**于 Vector |
| Vector Snell | `physics/vector_snell.dart` | Wikipedia vector form |
| Dispersion | `physics/dispersion_function.dart` | Sellmeier + air + mix |
| Prism intersection | `physics/prism_intersection.dart` | edges + arcs |
| Wave | `physics/wave_math.dart` + `LightRay.getCosArg` | cos(kx−ωt+φ) |
| Ray tracing | `PrismsModel._propagateTheRay` | depth≤50, power\<0.001 |

## 3. Intro implementation

- θ1 = laserAngle − π/2；θ2 = asin((n1/n2) sin θ1)  
- TIR / R≥0.005 / #296 全反射不建透射  
- incident / reflected / transmitted `LightRay`  
- IntensityMeter absorb（圆传感器简化交点）  
- time step 1e-16 / 0.5e-16  

## 4. Prism implementation

- 6 prototypes（triangle…diverging-lens）  
- 最近交点 → VectorSnell → 反射（可选或 TIR）+ 折射递归  
- 介质判定：交点后微移 + 前方交点数奇偶  
- 白光多波长 / manyRays 偏移已接入 Model  

## 5. Fresnel

`getReflectedPower` / `getTransmittedPower`；Prisms 侧 clamp01。

## 6. Dispersion

见 `DISPERSION_MODEL.md`。XYZ 白光渲染表未移植（P2 view）。

## 7. Wave

`LightRay.getCosArg` ≡ `WaveMath.cosArg`；`getWaveValue` = √P · cos(phase+π)。

## 8. Sensors

`IntensityMeter` / `VelocitySensor` / `WaveSensor`+`Probe` model state；无 ProbeNode UI。

## 9. Reset

见 `RESET_BEHAVIOR.md`。

## 10. Test count

**50** tests · `flutter test test/bending_light/` → **All passed**

| File | Coverage |
|---|---|
| fresnel_test.dart | R+T, angles, n1=n2 |
| intro_snell_test.dart | normal, TIR, critical, media |
| vector_snell_test.dart | normal, TIR, n1=n2 |
| dispersion_test.dart | 650nm, units, trend |
| wave_test.dart | phase, dt, v=c/n |
| ray_tracing_test.dart | intersect, recurse, rotate |
| prism_geometry_test.dart | prototypes |
| model_integration_test.dart | Intro/MT/Prisms + reset |

## 11. dart analyze

`dart analyze lib/bending_light test/bending_light` → **No issues found**

## 12. Known limitations

1. Intensity meter 交点用圆距离，非 kite Shape 双交点中点（行为近似，Phase 3 可精化）  
2. Diverging-lens `containsPoint` 为近似；交点仍走边+弧  
3. SemiCircle 半平面 contains 为近似  
4. White-light **XYZ/Bresenham 渲染**未做（Model 已可多波长传播）  
5. WaveParticle 粒子推进未移植（WebGL/Canvas 路径属 View）  
6. `MediumColorFactory` 为占位 ARGB（精确色 Phase 4）  
7. Model 使用 `ChangeNotifier`（flutter/foundation），无 Widget  

## 13. P0

**无** — 核心 Intro Snell / Vector Snell / Fresnel / Dispersion / 递归 / Reset / 测试均通过。

## 14. P1

| ID | Issue |
|---|---|
| P1-1 | Intensity absorb 几何与 PhET kite 不完全一致 |
| P1-2 | 部分棱镜 contains 近似可能影响 “laser in prism” 判定边角 |

## 15. P2

| ID | Issue |
|---|---|
| P2-1 | XYZ/D65 白光表未移植 |
| P2-2 | Medium 精确配色 |
| P2-3 | WaveParticle |

---

## Gate checklist

- [x] Model implemented  
- [x] Physics implemented  
- [x] Intro tests PASS  
- [x] Prism tests PASS  
- [x] Fresnel tests PASS  
- [x] Dispersion tests PASS  
- [x] Wave tests PASS  
- [x] Reset tests PASS  
- [x] Model integration tests PASS  
- [x] dart analyze clean  
- [x] Flutter UI = 0  
- [x] Home 未修改  

## Verdict

**PHASE 1 COMPLETE**

未宣布 READY。未进入 Phase 2。
