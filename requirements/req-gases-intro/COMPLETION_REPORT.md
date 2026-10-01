# COMPLETION_REPORT — Gases Intro

**日期**：2026-09-06（Layout fix + Asset Audit + View layout）  
**状态**：**未封板** — `status: view_reconstruction`

## 本轮完成

1. **P0 Layout**：修复 `RIGHT OVERFLOWED BY 11 PIXELS`（真正原因：225 面板宽被 margin/padding 吃掉；Particles 行固有宽过大）→ **[迁移布局 bug]**
2. **P0 Audit**：新增 `VIEW_ASSET_AUDIT.md`（Gauge / Thermometer / Handle≠Piston / Pump / Heater / Particles / Container）
3. **Layout**：`AspectRatio` + `SimulationViewport` + `ControlPanel(ListView)`；去掉 FixedBox→FittedBox 预溢出缩放
4. **文档**：更新 `VIEW_RECONSTRUCTION.md`、`ASSET_MAPPING.md`、`FUNCTIONAL_GAP_CLOSURE.md`、`BASELINE.md`、`GEOMETRY_CALIBRATION.md`
5. **Physics / Model**：未改

## 验证

```
flutter test test/gases_intro     → 15 passed
flutter analyze lib/gases_intro   → 0 issues
flutter build apk --debug / --release → 见 process.txt
```

## 分类用语

| 问题 | 标签 |
|---|---|
| 原版组件未迁 / 假仪器 | [迁移组件缺失] |
| 原版交互未保留 | [行为差异] |
| overflow / constraints | [迁移布局 bug] |
| **禁用** [视觉近似] | — |

## 仍开放（不封板）

- Collision Counter 可拖工具、完整 Stopwatch UI
- 仪器像素级对照（需 original.png / flutter.png）
- Interaction QA 真机清单
- P2 背景/主题校准（结构正确后再做）
