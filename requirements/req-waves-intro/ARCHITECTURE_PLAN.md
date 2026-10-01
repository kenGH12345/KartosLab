# ARCHITECTURE_PLAN

## 约束

- 一切业务在 `lib/waves_intro/` — **禁止** 在 `lib/common` 建跨 sim 波动框架 [已确认 用户约束]
- 不改其他 simulation / common API / Home taxonomy（仅 ADD 光学与波动条目）
- 不发明波动方程；Lattice.step 忠实移植

## 分层

```
WavesIntroHome (TabBar Water/Sound/Light)
  └─ WavesIntroMediumScreen (embedded)
       ├─ WavesIntroModel (ChangeNotifier + Ticker + EventTimer 累加器)
       │    └─ WaveScene (1× Lattice + TemporalMask [+ SoundParticles])
       ├─ LatticePainter / SoundParticlesPainter / CenterLineGraphPainter
       └─ WavesIntroControls
```

## 布局

对齐 GFLB / Curve Fitting：`NineGridLayout` 外壳 + `FittedBox` 768×464 内容区。

## 状态默认

| 属性 | 默认 | 标记 |
|---|---|---|
| isRunning | true | [已确认] |
| showGraph | false | [已确认] |
| disturbance | continuous | [已确认] |
| amplitude | 8 | [已确认] |
| frequency | range midpoint | [已确认] |
| soundView | waves | [已确认] |
