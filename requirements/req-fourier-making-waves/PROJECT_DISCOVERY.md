# Phase 0 — Project Discovery · Fourier Making Waves

> 需求：`req-fourier-making-waves`  
> 日期：2026-09-03  
> 阶段：Phase 0 完成 · **无阻塞决策** · 自动进入 Phase 1  
> 标记：`[已确认]` 有源码/配置/目录依据 · `[推测]` 有依据的推断 · `[待确认]` 证据不足

---

## 0. 结论摘要

1. **KARTOSLAB** 是独立 Flutter App（包名 `kratos`，SDK `^3.11.1`），入口 `lib/main.dart` → `HomeScreen`。[已确认]
2. Home **无** Fourier Making Waves 入口。光学与波动组已有几何光学 / 色觉 / 波的干涉 / 声波 / Normal Modes / 电磁波。[已确认 `lib/screens/home_screen.dart`]
3. 原版是 PhET HTML5/TypeScript **`fourier-making-waves` 1.2.0-dev.0**（本地 `package.json`）。`dependencies.json` 注释写 `1.1.0-dev.9` + sha `04217277…`——**以 `package.json` version 为准记录本地树版本**，不替换源码。[已确认]
4. **三个 joist Screen**（顺序即默认）：`DiscreteScreen` → `WaveGameScreen` → `WavePacketScreen`。各自 `() => new *Model()`，**不共享 Model**。[已确认 `fourier-making-waves-main.ts:21-25`]
5. 数学模型在本地源码中**完整可确认**：`Waveform.getAmplitudes` + `getAmplitudeFunction` 六式 + Wave Packet 高斯/`carrier×envelope` + Wave Game 振幅向量相等。**不需要**教科书补公式，不停自动推进。[已确认]
6. 推荐落点：`lib/fourier_making_waves/`（与 `normal_modes/`、`density/` 同级）。
7. 业务 PNG 极少：`images/` 仅 home icon 的 TS 封装；图表/滑条为 scenery 矢量。[已确认]
8. 当前工程 **无** Fourier 旧实现。Phase 12 无归档对象。

---

## 1. 当前 KARTOSLAB 工程

### 1.1 根与入口

| 项 | 值 | 证据 |
|---|---|---|
| 工作区 | `KartosLab/`（包名 `kratos`） | `pubspec.yaml:1` |
| SDK | `^3.11.1` | `pubspec.yaml:22` |
| 入口 | `lib/main.dart` → 横屏锁定 → `HomeScreen` | `lib/main.dart` |
| 路由 | `Navigator.push(MaterialPageRoute)` | `home_screen.dart` |
| 依赖 | `flutter_svg ^2.3.0` · `audioplayers ^6.7.1` | `pubspec.yaml` |
| AGENTS.md 路径 | 写 `c:\workspace\kratos`，与本工作区不一致 | 以本仓库为准 [已确认] |

### 1.2 `lib/` 学科目录

已有：`common/` `circuit/` `forces/` `optics/` `color_vision/` `sound/` `radio_waves/` `wave_interference/` `magnetism/` `astronomy/` `density/` `chemistry/` `cck_ac_virtual_lab/` `normal_modes/`

**无** `fourier*`。[已确认 glob]

### 1.3 Home 注册

本 sim 归入 **物理 → 光学与波动** 新卡「Fourier: Making Waves」（傅里叶合成 · 波包）。

三屏导航：一张 Home 卡 + `KratosTabbedScreen`（Normal Modes / Density 先例）。**不**改 Navigation 架构。

### 1.4 common（L0）与本 sim 相关度

| L0 | 路径 | 本 sim | 判定 |
|---|---|---|---|
| NineGridLayout | `common/widgets/nine_grid_layout.dart` | 页面级外壳 | **复用**。中间格放整个 PhET ScreenView（局部坐标） |
| KratosTabbedScreen | `common/widgets/kratos_tab_bar.dart` | 三 Screen | **复用** |
| SimulationClock | `common/simulation_clock.dart` | Discrete 心跳 | **不套**。固定 1/60 忽略墙钟 dt；原版 `step(dt)` 用墙钟。本 sim 用 Ticker 传墙钟 dt（同 Normal Modes / CCK） |
| TimeControlBar | `common/widgets/time_control_bar.dart` | Play/Pause/Step | **不套外观**。仅 Discrete 且仅 SPACE_AND_TIME |
| KratosSlider / ComboBox / Radio | | 振幅滑条 / waveform / domain | **不套外观**；逻辑对照源码自绘 |
| SnapshotChart / ScenarioManager | | | **不用**（无 scenario） |
| chart/ | `common/chart/` | | **评估后可能局部复用坐标系概念**；Fourier 图表几何对齐 PhET ChartRectangle，优先 sim 内 Painter |

G3：Fourier 级数、谐波滑条、波包高斯、Wave Game 匹配均为 **第 1 个 Fourier 用户**，留在 sim 内。

### 1.5 已有 sim 架构范式（最近邻）

| 范式 | 代表 | 数据流 |
|---|---|---|
| 可变 Model + 墙钟 Ticker | Normal Modes / CCK | tick 改 Model |
| ChangeNotifier Controller | Kepler / Density | 命令进 Controller |

最近邻：**可变 Model（振幅/波形/domain/t）+ 纯函数采样 Solver + Controller + RenderData + Painter**。

推荐：

```
DiscreteModel / WaveGameModel / WavePacketModel（SSOT，各自独立）
  + solver 纯函数（getAmplitude / synthesize / presets / gaussian）——单测
  + Controller（Ticker 仅 Discrete；交互 / reset / notify）
  + Render DTO + Chart Painters
```

### 1.6 tests / assets / schemas

- `test/`：无 fourier。
- `assets/`：无需大量新 PNG；矢量自绘；可选复制 home icon。
- `schemas/`：**不做假 scenario schema** [有意差异]。
- `requirements/`：本需求 `req-fourier-making-waves/`。

---

## 2. 原版 PhET 调查

### 2.1 身份

| 项 | 值 |
|---|---|
| 官网 | https://phet.colorado.edu/sims/html/fourier-making-waves/latest/fourier-making-waves_all.html |
| 本地 | `phet sourses/fourier-making-waves-main/fourier-making-waves-main` |
| name / version | `fourier-making-waves` / **`1.2.0-dev.0`** [已确认 `package.json`] |
| dependencies.json 注释 | `1.1.0-dev.9` · sha `04217277c1990c5937b3bc6114d78afbb4a2dc79` · 2024-12-09 [已确认；不覆盖 package.json] |
| 入口 | `js/fourier-making-waves-main.ts` |
| 文档 | `doc/model.md` · `doc/implementation-notes.md` · `doc/qa-notes.md` |
| 字符串 | `fourier-making-waves-strings_en.json` |
| 无本地 `.git` | commit 精确对齐上游 [待确认]；以树内文件为准 |

### 2.2 Screen 数量与导航 [已确认]

```typescript
const screens = [
  new DiscreteScreen( ... ),   // 默认
  new WaveGameScreen( ... ),
  new WavePacketScreen( ... )
];
```

| # | Screen | Model | 共享？ |
|---|---|---|---|
| 0 | Discrete | `DiscreteModel` | 否 |
| 1 | Wave Game | `WaveGameModel` | 否 |
| 2 | Wave Packet | `WavePacketModel` | 否 |

Screen 切换：Joist 保留各 Screen 实例；Flutter 对齐 Normal Modes——各 Controller 随 Home StatefulWidget 生命周期创建/dispose，Tab 切换不销毁 Model（除非离开 Home）。Reset 不重新 `new Model`，而是调用 `reset()`。[已确认源码 reset 模式；Flutter lifecycle [推测] 对齐 Normal Modes]

### 2.3 数学 / 时钟一句话

| Screen | 数学 SSOT | 时钟 |
|---|---|---|
| Discrete | `Waveform` 振幅预设 + `Σ Aₙ·sin/cos(...)` | 仅 SPACE_AND_TIME：`t += dt*1000*0.001`；STEP=50ms |
| Wave Game | 双 FourierSeries；`|g−a|≤0` | **无**物理 t；仅反馈 UI 动画 |
| Wave Packet | 高斯 A(k)；有限和 / 无限 `exp(-x²/(2σₓ²))·sin\|cos(k₀x)` | **t≡0**；无 play |

### 2.4 关键否定项（避免臆测）

- **无独立相位 φ 参数**；仅 SeriesType SIN/COS。[已确认]
- **Infinite Harmonics ≠ n→∞ 级数**；是硬编码折线。[已确认]
- Discrete Wave Packet 预设 ≠ Wave Packet Screen；前者是振幅查表。[已确认]
- Wave Game **不是**波形点集 RMS 评分。[已确认]

---

## 3. Phase 0 决策

| 决策 | 结论 | 是否阻塞 |
|---|---|---|
| 代码落点 | `lib/fourier_making_waves/` | 否 |
| Home | 光学与波动新卡 | 否 |
| common API | 不修改 | 否 |
| 核心数学 | 本地源码完整 | 否 · **不暂停** |
| scenario JSON | 不做 | 否 · 有意差异 |

**Phase 0 状态：完成 · 自动进入 Phase 1**
