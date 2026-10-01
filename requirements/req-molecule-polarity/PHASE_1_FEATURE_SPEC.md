# PHASE 1 — Feature Spec · Molecule Polarity

> Source of Truth：本地 `molecule-polarity 2.1.0-dev.0`  
> 禁止按化学教材自行扩展功能。

---

## 1. Screen 功能总览

### 1.1 Two Atoms（默认）

用户可以：

| 动作 | 说明 |
|---|---|
| 调整 A/B 电负性 | 滑块 EN ∈ [2, 4]，步进 0.2；松手 snap |
| 拖拽旋转分子 | 相对分子中心角度，**5° 量化** |
| 开关 Bond Dipole | 默认 **开** |
| 开关 Partial Charges | 默认关 → δ+/δ− |
| 开关 Bond Character | 默认关 → Covalent↔Ionic 读数条 |
| 切换 Surface | none / Electrostatic Potential / Electron Density |
| 开关 Electric Field | 默认关；开则显示极板并自动旋转对齐 |
| Reset All | 重置 model + viewProperties + hint arrows |

### 1.2 Three Atoms

| 动作 | 说明 |
|---|---|
| 调整 A/B/C 电负性 | 三个 EN 面板 |
| 拖 B 或键 → 整分子旋转 | `MoleculeAngleDragListener` |
| 拖 A 或 C → 改键角 | `bondAngleAB` / `bondAngleBC` |
| 开关 Bond Dipoles | 默认 **关** |
| 开关 Molecular Dipole | 默认 **开** |
| 开关 Partial Charges | 默认关 |
| 开关 Electric Field | 同 Screen 1；极板间距更大（600） |
| **无 Surface 控件** | — |
| Reset All | model + viewProperties + hints |

### 1.3 Real Molecules

| 动作 | 说明 |
|---|---|
| ComboBox 选分子 | 19 种；默认 **HF** |
| 3D 拖拽旋转 | quaternion；scale ≈ 0.007 |
| View 开关 | Bond Dipoles / Molecular Dipole / Partial Charges / Atom Electronegativities / Atom Labels（默认 labels **开**） |
| Surface | none / ESP / Electron Density |
| Model | Basic / Advanced（默认 Basic） |
| Reset All | model + viewProperties（无 hint） |
| **无 E 场** | — |

### 1.4 全局 Preferences

| 项 | 选项 | 默认 |
|---|---|---|
| Dipole Direction | positiveToNegative / negativeToPositive | positiveToNegative |
| Surface Color（Real ESP） | blueWhiteRed / rainbow | blueWhiteRed |

---

## 2. 可观察量（只观察，不新增）

- 原子球 + 标签（A/B/C 或元素符号）
- 键
- 键偶极箭头（黑）/ 分子偶极箭头（黄 `rgb(255,200,0)`）
- 部分电荷 δ+/δ−
- 2D 表面云（Screen 1）/ 3D surface mesh（Screen 3）
- Bond Character 连续体指针（Screen 1）
- E 场极板 + 极性指示（Screen 1/2）
- EN 对照表（Screen 3，开关控制）
- Surface color key

---

## 3. 非目标（Out of Scope）

- 自行添加更多分子 / 真实量子化学计算
- 改写源码简化公式（partial charge ≡ deltaEN 等必须保留）
- Stats / 额外 Screen
- M5 前写入 Home
- a11y 完整 Fluent 语音（可后置；不阻塞 Visual/Behavior Gate）

---

## 4. Acceptance Criteria（摘要）

1. 三屏入口顺序与默认状态与源码一致  
2. EN / 偶极 / 部分电荷 / 键角公式与源码一致（单元测试）  
3. 所有 View/Surface/E-field/Model 开关行为与源码一致  
4. Reset All 仅重置当前屏  
5. Preferences 跨屏共享 dipole 方向  
6. Visual QA：ORIGINAL/FLUTTER/DIFF 矩阵覆盖关键状态  
7. `flutter test` PASS · `flutter analyze` CLEAN · P0=P1=0  
8. Final Gate 通过后才接入 Home
