/// Model → view transform for Spin measurement area (scale 180, Y inverted).
library;

import 'dart:math' as math;
import 'dart:ui';

import '../../layout/qm_spin_layout_spec.dart';

class SpinVec2 {
  const SpinVec2(this.x, this.y);
  final double x;
  final double y;

  SpinVec2 operator +(SpinVec2 o) => SpinVec2(x + o.x, y + o.y);
  SpinVec2 operator -(SpinVec2 o) => SpinVec2(x - o.x, y - o.y);
  SpinVec2 scaled(double s) => SpinVec2(x * s, y * s);
  double get length => math.sqrt(x * x + y * y);

  SpinVec2 withMagnitude(double mag) {
    final len = length;
    if (len == 0) return const SpinVec2(0, 0);
    return scaled(mag / len);
  }

  static const zero = SpinVec2(0, 0);
}

class SpinViewTransform {
  const SpinViewTransform({
    this.scale = QmSpinLayoutSpec.modelViewScale,
    this.origin = Offset.zero,
  });

  final double scale;
  final Offset origin;

  Offset physicsToView(SpinVec2 m) => Offset(
        origin.dx + m.x * scale,
        origin.dy - m.y * scale,
      );

  SpinVec2 viewToPhysics(Offset v) => SpinVec2(
        (v.dx - origin.dx) / scale,
        -(v.dy - origin.dy) / scale,
      );

  double modelToViewDeltaX(double m) => m * scale;
  double modelToViewDeltaY(double m) => -m * scale;
}

/// Model-space apparatus anchors from LayoutSpec / SternGerlach.ts
class SpinApparatusMeters {
  const SpinApparatusMeters();

  static const sgWidth = QmSpinLayoutSpec.sternGerlachWidth;
  static const sgHeight = QmSpinLayoutSpec.sternGerlachHeight;
  static const holeW = 5 / 200;
  static const holeH = 20 / 200;

  SpinVec2 get source => SpinVec2(
        QmSpinLayoutSpec.particleSourcePosition.x,
        QmSpinLayoutSpec.particleSourcePosition.y,
      );

  /// Exit tip of particle source (right of body).
  SpinVec2 get sourceExit => SpinVec2(
        source.x + ParticleSourceMeters.width / 2,
        source.y,
      );

  SpinVec2 get sg0 => SpinVec2(
        QmSpinLayoutSpec.sg0Position.x,
        QmSpinLayoutSpec.sg0Position.y,
      );
  SpinVec2 get sg1 => SpinVec2(
        QmSpinLayoutSpec.sg1Position.x,
        QmSpinLayoutSpec.sg1Position.y,
      );
  SpinVec2 get sg2 => SpinVec2(
        QmSpinLayoutSpec.sg2Position.x,
        QmSpinLayoutSpec.sg2Position.y,
      );

  SpinVec2 entrance(SpinVec2 center) =>
      center + const SpinVec2(-sgWidth / 2 - holeW / 2, 0);
  SpinVec2 topExit(SpinVec2 center) =>
      center + const SpinVec2(sgWidth / 2 + holeW / 2, sgHeight / 4);
  SpinVec2 bottomExit(SpinVec2 center) =>
      center + const SpinVec2(sgWidth / 2 + holeW / 2, -sgHeight / 4);

  /// BLOCKER_OFFSET from SpinModel.ts
  static const blockerOffset = SpinVec2(0.1, 0);
  static const horizontalEndpoint = SpinVec2(10, 0);
}

class ParticleSourceMeters {
  static const width = 120 / 200;
  static const height = 120 / 200;
}
