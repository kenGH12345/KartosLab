# AUDIO_MAP — Quantum Wave Interference

> 不沿用 Build an Atom 结论。本 sim 单独审计。

---

## Original audio files

| File | Format | Event | PhET usage | Flutter |
|---|---|---|---|---|
| `sounds/snapshotCaptured.mp3` | mp3 | Snapshot captured successfully | `SoundClip` gain/level **0.4** | 复用原 mp3；触发于 `takeSnapshot` 成功 |

无 wav / ogg / aac 源文件。

`package.json` → `simFeatures.supportsSound: true`。

---

## Shared / framework sounds（受限项）

| Event | Source | Local file? | Flutter plan |
|---|---|---|---|
| Snapshot delete / erase | `sharedSoundPlayers.get('erase')` | ❌ in sim | 若 KartosLab 已有 erase shared sound则复用；否则记为受限 / 静音策略与项目一致 |
| Probe / ruler drag | `SoundDragListener` / `SoundKeyboardDragListener` | ❌ | L0 drag ticks if available |
| Slit position / plot value change | `ValueChangeSoundPlayer` | ❌ | optional value-change ticks |
| Default buttons | often `nullSoundPlayer` when custom sound used | — | avoid double-sounds |

**tambo** 依赖锁 SHA `d9ee906…` — 本地 **MISSING**。

---

## Sound design credit

`QuantumWaveInterferenceConstants.CREDITS.soundDesign` = `''`（空）  
`sounds/license.json` notes: created by Matthew Blackman。

---

## Implementation rules

1. Snapshot 成功 → 必须播放原版 `snapshotCaptured.mp3`（或等价解码）。
2. 不得用无关 UI 音效冒充快门声。
3. 无粒子撞击专用原音频 → 不要发明“量子哔哔”音效。