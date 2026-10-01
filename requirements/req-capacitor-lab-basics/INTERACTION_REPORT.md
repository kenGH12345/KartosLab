# INTERACTION_REPORT — Capacitance Phase 4

> 2026-09-12

## 已实现

1. **BatteryVoltageSlider** — 自定义竖滑条（非 Material Slider 皮肤），约束 0.05、松手 snap 0.15  
2. **SwitchGestureLayer** — tip/hinge 命中；拖角；松手 BATTERY↔OPEN；`markSwitchUsed`；cue 随 `switchUsed`  
3. **Plate handles** — Canvas 绿箭头+虚线；separation / area 改 C  
4. **CLBViewControlPanel / BarMeterPanel / ToolboxPanel** — checkbox、条宽∝value/2.7e-12、电压表拖出/回收  
5. **VoltmeterDragLayer** — body/probe 拖；隐藏时 toolbox icon；无测压算法  
6. **CapacitanceInteractiveScreenBody** — ListenableBuilder Stack + ResetAll → `model.reset()`  
7. **CircuitRenderData** — 开关位姿、把手锚点、电表可见性、条表值、按连接重建导线  

## 视觉标记

- `[原版资源一致]` voltmeter body/probes / switch cue PNG  
- `[布局已对齐]` 面板锚点按 ScreenView 公式（toolbox 高度近似）  
- `[动态绘制已对齐]` 开关 tip r=8、把手绿箭头、VSlider 尺寸色  

## 测试

`test/capacitor_lab_basics/interaction_test.dart` — slider / switch / plate / voltmeter / integration  

## [待确认]

见 `INTERACTION_COORDINATE_MAP.md` 末节。
