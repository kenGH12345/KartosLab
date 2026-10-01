import 'dart:ui';

import 'package:kratos/energy_skate_park/esp_constants.dart';
import 'package:kratos/energy_skate_park/model/esp_vec.dart';

/// Model↔view transform — EnergySkateParkScreenView MVT (scale 61.40, y flip).
class EspMvt {
  const EspMvt({
    required this.viewOrigin,
    this.scale = EspConstants.mvtScale,
  });

  /// View pixel corresponding to model (0, 0) — ground center.
  final Offset viewOrigin;
  final double scale;

  Offset modelToView(EspVec p) => Offset(
        viewOrigin.dx + p.x * scale,
        viewOrigin.dy - p.y * scale,
      );

  Offset modelToViewXY(double x, double y) => Offset(
        viewOrigin.dx + x * scale,
        viewOrigin.dy - y * scale,
      );

  EspVec viewToModel(Offset p) => EspVec(
        (p.dx - viewOrigin.dx) / scale,
        (viewOrigin.dy - p.dy) / scale,
      );

  double modelToViewDeltaX(double dx) => dx * scale;
  double modelToViewDeltaY(double dy) => -dy * scale;

  /// Default: origin at horizontal center, near bottom of play area.
  static EspMvt forPlayArea(Size size) {
    return EspMvt(
      viewOrigin: Offset(size.width / 2, size.height * 0.82),
      scale: EspConstants.mvtScale,
    );
  }

  static EspMvt forLayout() => EspMvt(
        viewOrigin: Offset(
          EspConstants.layoutWidth / 2,
          EspConstants.layoutHeight * 0.82,
        ),
      );
}
