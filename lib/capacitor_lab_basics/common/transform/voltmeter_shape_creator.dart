import 'dart:math' as math;
import 'dart:ui' show Offset, Path;

import '../model/voltmeter.dart';
import 'yaw_pitch_mvt.dart';

/// Probe tip shapes in view space — `VoltmeterShapeCreator.js`
class VoltmeterShapeCreator {
  VoltmeterShapeCreator(this.voltmeter, this.mvt);

  final Voltmeter voltmeter;
  final YawPitchMvt mvt;

  /// `PROBE_TIP_OFFSET` — js:18
  static const double tipOffsetX = 0.00018;
  static const double tipOffsetY = 0.00025;

  /// `PROBE_TIP_SIZE` — Voltmeter.js:29
  static const double tipWidth = 0.0003;
  static const double tipHeight = 0.0013;

  Path getPositiveProbeTipShape() {
    return getProbeTipShape(
      originX: voltmeter.positiveProbeX + tipOffsetX,
      originY: voltmeter.positiveProbeY + tipOffsetY,
      theta: -mvt.yaw,
    );
  }

  Path getNegativeProbeTipShape() {
    return getProbeTipShape(
      originX: voltmeter.negativeProbeX + tipOffsetX,
      originY: voltmeter.negativeProbeY + tipOffsetY,
      theta: -mvt.yaw,
    );
  }

  /// Tip polygon rotated about origin then projected — js:64-81
  Path getProbeTipShape({
    required double originX,
    required double originY,
    required double theta,
  }) {
    const midRatio = 0.5;
    final corners = <Offset>[
      Offset(originX + tipWidth / 2, originY),
      Offset(originX + tipWidth, originY + tipHeight * midRatio),
      Offset(originX + tipWidth, originY + tipHeight),
      Offset(originX, originY + tipHeight),
      Offset(originX, originY + tipHeight * midRatio),
    ];

    final path = Path();
    for (var i = 0; i < corners.length; i++) {
      final r = _rotateAround(corners[i], originX, originY, theta);
      final v = mvt.modelToViewXYZ(r.dx, r.dy, 0);
      if (i == 0) {
        path.moveTo(v.dx, v.dy);
      } else {
        path.lineTo(v.dx, v.dy);
      }
    }
    path.close();
    return path;
  }

  static Offset _rotateAround(Offset p, double cx, double cy, double theta) {
    final dx = p.dx - cx;
    final dy = p.dy - cy;
    final c = math.cos(theta);
    final s = math.sin(theta);
    return Offset(cx + dx * c - dy * s, cy + dx * s + dy * c);
  }

  /// Tip size reference for tests / docs.
  static ({double width, double height}) get probeTipSize => (
        width: tipWidth,
        height: tipHeight,
      );
}
