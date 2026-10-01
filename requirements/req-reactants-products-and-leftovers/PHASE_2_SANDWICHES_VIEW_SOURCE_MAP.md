# PHASE_2 — Sandwiches View Source Map

本地基准：`js/sandwiches/` + `js/common/view/`  
日期：2026-09-22

## Node Hierarchy（SandwichesScreenView）

```text
SandwichesScreenView extends RPALScreenView
├── ReactionBarNode
│   ├── barNode (Rectangle, STATUS_BAR_FILL, full visible width)
│   ├── ReactionRadioButtonGroup (right, X_MARGIN=20)
│   │   └── AquaRadioButton × 3 (Cheese / Meat and Cheese / Custom)
│   └── equationNode
│       └── SandwichesEquationNode × 3 (visible when selected)
├── sceneNodes
│   └── SandwichesSceneNode × 3 (visible when selected)
│       ├── HBox spacing 10
│       │   ├── StacksAccordionBox (Before "Reaction")
│       │   │   └── StackNode × N reactants
│       │   ├── RightArrowNode (scale 0.75, STATUS_BAR_FILL)
│       │   └── StacksAccordionBox (After "Reaction")
│       │       └── StackNode × (products + leftovers)
│       └── QuantitiesNode (top = before.bottom + 6)
│           ├── reactants: NumberSpinner + icon + bracket "Reactants"
│           ├── products: NumberNode + icon + bracket "Products"
│           └── leftovers: NumberNode + icon + bracket "Leftovers"
└── ResetAllButton (scale 0.75, right-10, bottom-10)
```

## Viewport

| Constant | Value |
|---|---|
| layoutBounds | 835 × 504 |
| SANDWICHES_BEFORE_AFTER_BOX_SIZE | 310 × 240 |
| QUANTITY_RANGE | 0–8 |
| SANDWICH_COEFFICIENT_RANGE | 0–3 |
| scene top | reactionBar.bottom + 12 |
| boxYMargin | 8 |
| showSymbols | false |

详见 `RPL_SANDWICHES_VIEWPORT_REPORT.md`。

## Recipe Selector

- `ReactionRadioButtonGroup`：vertical AquaRadio，radius 8，spacing 10，白字 PhetFont 16
- 顺序：Cheese → Meat and Cheese → Custom
- 绑定 `model.reactionProperty`

## Equation（SandwichesEquationNode）

- 系数（Custom 用 NumberSpinner 0–3；静态用 Text）
- 原料图标（bread/meat/cheese，scale 0.65）
- PlusNode 白 / RightArrowNode 白
- 右侧 sandwich 图标 或 `No\n"Reaction"`（isReaction==false）

## StacksAccordionBox

- AccordionBox：fill white，stroke DARK_BLUE α0.3，cornerRadius 3
- titleBar：STATUS_BAR_FILL，白字 14，标题居中，按钮左（减号/加号）
- StackNode：eager max=8 icons，visibility 按 quantity，**无动画**（立即显隐）
- deltaY = (boxH − 2×margin − maxIconH) / (maxQuantity − 1)

## QuantitiesNode

- interactiveBox = BEFORE（Sandwiches）
- NumberSpinner font 28；图标在数字下方；bracket 在下方
- createXOffsets：n>2 时 xMargin=0，否则 0.15×boxWidth

## Assets

| File | Role |
|---|---|
| bread.png | ingredient + sandwich 层 |
| cheese.png | ingredient + sandwich 层 |
| meat.png | ingredient + sandwich 层 |

SandwichNode：Y_SPACING=4，SANDWICH_SCALE=0.65，交错堆叠算法见 source。

## Animation

| 元素 | Source 行为 | Flutter |
|---|---|---|
| Stack quantity | 立即 visible | 立即显隐，不加动画 |
| Accordion expand | sun AccordionBox 高度动画 | AnimatedSize |
| Reset button | press/release | KratosResetAllButton |

## View vs Model

| State | Owner |
|---|---|
| recipe, quantities, coefficients | SandwichesModel |
| beforeExpanded, afterExpanded | View（BooleanProperty，reset 时一并恢复） |

## 禁止

- Game Show All / Hide Molecules / Hide Numbers
- Material DropdownButton / Icons.lunch_dining
- 修改 Phase 1 Reaction 计算
