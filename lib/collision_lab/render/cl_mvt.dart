import 'dart:ui';

import '../collision_lab_constants.dart';
import '../model/cl_vec.dart';
import '../model/play_area.dart';

/// Model↔view transform — `CollisionLabScreenView.js` inverted-Y mapping.
class ClMvt {
  const ClMvt({
    required this.modelOrigin,
    required this.viewOrigin,
    required this.scale,
  });

  final ClVec modelOrigin;
  final Offset viewOrigin;
  final double scale;

  Offset modelToView(ClVec p) => Offset(
        viewOrigin.dx + (p.x - modelOrigin.x) * scale,
        viewOrigin.dy - (p.y - modelOrigin.y) * scale,
      );

  ClVec viewToModel(Offset p) => ClVec(
        modelOrigin.x + (p.dx - viewOrigin.dx) / scale,
        modelOrigin.y - (p.dy - viewOrigin.dy) / scale,
      );

  double modelToViewDeltaX(double dx) => dx * scale;
  double modelToViewDeltaY(double dy) => -dy * scale;

  Offset modelToViewDelta(ClVec d) =>
      Offset(modelToViewDeltaX(d.x), modelToViewDeltaY(d.y));

  /// Inverse of [modelToViewDelta] — used by velocity tip drag.
  ClVec viewToModelDelta(Offset d) => ClVec(d.dx / scale, -d.dy / scale);

  Rect modelToViewBounds(ClBounds b) {
    final topLeft = modelToView(ClVec(b.minX, b.maxY));
    final bottomRight = modelToView(ClVec(b.maxX, b.minY));
    return Rect.fromLTRB(
      topLeft.dx,
      topLeft.dy,
      bottomRight.dx,
      bottomRight.dy,
    );
  }

  /// PhET: origin at (playArea.left, playArea.top) → (playAreaLeft, playAreaTop).
  static ClMvt forPlayArea(PlayArea playArea, {double? playAreaTop}) {
    final top = playAreaTop ??
        (playArea.dimension == PlayAreaDimension.one
            ? CollisionLabConstants.playAreaViewTop1d
            : CollisionLabConstants.screenViewYMargin);
    return ClMvt(
      modelOrigin: ClVec(playArea.left, playArea.top),
      viewOrigin: Offset(CollisionLabConstants.playAreaLeft, top),
      scale: CollisionLabConstants.modelToViewScale,
    );
  }
}
