# AUDIO_ANALYSIS · Fourier Making Waves

> 日期：2026-09-03  
> 范围：本地源码取证 **only** · **本轮不实现音频**  
> 标记：`[已确认]` / `[待确认]`

---

## 1. 结论摘要

| 项 | 结论 |
|---|---|
| 用户可听 Fourier 振荡音频 | **仅 Discrete 屏** `[已确认]` |
| Wave Game | 仅 UI 反馈音效（正确/错误），**无** Fourier 谐波振荡器 `[已确认]` |
| Wave Packet | **无** sound 引用 `[已确认]` |
| 本轮实现 | **不实现** · 见 FUNCTIONAL_GAP_CLOSURE |
| KARTOSLAB 统一音频架构 | **[待确认：工程级 Audio architecture]** · 有 `audioplayers` 依赖，但无跨 sim 的统一 SoundManager 封装；**禁止改 common** |

---

## 2. Discrete · FourierSoundGenerator

| 项 | 证据 |
|---|---|
| 类 | `js/discrete/view/FourierSoundGenerator.ts`（及 SoundBox / FourierSoundEnabledCheckbox） |
| 挂载 | `DiscreteScreenView` → `soundManager.addSoundGenerator(...)` |
| 启用默认 | `FourierSeries.soundEnabledProperty = false` |
| 频率来源 | 每谐波 `harmonic.frequency = 440 · n` Hz → `OscillatorSoundGenerator({ initialFrequency })` |
| 振幅来源 | `amplitudesProperty` → 映射到 oscillator output level；总音量 `soundOutputLevelProperty`（默认 0.5） |
| waveform 来源 | 振荡器正弦系；振幅向量来自当前 FourierSeries（含预设/custom） |
| start/stop | `soundEnabledProperty` true → 各 oscillator `.play()`；false → `.stop()` |
| pause/resume | 与 soundEnabled / 全局 audioManager 门控相关；细节待 OscillatorSoundGenerator 深挖 `[待确认]` |
| dispose | 随 Screen/soundManager 生命周期；PhET-iO 细节 `[待确认]` |
| Screen 切换 | Joist 保留 Screen；声音是否跨屏静音依赖 soundManager 策略 `[待确认]` |

---

## 3. Wave Game

- `correctEmitter` / `incorrectEmitter` → 短暂反馈音（vegas/nullSoundPlayer 模式）
- **不**把 answer/guess 振幅合成为可听 Fourier 音

---

## 4. Flutter 后续实现建议（未执行）

1. 不修改 `lib/common`。  
2. 若实现：在 `lib/fourier_making_waves/` 内用 `audioplayers` 或平台 tone 生成，**仅 Discrete**。  
3. 必须对照 `FourierSoundGenerator` 振幅→电平映射；禁止猜测。  
4. 标为独立子任务，需用户确认工程级 Audio 策略后再做。

---

## 5. 状态

| 标记 | 含义 |
|---|---|
| 取证 | **完成** |
| 实现 | **[待实现]** · 有意延后（用户本轮明确要求） |
| BLOCKED | 无（除非未来要求统一 Audio architecture） |
