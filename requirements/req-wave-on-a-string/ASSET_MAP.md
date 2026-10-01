# ASSET_MAP · Wave on a String

> Final Phase 5 audit. **Substituted assets = 0**.  
> Local source version: **1.3.0-dev.0**

## Bitmap (original PhET → Flutter)

| Original Path | Used By | Flutter Path | Scale / Notes | Category |
| ------------- | ------- | ------------ | ------------- | -------- |
| `images/wrench.png` | `WrenchNode` / Manual | `assets/simulations/wave_on_a_string/wrench.png` | scale ~0.9/4; StartNode | Original bitmap |
| `images/clamp.png` | Fixed End | `assets/simulations/wave_on_a_string/clamp.png` | EndNode Fixed | Original bitmap |
| `images/ringFront.png` | Loose End | `assets/simulations/wave_on_a_string/ringFront.png` | Front ring | Original bitmap |
| `images/ringBack.png` | Loose End | `assets/simulations/wave_on_a_string/ringBack.png` | Back ring | Original bitmap |
| `images/windowFront.png` | No End front | `assets/simulations/wave_on_a_string/windowFront.png` | above string | Original bitmap |
| `images/windowBack.png` | No End back | `assets/simulations/wave_on_a_string/windowBack.png` | behind string | Original bitmap |

## Source-generated shapes

| Visual | Implementation | Category |
| ------ | -------------- | -------- |
| Red / cyan beads | `WoasStringPainter` | Source-generated |
| String Path | stroke `#F00` | Source-generated |
| Center equilibrium line | dash `[8,5]` `#6c4a1d` | Source-generated |
| Reference line | Path `#F00` | Source-generated |
| Loose-end post | LinearGradient | Source-generated |
| Oscillate / pulse chrome | `WoasStartNode` | Source-generated |
| Reset All | `KratosResetAllButton` L0 | Shared PhET-style |

## Substituted assets

```text
Substituted assets = 0
```
