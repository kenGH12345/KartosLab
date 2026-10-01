# PHASE_2_CORE_PLAY_AREA_REPORT.md

> Phase: **2 — Core Play Area**  
> Date: 2026-09-18  
> Source: bending-light `1.3.0-dev.0`  
> Home: **未接入** · READY: **未宣布**

---

## 1. Architecture

```
lib/bending_light/
  transform/bl_mvt.dart          # PhET MVT
  view/medium_colors.dart       # MediumColorFactory against white
  view/*_play_area.dart         # Intro / Prisms / More Tools
  components/
    laser_pointer_widget.dart   # LaserPointerNode vector recreation
    play_area_painters.dart     # Medium / Rays / Prism / Angles
  screens/
    bending_light_scene_shell.dart  # 834×504 FittedBox
    intro_screen.dart / prisms_screen.dart / more_tools_screen.dart
    bending_light_hub.dart
  bending_light_demo_main.dart  # flutter run -t … (不改 Home)
```

Model → `ListenableBuilder` → CustomPaint / LaserPointerWidget.  
Painters **只消费** `model.rays` / prisms / media — **不**重算 Snell。

## 2. Coordinate transform

`BlMvt` = `createSinglePointScaleInvertedYMapping`：

| Screen | viewOrigin | scale |
|---|---|---|
| Intro | (286, 252) | `504 / modelHeight` |
| Prisms | (148, 209) | 同 |
| More Tools | (388, 252) | 同 |

API: `worldToScreen` / `screenToWorld` / delta helpers.  
Viewport: 834×504 + `BendingLightSceneShell` 等比 fit。

## 3. Laser implementation

`LaserPointerWidget` 按 scenery-phet `LaserPointerNode`：

- body 70×30 · nozzle 10×25 · button r=12 · cornerRadius 2  
- 灰金属渐变 + 红电源键  
- tip @ `emissionPoint`（MVT）· 朝向 pivot  
- Intro/MT：拖 body → `setAngle`（Q2 clamp）  
- Prisms：body 平移 · knob 旋转 · `showKnob`  

**非** `laser.png` / Material icon。

## 4. Medium implementation

`IntroMediumPainter` + `MediumColors`（Air/Water/Glass/Diamond 插值，对齐 `MediumColorFactory` white profile）。  
水平界面 y=0 · 虚线法线（`showNormal`）。

## 5. Ray rendering

`RaysPainter` / `PrismScenePainter`：`LightRay.tail→tip` 经 MVT 画线；alpha ∝ `powerFraction`。  
TIR：Model 不产出 transmitted → View 自然无折射线。

## 6. Normal rendering

Intro：竖直虚线过原点。  
Prisms：`showNormals` 时画 `intersections` 短法线。

## 7. Prism rendering

`PrismScenePainter`：半透明填充 α=0.5 · 轮廓 · 多边形/圆/半圆。  
Demo：默认 square + 激光置于左侧指向棱镜。

## 8–10. Screen integration

| Screen | Play area | Notes |
|---|---|---|
| Intro | Air/Water · laser drag · debug bar | Air/Water ↔ Water/Air TIR |
| Prisms | square prism · translate/rotate laser | Normals toggle |
| More Tools | Glass bottom · laser+rays | Placeholder: Sensors/Wave Phase 3+ |

## 11. Interaction

Gesture → `screenToWorld` / `viewToModelDelta` → Model → `updateModel()` → repaint.  
禁止在 Gesture 内算 Snell。

## 12. Reset

Debug **Reset** → `model.reset()` → Listenable 刷新 View。  
Prisms Reset 后重新 seed demo prism。

## 13. Tests

**61 passed** · `dart analyze` **No issues found**

| Suite | Count |
|---|---|
| Phase 1 physics/model | 50 |
| BlMvt | 5 |
| Widget integration (3 screens) | 3 |
| Screenshot capture | 3 |

## 14. Runtime result

| Target | Result |
|---|---|
| Android emulator | **不可用**（`flutter devices` 仅 Windows / Chrome / Edge） |
| Widget pump Intro/Prisms/MoreTools | PASS · 无 exception |
| Demo entry | `flutter run -t lib/bending_light/bending_light_demo_main.dart` |

## 15. Screenshot result

生成于 `requirements/req-bending-light/visual-qa/`（Canvas 直绘 medium+rays+prism；**不含** LaserPointer overlay）：

- `PHASE_2_INTRO.png` — 入射/反射/折射 + 法线 + Air/Water ✓  
- `PHASE_2_PRISMS.png` — square + ray path  
- `PHASE_2_MORE_TOOLS.png` — Air/Glass + rays ✓  

完整含激光的 UI 需本机 `flutter run` 上述 demo target。

## 16. P0

**无**

## 17. P1

**无**（坐标、射线、介质、棱镜、激光组件、三屏创建/销毁均满足 Gate）

## 18. P2

| ID | Issue |
|---|---|
| P2-1 | Angle arcs 仍为激光角示意，未接完整 `AngleNode` 读数 |
| P2-2 | 截图未含 LaserPointer 图层 |
| P2-3 | 控制面板 / toolbox / sensors / wave / wavelength UI 未做 |
| P2-4 | knob 为自绘棕圆，未挂 `knob.png` asset |
| P2-5 | 激光命中区 / 精确与 scenery 像素级对齐待 Visual QA |

## 19. Remaining work (Phase 3+)

- 完整 control panel / toolbox / sensors  
- Wave 可视化 · TimeControl  
- Wavelength UI  
- Home 接入（物理 → 光学与波动）  
- Visual QA 1:1  

---

## Gate

- [x] P0 = 0  
- [x] P1 = 0  
- [x] tests PASS (61)  
- [x] dart analyze clean  
- [x] 三屏可创建/显示（widget）  
- [~] Android runtime — 设备不可用；以 widget + demo main 替代  
- [x] Screenshots 已生成  
- [x] Home 未修改  

## Verdict

**PHASE 2 COMPLETE**

未宣布 READY · 未接 Home · 未进入最终 Visual QA。
