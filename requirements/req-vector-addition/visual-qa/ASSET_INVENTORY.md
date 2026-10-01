# Asset Inventory · Vector Addition

> 扫描范围：  
> 1. `phet sourses/vector-addition-main/vector-addition-main`（sim 本体）  
> 2. `phet sourses/scenery-phet`（`dependencies.json` → EraserButton / ResetAllButton）  
> 判定规则：仅当 Original Asset = **NOT FOUND**（含 PhET 源码明确程序化绘制）才允许 `[Custom Draw Required]`。

## Scan summary

| Location | PNG/SVG/JPEG found | UI-icon usable |
|---|---|---|
| vector-addition `assets/` | 7 screenshots only | ❌ (reference captures, not UI chrome) |
| vector-addition `doc/images/` | 2 notes diagrams | ❌ (doc only) |
| vector-addition `js/` | 0 image files | — |
| scenery-phet `images/` | eraser.svg + many unrelated | ✅ eraser.svg for Eraser |
| scenery-phet ResetButton | **no image** (ResetShape Path) | — |

## Inventory table

| UI Element | Original Asset | Type | Original Size | Flutter Asset | Status |
|---|---|---|---|---|---|
| Eraser button icon | `scenery-phet/images/eraser.svg` | SVG | 69.44×55.96 | `assets/phet/vector_addition/scenery_phet/eraser.svg` | **[Original Asset Reused]** |
| Reset All icon | NOT FOUND — `ResetButton.ts`: “Drawn programmatically, does not use any image files.” (`resetArrow.png` unused by ResetButton) | Path/ResetShape | radius≈24 | CustomPaint `_ResetAllPainter` | **[Custom Draw Required]** |
| Components · invisible | NOT FOUND — `createEyeCloseIcon` / FontAwesome `eyeSlashSolidShape` Path | Path | 45×45 | `VaComponentStyleIcon` | **[Custom Draw Required]** |
| Components · triangle | NOT FOUND — `VectorAdditionIconFactory` ArrowNode | Node | 45×45 | `VaComponentStyleIcon` | **[Custom Draw Required]** |
| Components · parallelogram | NOT FOUND — same factory | Node | 45×45 | `VaComponentStyleIcon` | **[Custom Draw Required]** |
| Components · projection | NOT FOUND — same factory | Node | 45×45 | `VaComponentStyleIcon` | **[Custom Draw Required]** |
| Cartesian scene radio | NOT FOUND — `createCartesianSceneIcon` ArrowNode | Node | 45×45 | `VaCartesianSceneIcon` | **[Custom Draw Required]** |
| Polar scene radio | NOT FOUND — `createPolarSceneIcon` ArrowNode | Node | 45×45 | `VaPolarSceneIcon` | **[Custom Draw Required]** |
| Base Vectors checkbox icon | NOT FOUND — `createVectorIcon(50)` ArrowNode | Node | ~50 | `VaVectorCheckboxIcon` | **[Custom Draw Required]** |
| Resultant checkbox icon | NOT FOUND — `createVectorIcon(35)` | Node | ~35 | (text symbol fallback) | **[Custom Draw Required]** |
| Equation type radios | NOT FOUND — EquationTypeRadioButtonGroup + EquationTypeNode (text/Arrow) | Node | — | Text radios | **[Custom Draw Required]** |
| Accordion ± button | NOT FOUND — sun ExpandCollapseButton Path | Path | 22×22 | `_AccordionGlyphPainter` | **[Custom Draw Required]** |
| Screen icons (Explore1D/2D/Lab/Equations) | NOT FOUND in-repo — ScreenIcon factory Nodes | Node | — | n/a (Kartos home card) | — |
| Sim screenshots | `vector-addition/assets/*.png` | PNG | various | `visual-qa/ref/` | reused as **ref only** |

## Mapping chain (Eraser)

```
scenery-phet/images/eraser.svg
        ↓ copy
assets/phet/vector_addition/scenery_phet/eraser.svg
        ↓ pubspec assets:
assets/phet/vector_addition/scenery_phet/
        ↓
SvgPicture.asset(VaAssets.eraserSvg, width: 20)
        ↓
_EraserButton (Explore 1D / 2D / Lab)
```

## Asset QA

- Original assets scanned (sim + scenery-phet images dir): **30+** files enumerated; **1** UI-relevant for this sim chrome
- Assets reused: **1** (`eraser.svg`)
- Custom drawn assets (PhET also procedural): **9** UI glyphs
- Material replacements: **0** (removed `Icons.add` / `Icons.remove` / prior Custom eraser geometry)
- Unverified assets: **0**
- **[ASSET MISMATCH]**: none for elements that have an Original Asset

## Verdict

Eraser: **[Original Asset Reused]**  
All other listed chrome icons: **[Custom Draw Required]** with source citation (no PNG/SVG in PhET for those nodes).
