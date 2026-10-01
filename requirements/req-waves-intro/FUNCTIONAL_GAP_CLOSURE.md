# FUNCTIONAL_GAP_CLOSURE

## 已实现

### 核心波（锁定，未改）
- FDTD / Lattice / c=0.5 / λ=v/f / continuous / pulse / droplet → **[物理一致]**

### 工具 / Side / Intensity / Audio
- 见既有条目；本轮**未改** Wave Model 核心

### 本轮 · Visual / Interaction Reconciliation
- [x] `WaveRenderVisibility`：Control → State → Visibility → Visual（单一真相）
- [x] `WaterScreenView` / `SoundScreenView` / `LightScreenView` + `WavesIntroShell`
- [x] Sound **Waves / Particles / Both**
- [x] 主 sim 放大；右栏分段；底栏 Viewpoint/Play/Slow/Reset
- [x] Speaker / water_drop 资产；水龙头/激光几何源
- [x] Graph / Screen / tools 开关驱动主区组件出现

**问题分类**：[迁移架构/视图问题]（已修主路径）— **不要**标成 [视觉近似]

## 待实现 / 有意差异

| 项 | 状态 |
|---|---|
| scenery-phet Faucet/Laser 像素资产 | [待确认] |
| Intensity graph panel | [有意差异/非 Intro] |
| Perspective3D 完整 | [视觉近似] |
| 旧统一 Wave UI 残余（`waves_intro_controls.dart` 未挂载） | [有意差异] 遗留文件可删 |

## 测试

`flutter test test/waves_intro` — **56 passed**（含 `view_binding_test`）  
`flutter analyze lib/waves_intro test/waves_intro` — **0 issues**
