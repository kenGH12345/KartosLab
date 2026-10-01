# GEOMETRY_CALIBRATION — Curve Fitting

## 状态

**[待确认：缺少原版运行截图]** — 本文件为 **rules-based** 校准，非像素 overlay。

## Visual QA + Drag regression (2026-09-05)

### Layout / hit-test

Interaction (graph paint, bucket, data points) uses a **full-bleed** layer.
Side panels are `Positioned` with **intrinsic** width/height only — never a
full-height left/right sibling that steals bucket hits.

```
Stack(
  Positioned.fill( interaction: graph + bucket + points ),  // MVT space
  Positioned(left: gutter, child: Deviations),               // intrinsic hits
  Positioned(right: gutter, child: Controls),
)
```

### MVT

```
MathCoordinateTransform.forGraphViewport(
  Size(graphW, h),
  viewOriginInParent: Offset(colW + graphW/2, h/2),
)
scale = min(graphW, h) / 20   // background [-10,10]
```

Bucket at model (−13.5, −8) maps into the left gutter in parent coordinates
but remains inside the full-bleed hit layer.

### Drag regression notes

| Cause | Fix |
|---|---|
| Left full-height column ate bucket hits | Full-bleed interaction layer |
| Bucket front `CustomPaint` full-rect hitTest | `IgnorePointer` on hole/front |
| `notifyListeners` mid-pan cancelled gestures | `paintEpoch` during drag; defer `addPoint` notify |
| Hit radius | `8 + 5` dilation (`PointNode`) |
| Grab offset | [已确认] PhET none — follow pointer |

**Classification:** [迁移引入：DataPoint Drag / Hit-Test Regression] — fixed.

## Graph bounds（model）

| Bounds | 值 |
|---|---|
| BACKGROUND | [-10,10]² |
| NODE | [-12,12]² |
| AXES | [-10.75,10.75]² |
| CURVE_CLIP | [-10,10]² |

数学范围未改。
