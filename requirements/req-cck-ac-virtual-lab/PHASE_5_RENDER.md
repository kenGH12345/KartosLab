# Phase 5 — Static Render

日期：2026-09-02

## 完成了什么

- 从 PhET `*_png.ts` data-URL **抽出** 26 张 PNG 到 `assets/cck_ac_virtual_lab/images/`（不自制）
- `CircuitPainter`：导线渐变（`#993f35/#cd7767/#f6bda0/#3c0c08`，线宽 16）、焊点 `#ae9f9e` r=11.2、顶点虚线圆 r=16
- 元件：电池/电阻/保险丝/日用品/灯泡 PNG 沿顶点对齐；AC 圆+正弦（`ACVoltageNode.ts`）；电感线圈；开关三段；电容 IEEE 平行板
- 背景 `#99c1ff`

## 测试

Screen widget 测试确认 `CircuitPainter` 挂载。

## 视觉状态

- [视觉近似] 电容 lifelike：scenery-phet `CapacitorNode` 不在本地仓库，用平行板+wire stub 代替 3D 电容
- [视觉近似] 工具箱图标：窄边格内用线稿 glyph，未把 60×31 PNG 图标逐像素塞进 NineGrid midLeft
- [待确认：缺少原版运行截图]

## blocked

无
