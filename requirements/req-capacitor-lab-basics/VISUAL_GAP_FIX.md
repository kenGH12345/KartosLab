# VISUAL_GAP_FIX — 对照用户截图（移植 vs 原版）

> 2026-09-12 · 用户图一/二 = Flutter；图三/四 = PhET 原版

## 根因（已修）

| 问题 | 原因 | 修复 |
|------|------|------|
| 右侧巨大米色空面板 | `Transform.scale` 不改变 layout size，toolbox 按 405×502 占位 | 显式 `SizedBox` + 缩放后的 Image 尺寸 |
| 电表缺探针 / Voltage? | 仅放了 body PNG | 对齐 `VoltmeterIconNode`：body+红黑探针+读数 |
| 缺 `0.30 pF` 读数 | BarMeter 未显示 pico 文本 | ×1e12 + 2 位小数 |
| 缺 Separation / Plate Area 标签 | PlateHandlesPainter 无 DragHandleValueNode | 补标签与数值 |
| 电池无 1.5 V / 0 / −1.5 V | `showTickLabels: false` | 两屏改为 `true` |
| 开关虚线接点只在 tip | 未画 ConnectionNode 各接点 | battery / open / bulb 接点 |
| Light Bulb 秒表常驻 | 未跟 `isVisible` | 默认隐藏，从 toolbox 点出 |
| TimeControl 显大 | 半透明大块 | 紧凑 Material 条 |

## 仍可能差距（下一轮）

| 项 | 判定 |
|----|------|
| 电池渐变 / 极板透视像素 | `[视觉近似]` |
| 灯泡玻璃/灯丝/halo | `[视觉近似]` |
| TimeControl 皮肤 vs scenery-phet | `[有意差异]` |
| Cue 箭头偏移量 | `[待确认]` 对照原图微调 |
| 电荷密度/电场箭头间距 | `[视觉近似]` |
| 对官方 URL 像素 diff | `[待确认]` |

请热重载后对照：右侧 toolbox 应约 175 宽小方块；电表带探针；电容显示 **0.30 pF**。
