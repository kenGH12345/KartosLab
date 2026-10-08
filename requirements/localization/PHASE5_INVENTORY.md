# PHASE5_INVENTORY — Optics / Waves / Quantum

> Coverage of user-visible strings migrated in PHASE 5. Status: LOCALIZED (legacy bags → ZH + loc.*).

| Simulation | File (representative) | String | Type | Visible | A11y | Existing Key | Proposed Key | Chinese | Status |
|---|---|---|---|---|---|---|---|---|---|
| bending-light | bl_strings.dart | title | title | Y | | optics.* | optics.bendingLight | 光的折射 | LOCALIZED |
| bending-light | control_widgets.dart | indexOfRefraction | label | Y | | optics.indexOfRefraction | same | 折射率 (n) | LOCALIZED |
| bending-light | substance.dart | air/water/glass… | material | Y | | — | optics.air… | 空气/水/玻璃… | LOCALIZED |
| bending-light | control_widgets.dart | normal / ray / wave | control | Y | Y | optics.normal | same | 法线/光线/波 | LOCALIZED |
| color-vision | color_vision_strings.dart | tabs | tab | Y | | — | optics.colorVision | 单灯泡/RGB | LOCALIZED |
| wave-on-a-string | woas_strings.dart | mode/end/controls | control | Y | Y | waves.* / physics.* | same | 手动/振荡/脉冲… | LOCALIZED |
| waves-intro | waves_intro_strings.dart | scenes/controls | control | Y | Y | waves.* | same | 水波/声波/光… | LOCALIZED |
| normal-modes | normal_modes_strings.dart | modes/phase | label | Y | | waves.phase | same | 简正模式/相位 | LOCALIZED |
| fourier-making-waves | fmw_strings.dart | title/tabs | title | Y | | waves.period | same | 傅里叶：合成波 | LOCALIZED |
| sound | (prior ZH) | — | — | Y | | — | — | already ZH | LOCALIZED |
| radio-waves | (prior ZH) | — | — | Y | | — | — | already ZH | LOCALIZED |
| quantum-measurement | qm_strings.dart | tabs/modes | tab | Y | Y | quantum.* | same | 硬币/光子/自旋… | LOCALIZED |
| quantum-wave-interference | qwi_strings.dart | tabs/slits | control | Y | Y | quantum.* | same | 实验/高强度/单粒子 | LOCALIZED |
| quantum-coin-toss | quantum_measurement_strings.dart | coin UI | control | Y | | quantum.* | same | 经典/量子硬币… | LOCALIZED |

### Dynamic / parameterized

| Pattern | Example ZH | Units/symbols |
|---|---|---|
| Wavelength readout | 波长：500 nm | nm kept |
| Frequency | 频率：2 Hz | Hz kept |
| Probability | 概率：0.25 | numeric |
| Angle | 入射角：30° | ° kept |
| Hits count | 击中 N | int |
| Zoom | 缩放 N | int |

### Exceptions (allowed English / symbols)

λ, f, T, A, φ, θ, n, c, ψ, \|ψ⟩, nm, Hz, eV, RGB (channel letters), SG axis labels (SGz/SGx), ↑↓ symbols.
