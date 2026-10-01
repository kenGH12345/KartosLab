# PHASE 2 — Model Screen Report

状态：**Model Screen 可用 · 整体仍为 NOT READY**（Real Molecules Screen / Home / Final QA 未做）。

## 交付

| 项 | 路径 |
|---|---|
| 排斥 / Kabsch 吸引子 | `lib/molecule_shapes/model/attractor_model.dart` |
| `VseprMolecule.update` | `lib/molecule_shapes/model/molecule.dart` |
| 统一 `step(dt≤0.2)` | `ModelMoleculesModel.step` |
| 透视投影 | `lib/molecule_shapes/view/molecule_camera.dart` |
| 深度排序绘制 | `lib/molecule_shapes/view/molecule_painter.dart` |
| Model Screen UI | `lib/molecule_shapes/view/model_molecules_screen.dart` |
| Source map | `PHASE_2_MODEL_VIEW_SOURCE_MAP.md` |

## 3D 策略

- 不引入 Flutter GPU 3D。
- Model 坐标 → 四元数世界朝向 → 透视投影 → CustomPainter。
- 相机 `(6, -1.25, 40)`，FOV 50°，near 1 / far 100。
- 绘制顺序按相机深度（远先近后）。
- 单 ticker 驱动 `model.step`，无 per-atom AnimationController。

## 交互

| 操作 | 行为 |
|---|---|
| 点中径向原子 / 孤对 | 球面拖动，写 Model 位置，几何名不变 |
| 点背景 | 旋转 `quaternion`，局部坐标不变 |
| Bonding 单/双/三 | 各加 1 domain；视图画 1/2/3 根键线 |
| Lone Pair | 加 order 0；Show Lone Pairs 关闭时禁用 |
| Remove / Remove All | 删 group；保留中心原子 |
| Options | Show Lone Pairs / Show Bond Angles |
| Name | Electron / Molecule **名称**可见性（非 3D 框线） |
| Reset | `KratosResetAllButton` → 两个单键 + 默认选项 |

## Geometry / 键角

- 名称仍只由 `(x,e)` 决定（Phase 1 未改）。
- 键角标签来自**当前** orientation，`toFixed(1)°`。
- 排斥积分会把域拉向理想槽；拖动时暂停该粒子的力。

## Assets

- 原子 / 键 / 孤对 / 删除 X / 复选勾：CustomPainter。
- Reset：L0 `KratosResetAllButton`。
- **Substituted = 0**（无 Material icon 冒充分子图形；复选勾与 X 为自绘）。
- VERSION_DELTA：孤对壳用程序化笔画近似 `LonePairGeometryData` 网格，未嵌入完整 balloon OBJ。

## Tests / Analyze

```text
flutter test test/molecule_shapes/
29 tests, All tests passed

dart analyze lib/molecule_shapes test/molecule_shapes
No issues found
```

新增覆盖：加键、孤对、Remove All、reset、拖动不改名、step 松弛到 ~180° / ~109.5°、控件存在性。

## P0 / P1 / P2

| 级别 | 状态 |
|---|---|
| P0 | 0（可启动、可渲染、控件不崩、step/reset 可用） |
| P1 | 见 VERSION_DELTA：孤对网格精度、键圆柱着色分段、缩略图非 WebGL 截图、吸引子 Jacobi SVD 与 MatrixOps3.svd3 数值细节可能略有差别 |
| P2 | 面板圆角/字体、球高光、键角扇区透明度阈值等 scenery-phet chrome |

## 明确未做

- Real Molecules Screen UI
- Home 接入
- 完整 balloon 孤对网格导入
- Real/Model 切换时的朝向连续映射

## Status

```text
Model Screen: PASS (functional)
Overall: NOT READY
```

下一阶段：Phase 3 Real Molecules Screen（仍不接 Home）。
