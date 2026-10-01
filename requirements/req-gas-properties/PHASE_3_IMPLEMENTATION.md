# PHASE 3 — FLUTTER IMPLEMENTATION · Gas Properties

> **状态**：四屏 View + Home 注册完成；**未进入 Phase 4 Validation**  
> **代码**：`lib/gas_properties/{controller,transform,render,painters,widgets,screens}/`  
> **入口**：Home → 热学与气体 → **Gas Properties**

---

## 1. Screens

| Screen | 实现 | 说明 |
|--------|------|------|
| Ideal | ✅ | Hold Constant ×5、墙拖拽暂停重分布、泵/热冷/仪表 |
| Explore | ✅ | 同壳 + Wall Velocity + 左墙做功 |
| Energy | ✅ | 左直方图/Avg Speed、Injection T、collision toggle、固定宽 |
| Diffusion | ✅ | 左右 Settings、Divider、COM、Flow、Normal/Slow |
| Navigation | ✅ | TabBar 四屏；各 Screen 独立 Controller/Model |
| Home | ✅ | `热学与气体` 组注册 |

---

## 2. Architecture

```
Ticker (GasSimulationController)
  → IdealGasLawModel.stepRealTime / DiffusionModel.stepRealTime
  → notifyListeners
  → GasRenderState.fromModel
  → GasPlayAreaPainter / HistogramPainter / DiffusionPainter
```

| 层 | 路径 |
|----|------|
| Controller | `controller/gas_simulation_controller.dart` |
| Transform | `transform/gas_coordinate_transform.dart`（MVT 0.040, origin 645/475） |
| Render | `render/gas_render_state.dart` |
| Painters | `painters/gas_play_area_painter.dart`, `histogram_painter.dart`, `shaded_sphere.dart` |
| Shell | `widgets/gas_ideal_family_shell.dart`, `gas_diffusion_shell.dart` |
| Home | `screens/gas_properties_home.dart` |

**未改** Phase 2 `solver/` 核心算法；Diffusion 仅追加 mass/radius/T setters（UI 需要，对齐 PhET Settings 行为）。

---

## 3. Interactions

| 交互 | 行为 |
|------|------|
| Pump tap / 上拖 | `pump(50)` / `pump(10)` |
| Heat/Cool press | `setHeatCool(±1)` → 松手 0 |
| Heavy/Light spinner | ±10 |
| Hold Constant | Ideal only；禁用条件对齐 Phase 1 |
| Left wall drag | Ideal：pause+resize；Explore：做功动画 |
| Play/Pause/Step/Reset | Clock + model.reset |
| Energy zoom | `energySampling.zoomIn/Out` |
| Diffusion divider | Remove / Reset |
| Oops | phetGirlLabCoat + 文案；OK 清除 |

---

## 4. Visual

| 元素 | 方式 |
|------|------|
| Particles | ShadedSphere CustomPainter 合批 |
| Container / lid / handle | CustomPainter |
| Thermometer / Pressure gauge | CustomPainter |
| Pump | 简化程序绘制（非 scenery-phet 几何 1:1） |
| Histograms | 19-bin CustomPainter |
| Oops icon | `assets/gases_intro/phetGirlLabCoat.png` |
| Layout | 1008×618 logical + uniform fitScale |

---

## 5. Performance

- 粒子：**单** CustomPainter，无 per-particle Widget
- 目标 60 FPS；1000 粒子依赖 spatial partition（Phase 2）
- Phase 4 需在真机/模拟器压测 100/500/1000

---

## 6. Validation（本阶段）

```bash
flutter analyze lib/gas_properties lib/screens/home_screen.dart  → 0 issues
flutter test test/gas_properties/                                → Phase 2: 23 PASS + home smoke
```

截图对照 PhET HTML：**留给 Phase 4**（本环境未自动截图）。

---

## 7. Known Differences（诚实清单）

| 项 | 说明 |
|----|------|
| Pump 几何 | 简化块状 UI，非 BicyclePumpNode 完整矢量 |
| Heater/Cooler | 按钮式按住，非火焰/冰块位图完整复刻 |
| Stopwatch 拖拽 | 未做可拖秒表节点（Tools 勾选预留） |
| Collision Counter | 面板数字，非独立可拖米色计数器 |
| Lid 开口拖拽 | 仅炸盖后 Return Lid；细粒度 lid width 拖未做 |
| Diffusion 坐标 | 左下→MVT 右下换算；布局与 PhET 像素级可能有偏移 |
| Preferences | 未单独做 Pressure Noise 设置页（Model 默认 noise on） |
| Pixel-perfect | 面板间距/字体非逐像素对齐 PhET |

---

## 8. Phase 4 准备

1. 并排 PhET HTML 与 Flutter 截图四屏  
2. 交互清单逐项点检（VALIDATION.md）  
3. 1000 粒子 FPS  
4. 补齐泵/加热器视觉与 lid drag（按优先级）

**Phase 3 完成。等待确认后进入 Phase 4 — Validation。**
