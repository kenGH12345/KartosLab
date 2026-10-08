# PHASE7C_REMAINING

> Exact set from `resources/localization/migration_status.json` where status was LOCALIZED at Phase 7C start (12). All remediations closed.

| Simulation | Reason Not VERIFIED (pre-7C) | Missing Golden | Behavior | A11y | Layout | Action (7C) |
|---|---|---|---|---|---|---|
| l10n-architecture | Infra module (no Home UI golden) | N/A | PASS | PASS | N/A | Promote VERIFIED |
| collision-lab | ListTile under DecoratedBox assertion | was PENDING | PASS | PASS | P2 OK | Material panel + ZH golden |
| friction | audioplayers / clock | was PENDING | PASS | PASS | P2 OK | `enableAudio:false` + settle |
| resistance-in-a-wire | Undeterministic impurity dots | was PENDING | PASS | PASS | P2 OK | Seeded `dotRandom` |
| cck-ac-virtual-lab | toolbox label overflow (CJK) | was PENDING | PASS | PASS | fixed P1-ish overflow | ellipsis + FittedBox |
| circuit | audioplayers on init | was PENDING | PASS | PASS | OK | Lazy SFX + deferred construct |
| beers-law-lab | Concentration audio shell | was PENDING | PASS | PASS | OK | Silent ConcentrationAudio |
| fourier-making-waves | ListTile + animation | was PENDING | PASS | PASS | OK | Material panel + TickerMode |
| quantum-coin-toss | animation / haze | was PENDING | PASS | PASS | OK | TickerMode freeze |
| acid-base-solutions | particle Random + ticker | was PENDING | PASS | PASS | OK | Seeded IntroController + freeze |
| states-of-matter | particle Random + clock | was PENDING | PASS | PASS | OK | Seeded SomRandom + paused |
| molarity | MolarityAudioPlayer EventChannel | was PENDING | PASS | PASS | OK | RecordingMolarityAudio |

Post-7C: all rows → **VERIFIED**. LOCALIZED remaining = **0**.
