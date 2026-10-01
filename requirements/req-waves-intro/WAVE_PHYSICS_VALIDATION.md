# WAVE_PHYSICS_VALIDATION

## Lattice.step

[已确认] 内点：

```
value = m1*2 - m2 + WAVE_SPEED_SQUARED * (neighborSum - 4*m1)
```

`WAVE_SPEED_SQUARED = 0.25`。边界吸收公式按 Lattice.ts 左右上下四边移植。

测试：`test/waves_intro/lattice_step_test.dart` — 脉冲传播、能量非零、c² 常量。

## 点源

[已确认]

```
waveValue = -sin(t * 2π f + phase) * amplitude * 1.2
```

脉冲：`timeSincePulseStarted > period` → 0，然后 `pulseFiring=false`。

测试：`point_source_test.dart`、`continuous_pulse_test.dart`。

## 波长

[已确认] `λ = waveSpeed / frequency`（各 scene 单位系内）。

测试：`wavelength_test.dart`。

## TemporalMask

[已确认] 已移植 `matches` / `set` / `prune`。用于抑制数值伪影、光场景“变黑”。

## Sound particles

[已确认] 21×21 网格 + 梯度力 + 热噪声；Flutter 用 **seeded Random(42)** 保证可复现。[推测] 视觉与 PhET 粒子抖动不完全逐帧一致属预期。

## 未验证 / 简化

| 项 | 标记 |
|---|---|
| 水滴水龙头延迟发波 | [待实现] 本期水场景直接点源 |
| 光波长→颜色 LUT | [视觉近似] 分段光谱近似 |
| EventTimer 与 UI 60fps 插值 | [已确认] 模型侧有 interpolationRatio；热图使用 interpolated 值 |
| WI deps.json SHA vs clone | [待确认] mismatch 已记录 |
