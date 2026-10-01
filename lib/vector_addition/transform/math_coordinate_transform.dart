import 'dart:ui';

import '../model/va_vec.dart';
import '../vector_addition_constants.dart';

/// Model ↔ view transform for Vector Addition.
///
/// Mirrors PhET `ModelViewTransform2.createRectangleInvertedYMapping`:
/// model +y up, view +y down. **All Y inversion lives here** — Painters must
/// not scatter `height - y` / `-dy`.
class MathCoordinateTransform {
  MathCoordinateTransform({
    required this.modelBounds,
    required this.viewBounds,
  }) : scaleX = viewBounds.width / modelBounds.width,
       scaleY = viewBounds.height / modelBounds.height;

  final VaBounds modelBounds;

  /// View rectangle: left, top, width, height (Flutter / Scenery: +y down).
  final Rect viewBounds;

  final double scaleX;
  final double scaleY;

  /// PhET Graph: scale is uniform [MODEL_TO_VIEW_SCALE].
  factory MathCoordinateTransform.fromGraph({
    required VaBounds modelBounds,
    required Offset bottomLeft,
    double scale = VectorAdditionConstants.modelToViewScale,
  }) {
    final viewBounds = Rect.fromLTRB(
      bottomLeft.dx,
      bottomLeft.dy - scale * modelBounds.height,
      bottomLeft.dx + scale * modelBounds.width,
      bottomLeft.dy,
    );
    return MathCoordinateTransform(
      modelBounds: modelBounds,
      viewBounds: viewBounds,
    );
  }

  Offset modelToView(VaVec p) {
    final fx = (p.x - modelBounds.minX) / modelBounds.width;
    final fy = (p.y - modelBounds.minY) / modelBounds.height;
    return Offset(
      viewBounds.left + fx * viewBounds.width,
      viewBounds.bottom - fy * viewBounds.height, // invert Y
    );
  }

  VaVec viewToModel(Offset p) {
    final fx = (p.dx - viewBounds.left) / viewBounds.width;
    final fy = (viewBounds.bottom - p.dy) / viewBounds.height; // invert Y
    return VaVec(
      modelBounds.minX + fx * modelBounds.width,
      modelBounds.minY + fy * modelBounds.height,
    );
  }

  Offset modelToViewDelta(VaVec d) => Offset(d.x * scaleX, -d.y * scaleY);

  VaVec viewToModelDelta(Offset d) => VaVec(d.dx / scaleX, -d.dy / scaleY);

  double modelToViewDeltaX(double dx) => dx * scaleX;
  double viewToModelDeltaX(double dx) => dx / scaleX;

  Rect modelToViewRect(VaBounds b) {
    final topLeft = modelToView(VaVec(b.minX, b.maxY));
    final bottomRight = modelToView(VaVec(b.maxX, b.minY));
    return Rect.fromLTRB(
      topLeft.dx,
      topLeft.dy,
      bottomRight.dx,
      bottomRight.dy,
    );
  }
}
