# PHASE 0 SOURCE AUDIT — PhET Friction → Flutter

## Source version
- Package: `friction` **1.7.0-dev.0** (`package.json`)
- Repo: https://github.com/phetsims/friction.git
- Local: `phet sourses/friction-main/friction-main`

## Source structure
```
js/friction-main.js          # entry, LAYOUT_BOUNDS 768×504
js/friction/
  FrictionConstants.js
  model/FrictionModel.js, Atom.js
  view/FrictionScreenView.js
  view/book/{BookNode,CoverNode,BookRubSoundGenerator,...}
  view/magnifier/{MagnifierNode,AtomCanvasNode,MagnifierTargetNode}
  view/FrictionDragListener.js, FrictionKeyboardDragListener.js
sounds/*.mp3                 # pickup/drop/contact/breakOff (+ NoiseGenerator for rub)
doc/model.md, implementation-notes.md
```

## Screens
- Single screen: Friction (white background)

## Models
- **FrictionModel**: qualitative; primary state = `vibrationAmplitudeProperty` (atom oscillation = “temperature”)
- Heating: on contact + horizontal drag, `dx * HEATING_MULTIPLIER(0.0075)`
- Cooling: each step `amplitude *= (1 - dt * COOLING_RATE(0.2))`
- Shear-off: when amplitude > 7, random shearable atom shears; cools by 0.01
- Top book position Vector2; drag bounds ±600 x, y ∈ [−70, distance]
- `bookDraggingScaleFactor = 0.025` (macro book view mapping)

## Views
- Physics book (fixed) @ (50, 225); Chemistry book (draggable) @ (65, 209)
- MagnifierNode 690×300 @ (40, 25), ROUND=30, stroke 5
- MagnifierTargetNode dashed lines to book interface
- ThermometerNode @ (690, 250), tubeHeight 160, bulbDiameter 24
- ResetAllButton radius 22 @ (0.94w, 0.9h)
- Atoms via AtomCanvasNode (ShadedSphere → canvas images)

## Assets
- **No PNG book/atom assets** — books = CoverNode Path geometry; atoms = shaded spheres
- Sounds: simplePickup/Drop, harpPickup/Drop, contactLower, breakOffAutosinfonieSpatialized
- Rub + molecule motion + cooling = Tambo *NoiseGenerator* (procedural; Flutter P2 proxy)

## Sounds
| File | Use |
|------|-----|
| simplePickup/Drop | Macro book grab/release |
| harpPickup/Drop | Magnifier grab/release |
| contactLower | Books enter contact |
| breakOff… | Atom shear (every 4th) |
| (NoiseGenerator) | Rub / molecule / cooling |

## Interactions
- Pointer drag Chemistry book (macro + magnifier)
- Keyboard: Arrow / WASD, Shift = slower (dragSpeed 1000 / shift 500)
- Grab/Drag a11y pattern (PDOM / Voicing) — Flutter: Focus + keyboard; full voicing = P2

## Keyboard
- Move: arrows / W A S D
- Slower: Shift + same
- Grab/release (Space) in PhET GrabDragInteraction — Flutter: focus then keys

## Accessibility
- Full PDOM + Voicing + Interactive Description in PhET
- Flutter MVP: Semantics labels + keyboard drag; voicing alerts = P2

## Core physics
```
relative motion while contact → heating (amplitude↑)
→ atoms vibrate with amplitude
→ amplitude > 7 → shear off atoms → slight cooling
→ continuous cooling while not heating
thermometer = map(amplitude, ~−0.05 .. ~7.7)
```

## Known Risks
1. Procedural NoiseGenerator rub/cooling sounds hard to port 1:1 (P2)
2. CoverNode page geometry must match Path math exactly
3. Atom count ~200; need CustomPainter not per-widget
4. Dual drag surfaces (macro + magnifier) share one position property
5. bookDraggingScaleFactor makes macro motion subtle — easy to get wrong
