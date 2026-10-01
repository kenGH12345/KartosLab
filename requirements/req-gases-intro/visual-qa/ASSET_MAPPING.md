# ASSET_MAPPING — Gases Intro（View reconstruction）

权威审计：`../VIEW_ASSET_AUDIT.md`

| 元素 | 源码类型 | Flutter Asset | Flutter Component |
|---|---|---|---|
| Pressure gauge | GaugeNode **geometry** | — | `PressureGaugeInstrument` / `GaugePainter` |
| Thermometer | ThermometerNode **geometry** | — | `ThermometerInstrument` / `ThermometerPainter` |
| Particles | ShadedSphere **geometry** | — | `paintShadedSphere` in play area |
| Bicycle pump | BicyclePumpNode **Path** | — | `BicyclePumpWidget` / `BicyclePumpPainter` |
| Left-wall handle | HandleNode **geometry** | — | play_area handle + hit（**非活塞**） |
| Container | BaseContainerNode **geometry** | — | `PlayAreaPainter` walls/clip |
| Heater flame/ice | **PNG** | `assets/gases_intro/flame.png`, `iceCubeStack.png` | `HeaterCoolerWidget` |
| Erase | **SVG** | `assets/gases_intro/eraser.svg` | toolbar |
| Reset | **PNG** | `assets/gases_intro/resetArrow.png` | `_TimeBar` |
| Piston | **不存在于 Gases Intro** | — | 禁止添加 |

规则：有真实 PNG/SVG → 直接用；仅源码为 geometry → CustomPainter。
