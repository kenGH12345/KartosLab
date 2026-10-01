# PHASE_4 — Game View Source Map

本地基准：`js/game/`  
日期：2026-09-22

## Hierarchy

```text
GameScreenView (layoutBounds 835×504)
├── SettingsNode          (GamePhase.SETTINGS)
│   ├── "Choose Your Level"
│   ├── RPALLevelSelectionButtonGroup (Level 1/2/3)
│   ├── GameVisibilityPanel (Show All / Hide Molecules / Hide Numbers)
│   ├── TimerToggleButton
│   └── ResetAllButton
├── PlayNode              (GamePhase.PLAY)
│   ├── FiniteStatusBar (score, level, challenge #, timer, Start Over)
│   └── ChallengeNode
│       ├── MoleculesEquationNode
│       ├── RandomBox Before + Arrow + RandomBox After
│       ├── QuantitiesNode (interactive = Before|After)
│       ├── HideBox overlays (molecules/numbers)
│       ├── GameButtons (Check / Try Again / Show Answer / Next)
│       ├── FaceWithPointsNode
│       └── Question mark (until valid guess)
└── ResultsNode           (GamePhase.RESULTS)
    ├── LevelCompletedNode
    └── RPALRewardNode (perfect score)
```

## PlayState

```text
FIRST_CHECK → (correct) NEXT
            → (wrong) TRY_AGAIN → (edit qty) SECOND_CHECK
                                 → (wrong) SHOW_ANSWER → NEXT
            SECOND_CHECK → (correct) NEXT
NEXT → next challenge | RESULTS
```

## Challenge generation

- 5 challenges / level
- Exactly 1 zero-product challenge / set
- No duplicate reactions in a set
- Level 0 interactive=BEFORE, pool=39
- Level 1 interactive=AFTER, pool=21 one-product
- Level 2 interactive=AFTER, pool=18 two-product
- maxQuantity = 8
- Visibility from Settings baked into Challenge options

## Scoring

- FIRST_CHECK correct: +2
- SECOND_CHECK correct: +1
- Show Answer: 0 points
- Perfect = 5 × 2 = 10

## Timer

- Optional (`timerEnabledProperty`, default false)
- Starts on `play()`, stops on last correct or `results()`

## Viewport

Same `SCREEN_VIEW_LAYOUT_BOUNDS` 835×504; Game boxes 330×240.
