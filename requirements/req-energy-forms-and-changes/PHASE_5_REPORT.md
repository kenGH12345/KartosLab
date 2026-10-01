# Phase 5 Report — Static Render (continued)

> 2026-09-10

## PHASE: 5
## STATUS: SUBSTANTIAL PROGRESS

### 1. Completed
- Intro: Beaker (water/olive oil) + BeakerPainter（透视椭圆/刻度/蒸汽）
- Intro: 4 thermometers + storage rack；MVT 锚点摆位
- Intro: 默认布局 [iron][brick][L burner][R burner][water][oliveOil]（源码 spot 取整）
- Intro: EC 图标层（energyThermal PNG）；Energy Symbols 开关半透明
- Systems: 三列 carousel 元件本体 PNG（bicycleFrame/generator/teaKettle/fan01…）
- Systems: Energy legend；belt 示意线
- Assets: 仅用已解码 105 PNG；HeaterCooler 火焰 / FaucetNode / flame **[BLOCKED D类]**

### 2. Files
- `common/model/beaker.dart`, `thermal_container.dart`, `energy_chunk_wander.dart`
- `intro/model/*` 重写；`intro/painters/beaker_painter.dart`；`intro/screens/intro_screen_body.dart`
- `systems/model/systems_model.dart`；`systems/screens/systems_screen_body.dart`

### 3. Evidence
- `[已确认]` beaker W=0.085 H=W×1.1；majorTick=H×0.95/3
- `[已确认]` ground spot round×1000；burner indices 2,3
- `[BLOCKED]` scenery-phet HeaterCooler/FaucetNode/flame — 行为用 slider 等价，外观未复刻

### 4. Tests: 22 passed
### 5. Analyze: 0 error（info/warning only）
### 6. Visual: 可运行；未做 runtime overlay（缺本地 PhET 构建）
### 7. Blocked: scenery-phet 三件套 D 类
### 8. Limitations: EC 分布算法简化；beaker 3D 纹理为矢量近似（原版亦多为 path）
### 9. Next: Phase 6 交互打磨 → Phase 7 动画精修
