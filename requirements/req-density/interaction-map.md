# Interaction Map · Density

## 1. 可交互对象

| 对象 | Intro | Compare | Mystery | 行为 |
|---|---|---|---|---|
| Cuboid 块 | A，可选 B | 4 | 5 | 抓取拖放；受物理 |
| 材料 Combo | A/B 各一 | 无 | 无 | 切换材料 |
| Mass NumberControl | A/B | 仅 Same Mass 全局一条 | 无（默认） | 见耦合表 |
| Volume NumberControl | A/B | 仅 Same Volume 全局 | 无 | 滑条 0.5 L 吸附 |
| Density NumberControl | 只读数轴 | 仅 Same Density 全局 | Table 只读 | |
| One/Two Blocks | 有 | 无 | 无 | 显隐 B |
| BlockSet radio | 无 | Same M/V/ρ | Set1/2/3/Random | 切可见块集 |
| Random refresh | 无 | 无 | Random 时 | regenerate |
| Density accordion | 数轴 | 无 | Table | 展开/折叠 |
| Reset All | 有 | 有 | 有 | 见下 |
| 台秤 | 无 | 无 | 固定 | 不可搬；显示 kg |
| 池 | 不可点 | 同 | 同 | 水位随排水 |
| Preferences Volume Units | 全局 | 全局 | 全局 | L vs dm³ |

拖拽 **不** 改 mass/volume，只改位置（经约束）。大小表示 volume。Compare/Mystery 颜色表示套装色或神秘色，**不是** Intro 的材料纹理（Compare 用 custom 底色随密度明暗）。

---

## 2. 拖拽状态机

```
pointer down on mass (ray pick 最近)
  → grab 音
  → Mass.startDrag(modelXY)
       userControlled=true
       y += 0.0001
       engine.addPointerConstraint(body, point)
pointer move
  → updateDrag(modelXY) → updatePointerConstraint
pointer up / interrupt
  → endDrag → removePointerConstraint, userControlled=false
  → release 音
```

证据：`BackgroundEventTargetListener.ts`、`Mass.ts:525-550`、`MassView.ts` GrabDragInteraction（键盘）。

其它：

- 可重叠（接触力，无 restitution）
- 不可拖到面板后（隐形屏障；屏障移动会 rescue 被困块）
- 无磁吸网格
- 多块可同时 pointer-drag 列表 `draggedMasses`
- 键盘 Grab/Release + 方向键移动（Intro/Compare）

坐标：屏幕点 → THREE 射线 → 与地面/块相交 → 模型 (x,y)。Flutter 必须有 **World ↔ Viewport**，禁止把逻辑米当成 Flutter 像素。

---

## 3. 输入控件精度

来自 `MaterialMassVolumeControlNode` + Constants：

| 项 | 值 |
|---|---|
| NumberControl delta（箭头） | 0.01 |
| 体积滑条吸附 | `roundSymmetric(v*2)/2` → **0.5 L** |
| 质量滑条 | 1 位小数；贴上下限时用精确 min/max（styrofoam #46） |
| 数字显示 | 2 位小数 |
| Compare 锁定滑条吸附 | 0.05 |
| 键盘 step / page / shift | 0.5 / 1 / 0.01 |
| 体积 UI 单位 | L（或 dm³，数值相同因 1 L = 1 dm³） |
| 密度 UI | kg/L = SI/1000 |
| 非法数字 | NumberControl 不提交；范围外 clamp |
| 超范围质量 | GuardedNumberProperty 拒绝导致体积越界的 mass |

Intro Custom 最大质量 **10 kg**（覆盖默认 27）。

---

## 4. Reset All

| 屏 | 恢复 |
|---|---|
| Intro | ONE_BLOCK；A Wood 2 kg @ (-0.2,0.2)；B Al 13.5 kg 隐藏；密度手风琴折叠状态 reset |
| Compare | SAME_MASS；锁定 5 kg / 0.005 m³ / 500；四套块 reset + 重摆 |
| Mystery | SET_1；Table 折叠；**Random 套重新生成**；秤位置按屏障 |

三屏 Model 独立，Reset 只影响当前屏。

---

## 5. 无障碍

- 块 `focusablePath` + Grab Mass A/B/… 语义（MassTag / tandemName）
- Intro 焦点序：cubeA → panelA → cubeB → panelB；控件区：blocksMode → densityAccordion → Reset
- Compare：cuboids 按 tag 字母序 → blocksPanel → valuePanel → Reset
- Mystery：cuboids → blockSetPanel → densityTable → Reset
- 禁止依赖 Windows 全局 `ExcludeSemantics` 作为「无障碍方案」
