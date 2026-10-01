# FUNCTION / MODEL / VISUAL / INTERACTION INVENTORY

## FUNCTION INVENTORY
| Feature | Source | Priority | Status |
|---------|--------|----------|--------|
| Chemistry Book (draggable) | BookNode drag:true | P0 | |
| Physics Book (fixed) | BookNode | P0 | |
| Friction heating on contact+dx | FrictionModel | P0 | |
| Cooling over time | FrictionModel.step | P0 | |
| Zoomed magnifier view | MagnifierNode | P0 | |
| Atom vibration | Atom.step | P0 | |
| Atom shear-off | tryToShearOff | P0 | |
| Thermometer ↔ amplitude | ThermometerNode | P0 | |
| Magnifier ↔ main sync | topBookPositionProperty | P0 | |
| Cue arrows (hint) | hintProperty | P1 | |
| Reset All | ResetAllButton | P0 | |
| Keyboard WASD/Arrows | FrictionKeyboardDragListener | P0 | |
| Grab pickup/drop sounds | SoundClip | P1 | |
| Contact sound | contactLower | P1 | |
| Break-off sound | shearedOffEmitter | P1 | |
| Rub noise | BookRubSoundGenerator | P2 | |
| Molecule/cooling noise | MoleculeMotion / CoolingSound | P2 | |
| Full Voicing / PDOM alerts | *Alerter | P2 | |
| PhET menu / Preferences | joist | P2 (KartosLab chrome) | |

## MODEL INVENTORY
- FrictionModel (vibrationAmplitude, topBookPosition, distance, contact, shear rows)
- FrictionAtom (center, vibration, shear velocity)
- Constants locked from FrictionConstants + FrictionModel literals

## VISUAL INVENTORY (from screenshot + ScreenView)
- White background 768×504
- Magnifier top-left area, thick black rounded border
- Split blue/green atom backgrounds with jagged white interface
- Double-headed white arrow at top of magnifier
- Thermometer right inside magnifier area
- Macro books below with dashed zoom lines
- Orange Reset All bottom-right

## INTERACTION INVENTORY
- Pointer drag macro Chemistry book (scale 0.025)
- Pointer drag magnifier top atoms (1:1 model)
- Keyboard drag when focused (speed 1000 / shift 500)
- Release → drop sound; contact → contact sound
- Reset restores model + view cues
