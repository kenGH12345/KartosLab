# Build an Atom — Game Rules (locked to PhET source)

Evidence: `GameModel.ts`, `ChallengeDescriptorSetFactory.ts`, `AtomValuePool.ts`,
`AnswerAtom.ts`, `GameLevel.ts`, vegas `ScoreDisplayStars.ts` / `GameUtils.ts`.

## Levels (1–4)

| Level | Types |
|---|---|
| 1 | schematic-to-element, counts-to-element |
| 2 | schematic/counts → charge / mass-number |
| 3 | schematic/counts → symbol charge / mass / proton |
| 4 | *-symbol-all, symbol-to-schematic, symbol-to-counts |

## Generation

- `challengesPerLevel = 5`
- Random type from level list; **skip if same as previous**
- Schematic-related: `protonCount < 3` (constant name is 3; filter is strict `<`)
- Non-schematic: `protonCount >= 4`
- Charge-related: `isChargedRequired = random.nextBoolean()`
- Atom values from hard-coded `CHALLENGE_POOLS` (L1:32, L2:32, L3:60, L4:60, **total 184**)

## Scoring

- Attempt 1 correct → **+2**
- Attempt 2 correct → **+1**
- Max attempts = 2
- Perfect = `5 × 2 = 10`
- Stars = 5; fill proportion = `score / perfectScore`; half-stars allowed

## State machine

```text
levelSelection
  → presentingChallenge
  → solvedCorrectly | tryAgain | attemptsExhausted
  → showingAnswer (from attemptsExhausted via displayCorrectAnswer)
  → next → presentingChallenge | levelCompleted
```

## Element challenges

View submits `AnswerAtom` with user Z + ion/neutral, **N/e copied from correct answer**.
Only Z + ion/neutral semantics are effectively tested.

## Timer

- Default **off**
- If enabled, `start` on level start; `stop` on `endLevel`
- Best time updated only when timer enabled (`GameUtils.updateScoreAndBestTime`)

## Reset vs Start Over

| Action | Clears score/attempts/timer | Clears bestScore/bestTime | Clears timerEnabled | randomSeed++ | State |
|---|---|---|---|---|---|
| `startOver` | yes | **no** | no | yes | levelSelection |
| `reset` (Reset All) | yes | **yes** | **yes → false** | no* | levelSelection |

\* PhET `reset()` does not bump seed; `startOver` / `endLevel` do.

## Reward

`shouldShowReward` when level score ≥ perfect (10). UI deferred.
