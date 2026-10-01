# BASELINE — Gases Intro Visual QA

**前置**：需成对 `original.png` / `flutter.png` 才可封视觉。  
错误分类只用：[迁移组件缺失] / [行为差异] / [迁移布局 bug]。

| # | 检查项 | Original | Flutter | Delta / Cause / Fix |
|---|---|---|---|---|
| 1 | overall viewport | layoutBounds 1008×618 | AspectRatio + shell | layout overflow 已修；像素 QA 待 |
| 2 | container | BaseContainerNode | PlayAreaPainter | 待对照 |
| 3 | left-wall handle（非活塞） | HandleNode | hit + painter | 禁止活塞几何 |
| 4 | pressure gauge | GaugeNode | GaugePainter | 待对照 |
| 5 | thermometer | ThermometerNode | ThermometerPainter | 待对照 |
| 6 | pump | BicyclePumpNode | BicyclePumpWidget | 待对照 |
| 7 | heater/cooler | HeaterCooler + PNG | Widget + assets | 待对照 |
| 8 | particle area | ParticlesNode | shaded spheres | 待对照 |
| 9 | control panel | IdealControlPanel | ListView 225px | overflow 根因已修 |
| 10 | bottom controls | TimeControlNode | _TimeBar | 待对照 |

[待确认：缺少原版 runtime 截图配对]
