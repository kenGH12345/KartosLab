# White light spatial analysis

Official frame: `visual-qa/official/OFFICIAL_WHITE_LIGHT.png` (phet-dev 1.2.5, 1024×618).
Flutter frame used for this split: `visual-qa/flutter/FINAL4_WHITE_LIGHT.png` (same viewport crop).

The color formula was not changed. Stage mean absolute RGB on that pair is 51.08. That number is not a beam error.

Grid of mean absolute RGB on y<569, cells 80×128:

| y | x 0–640 | x 768–896 |
| ---: | --- | --- |
| 0–240 | 0 to 4 | 85 to 111 |
| 160–240 beam | under 4 | panel interior |
| 320–560 | 32 to 205 | toolbox / controls |

Sampled pixels:

| Point | Official | Flutter | Region |
| --- | --- | --- | --- |
| (500, 235) | (255, 255, 255) | (255, 255, 255) | beam |
| (500, 300) | (0, 0, 0) | (0, 0, 0) | background |
| (500, 400) | (0, 0, 0) | (0, 0, 0) | background |
| (180, 240) | (205, 7, 6) | (227, 59, 55) | laser body |
| (850, 40) | (238, 238, 238) | (232, 232, 232) | panel |
| (80, 360) | (0, 0, 0) | (224, 224, 224) | lower toolbox band |

1. Beam: match. Leave the sampler, VisibleColor, D65, and `BlendMode.plus` alone.
2. Background: both black away from the beam.
3. Lower environment: the large difference. Official is black there; the Flutter toolbox sat higher. This pass moved the Prisms toolbox to `left = 12` and `bottom = 489` from `FloatingLayout`, which is the source anchor. It is not a white-light color change.
4. Prism: neither default capture places a prism in the beam.
5. Panel: both have a gray panel at the upper right. Interior controls still differ (Material slider vs `HSlider`).
6. Controls: the wavelength panel and the reset follow `floatRight` / `floatTop` / `floatBottom` after this pass.

Black fraction of the stage was 0.778 official and 0.784 Flutter. The environments are the same kind of black. The remaining difference is panels and the lower toolbox, not the beam.
