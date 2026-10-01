# PHASE 0 — DEPENDENCY MAP · Wave on a String

Local: `dependencies.json` + TypeScript imports under `js/`.

## Direct sim modules (in-repo)

```text
js/wave-on-a-string-main.ts
js/waveOnAString.ts
js/WaveOnAStringFluent.ts
js/WaveOnAStringStrings.ts
js/wave-on-a-string/model/*
js/wave-on-a-string/view/*
js/wave-on-a-string/WOASConstants.ts
images/*
```

## PhET common libraries (imported; sibling repos in full PhET checkout)

| Library | Used for |
| ------- | -------- |
| joist | Sim, Screen, ScreenView, simLauncher |
| axon | Property, Emitter, EnumerationProperty, Multilink, … |
| dot | Range, Utils.linear, Vector2, Bounds2, clamp |
| kite | Shape |
| scenery | Node, Path, Image, Line, Circle, layout |
| scenery-phet | ResetAllButton, TimeControlNode, RulerNode, Stopwatch, Sound*DragListener, ArrowNode, PhetFont, TimeSpeed |
| sun | Panel, Separator, checkbox/radio/NumberControl pieces |
| tandem | Tandem, PhET-iO IOType |
| phetcommon | ModelViewTransform2 |
| phet-core | optionize, Enumeration |
| brand / chipper / babel | build/i18n (toolchain) |

## KartosLab Flutter implication (audit only)

- Prefer existing L0: `KratosResetAllButton`, shared time control / stopwatch / ruler patterns if already ported elsewhere.
- Core wave math has **no** external physics library — port `WOASModel` logic directly.
- Bitmap assets listed in `ASSET_MAP.md` must ship with the Flutter sim.
