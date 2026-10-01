# ASSET_MAP — Pendulum Lab

政策：`VISUAL_ASSET_POLICY.md` · Substituted Assets 必须为 0。

| Original Path | Type | Used By | Flutter Path | Scale | Rotation | Crop | Opacity | Transform |
|---|---|---|---|---|---|---|---|---|
| `mipmaps/introNavbarIcon.png` | PNG | Intro tab | `assets/simulations/pendulum_lab/introNavbarIcon.png` | contain ~24h | 0 | none | 1 | — |
| `mipmaps/energyScreenIcon.png` | PNG | Energy tab（无 navbar） | `assets/simulations/pendulum_lab/energyScreenIcon.png` | contain ~24h | 0 | none | 1 | — |
| `mipmaps/labNavbarIcon.png` | PNG | Lab tab | `assets/simulations/pendulum_lab/labNavbarIcon.png` | contain ~24h | 0 | none | 1 | — |
| `mipmaps/introScreenIcon.png` | PNG | 抽取备份 / Home | `assets/simulations/pendulum_lab/introScreenIcon.png` | — | 0 | none | 1 | — |
| `mipmaps/labScreenIcon.png` | PNG | 抽取备份 | `assets/simulations/pendulum_lab/labScreenIcon.png` | — | 0 | none | 1 | — |
| `mipmaps/periodTimerBackground.png` | PNG | PeriodTimerNode | `assets/simulations/pendulum_lab/periodTimerBackground.png` | **0.6** | 0 | none | 1 | center 对齐内容 |
| Pendulum bob+rod | Scenery Rectangle/Line/Gradient | PendulaNode | CustomPainter | massToScale | −θ | none | 1 | MVT |
| Protractor | Path ticks | PendulumLabProtractorNode | CustomPainter | 1 | 0 at pivot | none | 1 | MVT origin |
| Ruler | scenery-phet RulerNode | PendulumLabRulerNode | CustomPainter | 1 m → scale px | +π/2 | none | 1 | center = model.position |
| Period trace | kite Shape arcs | PeriodTraceNode | CustomPainter | 1 | +π/2 at origin | none | fade α | MVT origin |
| Play/Pause/Step/Reset/Stop | scenery-phet geometry | Playback + ResetAll | CustomPainter | PhET radii | 0 | none | 1 | — |

**Substituted Assets: 0**（无 Material / Emoji / 网络图）。
