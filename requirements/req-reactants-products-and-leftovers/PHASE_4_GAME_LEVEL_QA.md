# PHASE_4 — Game Level QA

日期：2026-09-22

## Pool / Level

| Check | Expected | Result |
|---|---|---|
| Level1 pool size | 39 | PASS |
| Level2 pool size | 21 | PASS |
| Level3 pool size | 18 | PASS |
| Challenges / level | 5 | PASS |
| Zero-product count / set | 1 | PASS |
| Level1 interactive | Before | PASS |
| Level2 interactive | After | PASS |
| Level3 interactive | After | PASS |
| No duplicate reactions / set | true | PASS |
| Perfect score | 10 | PASS |

## PlayState transitions

| Transition | Result |
|---|---|
| settings → play(level) → FIRST_CHECK | PASS |
| FIRST_CHECK correct → NEXT (+2) | PASS |
| FIRST_CHECK wrong → TRY_AGAIN | PASS |
| TRY_AGAIN → tryAgain() → SECOND_CHECK | PASS |
| TRY_AGAIN + qty edit → SECOND_CHECK | PASS |
| SECOND_CHECK correct → NEXT (+1) | PASS |
| SECOND_CHECK wrong → SHOW_ANSWER | PASS |
| SHOW_ANSWER → NEXT (0 pts, filled) | PASS |
| NEXT ×5 → RESULTS | PASS |
| RESULTS Continue → SETTINGS | PASS |
| Start Over → SETTINGS | PASS |
| Reset All → defaults | PASS |

## Scoring samples

| Path | Score | Result |
|---|---:|---|
| 5× first-check correct | 10 | PASS |
| first wrong + second correct | 1 | PASS |
| show answer | 0 | PASS |

## Visibility

| Setting | moleculesVisible | numbersVisible | Result |
|---|---|---|---|
| Show All | true | true | PASS |
| Hide Molecules | false | true | PASS（baked at play） |
| Hide Numbers | true | false | PASS（baked at play） |
