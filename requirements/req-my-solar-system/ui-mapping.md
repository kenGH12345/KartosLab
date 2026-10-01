# UI Mapping · My Solar System → Flutter

> 原版：joist Screen + AlignBox 贴 `interfaceBounds`。  
> Kratos：`NineGridLayout` 中间格 ≥70% 只放 Play Area；控件进边格或页级 Overlay（对齐 Kepler：Reset 可贴中心格角，不塞进 NineGrid 边格若会挡轨道）。

## 1. 屏结构

| 原版 | Flutter |
|---|---|
| joist 底栏 Intro / Lab | `KratosTabbedScreen`：Intro \| Lab |
| 每屏独立 Model | 每 Tab **独立** Controller（切走 dispose，有意差异同 Kepler） |
| 黑/投影背景 `SolarSystemCommonColors.background` | 只 default 黑底 |
| 强制横屏（Kratos app） | 已有 `main.dart` 横屏 |

## 2. 原版 Align → NineGrid / Overlay

| 原版位置 | 节点 | Flutter |
|---|---|---|
| 铺满 layout | Body + 速度矢 + 重力矢 + CoM + Paths canvas | **center** CustomPaint + 手势层 |
| 右上 VBox | Lab: OrbitalSystemPanel；TimePanel；VisibilityControlPanel | topRight，窄屏可滚 |
| 左上 | Zoom ± | topLeft |
| 顶中 | Return Bodies；gravity offscale 文案 | Overlay 顶中（不进中间格逻辑） |
| 左下 | More Data + Info；ValuesPanel；Bodies；Follow CoM | bottomLeft / footer 左 |
| 右下 | Reset All（父类） | Overlay 右下，对齐 Kepler Reset |
| 底中 | （时间已在右上 TimePanel，无 Kepler 底栏 TimeControl） | 保持右上，不要误搬到底中 |

**注意**：MSS 的 Restart/Play/Step 在 **右上 TimePanel**，不在屏幕底中。不要用 Kepler 底栏布局硬套。

## 3. 控件映射

| 原版 | Flutter L0 / 新建 |
|---|---|
| ComboBox preset | `KratosComboBox` |
| SolarSystemCommonTimeControlNode | **不**用 `TimeControlBar`（缺 Restart≠Reset、缺三速、缺 Clear）→ sim 内 `time_panel.dart`（Kepler 已有同类有意差异） |
| NumberSpinner bodies | 无现成 L0 spinner → sim 内，或 NumberField+按钮；登记 L1 |
| Checkbox 行 | 主题 Checkbox + 文案；CoM 用 CustomPaint 红 X 图标；Path 图标缺 png → 用 Icon/Painter 替代并记录 |
| Mass NumberControl | `KratosSlider` |
| InteractiveNumberDisplay + KeypadDialog | `KratosNumberField` 或 Dialog 数字键盘 |
| MagnifyingGlassZoomButtonGroup | IconButton ± |
| Info Dialog | `AlertDialog` 三则 unitsInfo |
| GravityForceZoomControl | `KratosSlider` 绑定 gravityForceScalePower，仅 gravity 开时可用 |
| Measuring tape | Kepler 已有测量尺 Painter/手势可参考，**不改 Kepler 文件**，本 sim 复制或后续上抽 |
| Grid | Kepler `grid_painter` 模式复制 |

## 4. 视觉常量 `[二次证据 PANEL_OPTIONS]`

- 面板 fill 深灰、cornerRadius 5、margin 10
- VBox spacing 7 / 7.5（Visibility vs ScreenView topRight 7.5）
- 字体 16 / 标题 18
- Follow CoM 按钮 `baseColor: orange`
- Body 颜色：黄 / 品红 / 青 / 绿
- Path strokeWidth 3

## 5. 响应式

原版 `interfaceBoundsProperty` + AlignBox，无独立 mobile layout 文件。  
Kratos 必须：375×667 / 1024×768 / 1920×1080 无溢出；中间格 LayoutBuilder 算 MVT。

窄屏风险：左下 ValuesPanel（More Data 后 6 列）+ 右上双面板。允许边格滚动，禁止压扁 Canvas 到不可见。

## 6. Z-order（原版 layer）

1. bottomLayer：Paths  
2. bodiesLayer：BodyNode  
3. componentsLayer：速度、重力、CoM  
4. interfaceLayer：全部面板与按钮  

手势：Body / 速度矢在画布上，面板在上且进入 drag bounds 避让列表。

## 7. 文案（英，一期）

Title: My Solar System。屏名 Intro / Lab。Preset 用 strings_en。Home 中文组名「天体力学」不变；卡片标题可用英文专名（同 Kepler's Laws）。
