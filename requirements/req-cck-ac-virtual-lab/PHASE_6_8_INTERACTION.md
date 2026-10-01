# Phase 6–8 — Interaction / Animation / Screen

日期：2026-09-02

## Interaction [源码一致 / 行为一致]

- 顶点拖拽 + `SNAP_RADIUS=30` 合并（相邻端点不合并，对齐 `dropTarget`）
- 元件整体拖
- 点击开关切换（`tapThreshold=15`）
- 工具箱点击在画布中心 spawn；库存上限：导线 50、标准 10、电感 1、日用品 1
- 编辑条：V/R/C/L/f/保险丝额定
- Reset 清空拓扑并恢复默认显示选项
- 电压表探头拖到焊点/金属段读数

[有意差异] 一期无键盘拖；回投工具箱 hit-box 未接到 NineGrid midLeft 像素（`toolboxOrigin` 为空则不删除）

## Animation [源码一致]

| 对象 | from→to | duration | easing | 中断 |
|---|---|---|---|---|
| Zoom | 当前 scale→`[0.5,1,1.6][i]` | 0.35s | cubic-in-out | 新 zoom 覆盖 |
| 电荷 | 沿元件 `distance` | `v = I * 25`，限速 `CHARGE_SEPARATION*0.43` | 无 | reset 清 charges |
| 保险丝火花 | scale 0.75→2，opacity 1→0 after 0.8 | 0.3s | quadratic in-out | dispose 随元件 |

电荷 equalize 顺序为下标而非 `dotRandom.shuffle`。[有意差异：可测确定性]

## Screen

`CckAcVirtualLabScreen`：AppBar + NineGrid  
- center：电路 Canvas + 电压表 overlay + 编辑条  
- midLeft：工具箱 / Lifelike-Schematic / Zoom  
- midRight：Display / Sensors / Advanced  
- footer：Play/Pause/Step（暂停仍微步）  
- bottomRight：Reset 橙圆

模拟对象不进边格。
