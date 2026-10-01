import 'dart:ui';

import '../caf_constants.dart';
import '../model/vec2.dart';

/// ModelViewTransform2.createSinglePointScaleInvertedYMapping port.
class CafMvt {
  CafMvt({
    required this.layoutSize,
    CafVec2? modelOrigin,
    Offset? viewOrigin,
    double? scale,
  })  : modelOrigin = modelOrigin ?? CafVec2.zero,
        viewOrigin = viewOrigin ??
            Offset(layoutSize.width / 2, layoutSize.height / 2),
        scale = scale ?? (layoutSize.width / CafConstants.width);

  final Size layoutSize;
  final CafVec2 modelOrigin;
  final Offset viewOrigin;
  final double scale;

  factory CafMvt.fromLayout(Size layoutSize) => CafMvt(layoutSize: layoutSize);

  Offset modelToView(CafVec2 m) {
    return Offset(
      viewOrigin.dx + (m.x - modelOrigin.x) * scale,
      viewOrigin.dy - (m.y - modelOrigin.y) * scale, // inverted Y
    );
  }

  CafVec2 viewToModel(Offset v) {
    return CafVec2(
      modelOrigin.x + (v.dx - viewOrigin.dx) / scale,
      modelOrigin.y - (v.dy - viewOrigin.dy) / scale,
    );
  }

  double modelToViewDelta(double d) => d * scale;
  double viewToModelDelta(double d) => d / scale;

  CafBounds2 viewToModelBounds(Rect r) {
    final a = viewToModel(r.topLeft);
    final b = viewToModel(r.bottomRight);
    return CafBounds2(
      a.x < b.x ? a.x : b.x,
      a.y < b.y ? a.y : b.y,
      a.x > b.x ? a.x : b.x,
      a.y > b.y ? a.y : b.y,
    );
  }
}
