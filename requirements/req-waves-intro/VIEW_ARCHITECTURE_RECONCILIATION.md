# VIEW_ARCHITECTURE_RECONCILIATION — Waves Intro

**问题分类：【迁移架构/视图问题】**（不是「视觉近似」）

对照：PhET WI lock `31ebfd7` + waves-intro reference PNG  
`visual-qa/reference/{water,sound,light}_phet.png`

---

## 根因

先前 Flutter 把三屏压成「统一 Control Panel + 统一 Wave Canvas」，  
控件变更多半只改 checkbox state，**主实验区不形成 Control → Visualization 闭环**。

原版是：

```
Control → Model State → Layer Visibility → Screen-specific Visual Component
```

---

## 目标架构（已落地）

```
WavesIntroModel          // 物理 + showGraph/showScreen/soundViewType/tools（未改 FDTD）
    ↓
WaveRenderVisibility     // 唯一派生层，禁止 Widget 另存 showWaves
    ↓
WaterScreenView | SoundScreenView | LightScreenView
    ↓
WaveSimulationCanvas + source nodes + tools overlay + LightScreenPainter
```

Shell：

```
[Disturbance C/P]  [Main Sim Area]  [Right Control Column]
                   [Graph strip]
[Bottom: Viewpoint | Play/Step | Normal/Slow | Reset]
```

---

## Control → Visual 绑定表

| Control | State | Visibility | Visual |
|---|---|---|---|
| Graph | `showGraph` | `vis.showGraph` | `WaveGraphStrip` |
| Screen (Light) | `showScreen` | `vis.showLightScreen` | `LightScreenPainter` 列 |
| Waves / Particles / Both | `soundViewType` | `showWaves` / `showParticles` | Lattice +/ Particle painters |
| Play Tone | `audioState.isTonePlaying` | audio renderer | tone |
| Sound Effect | `audioState.soundEffectEnabled` | audio renderer | light loop |
| Tape / Timer / Meter | `tools.*` | `showMeasuringTape` 等 | overlay components |
| Top / Side | `viewpoint` + `rotationAmount` | `showTopLattice` / `showWaterSideView` | lattice vs water side |
| Continuous / Pulse | `disturbanceType` | source behavior | left icon toggle |
| Source button | `buttonPressed` | faucet/speaker/laser | screen-specific source |

**禁止**：Widget 本地 `bool showWaves` 与 Model 双写。

---

## Screen-specific

| Screen | Source | Field bg | Extra |
|---|---|---|---|
| Water | Faucet geometry + `water_drop.png` | water blue tint | Side View 水面 |
| Sound | `speaker_MID.png` (lock) | gray medium | Waves/Particles/Both |
| Light | Laser geometry | **black** | Screen 强度列 + spectrum slider track |

共享：WaveModel / tools / audio；**不**强迫同一 Painter。

---

## 布局校准

| 量 | 旧 | 新 | 标记 |
|---|---|---|---|
| layout | 768×464 | **960×560** | [迁移架构/视图问题] 已修 |
| wave area | 340 | **420** | 主区域优先 |
| control column | ~200 单长卡 | **168** 分段 Panel | Tools / Params / Viz / Audio |
| bottom bar | 挤在右卡 | **独立底栏** | 对齐原版 |

---

## Assets

| 资源 | 来源 | 标记 |
|---|---|---|
| `speaker_MID.png` | WI lock images/speaker | [源码一致] |
| `water_drop.png` | WI images | [源码一致] |
| Faucet / Laser | scenery-phet（无 WI PNG）→ 几何重建 | [行为一致]/源码 geometry |
| Toolbox icons | 几何绘制（非 Material straighten/timer） | [行为一致] |

---

## 验证

- `test/waves_intro/view_binding_test.dart` — Control→Visibility
- Screenshots 已重生：`visual-qa/screenshots/*`
- `flutter test test/waves_intro` / `flutter analyze lib/waves_intro` → 见 COMPLETION_REPORT

---

## 仍属视图 backlog（非 Wave Model）

| 项 | 标记 |
|---|---|
| scenery-phet FaucetNode / LaserPointerNode 像素级资产 | [待确认] 需 scenery-phet 抽图 |
| Measuring tape / stopwatch 全套 skeuomorphic chrome | [迁移架构/视图问题] 部分 |
| Length-scale arrow 精确样式 | [迁移架构/视图问题] 简化标签 |
| Perspective3D 旋转插值 | [视觉近似]（旋转中遮罩） |
