import 'dart:math' as math;
import 'dart:ui';

/// Water side-view geometry — [已确认] WaveInterferenceUtils.getWaterSideShape/Y @ 31ebfd7
class WaterSideGeometry {
  WaterSideGeometry._();

  static const Color waterSideColor = Color(0xFF58C0FA);

  /// Map lattice value → view Y. value 0 → centerY; value 5 → centerY-47.
  static double waterSideY(Rect waveAreaBounds, double waveValue) {
    final centerY = waveAreaBounds.center.dy;
    return centerY + (0 - waveValue) / 5 * 47;
    // Utils.linear(0, 5, centerY, centerY-47, waveValue)
    // = centerY + (waveValue-0)/(5-0)*((centerY-47)-centerY) = centerY - waveValue/5*47
  }

  static double waterSideYExact(Rect bounds, double waveValue) {
    return bounds.center.dy - (waveValue / 5.0) * 47.0;
  }

  /// Smooth source cell: (v + 3*prev + 3*next)/7 at POINT_SOURCE index.
  static List<Offset> sidePathPoints({
    required List<double> centerLine,
    required Rect waveAreaBounds,
    required int pointSourceIndex,
  }) {
    final n = centerLine.length;
    if (n == 0) return const [];
    final pts = <Offset>[];
    for (var i = 0; i < n; i++) {
      var value = centerLine[i];
      if (i == pointSourceIndex && i > 0 && i < n - 1) {
        value = (centerLine[i] +
                3 * centerLine[i - 1] +
                3 * centerLine[i + 1]) /
            7;
      }
      // Map cell center: linear(-0.5, n-1+0.5, left, right, i)
      final x = _linear(-0.5, n - 1 + 0.5, waveAreaBounds.left,
          waveAreaBounds.right, i.toDouble());
      final y = waterSideYExact(waveAreaBounds, value);
      pts.add(Offset(x, y));
    }
    return pts;
  }

  static double _linear(
    double x1,
    double x2,
    double y1,
    double y2,
    double x,
  ) {
    if ((x2 - x1).abs() < 1e-15) return y1;
    return y1 + (x - x1) / (x2 - x1) * (y2 - y1);
  }

  /// Piecewise brightness for Waves Intro light screen — LightScreenNode.js
  static double piecewiseBrightness(double intensity) {
    const xs = [
      0.0,
      0.002237089269640335,
      0.008937089269640335,
      0.05372277438413573,
      0.13422634397144692,
      0.2096934692889395,
      1.0,
    ];
    const ys = [0.0, 0.4, 0.5, 0.64, 0.74, 0.8, 1.0];
    if (intensity <= xs.first) return ys.first;
    if (intensity >= xs.last) return ys.last;
    for (var i = 0; i < xs.length - 1; i++) {
      if (intensity >= xs[i] && intensity <= xs[i + 1]) {
        return _linear(xs[i], xs[i + 1], ys[i], ys[i + 1], intensity);
      }
    }
    return ys.last.clamp(0.0, 1.0);
  }

  static double cubicInOut(double t) {
    // Easing.CUBIC_IN_OUT for perspective — approximate
    t = t.clamp(0.0, 1.0);
    return t < 0.5
        ? 4 * t * t * t
        : 1 - math.pow(-2 * t + 2, 3) / 2;
  }
}
