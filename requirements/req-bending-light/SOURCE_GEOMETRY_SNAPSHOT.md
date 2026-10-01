# Source geometry snapshot

Local source: bending-light `1.3.0-dev.0`. Numbers below are source constants or anchor formulas. A blank width/height means scenery measures it from text or children. Those sizes were not taken from a screenshot.

Coordinate meaning: scenery `left` / `top` / `right` / `bottom` are in the parent, which for screen children is the 834×504 `layoutBounds`. `setTranslation` sets the node origin. `center` is the node center. `FloatingLayout` then overwrites the edge it names.

## Screen root

`BendingLightScreenView` `layoutBounds` is `Bounds2(0, 0, 834, 504)`. The comment says this must not be changed to the joist default.

MVT: `scale = 504 / modelHeight`. View origin `(388 - horizontalPlayAreaOffset, 252 + verticalPlayAreaOffset)`.

| Screen | horizontal offset | vertical offset | view origin |
| --- | ---: | ---: | --- |
| Intro | 102 | 0 | (286, 252) |
| More Tools | 0 | 0 | (388, 252) |
| Prisms | 240 | -43 | (148, 209) |

Child order of the screen, back to front:

| Node | Parent | z-order |
| --- | --- | ---: |
| mediumNode | screen | 1 |
| beforeLightLayer | screen | 2 |
| beforeLightLayer2 | screen | 3 |
| light nodes | screen | 4 |
| singleColorLightNode | screen | 5 |
| afterLightLayer | screen | 6 |
| laserViewLayer | screen | 7 |
| laser handles | screen | 8 |
| laserNode | screen | 9 |
| afterLightLayer2 | screen | 10 |
| afterLightLayer3 | screen | 11 |

`afterLightLayer3` is above `afterLightLayer2`. The source comment says sensors go behind the right panels.

## Intro / More Tools panels

`INSET = 10`. `FloatingLayout`: `leftRightPadding = 10`, `topBottomPadding = 15`, `floatFraction = 0.3`.

At the default 834×504 visible bounds:

| Node | Parent | anchor | x / y | scale |
| --- | --- | --- | --- | ---: |
| top MediumControlPanel | afterLightLayer3 | bottom = `modelToViewY(0) - 2*INSET + 4` = 236; `floatRight` sets right = 824 | right 824 | 1 |
| bottom MediumControlPanel | afterLightLayer3 | top = `modelToViewY(0) + 2*INSET + 1` = 273; right = 824 | top 273 | 1 |
| laser Panel | laserViewLayer | `floatLeft` left = 10; `floatTop` top = 15 | left 10, top 15 | 1 |
| checkbox VBox | beforeLightLayer2 | `floatLeft` left = 20; `floatBottom` bottom = 489 | left 20 | 1 |
| toolbox Panel | beforeLightLayer2 | left = 10; bottom = checkbox.top - 10 | left 10 | 1 |
| reset | afterLightLayer2 | right = 824; bottom = 489; radius 19 | — | 1 |
| time control | beforeLightLayer | `x = normalLine.centerX`; bottom = 489 | x = view origin x | 1 |

The initial `laserViewYOffset` and the medium-panel x offset are overwritten by `FloatingLayout` once `visibleBoundsProperty` fires.

Laser panel paint: `cornerRadius 5`, `xMargin 9`, `yMargin 6`, fill `#EEEEEE`, stroke `#696969`, `lineWidth 1.5`.

Medium panel inner `Panel`: fill `#EEEEEE`, stroke `#696969`, `xMargin 13.5`, `yMargin` 7 on Intro/More Tools and 6 on Prisms, `cornerRadius 5`, `lineWidth 1.5`, `resize: false`. The constructor default fill `#f2fa6a` is not the panel that is added.

Slider when the readout is visible: track `Dimension2(210, 1)`, thumb `Dimension2(10, 20)`, major tick length 11. Index readout box `Rectangle(0, 0, 45, 20)`. Arrow buttons scale 0.7, spacing 4.

## Toolbox

Parent: `beforeLightLayer2`, added after the checkbox, before the protractor and intensity nodes.

| Node | Parent | constants |
| --- | --- | --- |
| toolbox Panel | beforeLightLayer2 | `xMargin 10`, `yMargin 10`, fill `#EEEEEE`, stroke `#696969`, `lineWidth 1.5` |
| VBox | toolbox | `spacing 10`, `excludeInvisibleChildrenFromBounds: false` |
| protractor icon | VBox | `ProtractorNode.createIcon` scale 0.24 |
| intensity icon | VBox | live node hidden while the tool is out |
| extra icons | VBox | More Tools adds wave icon scale 0.4 and velocity icon scale 1.2 |

Drag preview is the real node, shown by setting `enabled = true` and forwarding the pointer. It is not a second scaled copy left on screen. The toolbox icon scale is only the icon.

Occupied item: `visible = !enabled`.

## Prisms

| Node | Parent | anchor |
| --- | --- | --- |
| environment panel | afterLightLayer2 | `floatTop` top = 15; `floatRight` right = 824 |
| laser type radios | afterLightLayer2 | top = environment.bottom + 15; `floatRight` |
| wavelength panel | afterLightLayer2 | top = radios.bottom + 15; fill `#EEEEEE`; `xMargin 10`; `yMargin 6` |
| prism toolbox | afterLightLayer | left = 12; `floatBottom` bottom = 489 |
| protractor | afterLightLayer | scale 0.46; center follows a property |
| reset | afterLightLayer2 | `floatRight` and `floatBottom`; radius 19 |

## Wave graph

`WaveSensorNode.bodyNode` children, then `scale: 0.93`, then `center = modelToView(bodyPosition)`.

| Node | local bounds | paint |
| --- | --- | --- |
| outer Rectangle | 0,0,135,100 corner 5, lineWidth 2 | fill gradient `(0,0)-(0,100)` `#5EB4DE` to `#005B86`; stroke `#2F9BCE` to `#00486A` |
| inner Rectangle | 130×90, centered | fill `#0078B0`, stroke `#0081BE` |
| innerMost ShadedRectangle | `Bounds2(10, 0, 132.3, 63)`, center `(67.5, 40)`, corner 5 | base white, light from rightBottom |
| title | `PhetFont(16)`, `y = bodyNode.height * 0.82` | white |
| ChartNode | `innerMost.bounds.eroded(3)` | grid then series |

`135 * 0.93 = 125.55`, `100 * 0.93 = 93`. The older “126×93” is that body rounded. A 136×100 pixel box on a 1024×618 capture is that body after the viewport scale `569/504` (about 142×105) plus a loose color bbox. It is not a second design size.

Grid: `lineWidth 2`, `strokeStyle 'lightGray'`, dash `[10, 5]`. One horizontal line at model y = 0. Vertical lines every `timeWidth/4`, `timeWidth = 72e-16`. Series `lineWidth 2`. No numeric ticks.

## Z-order, More Tools

Back to front: toolbox (`beforeLightLayer2`) , light, laser, wave sensor (`afterLightLayer2`), right panels (`afterLightLayer3`).

Graph is in front of the toolbox. Right panels are in front of the graph. This is the source order, not a screenshot choice.
