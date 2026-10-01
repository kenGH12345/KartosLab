# Build an Atom — Asset Provenance Final (Phase 5)

Evidence roots:
- `phet sourses/build-an-atom-main/build-an-atom-main/images`
- `shred` ParticleNode / SymbolNode / ElectronShellView / ElectronCloudView
- `scenery-phet` FaceNode / PhetFont / PlusNode / MinusNode / BucketHole
- `vegas` ScoreDisplayStars / FiniteStatusBar / RewardNode / GameAudioPlayer
- `sun` NumberSpinner / TextPushButton / AccordionBox
- `tambo` sharedSoundPlayers (no mp3 shipped in BAA repo)

## Visual provenance matrix

| Visual | Origin | Flutter implementation | Exact asset? |
| --- | --- | --- | --- |
| atom icon | BAA `atomIcon.png` | `assets/build_an_atom/images/atomIcon.png` | ✅ exact PNG |
| element icon | BAA `elementIcon.png` | `assets/build_an_atom/images/elementIcon.png` | ✅ exact PNG |
| game icon | BAA `gameIcon.png` | `assets/build_an_atom/images/gameIcon.png` | ✅ exact PNG |
| periodic table icon | BAA `periodicTableIcon.png` + `PeriodicTableLevelIcon` | `GameLevelIcon` L1 + PNG | ✅ PNG + runtime crop |
| mass/charge icon | BAA `massChargeIcon.png` + `MassAndChargeLevelIcon` | L2 = ChargeMeter + `scale.png` (runtime) | ✅ PNG available; L2 uses runtime compose |
| scale | BAA `scale.png` 351×189 | Mass Number / Symbol / L2 | ✅ exact; `scale(0.33)` then outer `0.41` |
| particle | shred ParticleNode radial gradient | `ParticleSpherePainter` | runtime geometry |
| FaceNode | scenery-phet FaceNode | `PhetFaceNode` CustomPainter | runtime geometry |
| Level icon | BAA `*LevelIcon.ts` (+ optional PNGs) | `GameLevelIcon` | runtime + L1 PNG |
| spinner | sun NumberSpinner + BAA `bothRight` | `BaaNumberSpinner` | runtime chrome |
| Reward | vegas RewardNode + BAARewardNode | `_RewardRain` + FaceNode | runtime geometry |
| ChargeMeter ± | scenery-phet PlusNode / MinusNode | painted in `ChargeMeter` | runtime geometry |
| Stars | vegas ScoreDisplayStars | `GameStarsDisplay` | runtime geometry |
| Shells / Cloud | shred ElectronShellView / ElectronCloudView | painters + RadialGradient | runtime geometry |
| Buckets | scenery-phet BucketHole/Front | `BaaBucketPainter` | runtime geometry |
| Symbol box | shred SymbolNode | `BaaSymbolNode` / `InteractiveSymbolView` | runtime geometry |

## Screen backgrounds (`BAAColors`)

| Screen | Hex | Source |
| --- | --- | --- |
| Atom | `#FFFFFF` | `screenBackgroundColorProperty` |
| Symbol | `#F9FFE5` | Symbol screen background |
| Game | `#FFFFDF` | Game screen background |
| Level selector panel | `#D4AAD4` | LevelSelectionNode |

## Audio

| Event | Origin | Flutter |
| --- | --- | --- |
| correct / incorrect / gameOver* | vegas → tambo `sharedSoundPlayers` | `GameAudioAdapter` hooks only |

**No mp3 in BAA repo.** Forging audio is forbidden → retained P2 with evidence.

## Substituted Assets

| Item | Status |
| --- | --- |
| Runtime particles / shells / symbols / FaceNode / spinner | 0 substituted bitmaps |
| Home QA card icons | Temporary Material (Phase 8 — not this phase) |
| Game audio waveforms | Unavailable — hooks only (P2) |

## Material scan (Phase 5)

PhET-facing controls must not use Material icons as stand-ins.

| Pattern | Result |
| --- | --- |
| `Icons.sentiment_*` | removed — `PhetFaceNode` |
| `Icons.refresh` / Reset All | `KratosResetAllButton` |
| Level circles with digits only | replaced by `GameLevelIcon` |
| `Material(` wrappers | ink/hit targets only — chrome is custom painted |
| `ElevatedButton` / `FilledButton` / `Card` as PhET chrome | not used for PhET nodes |
