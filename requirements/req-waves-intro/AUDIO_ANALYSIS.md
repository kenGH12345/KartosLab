# AUDIO_ANALYSIS — Waves Intro / Wave Interference (lock `31ebfd7`)

**取证 SHA**：`wave-interference@31ebfd71800f065c2da3bc8d402cb65eafe65932`  
**waves-intro**：`1.2.0-dev.0` · `supportsSound: true` · `dependencies.json` → `tambo`

---

## 架构（Flutter）

```
WaveModel (WavesIntroModel)
  → WavesIntroAudioState   // mute / volume / Play Tone / Sound Effect / meter levels / ducking
  → WavesIntroAudio        // sim-local renderer (audioplayers)
```

- Painter **不**控制 audio。
- **未**引入全局 Audio framework（工程无无统一 joist/tambo 层；本 sim 本地实现）。
- 未改 common API。

---

## 结论

### **[源码确认：原版存在音效 → 已按 lock 补齐关键路径]**

| 检查 | 结果 | 标记 |
|---|---|---|
| WI `sounds/` | 有；已拷入 `assets/phet/waves_intro/sounds/` | [源码一致] |
| SoundClip / soundManager / tambo | lock 有 | [源码一致] |
| Intro `audioEnabled: true` | 本地 mute/volume 等价 | [行为一致] |

---

## 触发映射（lock → Flutter）

| Trigger | lock | Flutter | 标记 |
|---|---|---|---|
| Wave generator button | `Scene.waveGeneratorButtonSound` | Water always；Light when Sound Effect off；Sound no-op | [行为一致] |
| Water drop absorbed | random clip + amp→rate；ducking×0.9 | `playWaterDrop` + 4 clips | [行为一致] |
| Speaker membrane | oscillator +→− crossing；tone 时 maxVol=0 | `_syncSpeaker` | [行为一致] |
| Light beam loop | button∧running∧soundEffect | `_syncLight` | [行为一致] |
| Play Tone | `SineWaveGenerator` OscillatorNode f×1000 Hz | PCM sine loop + rate（非自制样本资产） | [行为一致] |
| Wave meter sonification | `getWaveMeterNodeOutputLevel` + saw/smooth | state levels + loop clips + ducking 0.3 | [行为一致] |
| Slider click | slider-click-v2 L/R | `playSliderClick` on A/f change | [行为一致] |
| Mute / master volume | joist soundManager | `AudioState.muted` + `masterVolume` + Level bar | [行为一致] |
| Reset / pause / dispose | stop generators | `stopAll` / `dispose` | [行为一致] |

---

## 屏特异

| Screen | 控件 | 默认 |
|---|---|---|
| Sound | Play Tone checkbox | false |
| Light | Sound Effect checkbox | false |
| All | Mute + Volume slider + Level meter | vol=0.7 |

---

## 标记汇总

- 存在性：**[源码确认：原版存在音效]**
- 接线：**[行为一致]**（meter / volume / mute / screen-specific / lifecycle）
- Play Tone 发生器：**[行为一致]**（算法振荡器，非自制 mp3）
- 全局 tambo：**[有意差异]**（sim-local，未建全局 framework）
