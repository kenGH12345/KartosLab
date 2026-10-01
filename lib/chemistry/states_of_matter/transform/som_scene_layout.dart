import 'dart:ui' show Size;

import 'som_coordinate_transform.dart';

/// Single viewport → layoutBounds fit (Joist ScreenView style).
///
/// Logical design space is always [layoutBoundsWidth]×[layoutBoundsHeight]
/// (834×504). Physical size = logical × uniform [fitScale].
///
/// **Forbidden:** nesting FittedBox × AspectRatio × Transform.scale on the
/// same scene (causes undersized content / giant black letterboxing when the
/// capture viewport is larger than layoutBounds).
class SomSceneLayout {
  SomSceneLayout._();

  static const double logicalWidth = SomCoordinateTransform.layoutBoundsWidth;
  static const double logicalHeight = SomCoordinateTransform.layoutBoundsHeight;

  /// Uniform scale so layoutBounds fills [maxWidth]×[maxHeight].
  /// Allows upscale (>1) so 1280×800 Visual QA matches PhET Joist fill.
  static double fitScale(double maxWidth, double maxHeight) {
    if (maxWidth <= 0 || maxHeight <= 0) return 1;
    final sx = maxWidth / logicalWidth;
    final sy = maxHeight / logicalHeight;
    return sx < sy ? sx : sy;
  }

  static Size physicalSize(double scale) => Size(
        logicalWidth * scale,
        logicalHeight * scale,
      );
}
