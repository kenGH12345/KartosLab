# Build an Atom — Symbol Mapping

Locked sources:
- `shred` `SymbolNode.ts` @ `427a2abe…`
- `build-an-atom` `BAASymbolNode.ts` / `SymbolScreenView.ts`

## Screen composition

```text
SymbolScreen
 └── SymbolScreenView extends BAAScreenView
      ├── InteractiveSchematicAtom (shared)
      ├── ParticleCountDisplay
      ├── PeriodicTable accordion (expanded default)
      ├── Symbol accordion ← Symbol-only
      │    └── BAASymbolNode (scale 0.41)
      ├── AtomAppearanceCheckboxGroup
      ├── ElectronModelControl
      └── ResetAllButton (r=20)
```

**Not present on Symbol Screen** (Atom-only): Net Charge accordion, Mass Number accordion.

Background: `#F9FFE5` (`BAAColors.symbolsScreenBackgroundColorProperty`).

## BAASymbolNode

```text
BAASymbolNode extends SymbolNode
 ├── scale.png          scale 0.33; left=0; centerY = massNumberDisplay.centerY
 ├── SymbolNode box      left = scale.right + 10
 └── ChargeMeter        scale 1.6; showNumericalReadout=false
                        left = box.right + 10; centerY = chargeDisplay.centerY
```

Outer node further scaled by **0.41** in the accordion.

## SymbolNode geometry (local)

| Constant | Value |
|---|---|
| `SYMBOL_BOX_WIDTH` | 275 |
| `SYMBOL_BOX_HEIGHT` | 325 |
| `NUMBER_FONT` | PhetFont(70) |
| `NUMBER_INSET` | 20 |
| Symbol font | PhetFont(150) |

| Field | Position | Color |
|---|---|---|
| Mass A | left=20, top=20 | black |
| Symbol X | center of box | black; Z=0 → `'-'` |
| Atomic Z | left=20, bottom=height−20 | `#D14600` (positiveColor) |
| Charge | right=width−20, top=20 | `CHARGE_TEXT_COLOR(charge)` |

## Charge notation (default `signLast`)

```text
charge > 0  →  `${abs}+`     e.g. 1+
charge < 0  →  `${abs}−`     e.g. 1−
charge == 0 →  `0`
```

`signFirst` alternative: `+1` / `−1` (preferences; default is signLast).

Charge text color: charge>0 → proton color; charge<0 → blue; else black.

## Display-only

Symbol Screen SymbolNode is **not** InteractiveSymbolNode (Game-only). No direct editing of A/Z/charge glyphs.
