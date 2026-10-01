# ASSET_MAP · Gravity and Orbits

> Substituted Assets = **0** · 全部来自本地 PhET `mipmaps/` / `images/`

| Original Path | Used By | Flutter Path | Scale | Rotation | Crop | Opacity | Notes |
|---|---|---|---|---|---|---|---|
| mipmaps/sun.png | Star body, scene icons | assets/astronomy/gravity_and_orbits/sun.png | view diameter | body.rotation | none | 1 | Image.asset |
| mipmaps/earth.png | Planet @ tick mass | …/earth.png | view diameter | body.rotation | none | 1 | |
| mipmaps/planetGeneric.png | Planet mass≠tick | …/planetGeneric.png | view diameter | | none | 1 | SwitchableBodyRenderer |
| mipmaps/moon.png | Moon @ tick mass | …/moon.png | view diameter | body.rotation | none | 1 | |
| mipmaps/moonGeneric.png | Moon mass≠tick | …/moonGeneric.png | view diameter | | none | 1 | |
| mipmaps/spaceStation.png | Satellite | …/spaceStation.png | view diameter | body.rotation | none | 1 | |
| mipmaps/modelIcon.png | Model tab | …/modelIcon.png | 28×28 | 0 | none | 1 | |
| mipmaps/toScaleIcon.png | To Scale tab | …/toScaleIcon.png | 28×28 | 0 | none | 1 | |
| images/pathIcon.png | Path checkbox | …/pathIcon.png | 18×18 | 0 | none | 1 | |
| images/iconMass.png | Mass checkbox (optional) | …/iconMass.png | — | — | — | — | available |
| images/pathIconProjector.png | projector mode | …/pathIconProjector.png | — | — | — | — | unused (no projector) |

**Programmatic (not substituted)**: PEFRL orbits, force/velocity arrows (ArrowPainter), grid, zoom ±, scene reset arrow Path, Reset All = `KratosResetAllButton`, explosion TBD if needed.

**判定**：`[原版资源一致]` — Substituted = 0
