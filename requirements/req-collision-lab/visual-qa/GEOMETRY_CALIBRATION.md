# GEOMETRY_CALIBRATION · Collision Lab

> P0 clipping / Grid drag 修复后

## Clip 与边框

| 项 | 规则 | 落地 |
|---|---|---|
| Ball clip | `playAreaViewBounds` | `BallPainter` → `canvas.clipRect(data.playAreaRect)` |
| Vectors | 不 clip | `VectorPainter` 在 clip 外层 |
| Border | dilated by stroke/2 | `PlayAreaBorderPainter` · `rect.inflate(stroke/2)` |
| hideBall | **禁止** | 不用 center-outside 隐藏整球 |

## Hit-test / Grid

| 项 | 规则 | 落地 |
|---|---|---|
| Drag layer | 高于 grid 绘制、低于装饰 | `Listener` + `HitTestBehavior.opaque` |
| Overlays | 不抢事件 | ScaleBar / KE / time → `IgnorePointer` |
| Hit | 视图空间 ball.center / radius | 不依赖 grid painter |
| Snap 时机 | drag **move**（`dragToPosition`） | Grid ON 吸附；OFF 仅 eroded 约束 |

## P0–P5

| 优先级 | 状态 |
|---|---|
| P0 Viewport / PlayArea clip | **[视觉已对齐]**（clip 语义） |
| P1 Grid drag | **[行为一致]** |
| P2 ScaleBar / Momenta | **[视觉近似]** |
| P3–P5 | **[视觉近似]** / 字体 **[有意差异]** |

禁止 screenshot tracing / hardcoded pixel offset。
