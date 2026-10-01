# BASELINE — Waves Intro visual-qa

## Status

- Flutter PNG：`screenshots/{water,sound,light}_{default,interaction}.png`（view reconciliation 后重生）
- 原版 reference：`reference/{water,sound,light}_phet.png`
- 差异主因已归类为 **[迁移架构/视图问题]**（见 `VIEW_ARCHITECTURE_RECONCILIATION.md`），不是「数学缺失」

## Layout（对齐原版层级）

```
Top tabs (Home)
Main: [C/P] [Sim 420²] [Right: Tools | Freq/Amp | Viz | Audio]
      [Graph strip if on]
Bottom: Top/Side · Play/Step · Normal/Slow · Reset
```

## Screen-specific

| Screen | Source | Field | Viz extras |
|---|---|---|---|
| Water | Faucet + drop asset | water tint / side blue | Graph, Tape, Timer, Meter, Top/Side |
| Sound | speaker_MID.png | gray | Waves/Particles/Both, Play Tone |
| Light | Laser geometry | **black** | Screen column, Sound Effect, spectrum track |

## Control → Visual

开关必须改变主区组件（由 `WaveRenderVisibility` 保证），不能只改 checkbox。
