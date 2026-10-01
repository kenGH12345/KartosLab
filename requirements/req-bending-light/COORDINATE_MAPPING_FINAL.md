# Coordinate mapping

## Why 1024×618 and 834×504 are both real

`BendingLightScreenView` sets `layoutBounds` to `Bounds2(0, 0, 834, 504)` and says not to replace it with the joist default. That 834×504 box is the simulation scene. It is source.

The 1024×618 frame is the browser window used for the 1.2.5 capture. Joist scales the 834×504 screen into the area above the navigation bar. Joist itself is not in the local tree, so the navbar top `y = 569` is a measurement of that 1.2.5 capture, not a 1.3.0 constant. It is a `VERSION_DELTA` for the window chrome, not a reason to change `layoutBounds`.

Flutter keeps both:

```text
BendingLightViewport 1024×618
  stage placed at scale 569/504, centered
    scene coordinates 834×504
      MVT: origin (388 - offset, 252 + verticalOffset), scale = 504 / modelHeight
        node left/top/right/bottom in that scene
```

MVT does not add the AppBar height. The AppBar is outside the viewport.

## Inverse

A scene point `(x, y)` in 834×504 becomes a viewport point:

```text
scale = 569 / 504
left = (1024 - 834 * scale) / 2
viewport = (left + x * scale, y * scale)
```

The inverse divides by `scale` and subtracts `left`. Test: `source_layout_test.dart` checks that the scaled stage is narrower than 1024 and centered.

## Verdict

`834×504` is `SOURCE MATCH`. Keeping it is required.

`569` as the content bottom is `VERSION_DELTA` (1.2.5 window). It is not used as a scene coordinate.
