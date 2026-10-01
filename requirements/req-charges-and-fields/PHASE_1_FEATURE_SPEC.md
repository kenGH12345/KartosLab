# PHASE 1 — Feature / Behavior Spec · Charges and Fields

> Behavior Reference = local source `1.1.0-dev.12`  
> 禁止凭教材经验添加源码不存在的功能（尤其：**无传统电场线**）。

---

## 1. Screens

| 项 | 结论 |
|---|---|
| Screen 数量 | **1** |
| Tabs | 无 |
| 标题 | Charges and Fields |

---

## 2. Charges

| 项 | 源码结论 |
|---|---|
| 类型 | 仅 **positive (+1)** / **negative (−1)** |
| 单位 | 1 模型单位 = **1 nC** |
| 可调数值 | **否**（固定 ±1；无 slider） |
| 创建 | 从底栏 bin 拖出 |
| 删除 | 拖回 bin → 动画 → dispose |
| 拖动 | 改 `positionProperty`；active 时重算场/势/传感器并清等势线 |
| 半径（view） | `CHARGE_RADIUS = 12` scenery units |
| 最大数量 | 桌面无限；部分 WebGL 移动端限 32 — Flutter **不限**（对齐桌面） |

---

## 3. Electric Field Visualization

| 项 | 结论 |
|---|---|
| 默认开 | Electric Field = **checked** |
| Direction only | 缩进子项；仅影响透明度，不改变箭头长度 |
| 采样 | 0.5 m 网格，单元中心采样 |
| 箭头长度 | **固定**（形状长 40，canvas scale 1.3） |
| 强度编码 | alpha = \|E\|/5 饱和 |

---

## 4. Voltage / Potential

| 项 | 结论 |
|---|---|
| Voltage checkbox | 电势色场网格（±40 V 饱和） |
| 等势线 | 电压表 Pencil 按钮添加；Eraser 清除全部 |
| Values | 显示传感器读数、等势线电压标签、网格「1 meter」 |

---

## 5. Measurement Tools

| 工具 | 来源 | 行为 |
|---|---|---|
| Voltmeter (Electric Potential Sensor) | 右 toolbox | 拖出；十字丝测 V；Pencil/Eraser |
| Measuring Tape | 右 toolbox | cm；可拖 base/tip |
| Electric Field Sensors | 底栏黄色圆 | 可多枚；测 E + 方向箭头 |

---

## 6. Grid

| 项 | 结论 |
|---|---|
| Grid checkbox | 主线 0.5 m / 次线 0.1 m |
| Snap to Grid | Grid 下缩进；吸附到 0.1 m |

---

## 7. Controls（右上面板）

顺序：

1. Electric Field  
2. Direction only（缩进）  
3. Voltage  
4. Values  
5. Grid  
6. Snap to Grid（缩进）

---

## 8. Reset

一键 Reset All：清电荷、传感器、等势线、卷尺、电压表位置/状态、全部 checkbox 回默认。

---

## 9. Out of Scope（源码无 / 不迁移）

- 传统电场线（从正电荷出发的流线）
- 可编辑电荷量
- 3D / 磁场
- Projector color profile（可后置；默认 default 黑底）
- PhET-iO / queryParameters.debug 批量等势线按钮

---

## 10. Acceptance Criteria（实现前）

- AC-E1：单正电荷在已知点 E、V 与源码公式一致（含 K=9）  
- AC-E2：多电荷叠加 `Σ E_i` / `Σ V_i`  
- AC-E3：电荷拖动后场/势/传感器同步更新  
- AC-E4：等势线由源码算法生成，非手绘近似  
- AC-UI1：初始态布局对齐原版（黑底、右面板、底 bin、橙 Reset）  
- AC-R1：Reset 恢复初始空板 + Electric Field on
