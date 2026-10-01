# notes · req-normal-modes

## L1 候选（第 1/3 用户 · 留在 sim 内）

| 组件 | 原因 |
|---|---|
| 竖直 VSlider（3×100 track / 26×15 thumb） | 与 `KratosSlider` 外观/尺寸不等价 |
| AccordionBox（collapse 不 dispose 内容） | PhET sun AccordionBox；Spectrum 折叠后仍保留 frequency Text |
| AmplitudeSelectorRectangle | 2D 专用填色格子 |
| TimeControlNode 蓝按钮 + Normal/Slow | 与 `TimeControlBar`（含 restart/秒表、无倍速）不等价 |
| 直线弹簧 Path | 不是线圈弹簧，lineWidth=5 |

## 有意差异

- 无 JSON scenario / schema（原版空默认态沙盒）
- KARTOSLAB AppBar + Tab 外壳（替代 joist 导航栏）
- 字体：工程无 Source Sans Pro / PhetFont 嵌入 → 用系统字体 + 同源字号
- Home 卡片仍用 Material Icon（与其他 Home 卡一致，不声称与 ScreenIcon 一致）；屏内图标按 IconFactory 自绘

## 不修

- `SimulationClock` 按 vsync 固定 1/60、忽略墙钟 dt → 本 sim 不改 common，本地 Ticker 传墙钟 dt
- `lib/` 其他 sim 一律不动
