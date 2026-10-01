# visual-qa / ASSET_MAPPING

| PhET | Flutter asset | 标记 |
|---|---|---|
| `images/waterScreenIcon.png` | `assets/phet/waves_intro/waterScreenIcon.png` | [已确认] |
| `images/soundScreenIcon.png` | `assets/phet/waves_intro/soundScreenIcon.png` | [已确认] |
| `images/lightScreenIcon.png` | `assets/phet/waves_intro/lightScreenIcon.png` | [已确认] |
| `sounds/squishier-button-v3-007.mp3` | `assets/phet/waves_intro/sounds/` | [源码一致] |
| `sounds/water-drop-v5*.mp3`（4） | 同上 | [源码一致] |
| `sounds/speaker-pulse-v4.mp3` | 同上 | [源码一致] |
| `sounds/light-beam-loop-v5-eq-out-bass.mp3` | 同上 | [源码一致] |
| `sounds/wave-meter-saw-tone.mp3` | 同上 | [源码一致] |
| `sounds/wave-meter-smooth-tone.mp3` | 同上 | [源码一致] |
| `sounds/organ-for-meter-loop.mp3` | 同上（资产就位；UI 未暴露音色切换） | [源码一致]/[有意差异] |
| `sounds/ethereal-flute-for-meter-loop.mp3` | 同上 | [源码一致]/[有意差异] |
| `sounds/slider-click-v2-{left,right}.mp3` | 同上 | [源码一致] |

`pubspec.yaml`：`assets/phet/waves_intro/`（含 sounds）。

几何绘制（非位图）：Water side fill、Lattice 热图、Light screen 列、Wave meter chart。

Home 列表卡 Material icon — [推测] 可接受。
