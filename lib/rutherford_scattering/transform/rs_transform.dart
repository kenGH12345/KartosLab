import 'dart:ui';

import 'package:kratos/rutherford_scattering/model/rs_geometry.dart';

/// Model→view mapping matching PhET
/// `ModelViewTransform2.createRectangleInvertedYMapping`.
class RsTransform {
  RsTransform({
    required this.modelBounds,
    required this.viewBounds,
  })  : _sx = viewBounds.width / modelBounds.width,
        _sy = viewBounds.height / modelBounds.height;

  final RsBounds2 modelBounds;
  final Rect viewBounds;
  final double _sx;
  final double _sy;

  Offset modelToView(RsVec2 p) {
    final x = viewBounds.left + (p.x - modelBounds.minX) * _sx;
    final y = viewBounds.top + (modelBounds.maxY - p.y) * _sy;
    return Offset(x, y);
  }

  double modelToViewDeltaX(double dx) => dx * _sx;
  double modelToViewDeltaY(double dy) => dy * _sy;

  /// Uniform scale for radii (uses X scale; bounds are square).
  double get scale => _sx;
}
