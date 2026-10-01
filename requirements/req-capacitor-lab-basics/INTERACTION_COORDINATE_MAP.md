# INTERACTION_COORDINATE_MAP — Capacitance Phase 4

> 2026-09-12 · 坐标 / 命中 / 吸附对照 PhET 源码

## Battery VSlider

| Item | Source | Flutter |
| --- | --- | --- |
| Track | `Dimension2(8, 0.55 * graphicHeight)` | `BatteryVoltageSlider` track 8 × 0.55×scaledH |
| Thumb | 35×20; fill `rgb(255,237,53)`; stroke `rgb(191,191,191)` | same |
| Center | `graphic.center + (5, 12)` | `batteryCenter + Offset(5,12)` |
| Range / step | [−1.5,1.5]; `roundSymmetric(v·20)/20` | `CapacitorPhysics.constrainBatteryVoltage` |
| End snap | \|V\|<0.15 → 0 | `Battery.endDragSnap` |

## Switch

| Item | Source | Flutter |
| --- | --- | --- |
| Hinge | `CircuitSwitch.getSwitchHingePoint` | `CircuitGeometry.switchHingePoint` |
| Tip | polar `0.9×SWITCH_WIRE_LENGTH` at angle | `switchTipEndFromAngle` |
| BATTERY angle | top −3π/4; bottom 3π/4 | `angleForConnection` |
| OPEN angle | top −π/2; bottom π/2 | same |
| Drag | view→model atan2(hinge) | `SwitchGestureLayer` |
| Snap | abs(angle): left BATTERY, center OPEN | `snapConnectionFromAbsAngle`（right→OPEN，Capacitance 无 bulb） |
| Tip highlight | yellow fill while controlled | `switchTipHighlighted` |
| Cue | `!switchUsed` | `CircuitRenderData.showSwitchCueArrows` |

## Plate handles

| Handle | Attach (model) | Drag | Quantize |
| --- | --- | --- | --- |
| Separation | `x+0.3w`, `y−sep/2−h`, z=0 → MVT | ΔY → `sep += 2·viewToModelΔY(−dy)` | `round(5e3·s)/5e3` |
| Area | back-right `x+w/2`, `y−sep/2−h`, `z+d/2` | ΔX → `w += 2·viewToModelΔX` | `sqrt(round(1e5·w²)/1e5)` |
| Area rotation | `−π/2 + yaw/2` | — | — |
| Arrow color | `rgb(61,179,79)` | `PlateHandlesPainter` | — |

## Panels / toolbox / voltmeter

| Item | Layout |
| --- | --- |
| View control | `rightTop = (1024−10, 10)`; fill `rgb(255,245,237)` |
| Toolbox | below view control `+ (0,10)` ≈ `top: 220`; icon scale 0.17 |
| Bar meters | `left ≈ topWire.left − 40`; `top = 10`; `minWidth 580` |
| Voltmeter body | MVT(body); scale 0.336; drag via viewToModel delta |
| Probes | MVT; rotate(−yaw); scale 0.25; independent drag |
| Return | body ∩ toolbox.eroded(40) → `voltmeterVisible=false` |
| Reset All | `right−30, bottom−30`, radius 25 |

## [待确认]

- Plate area drag 使用 ΔX 简化；完整 PhET `LinearFunction` 对角逆映射未逐像素对齐
- Toolbox `top` 用固定 210 近似 AlignBox 高度（非测量 viewControl.bottom）
- Voltmeter 读数矩形位置为近似；`measuredVoltage` 仍为 null/"?"（Phase 5）
