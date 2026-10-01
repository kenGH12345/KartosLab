# ASSET_RECONSTRUCTION — Gases Intro

**日期**：2026-09-06  
**范围**：仅 View / Assets / Component Geometry（**不改** Physics Model）  
**权威**：gases-intro 壳 + gas-properties Ideal @ `10c7c08` + scenery-phet

---

## 总判

Ideal / Gases Intro **运行时仪器几乎全部是 scenery-phet 几何组件**，不是 PNG 表盘/泵体。  
唯一必须接入的位图：`flame.png`、`iceCubeStack.png`（HeaterCooler）、`eraser.svg`（Erase）、`resetArrow.png`（Reset All）。

此前 Flutter 用 Container/Text/Slider/简化圆冒充 Gauge/Pump/Heater → 分类为 **[迁移组件缺失]** / **[资源迁移缺口]**，**不得**标 [视觉近似]。

---

## 完整映射表

| Asset / Geometry | Source | Node / Consumer | Flutter path | Flutter Consumer | Status |
|---|---|---|---|---|---|
| **GaugeNode** (geometry) | `scenery-phet/js/GaugeNode.ts` | `PressureGaugeNode` | N/A geometry | `painters/gauge_painter.dart` | [迁移组件缺失]→fixed |
| Pressure post gradient | `PressureGaugeNode.createPostGradient` | PressureGaugeNode | N/A geometry | `gauge_painter.dart` post | [迁移组件缺失]→fixed |
| Pressure range 0..20000 kPa | `PressureGauge.ts` / query `maxPressure` | GaugeNode range | N/A | needle linear map on `displayedPressureKpa` | [源码一致] |
| **ThermometerNode** | `scenery-phet/js/ThermometerNode.ts` | `GasPropertiesThermometerNode` | N/A geometry | `painters/thermometer_painter.dart` | [迁移组件缺失]→fixed |
| Thermometer range 0..1000 K | `Thermometer.ts` DEFAULT_RANGE | ThermometerNode | N/A | fill 0..1000; null→0 | [源码一致] |
| Fluid #850e0e / #ff7575 | ThermometerNode defaults | ThermometerNode | N/A | thermometer painter | [源码一致] |
| **ShadedSphereNode** | `scenery-phet/js/ShadedSphereNode.ts` | ParticlesNode | N/A geometry | `painters/shaded_sphere.dart` | [迁移组件缺失]→fixed |
| Heavy/Light colors | `GasPropertiesColors.ts` | Particle + icons | constants | shaded sphere main/highlight | [源码一致] |
| **BicyclePumpNode** Path | `scenery-phet/js/BicyclePumpNode.ts` | `GasPropertiesBicyclePumpNode` height=230 | N/A geometry | `BicyclePumpWidget` / `BicyclePumpPainter` | [迁移组件缺失]→fixed |
| Pump +50 / stroke | `GasPropertiesBicyclePumpNode` | numberOfParticlesProperty | N/A | `model.pump()` | [行为一致]（Model 不改） |
| **flame.png** | `scenery-phet/images/flame.png` | `HeaterCoolerBack` | `assets/gases_intro/flame.png` | `HeaterCoolerWidget` | [资源迁移缺口]→fixed |
| **iceCubeStack.png** | `scenery-phet/images/iceCubeStack.png` | `HeaterCoolerBack` | `assets/gases_intro/iceCubeStack.png` | `HeaterCoolerWidget` | [资源迁移缺口]→fixed |
| HeaterCooler bucket + VSlider | `HeaterCoolerFront/Back.ts` | GasPropertiesHeaterCoolerNode | N/A geometry + PNG | `HeaterCoolerWidget` | [迁移组件缺失]→fixed |
| **HandleNode** (left wall) | `scenery-phet/js/HandleNode.ts` | IdealGasLawContainerNode | N/A geometry | `play_area_painter.dart` | [迁移组件缺失]→fixed |
| Container walls Path | `IdealGasLawContainerNode.ts` | IdealGasLawScreenView | N/A geometry | `play_area_painter.dart` | [迁移组件缺失]→fixed |
| **eraser.svg** | `scenery-phet/images/eraser.svg` | EraserButton | `assets/gases_intro/eraser.svg` | Erase `IconButton` | [资源迁移缺口]→fixed |
| **resetArrow.png** | `scenery-phet/images/resetArrow.png` | ResetAllButton | `assets/gases_intro/resetArrow.png` | Reset All `TextButton.icon` | [资源迁移缺口]→fixed |
| Piston PNG | — | **unused by Ideal** | — | — | N/A（Ideal 无活塞） |
| Marketing screenshots | gases-intro/assets/*.png | docs only | visual-qa/ | QA only | N/A runtime |
| phetGirlLabCoat.png | gas-properties/images | OopsDialog only | — | 不迁入 play area | N/A |
| Speaker / faucet / etc. | scenery-phet/images | **unused by Ideal** | — | — | N/A |

---

## 「Piston」澄清

源码 **无 piston PNG/几何**。体积操纵 = **左墙 + HandleNode**（rotation −π/2, scale 0.4）。  
将矩形墙线冒充活塞 → **[迁移组件缺失]**（已改为 HandleNode-like grip）。

---

## pubspec

```yaml
flutter:
  assets:
    - assets/gases_intro/
```

---

## 禁止策略

| 禁止 | 原因 |
|---|---|
| 普通 Flutter Circle 冒充 GaugeNode | 缺 tick/span/needle 映射 |
| ElevatedButton 冒充 BicyclePump | 缺 body/shaft/hose/handle 几何与拖动语义 |
| 面板 Slider 冒充 HeaterCooler | 缺 stove + flame/ice 资源 |
| 无证据自创 particle shading | 必须跟 ShadedSphereNode stops |
| 标 [视觉近似] 掩盖缺组件 | 本文件用 [迁移组件缺失] / [资源迁移缺口] |
