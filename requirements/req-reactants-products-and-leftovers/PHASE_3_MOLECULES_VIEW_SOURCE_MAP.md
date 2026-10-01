# PHASE_3 — Molecules View Source Map

本地基准：`js/molecules/` + `js/common/view/`  
日期：2026-09-22

## Hierarchy

```text
MoleculesScreenView extends RPALScreenView
├── ReactionBarNode
│   ├── bar (STATUS_BAR_FILL)
│   ├── ReactionRadioButtonGroup
│   │   └── Make Water | Make Ammonia | Combust Methane
│   └── MoleculesEquationNode (RichText symbols + coefficients)
├── sceneNodes
│   └── MoleculesSceneNode extends RPALSceneNode
│       ├── StacksAccordionBox "Before Reaction"
│       ├── RightArrowNode
│       ├── StacksAccordionBox "After Reaction"
│       └── QuantitiesNode (showSymbols: true)
└── ResetAllButton scale 0.75
```

## Differences vs Sandwiches

| | Sandwiches | Molecules |
|---|---|---|
| Equation | image coeffs / sandwich icon | coefficient + RichText formula |
| Titles | Before/After **"Reaction"** | Before/After **Reaction** |
| showSymbols | false | **true** |
| boxYMargin | 8 | 6 (default) |
| minIconSize | max sandwich | 30×25 |
| contentSize | 310×240 | 310×240（同） |
| Show/Hide Game controls | 无 | **无** |

共享：`RPALScreenView`、`StacksAccordionBox`、`StackNode`、`QuantitiesNode` 布局、`createXOffsets`、layout **835×504**。

## Reactions（MoleculesModel / ReactionFactory）

1. Make Water — `2 H₂ + 1 O₂ → 2 H₂O`
2. Make Ammonia — `1 N₂ + 3 H₂ → 2 NH₃`
3. Combust Methane — `1 CH₄ + 2 O₂ → 1 CO₂ + 2 H₂O`

## Molecule visuals

Source：`nitroglycerin` `*Node`（非 PNG）。Flutter：CustomPainter 复刻 AtomNode + 几何布局。

Molecules Screen 分子集合：`H₂ O₂ H₂O N₂ NH₃ CH₄ CO₂`

## Quantity

`QUANTITY_RANGE` 0–8；Before 侧 NumberSpinner；After 只读。

## Accordion

与 Sandwiches **同一** `StacksAccordionBox` 组件类；Molecules 仅改 title 字符串与 boxYMargin/minIcon。

## Reset

`model.reset()` + before/after expanded = true。
