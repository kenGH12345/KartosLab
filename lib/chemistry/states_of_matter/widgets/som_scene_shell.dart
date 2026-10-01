import 'package:flutter/material.dart';

import '../som_colors.dart';
import '../transform/som_coordinate_transform.dart';
import '../transform/som_scene_layout.dart';

/// Fills the parent with a single uniform scale of the 834×504 design canvas.
///
/// ```
/// Viewport → fitScale → SizedBox(physical) → FittedBox.fill → 834×504 scene
/// ```
///
/// One scale only (no nested FittedBox + Transform.scale).
class SomSceneShell extends StatelessWidget {
  const SomSceneShell({
    super.key,
    required this.child,
    this.background = SomColors.background,
  });

  final Widget child;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = SomSceneLayout.fitScale(
            constraints.maxWidth,
            constraints.maxHeight,
          );
          final physical = SomSceneLayout.physicalSize(scale);
          return Center(
            child: SizedBox(
              width: physical.width,
              height: physical.height,
              child: FittedBox(
                fit: BoxFit.fill,
                // PhET ScreenView paints outside layoutBounds (e.g. pointing hand).
                clipBehavior: Clip.none,
                child: SizedBox(
                  width: SomCoordinateTransform.layoutBoundsWidth,
                  height: SomCoordinateTransform.layoutBoundsHeight,
                  child: child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
