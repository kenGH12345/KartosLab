# PHASE 2 — Model Screen Visual QA

检查方式：对照 source 行为与 Flutter `ModelMoleculesScreen` 实现（代码审查 + 自动化测试）。未跑真机截图 diff。Android = NOT VERIFIED。

| 场景 | 判定 | 备注 |
|---|---|---|
| Initial（两单键） | PASS | 中心紫球 + 两白球 + 白键；黑底 |
| 1 bond | PASS | 加键控件 / domain=1 |
| 2–3 bonds | PASS | 双/三键画多根线，仍 1 domain/键 |
| Lone pair | PASS | 壳+两点；Show Lone Pairs 可关 |
| Multiple domains | PASS | 上限 6；排斥松弛 |
| Geometry name visible | PASS | Name 面板文字，非 3D 框 |
| Angle visible | PASS | 弧 + `xxx.x°`，跟当前向量 |
| Rotated molecule | PASS | quaternion；局部坐标保留 |
| Dragged atom | PASS | 改角不改名 |
| Double / triple | PASS | 键线数量正确 |
| Reset | PASS | 回到两单键 |

## 视觉标签

- `[布局已对齐]` 右上控制 / 左下 Name / 右下 Reset，相对 1024×618 语义锚点（Flutter 用全屏 Stack + margin 10）
- `[动态绘制已对齐]` 原子半径 2、键半径 0.5、键间距 `12/5`、相机位置与 source 一致
- `[原版资源一致]` 颜色 profile default；孤对网格为近似（VERSION_DELTA）

## P0 = 0 · P1 残留

1. 孤对壳非完整 `LonePairGeometryData` 三角网  
2. Bonding 缩略图为 2D 示意，非 three.js 离屏截图  
3. 键未分 A/B 两色半段  

不影响 Model Screen 核心教学交互。

## Overall

```text
Model Screen Visual: PASS with VERSION_DELTA
Overall Status: NOT READY
```
