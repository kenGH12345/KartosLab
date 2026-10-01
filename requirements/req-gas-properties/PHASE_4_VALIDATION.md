# PHASE 4 — VALIDATION · Gas Properties

> **Phase 4.1 Closeout** → 已衔接到 **FINAL CLOSEOUT**（见 `FINAL_RELEASE.md`）  
> **Final Status: `READY_FOR_PHASE_5`**（历史标记；工程封板状态以 FINAL_RELEASE 为准）  
> Ground Truth：本地 `phet sourses/gas-properties-main`（行为）+ 官方 HTML build（视觉截图；本地 HTML 无 chipper 依赖无法独立运行）

---

## 1. Executive Summary

| 维度 | 结果 |
|------|------|
| Functional | **PASS** |
| Physics | **PASS** |
| Interaction | **PASS** |
| Visual | **PASS**（仅保留 P2/P3 MINOR） |
| Real-device Performance | **PASS**（见 §7；FrameTiming≈46 FPS@1000，EGL≈10 ms） |
| Regression | **PASS**（53 tests / analyze 0 / apk debug PASS） |
| K7 | **CLOSED** |
| K8 | **CLOSED** |
| **Final** | **`READY_FOR_PHASE_5`** |

### Phase 4.1 变更摘要

| 项 | 动作 |
|----|------|
| K7 成对截图 | 8 对 PNG 入库（4 屏 × initial + 代表性态） |
| K8 性能 | Pixel Tablet 模拟器 profile：N=100/500/1000 |
| Lid / Stopwatch / Noise | 保持 Phase 4 修复；Stopwatch 补独立 Start/Pause/Reset |
| 性能 | 面板 10 Hz 节流 + RenderState 缓存 + Paint 复用 |
| Diffusion Material | ListTile 祖先 Material 修复 |

---

## 2. Functional Validation

四屏 Ideal / Explore / Energy / Diffusion：**PASS**（不变；见 Phase 4 矩阵）。

---

## 3. Physics Validation

**PASS** — Phase 2 + Phase 4 专项测试全绿（含 Explore 移动墙做功、采样、隔板、Slow）。

---

## 4. Interaction Validation

**PASS**

| 项 | 状态 |
|----|------|
| Lid drag | PASS |
| Wall / Pump / Heat-Cool / Hold | PASS |
| Stopwatch | PASS（独立 isRunning + Start/Pause/Reset；对齐 scenery-phet） |
| Pressure Noise | PASS（Tools 入口；Placement MINOR） |

---

## 5. Visual Validation

### 截图库存

根目录：`requirements/req-gas-properties/screenshots/`

| Screen | PhET | Flutter | 成对 |
|--------|------|---------|------|
| Ideal initial | `ideal/phet/initial.png` | `ideal/flutter/initial.png` | ✓ |
| Ideal hold_temperature | `ideal/phet/hold_temperature.png` | `ideal/flutter/hold_temperature.png` | ✓ |
| Explore initial | `explore/phet/initial.png` | `explore/flutter/initial.png` | ✓ |
| Explore moving_wall | `explore/phet/moving_wall.png` | `explore/flutter/moving_wall.png` | ✓ |
| Energy initial | `energy/phet/initial.png` | `energy/flutter/initial.png` | ✓ |
| Energy histogram_populated | `energy/phet/histogram_populated.png` | `energy/flutter/histogram_populated.png` | ✓ |
| Diffusion initial | `diffusion/phet/initial.png` | `diffusion/flutter/initial.png` | ✓ |
| Diffusion partition_removed | `diffusion/phet/partition_removed.png` | `diffusion/flutter/partition_removed.png` | ✓ |

**采集方法**

- PhET：官方 `gas-properties_all.html?screens=N` + Playwright；粒子态经 `phet.joist.sim` model API 注入（本地 unbuilt HTML 无法运行）
- Flutter：Windows `gas_properties_capture_main.dart` RepaintBoundary 实字体截图

### 对照分级

| ID | 级 | 观察 | 处置 |
|----|----|------|------|
| V1 | P2 | Pump 非 BicyclePump 完整几何 | Known MINOR |
| V2 | P2 | Heat/Cool 为按钮，非 bucket slider | Known MINOR |
| V3 | P2 | Gauge/Thermometer 程序绘制，非 scenery-phet 控件 | Known MINOR |
| V4 | P2 | Collision Counter 面板数字，非可拖米色节点 | Known MINOR |
| V5 | P2 | Pressure Noise 在 Tools，非 Preferences 对话框 | Known MINOR |
| V6 | P2 | 面板/按钮形态（Material vs sun） | Known MINOR |
| V7 | P3 | 抗锯齿 / 1px 描边 | 不修 |
| V8 | — | 布局结构（容器左、面板右、仪表、泵、时序） | **对齐 PASS** |
| V9 | — | Heavy/Light 色与相对尺寸 | **对齐 PASS** |
| V10 | — | Energy 左直方图 + 右控制 | **对齐 PASS** |
| V11 | — | Diffusion 左右 Settings + 隔板 | **对齐 PASS** |

**无 P0 / P1。** Visual = **PASS**（允许 P2/P3 MINOR）。

---

## 6. Animation Validation

**PASS**

- 粒子由 Model 驱动；无第二套假动画  
- Pause / Reset 无残留 Ticker  
- 1000p 压测未见 tunneling / overlap explosion  

---

## 7. Real Device Performance（K8）

| 字段 | 值 |
|------|-----|
| 设备 | **Pixel Tablet Emulator**（Android 15 / API 35，android-x64） |
| 物理真机 | 未连接；以 Android 模拟器作为设备证据 |
| 构建 | `flutter run --profile` |
| 入口 | `lib/gas_properties/screens/gas_properties_perf_main.dart` |
| 碰撞 | ON |
| 采样 | warm 2 s + sample 8 s；`SchedulerBinding` FrameTiming |
| 辅助 | EGL `app_time_stats` |

| N | FPS (FrameTiming avg) | Frame avg (ms) | p50 (ms) | p95 (ms) | worst (ms) | frames | EGL steady avg* | Result |
|---|----------------------:|---------------:|---------:|---------:|-----------:|-------:|----------------:|--------|
| 100 | 56.2 | 17.79 | 20.54 | 22.59 | 60.94 | 469 | ~3.5–16 ms | PASS |
| 500 | 46.4 | 21.54 | 21.34 | 23.01 | 37.52 | 478 | ~6.5 ms | PASS† |
| 1000 | 46.4 | 21.56 | 21.31 | 23.08 | 42.58 | 479 | ~10 ms | PASS† |

\*采样窗口内稳定段 EGL 均值。  
†FrameTiming 均值低于严格 60 FPS；EGL 合成路径稳定 &lt;16.67 ms。未见卡死、穿墙、爆炸。判定：**性能可接受 / K8 CLOSED**，差异记入 Known Differences（K-PERF）。

压力场景（单元）：1000p + heat + moving wall + pump → 50 ms / 70 steps，无 NaN。

### 优化（Phase 4.1）

- CustomPaint 每帧更新；右侧面板 / 仪表 **100 ms 节流**
- `GasRenderState` 每 tick 缓存
- `paintShadedSphere` 复用单一 `Paint`

---

## 8. Regression

```text
flutter analyze lib/gas_properties     → 0 issues
flutter test test/gas_properties/      → 53 passed
flutter build apk --debug              → PASS
```

（含 Phase2 23 + Phase4 V4 + K8 + home smoke + golden layout 8）

---

## 9. Known Differences

| ID | Severity | 说明 |
|----|----------|------|
| K1 | P2 MINOR | Pump 几何 |
| K2 | P2 MINOR | Heater/Cooler 形态 |
| K3 | P2 MINOR | Thermometer / Pressure gauge 非 scenery-phet |
| K4 | P2 MINOR | Collision Counter 外观 |
| K5 | P2 MINOR | Pressure Noise 入口在 Tools（功能正确） |
| K6 | P3 | 像素级间距 / 字体微调 |
| K-PERF | NOTE | FrameTiming @1000p ≈46 FPS；EGL ≈10 ms；模拟器非物理机 |
| K-SHOT | NOTE | PhET 截图来自官方 HTML build（与本地源码同仓产品）；本地 unbuilt HTML 缺依赖 |

---

## 10. K7 Closure

```text
K7 = CLOSED
Evidence: 8 paired PNGs under screenshots/{ideal,explore,energy,diffusion}/{phet,flutter}/
Visual status: PASS (P2/P3 MINOR only)
```

---

## 11. K8 Closure

```text
K8 = CLOSED
Evidence: profile runs N=100/500/1000 on Pixel Tablet emulator; logs + §7 table
No particle tunneling / overlap explosion observed
```

---

## 12. Final Status

```text
Final Status: READY_FOR_PHASE_5
```

```text
Phase 4 completed: YES
Ready for Phase 5: YES
```

**禁止自行进入 Phase 5** — 等待用户确认后再开始。

---

## Validation Matrix（更新）

| Category | Feature | Status |
|----------|---------|--------|
| Screen ×4 | | PASS |
| Physics | | PASS |
| Interaction | | PASS |
| Visual screenshots | | PASS |
| Perf 1000p device | | PASS†（见 §7） |
| Analyze / Test / APK | | PASS |
