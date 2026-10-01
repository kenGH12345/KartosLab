# Phase 5 — Static Render · Vector Addition

> 日期：2026-09-04  
> 本地源：`1.3.0-dev.0`  
> 标记：`[已确认]` / `[推测]` / `[待确认]`

---

## 0. 结论摘要

1. **未改动** Phase 3/4 核心：`RootVector` canonical、`SumVector`、`EquationsResultant`、`MathCoordinateTransform`、`SnapPolicy`、Hit/Interaction 骨架。
2. 四屏静态壳已落地：`Explore1D` / `Explore2D` / `Lab` / `Equations`，路径 `Model → VaRenderBuilder → VaRenderData → VaScenePainter`。
3. Painter **不**重算 magnitude / angle / resultant / components / isOnGraph；Y 翻转仅经 Transform。
4. Home：**物理 → 力学 → Vector Addition**（四 Tab），未新建「数学」一级。
5. `flutter test test/vector_addition/`：**36 passed**；`flutter analyze lib/vector_addition`：**No issues**。
6. Flutter baseline：`visual-qa/flutter/screen{1..4}.png` 已生成。

---

## 1. 默认状态（源码）

| Screen | 默认 Scene | 向量 | isOnGraph | Sum/Resultant UI | Component | Grid |
|---|---|---|---|---|---|---|
| Explore 1D | Horizontal | a,b,c · xy=(5,0) | **false**（toolbox） | sumVisible=**false** | invisible | true |
| Explore 2D | Cartesian | a(6,8) b(8,6) c(0,-10) | **false** | sumVisible=**false** | invisible | true |
| Lab | Cartesian | u₁…u₁₀ + v₁…v₁₀ · xy=(8,6) | **false** | sumVisible=**false**；tails (12,10)/(25,5) | invisible | true |
| Equations | Cartesian | a(5,5)+(0,5)；b(15,5)+(5,5) | **true** | resultantVisible=**true**；`EquationsResultant` addition → c=(5,10) | invisible | true |

Lab ≠ Explore2D 复制：双 set × 10，双色板，toolbox 仅 u/v 两槽。

Equations **不用** `SumVector`；三方程 UI 可切换。

---

## 2. Render 管道

```
VaScreenModel
  → VaRenderBuilder.build
       → MathCoordinateTransform (graph.transform)
       → VaRenderData (view 坐标箭头/网格/锚点/面板)
  → VaScenePainter + chrome widgets
```

`VaArrowGeometry`：head 12×14、tail 3.5、dynamic head、fractional 0.5；短向量缩放头，禁 Material Icon。

---

## 3. 布局锚点（layout 1024×618 相对关系）

记录于 `VaLayoutAnchors` / RenderData：

| Anchor | 关系 |
|---|---|
| graphRect | Transform.viewBounds |
| controlPanel | right − margin − 175, top + margin |
| toolbox | 对齐 control 左，位于 scene radio 上方 |
| vectorValues | graph.centerX, top ≈ 35 |
| eraser | graph.right−40, graph.bottom+15 |
| reset | layout 右下 |

页面：`NineGridLayout` center ← `VaPageShell` FittedBox。

---

## 4. Visual QA 对应

| Flutter | Ref |
|---|---|
| `visual-qa/flutter/screen1.png` | `ref/screen1_explore1d.png` |
| `visual-qa/flutter/screen2.png` | `ref/screen2_explore2d.png` |
| `visual-qa/flutter/screen3.png` | `ref/screen3_lab.png` |
| `visual-qa/flutter/screen4.png` | `ref/screen4_equations.png` |

**说明**：Explore/Lab 源码默认为空图 + toolbox，故 Flutter baseline 图面比营销截图更空；Equations 有 a/b/c。结构（图区、右面板、toolbox、方程条）已对齐。大规模视觉微调留给后续。

---

## 5. Assets

- 无 runtime PNG/SVG 业务贴图；箭头为 geometry。
- 参考截图仅 visual-qa。

---

## 6. 已知缺口（不阻塞 Phase 6）

| 项 | 状态 |
|---|---|
| Lab Polar scene | Phase 5 仅 Cartesian 默认；Polar 可后续补 |
| Equations Polar / BaseVector 可视化 | baseVectorsVisible 默认 false；未画 base |
| Tip/body 拖动手势 | Phase 6 |
| Toolbox → drop 交互 | Phase 6 |
| 精细 arrow vs scenery-phet 像素 | 后续 visual QA |

---

## 7. 自动进入 Phase 6

无重大架构问题 → **Phase 6 INTERACTION**（body/tip drag、drop/pop、sum 可见联动、hit-test 接线）。

---

*Phase 5 · 2026-09-04*
