# Build an Atom — Game View Mapping

Locked sources: `GameScreenView.ts`, `LevelSelectionNode.ts`, `ChallengeView.ts`,
`InteractiveSymbolNode.ts`, vegas `FiniteStatusBar` / `LevelCompletedNode` / `RewardNode`,
Phase 1 Flutter `GameModel`.

## Screen composition (768×464)

```text
GameScreen
 ├── LevelSelectionNode          (visible when gameState == levelSelection)
 │    ├── title "Choose Your Game!"
 │    ├── 4× LevelSelectionButton (150×150, icons, ScoreDisplayStars)
 │    ├── GameTimerToggleButton  (default OFF)
 │    └── ResetAllButton
 ├── FiniteStatusBar             (hidden on levelSelection / levelCompleted)
 │    ├── Level N · score · timer (if enabled) · Start Over
 ├── ChallengeView                (per ChallengeType)
 │    ├── challengePresentationNode
 │    ├── interactiveAnswerNode
 │    ├── Check / Try Again / Show Answer / Next
 │    └── FaceNode + points feedback
 └── levelCompleted
      ├── LevelCompletedNode (score / stars / best / Start Over)
      └── BAARewardNode (perfect score only)
```

## Flutter mapping

| PhET | Flutter |
|---|---|
| GameScreenView | `BuildAnAtomGameScreen` |
| LevelSelectionNode | `GameLevelSelectionView` |
| ChallengeView | `GameChallengeView` |
| InteractiveSymbolNode | `InteractiveSymbolView` |
| ScoreDisplayStars | `GameStarsDisplay` |
| GameTimer | Phase 1 `GameTimer` |
| BAARewardNode | `BaaRewardView` |
| GameAudioPlayer | `GameAudioAdapter` (hooks; no forged audio files) |
| FiniteStatusBar | `GameStatusBar` |
| LevelCompletedNode | `GameLevelCompletedView` |

## Challenge → input mapping

| ChallengeType | Prompt | Answer input |
|---|---|---|
| schematic-to-element | NonInteractiveSchematic | Interactive PT + Neutral/Ion |
| counts-to-element | ParticleCounts | Interactive PT + Neutral/Ion |
| schematic-to-charge | Schematic | Charge spinner |
| counts-to-charge | ParticleCounts | Charge spinner |
| schematic-to-mass-number | Schematic | Mass spinner |
| counts-to-mass-number | ParticleCounts | Mass spinner |
| *-symbol-charge | Schematic/Counts | InteractiveSymbol (charge) |
| *-symbol-mass-number | Schematic/Counts | InteractiveSymbol (mass) |
| schematic-to-symbol-proton-count | Schematic | InteractiveSymbol (Z) |
| *-symbol-all | Schematic/Counts | InteractiveSymbol (all) |
| symbol-to-counts | InteractiveSymbol (display) | Particle count spinners |
| symbol-to-schematic | InteractiveSymbol (display) | Interactive schematic (BAAModel) |

## Answer submission rules (View → AnswerAtom → GameModel.check)

- **Element**: `AnswerAtom.forElementSubmission` (N/e from correct)
- **Charge**: `e = p_correct − charge_user`; p/n from correct
- **Mass**: `n = mass_user − p_correct`; p/e from correct
- **Symbol**: `n = mass − p`, `e = p − charge` from interactive fields
- **Counts / Schematic**: full particle counts from user input

## State → buttons

| State | Buttons | Feedback |
|---|---|---|
| presentingChallenge | Check | — |
| solvedCorrectly | Next | smile +N |
| tryAgain | Try Again | frown |
| attemptsExhausted | Show Answer | frown |
| showingAnswer | Next | correct values shown |

## Design note

Game InteractiveSymbol (275×300, font 56) ≠ Symbol Screen SymbolNode (275×325, font 70).
Do not reuse Symbol Screen layout for Game.
