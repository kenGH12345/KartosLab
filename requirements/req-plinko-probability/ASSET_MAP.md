# ASSET_MAP · Plinko Probability

> Substituted Assets target: **0**

| Original Path | Used By | Flutter Path | Scale | Rotation | Crop | Opacity | Notes |
|---|---|---|---|---|---|---|---|
| `images/counter.png` | HistogramModeControl | `assets/simulations/plinko_probability/images/counter.png` | 1 | 0 | none | 1 | Original |
| `images/cylinder.png` | HistogramModeControl (Intro) | `.../cylinder.png` | 1 | 0 | none | 1 | Original |
| `images/fraction.png` | HistogramModeControl (Lab) | `.../fraction.png` | 1 | 0 | none | 1 | Original |
| `images/introHomescreen.png` | Tab / future Home card | `.../introHomescreen.png` | 1 | 0 | none | 1 | Original |
| `images/introNavbar.png` | Tab icon (optional) | `.../introNavbar.png` | 1 | 0 | none | 1 | Original |
| `images/labHomescreen.png` | Tab / future Home card | `.../labHomescreen.png` | 1 | 0 | none | 1 | Original |
| `images/labNavbar.png` | Tab icon (optional) | `.../labNavbar.png` | 1 | 0 | none | 1 | Original |
| `sounds/bonk1ForPlinko.mp3` | Peg hit left | `.../sounds/bonk1ForPlinko.mp3` | — | — | — | — | Copied; wire playback |
| `sounds/bonk2ForPlinko.mp3` | Peg hit right | `.../sounds/bonk2ForPlinko.mp3` | — | — | — | — | Copied; wire playback |
| Board / Hopper / Ball | Painters | — (Canvas) | MVT | — | — | 1 | Source-drawn |
| Peg + Peg shadow | `PegsNode.js` | Runtime bake via `PegRaster` (`toCanvas`/`toImage` parity) then `drawImage` | pegScale | Lab rotates w/ p | — | 1 | **No PNG in PhET repo**; not a substituted asset |

**Substituted Assets: 0**
