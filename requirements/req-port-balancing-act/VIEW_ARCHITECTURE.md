# Balancing Act — View Architecture

> Phase 0 · Source-only · 2026-09-23

---

## 1. Layout bounds & responsive

| Item | Value |
|------|-------|
| `layoutBounds` | `Bounds2(0, 0, 768, 504)` |
| Mode | Fixed design viewport；Joist ScreenView 等比适配窗口 |
| Reset All scale | 0.96 |

---

## 2. Model-View Transform

### Intro / Lab (`BasicBalanceScreenView.ts` L107–111)

```typescript
ModelViewTransform2.createSinglePointScaleInvertedYMapping(
  Vector2.ZERO,
  new Vector2( layoutBounds.width * 0.375, layoutBounds.height * 0.79 ),
  105
);
```

| Param | Value |
|-------|-------|
| Model origin in view | `(768×0.375, 504×0.79) = (288, 398.16)` |
| Scale | **105 px/m** |
| Y | Inverted |

### Game (`BalanceGameView.ts`)

| Param | Value |
|-------|-------|
| Origin offset | `(width×0.45, height×0.86)` |
| Scale | **115 px/m** |

**Flutter 必须保持相同 MVT 语义**：禁止把 model 米直接当 Flutter 像素。

---

## 3. Node trees

### BasicBalanceScreenView (Intro / Lab base)

```
ScreenView
└── root (Node)
    ├── OutsideBackgroundNode          [Decoration] sky+ground
    ├── nonMassLayer
    │   ├── FulcrumNode                [Model-driven] PROCEDURAL Path
    │   ├── PlankNode                  [Model-driven] PROCEDURAL
    │   ├── AttachmentBarNode          [Model-driven] PROCEDURAL
    │   ├── LevelSupportColumnNode ×2  [Model-driven] PROCEDURAL（ColumnState）
    │   ├── RotatingRulerNode          [Control/View] scenery-phet Ruler
    │   ├── PositionMarkerSetNode      [Control/View]
    │   ├── LevelIndicatorNode         [Control/View] bubble level
    │   ├── Force vectors              [Model-driven] MysteryVectorNode | PositionedVectorNode
    │   ├── ColumnOnOffController      [Control] ABSwitch Panel
    │   ├── controlPanelsVBox          [Control]
    │   │   ├── Panel(Show + VerticalCheckboxGroup)
    │   │   └── PositionIndicatorControlPanel
    │   └── ResetAllButton             [Control]
    └── massesLayer
        └── MassNodeFactory → BrickStackNode | ImageMassNode | MysteryMassNode  [Interactive]
```

### BAIntroView
- 继承基类；仅为 mass 挂落点 `lazyLink`；**无额外子节点**

### BalanceLabScreenView
- 继承基类；`controlPanelVBox.addChild(MassCarousel)`

### BalanceGameView（独立，不继承 BasicBalance）

```
ScreenView
├── rootNode
│   ├── OutsideBackgroundNode
│   ├── controlLayer
│   ├── challengeLayer
│   │   ├── FulcrumNode, TiltedSupportColumnNode, LevelSupportColumnNode×2
│   │   ├── PlankNode, AttachmentBarNode
│   │   ├── mass nodes (movable / fixed)
│   │   ├── challengeTitleNode, MassValueEntryNode, TiltPredictionSelectorNode
│   │   ├── LevelIndicatorNode, RotatingRulerNode, PositionMarkerSetNode
│   │   └── PositionIndicatorControlPanel
│   ├── StartGameLevelNode             [choosingLevel]
│   └── Check / Next / TryAgain / ShowAnswer buttons
├── FiniteStatusBar
└── FaceWithPointsNode
(+ LevelCompletedNode at runtime)
```

---

## 4. Procedural vs image nodes

| Element | Type | Notes |
|---------|------|-------|
| Fulcrum | PROCEDURAL | fill `rgb(240,240,0)` stroke black |
| Plank | PROCEDURAL | fill `rgb(243,203,127)`；tick marks |
| Attachment bar | PROCEDURAL | |
| Support columns | PROCEDURAL | scenery-phet LevelSupportColumnNode 样式 |
| Column toggle icons | PROCEDURAL | `ColumnControlIcon`（assets 下 SVG 未运行时 import） |
| Brick stacks | PROCEDURAL Shape | `BrickStackNode` |
| Image masses | ORIGINAL SVG/PNG | `images/objects/*` + regional people |
| Mystery masses | ORIGINAL SVG | mysteryObject01–08 |
| Background | scenery-phet OutsideBackgroundNode | sky gradient + green ground |
| Game level icons | ORIGINAL SVG | gameLevel1–4Icon.svg |
| Screen icons | ORIGINAL | introIcon / labScreenIcon / gameIcon |

---

## 5. Typography (source-explicit)

| Constant | Value | File |
|----------|-------|------|
| Panel title | `PhetFont(16)` | BasicBalanceScreenView |
| Panel option | `PhetFont(14)`, maxWidth 130 | same |
| Carousel title | `PhetFont(16)` | MassCarousel |
| Game buttons | `PhetFont(24)` | BalanceGameView |
| Status bar | `PhetFont(14)` | BalanceGameView |

面板填充：`rgb(240, 240, 240)`。

---

## 6. Key colors (source-explicit)

| Element | Color |
|---------|-------|
| Fulcrum | `rgb(240, 240, 0)` |
| Plank | `rgb(243, 203, 127)` |
| Level indicator active | `rgb(173, 255, 47)` |
| Level indicator inactive | `rgb(230, 230, 230)` |
| Panel fill | `rgb(240, 240, 240)` |
| Game button | `Color(0, 255, 153)` |
| Status bar | `rgb(36, 88, 151)` |
| Reset All | scenery-phet 标准橙 `#F79722`（项目 L0 `KratosResetAllButton`） |

未在源码写死的天空/草地色 → 由 `OutsideBackgroundNode` 提供（scenery-phet）。

---

## 7. Dependency migration notes (View)

| Lib | Must vendor / reimplement? | Notes |
|-----|---------------------------|-------|
| scenery-phet ResetAllButton | Flutter → **KratosResetAllButton**（项目硬规则） | radius 跟 PhET；未写明用 20.5 |
| OutsideBackgroundNode | 需对齐 sky/ground | |
| vegas Game UI | 自建选关/计分/Face | Game 阻断级依赖 |
| sun controls | Flutter 原生等价 | Checkbox / Radio / Carousel / Switch |
| twixt | 不需要 | js 未直接使用 |
