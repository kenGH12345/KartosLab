# Phase 3 — Architecture Plan · Fourier Making Waves

> 需求：`req-fourier-making-waves`  
> **无重大阻塞决策**（不改 common API / Theme / Navigation；数学 SSOT 已确认）  
> 自动进入 Phase 4

---

## 1. 包结构

```
lib/fourier_making_waves/
  fmw_constants.dart
  fmw_colors.dart
  fmw_strings.dart
  model/
    domain.dart
    series_type.dart
    equation_form.dart
    waveform_kind.dart
    harmonic.dart
    fourier_series.dart
    axis_description.dart
    discrete_model.dart
    wave_game_model.dart
    wave_game_level.dart
    wave_packet.dart
    wave_packet_model.dart
  solver/
    amplitude_function.dart      # getAmplitudeFunction 六式
    waveform_presets.dart        # Waveform.getAmplitudes + infinite polylines
    fourier_synthesis.dart       # createSumDataSet / harmonic datasets
    wave_packet_math.dart        # gaussian A(k), infinite packet, envelope
    amplitudes_generator.dart    # Wave Game 出题
  controller/
    discrete_controller.dart
    wave_game_controller.dart
    wave_packet_controller.dart
  render/
    fmw_render_data.dart
    fmw_render_builder.dart
    fmw_mvt.dart                 # math → screen
  painters/
    amplitudes_chart_painter.dart
    harmonics_chart_painter.dart
    sum_chart_painter.dart
    wave_packet_charts_painter.dart
  widgets/
    fmw_page_shell.dart          # NineGrid + 局部 1024×618
    fmw_chart_stack.dart
    amplitude_sliders.dart
    discrete_control_panel.dart
    wave_game_controls.dart
    wave_packet_control_panel.dart
    fmw_time_control.dart
  screens/
    fourier_making_waves_home.dart
    discrete_screen.dart
    wave_game_screen.dart
    wave_packet_screen.dart
```

测试：`test/fourier_making_waves/`

---

## 2. 数据流（SSOT）

```
User / Ticker
  → Controller
    → Model（唯一业务状态）
      → Solver 纯函数 → samples / match / gaussian
        → RenderBuilder → RenderData
          → Painter（只画，不算 Fourier）
```

禁止：
- CustomPainter 内算 Σ Aₙ sin
- Widget 另存一份 amplitudes
- AnimationController 直接 tween 波形点
- Screen 重复持有 t / amplitudes

---

## 3. 三 Screen Model 边界

| Screen | Model | Clock |
|---|---|---|
| Discrete | `DiscreteModel` | Ticker → `step(wallDt)` 仅 SPACE_AND_TIME |
| Wave Game | `WaveGameModel` | 无物理 t；可选 UI 动画 timer |
| Wave Packet | `WavePacketModel` | 无 |

切换 Tab：**不**共享状态。离开 `FourierMakingWavesHome` → dispose 全部 Controller → 再进重新初始化。

---

## 4. 与其他 sim 的关系

- **不**抄 Normal Modes Verlet / Density 浮力。
- **复用** `KratosTabbedScreen` + NineGrid 模式（页面壳）。
- **不**改 `lib/common` API。
- **不**修改其他 simulation 文件（Home 仅追加入口）。

---

## 5. 有意差异

| 项 | 处理 |
|---|---|
| AppBar / Tab / NineGrid | 保留 KARTOSLAB |
| PhetFont / Source Sans | 系统/工程字体 |
| Harmonic 音频 | Phase 4–10 可先静音；标有意差异或后续加 |
| PhET-iO / tandem | 不做 |
| Keyboard 全套 | 核心指针交互优先；键盘标待确认/有意差异 |

---

## 6. 暂停条件检查

| 条件 | 是否触发 |
|---|---|
| 修改 common API | 否 |
| 修改全局 Theme / Navigation | 否 |
| 新跨 sim framework | 否 |
| Model ownership 不明 | 否 · 三独立 Model |
| 核心数学无法确认 | 否 |

**不暂停。**

---

## Phase 3 状态：完成 · 自动进入 Phase 4（Model / State + 测试）
