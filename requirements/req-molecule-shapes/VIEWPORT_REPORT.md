# VIEWPORT_REPORT

本地 `MoleculeShapesScreenView` 构造函数只调用 `super({ tandem })`，**没有**传入 `layoutBounds`。因此两屏的 layout 坐标系继承 joist `ScreenView` 的默认值。

## 证据

1. `js/common/view/MoleculeShapesScreenView.js` 第 37–39 行：`super({ tandem: tandem })`，无 `layoutBounds`。
2. 同文件用 `this.layoutBounds` 摆 Reset、Name 面板、右上控制盒，以及 Real/Model 单选的 `width/2 - 100`。
3. joist 在 2014-12（commit `f094544`，issue joist#640 的说明）把 `ScreenView` 默认 layout 从 768×504 改成 **1024×618**。Home screen 仍单独使用 768×504，那是 joist 主页，不是这两个 Screen。
4. `dependencies.json` 钉的 joist SHA 仓库里已 404（文件后来改成 `.ts`），但本 sim 源码至今仍不覆盖 layoutBounds，默认值没有回到 768×504。

禁止把 768×504 当成 Model / Real Molecules 的 layoutBounds。

## 采用的 layout

| 量 | 值 | 来源 |
|---|---|---|
| layoutBounds | x 0..1024，y 0..618（宽 1024，高 618） | joist `ScreenView.DEFAULT_LAYOUT_BOUNDS`，本 sim 未覆盖 |
| 原点 | 左上，y 向下（Scenery） | ScreenView |
| 可用屏幕 | `layout(viewBounds)` 收到的是窗口去掉导航栏后的区域 | `Sim` resize；导航栏高度随 Home 的 768×504 缩放，不改变 layoutBounds |
| activeScale | `min(screenWidth/1024, screenHeight/618)` | `MoleculeShapesScreenView.layout` |
| 3D 相机 | 位置 `(6, -1.25, 40)`，near 1，far 100，FOV 为 three.js `PerspectiveCamera` 默认 50° | 源码只改了 near/far 和 position |
| 模型原点 | 中心原子 `(0,0,0)`，与相机同一世界尺度 | `doc/implementation-notes.md` |
| 模型单位 | 注释：1 模型单位对应约 5.5 Å 的放大，力常数按这个尺度手调，没有改成 SI | `implementation-notes.md`、`RealMoleculeShape` |

`layoutBounds` 是 UI 布局框，不是 WebGL 画布像素。画布像素等于 sim 窗口尺寸，相机用 `setViewOffset` 对齐到 layout 框的全局边界。

## 控件锚点（layout 坐标）

| 控件 | 锚点 |
|---|---|
| 右上控制栈 | `xAlign right`，`yAlign top`，margin 10 |
| Name 面板 | `xAlign left`，`yAlign bottom`，margin 10 |
| Reset All | right `1014`，bottom `608`（max−10） |
| Real/Model 单选 | top `20`，centerX `1024/2 - 100 = 412` |

Phase 2 不得改用 768×504 或 1024×768 作为这套锚点的分母。
