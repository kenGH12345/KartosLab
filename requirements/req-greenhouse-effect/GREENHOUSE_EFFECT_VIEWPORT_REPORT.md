# GREENHOUSE_EFFECT_VIEWPORT_REPORT

| Item | Value |
|---|---|
| PhET ScreenView layoutBounds | joist default **1024 × 618** (not overridden in GreenhouseEffectScreenView) |
| Observation window | **780 × 525** screen coords |
| Observation position | left **15**, top **10** |
| Model width (sunlight span) | **85000 m** |
| Model atmosphere height | **50000 m** |
| MVT origin | model `(0,0)` → view `(390, 525 − groundHeight)` |
| MVT scale | `(525 − groundHeight) / 50000` |
| groundHeight | `525 * 0.25 / 2` = **65.625** |
| Speed of light (sim) | **9000 m/s** |

Flutter keeps the same logical observation size and scales with `FittedBox` for smaller windows.
