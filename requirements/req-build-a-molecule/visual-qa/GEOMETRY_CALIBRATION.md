# GEOMETRY_CALIBRATION · Single Molecule

> Baseline: `visual-qa/reference/single-molecule.png`  
> Source: PhET `assets/build-a-molecule-screenshot-screen1.png` (installed as reference)  
> **[待确认]** 若用户另有本机 runtime 截图，请替换同路径文件后重测。  
> 规则：用 **归一化坐标 / 比例**，禁止硬编码绝对像素。

---

## Image metrics (measured from reference PNG)

| 量 | 归一化 (相对整图宽/高) | Flutter 映射 | 状态 |
|---|---|---|---|
| 整图纵横 | ~1.48 (宽/高) | 桌面主视口 | `[已确认]` 图 |
| 右侧 Your Molecules 宽 | ≈ 0.26–0.30 W | `yourMoleculesWidthFraction = 0.28` clamp 200–280 | `[视觉近似]` |
| 右侧 panel 左边 x | ≈ 0.72 W | `Row` Expanded + SizedBox | `[视觉近似]` |
| 底 Atom Inventory 高 | ≈ 0.20–0.24 H（含 dots） | `inventoryHeightFraction = 0.22` clamp 132–180 | `[视觉近似]` |
| Molecule viewport | 左上 → inventory 顶、panel 左 | `Expanded` 主区 | `[视觉已对齐]` 结构 |
| Collection card 预览高 | ≈ 50px @ 原图密度 → ~0.08 panelH | 固定 `height: 52` | `[视觉近似]` |
| Kit 桶区白底高度 | ≈ 0.14 H | inventory 内 `SizedBox(height: 118)` | `[视觉近似]` |
| Page dots | inventory 下方居中 | `_PageDots` | `[行为一致]` |
| Reset（panel 底黄钮） | panel 底居中 | `BamYourMoleculesPanel` Refresh | `[行为一致]` |
| Reset All（橙圆） | viewport 右下 | `BamMoleculeViewport` | `[行为一致]` |
| Refill（黄方） | viewport 左下 | 同 | `[行为一致]` |
| Top tab 高 | joist nav ≈ 0.06–0.08 H | `KratosTabbedScreen` TabBar | `[视觉近似]` |

---

## Page structure (Flutter)

```
KratosTabbedScreen (TopTabBar)
└─ BamScreenBody
   Column
   ├─ Expanded Row
   │   ├─ Expanded BamMoleculeViewport
   │   └─ SizedBox(w=panelW) BamYourMoleculesPanel
   └─ SizedBox(h=inventoryH) BamAtomInventory
```

无区域互叠的 Stack 布局；viewport 内仅浮动标签/按钮用局部 Positioned。

---

## Preview / 3D

| 区域 | 原版 | Flutter | 标记 |
|---|---|---|---|
| Collection 黑盒缩略图 | `Molecule3DNode` Canvas → Image | `BamMoleculeThumbnail` Canvas | `[源码一致]` 技术路径 |
| 3D 按钮 | `ShowMolecule3DButtonNode` | 绿「3D」→ Dialog | `[行为一致]` |
| Dialog | THREE WebGL | Canvas 拖拽旋转 | `[有意差异]` |

---

## 未改动

molecule database / structures / formula / collection matching 逻辑。
