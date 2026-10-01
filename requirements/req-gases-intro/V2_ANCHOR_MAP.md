# V2 PhET Anchor Map — IdealGasLawScreenView

**权威**：`gas-properties-for-gases-intro` @ `10c7c08`  
**Flutter**：`IdealScreenAnchors` + `GasesIntroMvt` + `GasesIntroShell` Stack

MVT（BaseModel）[源码一致]：
```
viewX = 645 + modelX × 0.040
viewY = 475 − modelY × 0.040
```
layoutBounds：1008 × 618 · margins：X/Y = 20 · RIGHT_PANEL_WIDTH = 225

---

## A. PhET Node → Parent → Anchor Target → Rule → Flutter

| PhET Node | Parent | Anchor Target | Anchor Rule (source) | Flutter Equivalent |
|---|---|---|---|---|
| `IdealGasLawContainerNode` | ScreenView | MVT(`container.position`) | bottom-right at (645,475); width/height via MVT | `_PlayCanvas` + `PlayAreaPainter` (full layoutBounds, MVT) |
| Left-wall `HandleNode` | ContainerNode | left wall mid | drag on left wall | `Positioned.fromRect(leftHandleHit)` |
| `IdealGasLawParticleSystemNode` | ScreenView | MVT particle positions | same MVT | painted in play canvas |
| `ContainerWidthNode` | ScreenView | container position + width | `visibleProperty: widthVisible` | painter arrows if `widthVisible` |
| `PressureGaugeNode` | ScreenView | **containerNode** | `left = containerNode.right - 2`; `centerY = MVT(container.top) + 30` | `Positioned` via `IdealScreenAnchors.gauge*` |
| `GasPropertiesThermometerNode` | ScreenView | **containerNode** | `centerX = containerNode.right - 50`; `bottom = MVT(container.top) + 60` | `Positioned` thermometer* |
| `EraseParticlesButton` | ScreenView | **containerNode** + widthNode | `right = containerNode.right`; `top = widthNode.bottom + 5` | `Positioned` erase* |
| `ReturnLidButton` | ScreenView | **container** opening/top | `right = MVT(right−openingRightInset)−30`; `bottom = MVT(top)−15` | `Positioned` when `!lidIsOn` |
| `ParticleTypeRadioButtonGroup` | ScreenView | **containerNode** + layoutBounds | `left = containerNode.right + 20`; `bottom = layout.bottom − Y_MARGIN` | part of `BicyclePumpWidget` column |
| `GasPropertiesBicyclePumpNode` | ScreenView | **radio** + hose→container | `translation = (radio.centerX, radio.top−15)`; hoseOffset = hoseView−pumpPos; height **230** | `Positioned` pump 120×230 |
| `GasPropertiesHeaterCoolerNode` | ScreenView | **container** + layoutBounds | `left = containerViewX − Δx(widthMin)`; `bottom = layout.bottom − Y_MARGIN` | `Positioned` heater* |
| `TimeControlNode` | ScreenView (Base) | **container** + layoutBounds | `left = containerViewX − Δx(widthDefault)`; `bottom = layout.bottom − Y_MARGIN` | `Positioned` `_TimeControl` |
| `ResetAllButton` | ScreenView (Base) | **layoutBounds** | `right = maxX − X_MARGIN`; `bottom = maxY − Y_MARGIN` | `Positioned` reset (resetArrow.png) |
| `toolsParent` / Stopwatch | ScreenView | view coords | initial `(240,15)` BaseModel | `_ToolsMount` SW mount **[待实现]** full node → V3 |
| `CollisionCounterNode` | toolsParent | view coords | Ideal `(40,15)` | `_ToolsMount` CC mount **[待实现]** full node → V3 |
| `IdealControlPanel` | IdealScreenView VBox | **layoutBounds** | `right = maxX − X_MARGIN`; `top = minY + Y_MARGIN`; width 225 | `Positioned` panel column |
| `ParticlesAccordionBox` | IdealScreenView VBox | below ControlPanel | VBox spacing **15** | sibling under ControlPanel |

**谁锚定谁（摘要）** [源码一致]：
- 仪器（Gauge / Thermometer / Erase / Pump·Radio）→ **ContainerNode / container MVT**，不是整屏随意摆放
- Heater / TimeControl → **containerViewX** + layoutBounds.bottom
- Reset / Right panels → **layoutBounds** edges
- toolsParent → 独立 view 坐标挂载点（为 V3）

---

## B. Flutter Layout Tree

```
GasesIntroHome
  FittedBox → SizedBox(1008×618) → TabBarView
    GasesIntroShell
      Stack(clipBehavior: none)  // layoutBounds space
        Positioned.fill _PlayCanvas          // container+particles+handle
        Positioned gauge                     // ← containerNode
        Positioned thermometer               // ← containerNode
        Positioned erase                     // ← container
        Positioned? returnLid                // ← container top
        Positioned pump+type                 // ← container.right + bottom
        Positioned heater                    // ← containerViewX + bottom
        Positioned timeControl               // ← containerViewX + bottom
        Positioned toolsMount SW             // V3 hook @ (240,15)
        Positioned toolsMount CC             // V3 hook @ (40,15)
        Positioned rightColumn               // ControlPanel ‖ Accordion
        Positioned resetAll                  // layoutBounds BR
```

代码：
- `lib/gases_intro/view/gases_intro_mvt.dart`
- `lib/gases_intro/view/ideal_screen_anchors.dart`
- `lib/gases_intro/widgets/play_area_layout.dart`（改用源码 MVT）
- `lib/gases_intro/widgets/gases_intro_shell.dart`（Stack 锚点重构）
