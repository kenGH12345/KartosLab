# ASSET_MAP — Friction

| Original Path | Used By | Flutter Path | Scale | Rotation | Crop | Opacity | Transform |
|---------------|---------|--------------|-------|----------|------|---------|-----------|
| CoverNode geometry | Macro books | `book_cover_painter.dart` | 1 | 0 | none | 1 | origin + topExtent |
| MagnifierNode | Zoom window | `friction_play_area.dart` `_MagnifierWindow` | 1 | 0 | clipRRect | 1 | (40,25) |
| MagnifierTargetNode | Dashed zoom lines | `_MagnifierTargetPainter` | 0.05 window | 0 | none | 1 | target (195,425) |
| AtomCanvasNode / ShadedSphere | Atoms | `atoms_painter.dart` | radius*2*1.2 | 0 | none | 1 | model coords |
| ThermometerNode | Temperature | `friction_thermometer.dart` | 1 | 0 | none | 1 | (690,250) |
| CueArrow | Hint | `cue_arrow_painter.dart` | ~0.7–1 | 0/π | none | 1 | magnifier top |
| ResetAllButton | Reset | `KratosResetAllButton` | r=22 | 0 | none | 1 | (0.94w,0.9h) |
| sounds/*.mp3 | Audio | `assets/simulations/friction/sounds/` | — | — | — | — | AssetSource |

**Substituted Assets: 0**
