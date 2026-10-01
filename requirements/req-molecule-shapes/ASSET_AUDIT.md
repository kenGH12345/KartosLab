# ASSET_AUDIT

统计范围：本地 `assets/`、`js/` 实际引用的几何与依赖。Phase 0 还没有 Flutter 画面，因此 Flutter 侧替代数为 0。后续画面必须保持 **Substituted = 0**。

## 盘点

| 类别 | 数量 | 说明 |
|---|---|---|
| Original assets（运行时几何） | 1 组孤对网格 | `js/common/data/LonePairGeometryData.js`，由 `assets/balloon2*.obj/json` 转换。`LonePairView` 在 WebGL 用高模，Canvas 用 quad 低模 |
| Original assets（OBJ/JSON 源） | 8 | `balloon2.obj/json`、low-res、quad-low-res、expanded-low-res。作者 Blender，见 `assets/balloon-README.txt` |
| 截图 PNG | 6 | `molecule-shapes-screenshot*.png`。实现笔记与代码都不把它们当控件或分子贴图 |
| 位图 UI | 0 | `doc/implementation-notes.md`：`images/` 留空，没有图片 |
| Custom drawn（源码几何） | 原子球、键圆柱、电子小球、键角弧、删除 X、面板/复选框/单选/ComboBox | Scenery + three.js + kite，不是外链图标 |
| Substituted | **0** | 尚未用 Material Icon、emoji 或截图裁切替换任何 source 图形 |

## 运行时谁在用什么

| 视觉 | 来源 | Flutter 阶段要求 |
|---|---|---|
| 孤对电子云 | `LonePairGeometryData` 顶点 | 使用这份网格（或等价 OBJ），禁止两个随便的圆点当最终孤对 |
| 孤对里的电子 | `ElectronView` 球，半径 0.25，局部 `(±0.75, 5, 0)` | CustomPainter / 3D 球，颜色 `lonePairElectron` |
| Model 原子 | `SphereGeometry` 半径 2 | 程序球，中心 `#9F66DA`，径向白 |
| 键 | `CylinderGeometry`，order 决定根数与 `bondRadius * 12/5` 间距 | 单/双/三键不能画成同一根线 |
| Real 原子颜色 | nitroglycerin `Element.color`（依赖不在本仓库） | 按元素符号取 PhET 元素色，不能改成 Model 的紫白 |
| Bonding 缩略图 | 运行时把 `MoleculeView` 渲染成 data URL | 用同一 3D 几何画缩略图，不要另做一套图标 |
| 删除 X | kite 折线，白描边，底 `#d00` | 自绘，不用 `Icons.close` |
| Reset All | scenery-phet `ResetAllButton` | KartosLab `KratosResetAllButton`，半径按 PhET ResetAll（未写明时 20.5） |
| 复选框 / 单选 / ComboBox / 面板 | sun + scenery-phet | 按 PhET 几何画，不用 Material `Checkbox` / `Radio` / `Dropdown` / `Card` 当最终视觉 |
| 截图 PNG | 不参与模拟 | 禁止当背景 |

## 依赖（`package.json` / `dependencies.json`）

直接 phetLibs：`mobius`（three.js 封装）、`nitroglycerin`（元素与化学式下标）。  
preload：`three-r71.js`、CanvasRenderer、Projector、Liberation Sans 数字子集。  
另外源码 import：`axon` `dot` `joist` `kite` `scenery` `scenery-phet` `sun` `tandem` `phet-core`。  
`tambo` 在 `dependencies.json` 中，但 `js/` 内没有声音调用。

## 结论

Source 的分子和孤对是几何驱动，不是一张可 `Image.asset` 的精灵表。Flutter 应加载孤对网格并程序化绘制原子/键。这不算 Substituted。用 Material 图标或截图顶替才算 Substituted，当前为 0。
