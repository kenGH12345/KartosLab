# PHASE 0 — VIEW SOURCE MAP · Wave on a String

Local source: `phet sourses/wave-on-a-string-main/wave-on-a-string-main`  
Version: **1.3.0-dev.0**

| Source Node | Role | Asset / Drawing | Model dependency | Interaction |
| ----------- | ---- | --------------- | ---------------- | ----------- |
| `WOASScreenView` | Root ScreenView; MVT; z-order; layout | Joist layoutBounds | entire model | owns frameEmitter |
| `StringNode` | Beads + connecting Path | Circle→toDataURL Images; Path stroke `#F00` | `yDraw`, `nextLeftYProperty`, `yNowChangedEmitter` | none (display) |
| Beads (×61) | Discrete markers | red regular / cyan every 10th; bead0×1.2 | `yDraw[i]` | none |
| `centerLine` | Equilibrium dashed line | Line `#6c4a1d` dash `[8,5]` lw 2 | MVT y=0 | **not** draggable; always on |
| `ReferenceLine` | Draggable horizontal ref | Path + handle gradients | `referenceLineVisibleProperty`, `referenceLinePositionProperty` | Sound drag + keyboard |
| `StartNode` | Left apparatus host | composes wrench / oscillator / pulse UI | `waveModeProperty` | delegates |
| `WrenchNode` | Manual drive | `wrench.png` + ArrowNodes | `nextLeftYProperty`, arrows visible, `isPlaying` | vertical drag/keyboard |
| Oscillator visuals (in StartNode) | Oscillate mode graphic | scenery nodes / wheel offset | mode + amplitude/angle | display / follow |
| `PulseButton` | Fire pulse | green button color property | `manualPulse`, pulse active | press |
| `EndNode` | Right boundary visuals | clamp / ring / window PNGs + post gradient | `stringEndTypeProperty`, last bead Y (loose) | display |
| `windowImage` | No-end front pane | `windowFront.png` | `NO_END` visibility | display (z above string) |
| `endNode.windowNode` | No-end back pane | `windowBack.png` | `NO_END` | behind string |
| `WOASRadioButtonGroup` (mode) | Manual/Oscillate/Pulse | Panel `#D9FCC5` | `waveModeProperty` | radio |
| `WOASRadioButtonGroup` (end) | Fixed/Loose/No End | Panel | `stringEndTypeProperty` | radio |
| `BottomControlPanel` | Sliders + tool checkboxes | NumberControls; separator | damping/tension/amp/freq/pulseWidth; tools | mode-dependent children |
| `WOASNumberControl` | Labeled slider+display | sun NumberControl styling | ranged properties (tension/damping ×100 UI) | keyboard steps |
| Checkbox group | Rulers / Stopwatch / Reference Line | sun checkboxes | visibility properties | toggle |
| `RulerNode` ×2 | Measurement | scenery-phet RulerNode | positions + `rulersVisibleProperty` | drag/keyboard |
| `StopwatchNode` | Timer tool | scenery-phet | `model.stopwatch` | drag; play/pause/reset on tool |
| `TimeControlNode` | Play/Pause/Step + Normal/Slow | scenery-phet | `isPlayingProperty`, `timeSpeedProperty`; Step→`manualStep` | buttons/radios |
| `RestartButton` | Soft string reset | light-blue round | `manualRestart` | press |
| `ResetAllButton` | Full reset | scenery-phet orange | `model.reset` | press |
| `WaveGenerationParagraphsNode` | a11y wave description paragraphs | text | model state | PDOM |
| `WOASScreenSummaryContent` | Screen summary | text | model | a11y |
| `WOASKeyboardHelpContent` | Keyboard help | help content | — | dialog |
| Background | Play area fill | `#FFFFB7` | `WOASColors.backgroundColorProperty` | — |

## MVT

```text
ModelViewTransform2.createSinglePointScaleMapping(
  Vector2.ZERO,
  (VIEW_ORIGIN_X=150, VIEW_ORIGIN_Y=265),
  SCALE_FROM_ORIGINAL=1.25
)
```

Bead view X: `modelToViewX(i * MODEL_UNITS_PER_GAP)`.

## Mode → visible controls (BottomControlPanel)

| Mode | Controls shown |
| ---- | -------------- |
| MANUAL | Damping, Tension |
| OSCILLATE | Amplitude, Frequency, Damping, Tension |
| PULSE | Amplitude, Pulse Width, Damping, Tension |
