import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../model/resistance_in_a_wire_model.dart';
import '../resistance_in_a_wire_view_constants.dart';

/// PhET `WireNode` + `DotsCanvasNode` — 3D wire with impurity dots.
///
/// Dot centers generated once (like source constructor); only visibility
/// tracks resistivity. [dotRandom] injects deterministic RNG for goldens.
class WireNode extends StatefulWidget {
  const WireNode({
    super.key,
    required this.model,
    this.dotRandom,
  });

  final ResistanceInAWireModel model;
  final math.Random? dotRandom;

  /// Source `DotsCanvasNode` scatterer layout — pure, testable.
  static List<Offset> buildDotCenters(math.Random random) {
    final dots = <Offset>[];
    final n = ResistanceInAWireViewConstants.numberOfDots.floor();
    final maxW = ResistanceInAWireViewConstants.maxWidthIncludingRoundedEnds;
    final maxH = ResistanceInAWireViewConstants.wireViewHeightMax;
    for (var i = 0; i < n; i++) {
      final centerX = (random.nextDouble() - 0.5) * maxW;
      final centerY = (random.nextDouble() - 0.5) * maxH;
      dots.add(Offset(centerX, centerY));
    }
    return dots;
  }

  @override
  State<WireNode> createState() => _WireNodeState();
}

class _WireNodeState extends State<WireNode> {
  late final List<Offset> _dotCenters;

  @override
  void initState() {
    super.initState();
    _dotCenters = WireNode.buildDotCenters(
      widget.dotRandom ?? math.Random(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = ResistanceInAWireViewConstants.lengthToWidth(widget.model.length);
    final h = ResistanceInAWireViewConstants.areaToHeight(widget.model.area);
    final padX = ResistanceInAWireViewConstants.wireViewHeightMax *
            ResistanceInAWireViewConstants.perspectiveFactor +
        8;
    final padY = 8.0;
    final boxW = ResistanceInAWireViewConstants.wireViewWidthMax + padX * 2;
    final boxH = ResistanceInAWireViewConstants.wireViewHeightMax + padY * 2;

    return Semantics(
      label: 'The Wire',
      child: SizedBox(
        width: boxW,
        height: boxH,
        child: CustomPaint(
          painter: _WirePainter(
            model: widget.model,
            dotCenters: _dotCenters,
            wireWidth: w,
            wireHeight: h,
          ),
        ),
      ),
    );
  }
}

class _WirePainter extends CustomPainter {
  _WirePainter({
    required this.model,
    required this.dotCenters,
    required this.wireWidth,
    required this.wireHeight,
  });

  final ResistanceInAWireModel model;
  final List<Offset> dotCenters;
  final double wireWidth;
  final double wireHeight;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    final w = wireWidth;
    final h = wireHeight;
    final rx = ResistanceInAWireViewConstants.perspectiveFactor * h / 2;

    // Body path: bottom → right outer arc → top → close left.
    final body = Path()..moveTo(-w / 2, h / 2);
    body.lineTo(w / 2, h / 2);
    _arcRightOuter(body, w / 2, h); // bottom → right → top
    body.lineTo(-w / 2, -h / 2);
    body.close();

    final gradient = ui.Gradient.linear(
      Offset(0, h / 2),
      Offset(0, -h / 2),
      const [
        ResistanceInAWireViewConstants.wireDark,
        ResistanceInAWireViewConstants.wireMid,
        ResistanceInAWireViewConstants.wireHighlight,
        ResistanceInAWireViewConstants.wireNearHighlight,
        ResistanceInAWireViewConstants.wireDark,
      ],
      const [0.0, 0.5, 0.65, 0.8, 1.0],
    );

    canvas.drawPath(
      body,
      Paint()
        ..shader = gradient
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      body,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Left end cap ellipse.
    final endRect = Rect.fromCenter(
      center: Offset(-w / 2, 0),
      width: rx * 2,
      height: h,
    );
    canvas.drawOval(
      endRect,
      Paint()..color = ResistanceInAWireViewConstants.wireMid,
    );
    canvas.drawOval(
      endRect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Impurity dots — clip to wire silhouette (approx elliptical ends).
    canvas.save();
    canvas.clipPath(_clipPath(w, h));
    final numDots =
        ResistanceInAWireViewConstants.resistivityToNumDots(model.resistivity)
            .floor();
    final dotPaint = Paint()..color = Colors.black;
    final r = ResistanceInAWireViewConstants.dotRadius;
    final limit = math.min(numDots, dotCenters.length);
    for (var i = 0; i < limit; i++) {
      final c = dotCenters[i];
      canvas.drawCircle(c, r, dotPaint);
    }
    canvas.restore();

    canvas.restore();
  }

  /// Right outer arc: PI/2 → -PI/2 through angle 0 (matches Dots right end).
  void _arcRightOuter(Path path, double centerX, double height) {
    const segments = 9;
    const start = math.pi / 2;
    const end = -math.pi / 2;
    final delta = (end - start) / segments;
    final xRadius =
        ResistanceInAWireViewConstants.perspectiveFactor * height / 2;
    final yRadius = height / 2;
    var t = start;
    for (var i = 0; i <= segments; i++) {
      path.lineTo(centerX + xRadius * math.cos(t), yRadius * math.sin(t));
      t += delta;
    }
  }

  Path _clipPath(double w, double h) {
    final path = Path()..moveTo(-w / 2, h / 2);
    // Left end: PI/2 → 3PI/2 through -x (DotsCanvasNode).
    _approxArc(path, h, -w / 2, math.pi / 2, 3 * math.pi / 2);
    path.lineTo(w / 2, -h / 2);
    // Right end: 3PI/2 → 5PI/2 through +x.
    _approxArc(path, h, w / 2, 3 * math.pi / 2, 5 * math.pi / 2);
    path.lineTo(-w / 2, h / 2);
    path.close();
    return path;
  }

  void _approxArc(
    Path path,
    double height,
    double centerX,
    double startAngle,
    double endAngle,
  ) {
    const segments = 9;
    final delta = (endAngle - startAngle) / segments;
    final xRadius =
        ResistanceInAWireViewConstants.perspectiveFactor * height / 2;
    final yRadius = height / 2;
    var t = startAngle;
    for (var i = 0; i <= segments; i++) {
      path.lineTo(centerX + xRadius * math.cos(t), yRadius * math.sin(t));
      t += delta;
    }
  }

  @override
  bool shouldRepaint(covariant _WirePainter oldDelegate) =>
      oldDelegate.wireWidth != wireWidth ||
      oldDelegate.wireHeight != wireHeight ||
      oldDelegate.model.resistivity != model.resistivity ||
      oldDelegate.dotCenters != dotCenters;
}
