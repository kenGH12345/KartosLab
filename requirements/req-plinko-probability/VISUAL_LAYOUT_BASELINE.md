# VISUAL_LAYOUT_BASELINE · Plinko Probability

> PhET reference layoutBounds ≈ **1024 × 618**  
> Board face reference：**600 × 300**（`Board.js`）  
> MVT：`createRectangleInvertedYMapping(GALTON_BOARD_BOUNDS → view triangle)`

## Screen: Intro / Lab (shared scene)

| Component | x (ref) | y (ref) | width | height | anchor | scale | Notes |
|---|---|---|---|---|---|---|---|
| Hopper | centerX = 512−80 = 432 | top=10 | ~70 top | thickness≈28 | top-center | layout | bottomWidth ∝ rows |
| Board triangle | x=hopper.centerX | top=hopper.bottom+10 | 600 | 300 | top-center | layout | origin top apex |
| Pegs | via MVT | via MVT | — | — | model pos | 1/(n+1) | Intro circle; Lab rotate |
| Histogram / Cylinders | HISTOGRAM_BOUNDS via MVT | | width=1 model | | | | below board |
| IntroPlayPanel | right | top≈16 | ~280 | ~80 | top-right | 1 | |
| NumberBallsDisplay | right | below play | ~120 | ~44 | | | Intro only |
| Lab PegControls | right | below play | ~260 | ~200 | | | Lab only |
| Statistics box | right | bottom≈80 | ~280 | ~180 | | | Lab only |
| HistogramModeControl | left≈24 | top≈100–120 | 52 | 52×N | | | PNG icons |
| HopperModeControl | center-x | bottom≈70 | | | | | Lab only |
| Eraser | left≈28 | bottom≈70 | 48 | 48 | | | |
| Sound + ResetAll | right≈24 | bottom≈16 | | | | Reset radius 20.5×0.75 | |

## Flutter mapping

`PlinkoMvt.fromCanvasSize` fits 1024×618 into canvas with uniform scale; board left/top derived from hopper position.

## Open geometry polish items

1. Exact PegsNode paint scale / shadow offset vs ORIGINAL
2. Cylinder ellipse perspective match
3. TrajectoryPath for Lab path mode (painter TBD)
4. Statistics accordion minimize chrome
5. Pixel-align control panels vs ORIGINAL screenshots
