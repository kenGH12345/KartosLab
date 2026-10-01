# PHASE_9_REPORT — Visual Fix

> 2026-09-12

## Asset 审计

| Asset | Flutter Path | 使用处 | 状态 |
|-------|--------------|--------|------|
| probeBlack | `…/probe_black.png` | VoltmeterDragLayer / StaticCircuitView | `[源码一致]` 原图 |
| probeRed | `…/probe_red.png` | 同上 | `[源码一致]` 原图 |
| voltmeterBody | `…/voltmeter_body.png` | 同上 | `[源码一致]` 原图 |
| switchCueArrow | `…/switch_cue_arrow.png` | cue overlays | `[源码一致]` 原图 |
| capacitanceScreenIcon | `…/capacitance_screen_icon.png` | Home Tab icon | `[源码一致]` 原图 |
| lightBulbBase | `…/light_bulb_base.png` | BulbNode + Light Bulb Tab | `[源码一致]` 原图 |

```text
Original Assets Reused = 6
Substituted Assets = 0
```

Home 卡片图标仍为 Material `Icons.battery_charging_full_rounded`——**KARTOSLAB Home catalog 既有惯例**（非 sim 内 UI），记为 `[有意差异]` vs PhET HTML homeScreenIcon。

## 本阶段修正

- **Plate area 拖拽**：接入 `PlateAreaDragHandler`（PhET `LinearFunction` 对角反解），去掉 Phase 4 简化 ΔX → `[源码一致]`
- **Battery 渐变**：`createGradient` 二次 blend stops 对齐 `BatteryGraphicNode.js` → `[视觉已对齐]`（原 `[视觉近似]`）
- 电流箭头颜色对齐 `ClbColors.currentElectronsArrow` / `currentConventionalArrow` / `redColorblind`

## 视觉判定（相对 PhET HTML）

| 区域 | 判定 |
|------|------|
| 1024×618 canvas + BG rgb(153,193,255) | `[视觉已对齐]` |
| MVT scale=12000 pitch=30° yaw=−45° | `[源码一致]` |
| Battery / Plates / Wires Canvas | `[视觉已对齐]`（电池渐变 stops 已对齐源码） |
| Probe / Voltmeter / Cue PNG | `[原版资源一致]` + `[视觉已对齐]` scale/yaw |
| Switch + 三态 | `[行为一致]`；tip 几何 `[视觉已对齐]` |
| Plate charges / E-field | `[源码一致]` 算法；像素密度 `[视觉近似]` |
| Plate area drag LinearFunction | `[源码一致]` |
| Light bulb glass/filament/halo | `[视觉近似]`；底座 PNG `[原版资源一致]` |
| Current indicators | `[行为一致]`；位置用导线中点 `[视觉近似]` vs batteryNode.right 测算 |
| TimeControl / Stopwatch | `[行为一致]`；控件皮肤为文本按钮 `[有意差异]` vs scenery-phet |
| Control panels | `[行为一致]`；非 Material Card 冒充 PhET panel 几何 `[视觉近似]` |

运行时与官方 URL 的像素级 diff：**未在本机浏览器自动化截图** → 记 `[待确认]`（需人工对照 https://phet.colorado.edu/sims/html/capacitor-lab-basics/latest/capacitor-lab-basics_en.html）。
