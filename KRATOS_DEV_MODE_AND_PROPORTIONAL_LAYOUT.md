# Kratos / KartosLab · 开发模式与画面比例布局算法

> 状态：与 `CLAUDE.md` / `AGENTS.md` 同级的工程说明  
> 范围：Flutter 复刻   模拟的工程开发模式 + **组件按比例排布在画面中的算法**  
> 依据：`lib/common/widgets/nine_grid_layout.dart`、`lib/buoyancy/layout/*`、`lib/density/render/density_mvt.dart`、`.codebuddy/rules/80-kratos-sim-checklist.mdc` §七、`docs/knowledge/kratos/frontend/ui-framework.md`、`docs/knowledge/kratos/notes.md`

---

## 1. 开发模式总览

### 1.1 目标

把科学模拟复刻到 Flutter，并满足：

| 原则 | 含义 |
|---|---|
| MVC | Model 持有物理状态；View 只读 Model 渲染；交互写回 Model |
| 组件化 | 可复用控件进 L0（`lib/common/`），sim 特有逻辑留在 `lib/<sim>/` |
| 通用化 | 布局 / Reset All / Tab / 音效等走统一约定，禁止每 sim 各造一套 |
| 配置化 | 场景、字符串、asset 映射可查（`requirements/<req-id>/`、`ASSET_MAP`） |
| 视觉忠实 | **原版 Asset 优先**；Reset All 统一 `KratosResetAllButton` |

### 1.2 三阶段流程

```
1. Intake（读蓝本 / EDD / checklist）
      ↓
2. Build（Vibe Loop：≤30min 一小步，拿可视反馈）
      ↓
3. Close（评审 → 收尾文档 → 知识库回写）
```

### 1.3 组件分层（L0 / L1 / L2）

| 层 | 位置 | 何时进入 |
|---|---|---|
| L0 | `lib/common/` | 跨 sim 复用 ≥ 3 次，或 checklist 强制（如 `NineGridLayout`、`KratosResetAllButton`） |
| L1 | 同学科 / 同家族共享（如 density–buoyancy 公共常量） | 2～3 个相关 sim 共用 |
| L2 | `lib/<sim>/` | 单 sim 专用 UI / 物理 / MVT |

### 1.4 视觉与资源硬规则（与布局正交但必须同时满足）

1. **Asset 优先级**：原图 → 原 SVG/PNG → Scenery Path 等价重建 → 最后才自绘。  
2. **禁止**用 Material Icons / Emoji 冒充 sim 内原版控件。  
3. **Reset All**：一律 `KratosResetAllButton`（球面高光 + 白箭头，`baseColor #F79722`，半径默认 `20.5`）。  
4. 交付物：`requirements/<req-id>/ASSET_MAP.md`；Substituted Assets 目标为 0。

### 1.5 入口与模块接线

```
lib/main.dart
  → HomeScreen（lib/screens/home_screen.dart）
       → Navigator.push → lib/<sim>/…Home 或 …Screen
```

- Home **只走 `lib/`**，不走根目录 ` /`、`simulations/`。  
- 新模块可经 `SimulationRegistry` 注册（如 Quantum Measurement）；多数卡片仍是 Home 内硬编码 `builder`。

---

## 2. 画面比例布局：两套范式

项目里「组件按比例排在画面里」**不是单一算法**，而是两套并存范式。选型决定公式。

| 范式 | 名称 | 核心思想 | 典型 sim |
|---|---|---|---|
| **A** | NineGrid（Flex 分格） | 视口切 3×3，中间格面积 ≥ 70%，控件进边格 / footer | Density、Wave Interference、早期 Circuit / Optics |
| **B** | Joist ScreenView（设计画布） | 固定设计分辨率（多为 1024×618），等比缩放后居中，控件按 AlignBox 锚可见区 | Buoyancy、Capacitor Lab、Wave on a String、多数忠实复刻屏 |

```text
                    ┌─────────────────────────┐
                    │   是否要对齐   像素级  │
                    │   AlignBox / layoutBounds │
                    └───────────┬─────────────┘
                          是╱         ╲否
                           ╱           ╲
                    范式 B              范式 A
                 设计画布缩放         NineGridLayout
              + Positioned 锚点      + LayoutBuilder(MVT.fit)
```

> **实务冲突说明**：checklist §七 L0-4 写「主屏必须 NineGrid」；后续大量忠实复刻（Buoyancy 等）采用范式 B，并在 overlay 注释中标明「AlignBox → Positioned」。新 sim 开工前先定范式，并在需求笔记写明依据，避免评审口径打架。

---

## 3. 范式 A · NineGridLayout 算法（详细）

**实现**：`lib/common/widgets/nine_grid_layout.dart`  
**规则**：`.codebuddy/rules/80-kratos-sim-checklist.mdc` §七 L0-4

### 3.1 格子语义

```text
┌──────────┬────────────────┬──────────┐
│ topLeft  │   topCenter    │ topRight │  ← 边格（信息 / 小控件）
├──────────┼────────────────┼──────────┤
│ midLeft  │     center     │ midRight │  ← center = 唯一主实验区
├──────────┼────────────────┼──────────┤
│bottomLeft│ bottomCenter   │bottomRight│
└──────────┴────────────────┴──────────┘
│              footer（可选，横跨整宽）   │
└────────────────────────────────────────┘
```

硬约束：

- **`center` 只放实验画面**（Canvas / DropCanvas / 主交互区）。  
- 控件面板、说明、托盘进 **8 个边格** 或 **footer**。  
- 拖拽工作区必须拆：`DropCanvas`→center，`DragTray`→边格。

### 3.2 输入 / 输出

**输入**（来自 `LayoutBuilder` 约束）：

- \(W = \texttt{constraints.maxWidth}\)
- \(H = \texttt{constraints.maxHeight}\)
- \(r = \texttt{centerAreaRatio}\)（默认 \(0.7\)）
- 是否有 `footer`

**输出**：

- 中间格宽高 \((W_c, H_c)\)
- 上下边格由 `Expanded` 均分剩余高度
- 左右边格由 `Expanded` 均分剩余宽度
- footer 高度 \(H_f\)（若有）

### 3.3 面积比 → 边长比

希望中间格面积占可用屏面积比例约为 \(r\)：

\[
\frac{W_c \cdot H_c}{W \cdot H_{\text{body}}} \approx r
\]

取**各向同性**边长比（宽、高各乘同一因子）：

\[
s = \sqrt{r_{\text{clamped}}}
\]

其中面积比先 clamp：

\[
r_{\text{clamped}} =
\begin{cases}
0.7 & r < 0.7 \\
r & 0.7 \le r \le 0.95^2 \\
0.9025 & r > 0.95^2
\end{cases}
\]

默认 \(r=0.7\) 时：

\[
s = \sqrt{0.7} \approx 0.8367
\]

### 3.4 Footer 高度（必须先扣）

若存在 footer：

\[
H_f = \min(96,\ 0.16\,H)
\]

否则 \(H_f = 0\)。

主体高度（参与九宫格分配）：

\[
H_{\text{body}} = H - H_f
\]

> **踩坑（已修）**：若不从主体扣掉 \(H_f\)，会出现  
> \(0.837H + 0.16H \approx 0.997H\)，上下边格被压到接近 0px（320×480 实证）。

### 3.5 中间格尺寸与矮屏降级

理想中间高度：

\[
H_c^{\text{ideal}} = H_{\text{body}} \cdot s
\]

上下边格各高：

\[
H_{\text{side}} = \frac{H_{\text{body}} - H_c^{\text{ideal}}}{2}
\]

**矮屏降级**（保证边格可点）：若 \(H_{\text{side}} < 48\)，则强制边格至少 48px：

\[
H_c = H_{\text{body}} - 2 \times 48
\]

此时极端矮视口下中间格面积可 **暂时低于 70%**；正常视口仍保持 \(\ge 70\%\)。

中间格宽度（无降级分支）：

\[
W_c = W \cdot s
\]

左右边格宽度由 `Expanded` 均分 \(W - W_c\)。

### 3.6 伪代码

```text
function NineGridLayout(W, H, r, hasFooter):
    area ← clamp(r, 0.7, 0.9025)
    s    ← sqrt(area)
    Hf   ← hasFooter ? min(96, 0.16*H) : 0
    Hbody ← H - Hf
    Wc   ← W * s
    Hc_ideal ← Hbody * s
    Hside ← (Hbody - Hc_ideal) / 2
    if Hside < 48:
        Hc ← Hbody - 2*48
    else:
        Hc ← Hc_ideal

    Column:
        Expanded → Row(Expanded topLeft | SizedBox(Wc) topCenter | Expanded topRight)
        SizedBox(height: Hc) → Row(Expanded midLeft | center | Expanded midRight)
        Expanded → Row(Expanded bottomLeft | …)
        if hasFooter: SizedBox(height: Hf, child: footer)
```

### 3.7 格子内内容如何「再比例」

NineGrid **只负责分格**，不画物理。中间格内典型两步：

1. `LayoutBuilder` 读到格子实际 `(Wc', Hc')`。  
2. 二选一：  
   - **自适应世界**：`DensityMvt.fit(Size(Wc', Hc'))`（见 §5.1）  
   - **可选再套设计画布**：`FittedBox(contain) + SizedBox(960×560)`（如 Waves Intro）

### 3.8 Footer 内控件排布约定

统一范式（见 `docs/knowledge/kratos/notes.md`）：

```text
footer
  └─ SingleChildScrollView(scrollDirection: horizontal)
       └─ Row( children: [ Wrap(SizedBox(限宽)→控件), … ] )
```

- **禁止**用 `FittedBox` 包无界宽 Slider（约束爆炸）。  
- 固定宽子控件在 320px 下易溢出 → 改 `Expanded` 或限宽 + 横滚。

---

## 4. 范式 B · Joist 设计画布缩放算法（详细）

### 4.1 设计坐标系

  HTML5 / Joist：

```text
ScreenView.DEFAULT_LAYOUT_BOUNDS = Bounds2(0, 0, 1024, 618)
```

Flutter 常量示例（Buoyancy）：

| 常量 | 值 | 来源 |
|---|---|---|
| `buoyancyDesignWidth` | 1024 | `ScreenView.DEFAULT_LAYOUT_BOUNDS` |
| `buoyancyDesignHeight` | 618 | 同上 |
| `MARGIN` | 10 | density-buoyancy-common |
| `MARGIN_SMALL` | 5 | 同上 |
| ResetAll radius | 20.5 |   ResetAllButton 默认 |

变体设计尺寸（按 sim）：

| Sim | 设计宽×高 |
|---|---|
| 多数 Joist sim | 1024×618 |
| Waves Intro（内层） | 960×560 |
| Gravity Force Lab Basics shell | 768×464（注释约定） |

### 4.2 Uniform Center 缩放（与 Joist `getLayoutScale` 一致）

设视口为 \(W_v \times H_v\)，设计为 \(W_d \times H_d\)：

\[
s = \min\left(\frac{W_v}{W_d},\ \frac{H_v}{H_d}\right)
\]

缩放后内容框尺寸：

\[
W' = W_d \cdot s,\quad H' = H_d \cdot s
\]

**居中原点**（内容框左上角在视口中的位置）：

\[
O_x = \frac{W_v - W'}{2},\quad
O_y = \frac{H_v - H'}{2}
\]

**设计点 → 视口点**：

\[
\begin{aligned}
v_x &= O_x + d_x \cdot s \\
v_y &= O_y + d_y \cdot s
\end{aligned}
\]

**视口 → 设计**：

\[
\begin{aligned}
d_x &= (v_x - O_x) / s \\
d_y &= (v_y - O_y) / s
\end{aligned}
\]

实现参考：`BuoyancyGlobalLayoutSpec.layoutScale` / `designFrame` / `BuoyancyDesignFrame`  
（`lib/buoyancy/layout/buoyancy_global_layout_spec.dart`）

### 4.3 与 Flutter 控件的三种落地方式

| 方式 | 做法 | 使用场景 |
|---|---|---|
| 显式矩阵 | 自算 \(s, O\)，`Positioned`/`Transform` | Buoyancy overlay 锚点 |
| `FittedBox(BoxFit.contain)` | 外包 `SizedBox(Wd×Hd)` | Capacitor、WOAS、多数 PageShell |
| `FittedBox` + 非对称对齐 | 宽受限时底对齐等 | Energy Forms and Changes |

`FittedBox.contain` 在数学上等价于 uniform scale + 居中 letterbox（未改 alignment 时）。

### 4.4 AlignBox → Positioned 锚点算法

 ：

```text
new AlignBox( node, {
  alignBoundsProperty: visibleBoundsProperty,
  xAlign: 'right',   // left | center | right
  yAlign: 'bottom',  // top | center | bottom
  margin: MARGIN_SMALL
})
```

Flutter 等价（视口像素，相对 **contentBounds / visibleBounds**）：

设可见矩形为 \(L, T, R, B\)（contentBounds），边距 \(m = \texttt{MARGIN_SMALL} \times s\)（若边距写在设计坐标则先乘 \(s\)；若控件已在设计画布内定位则用设计像素 \(m_d\)）。

| AlignBox | Flutter `Positioned` |
|---|---|
| left / top | `left: L+m`, `top: T+m` |
| right / top | `right: Wv−R+m` 或 `left: R−widgetW−m` |
| left / bottom | `left: L+m`, `bottom: Hv−B+m` |
| right / bottom | `right: Wv−R+m`, `bottom: Hv−B+m` |
| center / bottom | 水平居中于 \([L,R]\)，`bottom: Hv−B+m` |
| right / center | 竖直居中于 \([T,B]\)，贴右 |

**Reset All 标准锚点（右下）**：

\[
\begin{aligned}
\text{right} &= \texttt{visibleBounds.right} - \texttt{MARGIN\_SMALL} \\
\text{bottom} &= \texttt{visibleBounds.bottom} - \texttt{MARGIN\_SMALL}
\end{aligned}
\]

（设计坐标内；外包 FittedBox 时直接在设计 Stack 里用常量边距即可。）

### 4.5 Buoyancy 五屏控件树（范式 B 实例）

典型叠层：

```text
LayoutBuilder(viewport)
  └─ Stack
       ├─ 场景层（THREE / PlayArea，走相机投影，见 §5.3）
       └─ Overlay Stack（设计或视口坐标）
            ├─ 右上：控制面板 VBox
            ├─ 左下：Forces / Display options
            ├─ 底中：Fluid density
            └─ 右下：Mode radio + KratosResetAllButton
```

Compare 等屏可把右侧面板 `top` 绑到 **模型点投影**（如池子角 `modelToView`）再加 margin，而不是写死像素——这是「场景驱动锚点」。

### 4.6 EFAC 特例（非纯居中）

当 \(\texttt{scaleX} \le \texttt{scaleY}\)（宽度受限）时底对齐；否则水平居中。  
见 `lib/energy_forms_and_changes/common/layout/efac_viewport_layout.dart`。  
**不要**把该规则套到所有 sim；默认仍用 §4.2。

---

## 5. 场景坐标：Model ↔ View（物体比例的第二层）

面板锚点解决「控件贴哪」；**场景内物体**必须再经 Model–View Transform（MVT），禁止用裸屏幕像素表达物理量。

### 5.1 2D · 单点缩放 + Y 轴翻转（最常见）

世界：米制，**+y 向上**  
屏幕：逻辑像素，**+y 向下**

\[
\begin{aligned}
v_x &= O_x + x \cdot s \\
v_y &= O_y - y \cdot s \\[4pt]
x &= (v_x - O_x)/s \\
y &= (O_y - v_y)/s
\end{aligned}
\]

其中 \(s\) 为 px/m，\(O\) 为世界原点落在屏幕上的位置。

### 5.2 Density · `Mvt.fit`（填满画布）

世界窗口（常数）：

\[
x \in [-0.95,\ 0.95],\quad y \in [-0.50,\ 0.58]
\]

\[
\begin{aligned}
s &= \min\left(\frac{W_c}{x_{\max}-x_{\min}},\ \frac{H_c}{y_{\max}-y_{\min}}\right) \\
O_x &= \frac{W_c}{2} - \frac{x_{\min}+x_{\max}}{2}\cdot s \\
O_y &= \frac{H_c}{2} + \frac{y_{\min}+y_{\max}}{2}\cdot s
\end{aligned}
\]

实现：`DensityMvt.fit`（`lib/density/render/density_mvt.dart`）。  
**含义**：中间格变大 → 同一物理窗口放大填满；保持纵横比，可能一侧 letterbox。

### 5.3 Buoyancy · 三维相机投影（生产路径）

生产路径**不是** 2D scale map，而是：

```text
model(meters) → THREE world → camera → NDC → design(1024×618) → viewport
```

NDC → 设计像素（示意）：

\[
\begin{aligned}
d_x &= (n_x/2 + 0.5)\cdot W_d + o_x \\
d_y &= \bigl(1 - (n_y/2 + 0.5)\bigr)\cdot H_d + o_y
\end{aligned}
\]

相机默认量（考古自 density-buoyancy-common）：

| 量 | 值 |
|---|---|
| scaleIncrease | 3.5 |
| cameraZoom | \(1.75 \times 3.5\) |
| camera position | \((0,\ 0.2,\ 2)\times 3.5\) |
| lookAt（多数屏） | \((0,\ -0.18,\ 0)\) |

Debug 用的 `scale=600` inverted-Y **仅调试**，不可当生产 MVT。

### 5.4 其他常用变体

| 类型 | 公式要点 | 例 |
|---|---|---|
| 固定设计点 + 线性尺度 | \(v_x = x_0 + k\cdot i\cdot\Delta\) | Wave on a String |
| Yaw–Pitch 伪 3D | \(r=z\sin\theta\)；\(v_x=(x+r\cos\phi)s\) | Capacitor Lab |
| 拖拽工作区投影 | origin ≈ \((W/2,\ 0.55H)\) | Circuit / Optics（注意与 SceneProjection 可能不一致） |

---

## 6. 端到端数据流（从窗口到像素）

### 6.1 范式 A（Density 型）

```text
窗口尺寸 (Wv, Hv)
  → NineGrid：算出 center (Wc, Hc)、边格、footer
  → center 内 LayoutBuilder
  → DensityMvt.fit(Wc, Hc) → (O, s)
  → 方块中心 world → toScreen → Canvas / Positioned
  → 边格 / footer：Flex 排布控件（不经 MVT）
```

### 6.2 范式 B（Buoyancy 型）

```text
窗口尺寸 (Wv, Hv)
  → s = min(Wv/1024, Hv/618)
  → O = 居中原点；contentBounds = Rect(O, 1024s × 618s)
  → 场景：model → 相机 → design → ×s + O → 视口
  → 控件：AlignBox 规则相对 contentBounds / visibleBounds
  → ResetAll：右下 MARGIN_SMALL
```

### 6.3 嵌套（NineGrid 外包设计画布）

```text
NineGrid.center
  → FittedBox.contain
  → SizedBox(设计宽×高)
  → 内部 Stack 按设计像素绝对定位
```

外层负责「屏占比」，内层负责「  相对几何」。

---

## 7. 开发时怎么落地（操作清单）

### 7.1 新开一个屏之前

1. 打开   源：`ScreenView` / `layoutBounds` / `AlignBox` / `ModelViewTransform`。  
2. 选定范式 A 或 B，写入 `requirements/<req-id>/notes.md`。  
3. 列出控件树：每个节点的 **xAlign / yAlign / margin** 或所在九宫格格位。  
4. 列出场景 MVT 类型（2D fit / inverted-Y / 相机 / yaw-pitch）。  
5. 对照 checklist L0-1～L0-3（居中、无溢出、LayoutBuilder）；L0-4 按选定范式解释合规方式。

### 7.2 禁止项（布局相关）

| 禁止 | 原因 |
|---|---|
| 主图 `Positioned(left: 常数)` 冒充居中 | 视口一变就歪（L0-1） |
| 主 Canvas 写死 `SizedBox(800,600)` | 不响应式（L0-3） |
| 物理位置用屏幕像素硬编码 | 换分辨率物体错位 |
| footer 占高却不从 center 扣除 | 边格被挤没 |
| `FittedBox` 包无界 Slider | 布局约束爆炸 |
| Material `Icons.refresh` 当 Reset All | 视觉规则阻塞 |

### 7.3 推荐自检视口

| 视口 | 用途 |
|---|---|
| 375×667 | 手机竖屏压力 |
| 1024×768 | 平板横屏 |
| 1920×1080 | 桌面 |
| 320×480 | NineGrid 矮屏降级是否触发 |

（3 视口截图现为建议项，非强制门禁。）

---

## 8. 关键常量速查

```text
# Joist 默认
DEFAULT_LAYOUT_BOUNDS     1024 × 618
MARGIN / MARGIN_SMALL     10 / 5
ResetAllButton.radius     20.5
RESET_ALL_BUTTON_BASE     #F79722

# NineGrid
kMinCenterAreaRatio       0.7
side factor               √ratio ≈ 0.8367
footer max height         min(96, 0.16×H)
min side row height       48

# Density world window
x ∈ [-0.95, 0.95]
y ∈ [-0.50, 0.58]
```

---

## 9. 关键源码索引

| 主题 | 路径 |
|---|---|
| NineGrid 实现 | `lib/common/widgets/nine_grid_layout.dart` |
| 布局硬规则 | `.codebuddy/rules/80-kratos-sim-checklist.mdc` §七 |
| Buoyancy 设计画布 / scale | `lib/buoyancy/layout/buoyancy_global_layout_spec.dart` |
| Density MVT.fit | `lib/density/render/density_mvt.dart` |
| UI 框架说明 | `docs/knowledge/kratos/frontend/ui-framework.md` |
| footer / 比例踩坑 | `docs/knowledge/kratos/notes.md` |
| 拖拽工作区 | `docs/knowledge/kratos/frontend/drag-drop-workspace.md` |
| L0 抽象计划 | `docs/knowledge/kratos-java-simulations/shared-abstraction-plan.md` |
| Reset All | `lib/common/widgets/kratos_reset_all_button.dart` |
| Home 入口 | `lib/screens/home_screen.dart`、`lib/main.dart` |

---

## 10. 一句话记忆

> **控件贴边**：NineGrid 分格，或 Joist「设计画布 × uniform scale」+ AlignBox 锚点。  
> **物体在池子/场景里**：永远走 MVT（2D fit / inverted-Y / 相机），比例来自「世界窗口 ↔ 画布」或「投影矩阵」，不是随手写的 `left/top`。

---

## 修订

| 日期 | 说明 |
|---|---|
| 2026-10-04 | 初稿：开发模式 + 范式 A/B 比例算法 + MVT + 操作清单 |
| 2026-10-04 | 迁至仓库根目录，与 `CLAUDE.md` 平级 |
