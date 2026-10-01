import 'dart:ui';

import '../model/cck_vec.dart';

/// Circuit model pixels (zoom=1 canvas local) ↔ view pixels.
/// Zoom is about the canvas center, matching PhET `animatedZoomScaleProperty`.
class CckMvt {
  CckMvt({required this.canvasSize, required this.zoom});

  final Size canvasSize;
  final double zoom;

  Offset get origin => Offset(canvasSize.width / 2, canvasSize.height / 2);

  Offset toView(CckVec m) {
    return Offset(
      origin.dx + (m.x - origin.dx) * zoom,
      origin.dy + (m.y - origin.dy) * zoom,
    );
  }

  CckVec toModel(Offset v) {
    return CckVec(
      origin.dx + (v.dx - origin.dx) / zoom,
      origin.dy + (v.dy - origin.dy) / zoom,
    );
  }
}
