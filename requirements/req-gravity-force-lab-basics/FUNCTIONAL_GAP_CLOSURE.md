# FUNCTIONAL_GAP_CLOSURE — Gravity Force Lab: Basics

## Implemented (MVP)

| Feature | Status |
|---|---|
| F = G m1 m2 / r², G=6.67430e-11 | ✅ |
| Defaults m1/m2/x1/x2 / checkboxes | ✅ |
| Constant size + density radius | ✅ |
| Snap 100 / ±5000 / minSep 200 | ✅ |
| Step push on radius growth | ✅ |
| Piecewise force arrows + labels toFixed(1) | ✅ |
| Distance km label | ✅ |
| Puller PNG frames 1–31 | ✅ |
| Mass NumberPicker | ✅ |
| Checkbox panel | ✅ |
| Reset All | ✅ |
| Home card under 物理→力学 | ✅ |
| NineGrid + FittedBox 768×464 | ✅ |

## Explicitly skipped

| Feature | Note |
|---|---|
| A11y / PDOM / Voicing | Skip（与 tambo 音效分开） |
| Vibration (`tappi`) | Skip |
| Scientific notation UI | Basics has none |
| Cross-sim ISLC framework | Intentionally not extracted |

## Open gap — Audio

| Feature | Status | Evidence |
|---|---|---|
| Sound / Sonification | **[源码确认：原版存在音效 → 待迁移]** | `GFLBScreenView.js` + `tambo` + GFL sounds；见 `AUDIO_ANALYSIS.md` |

待迁移（禁止自制音效）：

- Force：`ContinuousPropertySoundClip` + `saturated-sine-loop-trimmed.wav`
- Mass：`MassSoundGenerator` + `rubber-band-v3.mp3`
- Boundary：`MassBoundarySoundGenerator` + inner/outer clips
- NumberPicker：源码为 `nullSoundPlayer`（保持静音）

## Known soft gaps

- Puller image intrinsic size approximated (~120×100 before 0.45 scale); rope attach is layout-faithful, not pixel-perfect to PhET.
- Force label uses `toFixed(1) + " N"` (spec) rather than full “Force on m1 by m2 = …” sentence.
