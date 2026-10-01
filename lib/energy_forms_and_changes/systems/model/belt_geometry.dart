import 'dart:math' as math;
import 'dart:ui';

/// Pure geometry port of PhET `js/systems/model/Belt.ts`.
///
/// Model coordinates are Y-up. View conversion samples the model outline so
/// MVT Y-inversion cannot corrupt arc winding.
class BeltGeometry {
  BeltGeometry({
    required this.wheel1Center,
    required this.wheel1Radius,
    required this.wheel2Center,
    required this.wheel2Radius,
  }) {
    _compute();
  }

  final Offset wheel1Center;
  final double wheel1Radius;
  final Offset wheel2Center;
  final double wheel2Radius;

  late final double contactAngle;
  late final Offset wheel1ArcStart;
  late final Offset wheel1ArcEnd;
  late final Offset wheel2ArcStart;
  late final Offset wheel2ArcEnd;
  late final double wheel1ArcStartAngle;
  late final double wheel1ArcEndAngle;
  late final double wheel2ArcStartAngle;
  late final double wheel2ArcEndAngle;

  /// Clockwise arc span used by Belt.ts (`arcPoint` anticlockwise=false).
  double get arcSweepMagnitude => math.pi + 2 * contactAngle;

  static Offset _perpendicular(Offset v) => Offset(-v.dy, v.dx);

  static Offset _withMagnitude(Offset v, double mag) {
    final d = v.distance;
    if (d < 1e-12) return Offset.zero;
    return v * (mag / d);
  }

  static Offset _rotated(Offset v, double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    return Offset(v.dx * c - v.dy * s, v.dx * s + v.dy * c);
  }

  static double _angleOf(Offset v) => math.atan2(v.dy, v.dx);

  void _compute() {
    final dist = (wheel2Center - wheel1Center).distance;
    assert(dist > (wheel2Radius - wheel1Radius).abs());
    final asinArg = ((wheel2Radius - wheel1Radius) / dist).clamp(-1.0, 1.0);
    contactAngle = math.asin(asinArg);

    final c1ToC2 = wheel2Center - wheel1Center;
    final w1ToArcEnd = _rotated(
      _withMagnitude(_perpendicular(c1ToC2), wheel1Radius),
      -contactAngle,
    );
    final w1ToArcStart = _rotated(w1ToArcEnd, math.pi + 2 * contactAngle);
    final w2ToArcStart = _rotated(
      _withMagnitude(_perpendicular(c1ToC2), wheel2Radius),
      -contactAngle,
    );
    final w2ToArcEnd = _rotated(w2ToArcStart, math.pi + 2 * contactAngle);

    wheel1ArcStart = wheel1Center + w1ToArcStart;
    wheel1ArcEnd = wheel1Center + w1ToArcEnd;
    wheel2ArcStart = wheel2Center + w2ToArcStart;
    wheel2ArcEnd = wheel2Center + w2ToArcEnd;

    wheel1ArcStartAngle = _angleOf(w1ToArcStart);
    wheel1ArcEndAngle = _angleOf(w1ToArcEnd);
    wheel2ArcStartAngle = _angleOf(w2ToArcStart);
    wheel2ArcEndAngle = _angleOf(w2ToArcEnd);
  }

  List<Offset> _sampleClockwiseArc(
    Offset center,
    double radius,
    double startAngle, {
    int segments = 48,
  }) {
    // Clockwise = decreasing angle in standard math; magnitude from Belt.ts.
    final sweep = -arcSweepMagnitude;
    final out = <Offset>[];
    for (var i = 1; i <= segments; i++) {
      final t = i / segments;
      final a = startAngle + sweep * t;
      out.add(Offset(
        center.dx + radius * math.cos(a),
        center.dy + radius * math.sin(a),
      ));
    }
    return out;
  }

  /// Ordered model-space outline matching Belt.ts path construction.
  List<Offset> modelOutlinePoints({int arcSegments = 48}) {
    final pts = <Offset>[wheel1ArcStart];
    pts.addAll(
      _sampleClockwiseArc(
        wheel1Center,
        wheel1Radius,
        wheel1ArcStartAngle,
        segments: arcSegments,
      ),
    );
    pts.add(wheel2ArcStart);
    pts.addAll(
      _sampleClockwiseArc(
        wheel2Center,
        wheel2Radius,
        wheel2ArcStartAngle,
        segments: arcSegments,
      ),
    );
    pts.add(wheel1ArcStart);
    return pts;
  }

  Path toViewPath(Offset Function(Offset model) modelToView) {
    final pts = modelOutlinePoints();
    final path = Path();
    final first = modelToView(pts.first);
    path.moveTo(first.dx, first.dy);
    for (var i = 1; i < pts.length; i++) {
      final p = modelToView(pts[i]);
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    return path;
  }
}
