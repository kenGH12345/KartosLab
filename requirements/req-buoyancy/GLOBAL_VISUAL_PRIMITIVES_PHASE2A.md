# GLOBAL_VISUAL_PRIMITIVES_PHASE2A

## Typography

| Role | Font | Size | Weight |
| ---- | ---- | ---: | ------ |
| Panel title | PhetFont | 16 | bold |
| Item / tag readout | PhetFont | 14 | bold |
| Radio | PhetFont | 14 | regular |
| Combo item | PhetFont | 14 | regular |
| Readout | PhetFont | 14 | regular |
| Force label | PhetFont | 12 | bold |
| Fluid level | PhetFont | 18 | — |
| Mass tag | PhetFont | 24 | bold |

## Controls (source widgets — do not Material-substitute)

| Control | Source | Notes |
| ------- | ------ | ----- |
| ResetAll | scenery-phet ResetAllButton | AlignBox R/B |
| Panel | sun Panel + PANEL_OPTIONS | radius 5, fill panelBackground |
| AccordionBox | ACCORDION_BOX_OPTIONS | title left |
| Checkbox | sun Checkbox | display options |
| ComboBox / NumberControl | sun + common views | mass/volume/fluid/gravity |
| Slider thumb | Dimension2(13,22) | THUMB_SIZE |
| Arrow buttons | scale 0.6 | ARROW_BUTTON_SCALE |
| RectangularRadioButtonGroup | sun | Applications mode; Explore mode |
| RectangularPushButton | sun | reset boat |
| InfoButton | scenery-phet | Shapes |

## Panels

| Property | Value |
| -------- | ----- |
| cornerRadius | 5 |
| xMargin / yMargin | 10 |
| fill | DensityBuoyancyCommonColors.panelBackgroundProperty |

## Force visualization (View mapping only)

| Item | Rule |
| ---- | ---- |
| tip | `(0, -Fy * vectorZoom * 20)` |
| zero | \|Fy\| < 0.05 → hide arrow |
| spacing | headWidth+3 between arrows |
| Lab default | forcesInitiallyDisplayed true |

## Z-order (global)

1. skyRectangle (back)
2. THREE sceneNode (pool/ground/fluid/masses)
3. massDecorationLayer / scenery overlays (forces, tags)
4. AlignBox control panels
5. popupLayer (front among screen children)
