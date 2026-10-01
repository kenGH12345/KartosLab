# Phase 7 · Controls / AC 收口

> 源码：`1.3.0-dev.0` · 进入时间：2026-09-04 20:25  
> **禁止改**：Canonical / SumVector / EquationsResultant / MathCoordinateTransform / SnapPolicy

## 范围

| 控件 | 源码 | 状态 |
|---|---|---|
| Vector Values accordion | `VectorValuesAccordionBox`：折叠标题 / 展开无选或 \|v\| θ x y | ✅ 可折叠 + 四量读数 |
| Values checkbox | 箭头旁显示 magnitude 标签 | ✅ Phase 5/6 |
| Angles checkbox | Explore2D / Lab / Equations；Explore1D **无** | ✅ 弧 + °；1D 面板隐藏 |
| Components radio | invisible / triangle / parallelogram / projection | ✅ |
| Sum / Resultant checkbox | Explore/Lab 默认 off；Equations 默认 on | ✅ |
| Base Vectors | Equations only | ✅ checkbox（可见性接线，base 几何精修可续） |
| Grid | 默认 on | ✅ |
| Scene radio | 1D H/V；2D/Lab/Eq Cartesian/Polar | ✅ |
| Toolbox | Explore/Lab；Equations 无 | ✅ |
| Eraser | Explore/Lab；Equations `includeEraserButton: false` | ✅ |
| Reset All | 全屏 | ✅ |
| Equation type chips | addition / subtraction / negation | ✅ |

## AC 核对（进行中）

- [x] AC-2 / AC-3 / AC-4 核心已在 Phase 4–6 锁定
- [x] AC-5 交互：toolbox / snap / sum / values / angles / reset 已接线
- [ ] AC-1 手动：Home → 四 Tab → 返回再进（待 Visual / 手测）
- [x] AC-6 `flutter test` + `analyze` 绿

## 本阶段不做

- 大规模 typography / color 重做
- Multi-touch
- 独立产品 `vector-addition-equations`
- 改其他 sim / common API
