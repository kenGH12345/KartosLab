# PhetFont mapping — Bending Light

Source of the family is not a screenshot guess.

`scenery-phet/js/sceneryPhetQueryParameters.ts` sets `fontFamily.defaultValue` to `'Arial'`.
`scenery-phet/js/PhetFont.ts` copies that family, then appends `', sans-serif'`.
A numeric `new PhetFont(n)` sets size only. Weight and style stay at the scenery `Font` default (`normal`) unless the call site passes `fontWeight` on the `Text` node.

`scenery/js/util/Font.ts` is not in the local source tree. Weight `normal` is the PhetFont comment and the scenery-phet default path, not a guessed face.

Flutter mapping: `lib/bending_light/phet_font.dart` → `fontFamily: 'Arial'`, `fontFamilyFallback: ['sans-serif']`, `FontWeight.normal`, `FontStyle.normal`.

When a scenery node also has `scale`, the Flutter size is `PhetFont size × node scale`, because the text is a child of that scaled node and Flutter does not scale the whole node.

| PhET Text | Source Font | Flutter Font | Size | Weight | Result |
| --- | --- | --- | --- | ---: | --- |
| Material title | `PhetFont(12)` + `Text` `fontWeight: 'bold'` (`MediumControlPanel.ts`) | Arial, sans-serif | 12 | bold | mapped |
| Material combo items | `PhetFont(10)` | Arial, sans-serif | 10 | normal | mapped |
| Index of Refraction (n) | `PhetFont(12)` | Arial, sans-serif | 12 | normal | mapped |
| n readout | `PhetFont(12)` | Arial, sans-serif | 12 | normal | mapped |
| What is n? | `PhetFont(16)` (`unknownStringProperty`) | Arial, sans-serif | 16 | normal | mapped |
| Objects | `PhetFont(10)` (`PrismToolboxNode.ts`) | Arial, sans-serif | 10 | normal | mapped |
| Reflections / Normal / Protractor labels | `PhetFont(10)` | Arial, sans-serif | 10 | normal | mapped |
| Wavelength nm | no `PhetFont` in bending-light (scenery-phet control, not in tree) | Arial, sans-serif | 12 | normal | family only |
| Ray / Wave | `PhetFont(12)` (`LaserTypeAquaRadioButtonGroup.ts`); Flutter uses `laser.png` icons, not these strings | Arial via `DefaultTextStyle` | 12 | normal | icons, not text buttons |
| Normal / Angles checkboxes | no local `PhetFont` on those rows | Arial, sans-serif | 12 | normal | family only |
| Time chart title | `PhetFont(16)` inside `bodyNode` `scale: 0.93` | Arial, sans-serif | 14.88 | normal | mapped |
| Intensity title | `PhetFont(24)` inside `bodyNode` `scale: 0.6` | Arial, sans-serif | 14.4 | normal | mapped |
| Intensity reading | `PhetFont(25)` inside the same `scale: 0.6` | not a separate Flutter text node | 15 | normal | size recorded, widget still one label |
| Speed title | `PhetFont(10)` | Arial, sans-serif | 10 | normal | mapped |
| Speed reading | `PhetFont(10)` | Arial, sans-serif | 10 | normal | mapped |
| Toolbox chip labels | no `PhetFont` on Intro toolbox chips (icon nodes) | Arial, sans-serif | 10 | normal | family only |
| Probe drag label | not a source text node | Arial, sans-serif | 9 | normal | family only |
| Protractor tick labels | painted in `protractor.png`, not `PhetFont` | asset | — | — | unchanged asset |
| Step + / − | no local `PhetFont` | Arial, sans-serif | 16 | normal | family only |
| Play / pause / speed | joist/scenery-phet time control, not in this tree | Arial via `DefaultTextStyle` | theme | normal | family only |

Arial is the source default. It is not chosen from the screenshot.
