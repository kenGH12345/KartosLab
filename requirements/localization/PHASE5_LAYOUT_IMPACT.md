# PHASE5_LAYOUT_IMPACT

## Optics (Bending Light / Color Vision)

| Area | Risk | Mitigation | Status |
|---|---|---|---|
| Side panels / material dropdown | ZH longer than EN | Intrinsic ComboBox + BlStrings | Monitor P2 |
| Ray / Normal / Angles row | short ZH | No expansion | OK |
| Prism Objects / Environment | label width | LayoutSpec parent constraints | OK |
| Color Vision tabs | 单灯泡 / RGB 灯泡 | Existing tab bar | OK |

## Waves

| Area | Risk | Mitigation | Status |
|---|---|---|---|
| WOAS mode/end segmented | 固定端/自由端 | Component labels | OK |
| Waves Intro control column | 频率/振幅 | Existing sliders | OK |
| Graph / axis labels | 电场 | Axis text only | OK |
| Fourier tabs | 离散/波包/游戏 | Tab bar | OK |

## Quantum

| Area | Risk | Mitigation | Status |
|---|---|---|---|
| QM tabs | 硬币/光子/自旋/布洛赫球 | Tab width | P2 possible on narrow |
| QWI slit configuration | longer ZH | Dropdown intrinsic | P2 |
| Probability / state labels | formula + ZH | Keep symbols | OK |
| Polarizing beam splitter | newline label | `偏振\n分束器` | OK |

## Rules applied

- No page-level magic `Positioned` for ZH fit
- No device-specific coordinates
- No physics/model/renderer changes for label length

## P0 / P1 / P2

- P0 = 0
- P1 = 0
- P2 = QWI configuration dropdown width; QM Bloch tab on 375px; full ZH Golden capture
