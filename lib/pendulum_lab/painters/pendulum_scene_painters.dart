import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:kratos/pendulum_lab/controller/pendulum_lab_controller.dart';
import 'package:kratos/pendulum_lab/model/pendulum.dart';
import 'package:kratos/pendulum_lab/pl_colors.dart';
import 'package:kratos/pendulum_lab/pl_constants.dart';
import 'package:kratos/pendulum_lab/transform/pendulum_lab_transform.dart';

const _transform = PendulumLabTransform();

/// Value-list comparison for painter fingerprints.
bool _fingerprintChanged(List<Object?> a, List<Object?> b) {
  if (a.length != b.length) return true;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return true;
  }
  return false;
}

class ProtractorPainter extends CustomPainter {
  ProtractorPainter({required this.pendula})
      : fingerprint = [
          for (final p in pendula) ...[p.isVisible, p.isTickVisible, p.angle],
        ];

  final List<Pendulum> pendula;

  /// Repaint only when a value the paint actually reads has changed.
  final List<Object?> fingerprint;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(_transform.origin.dx, _transform.origin.dy);

    final maxLen = _transform.modelToViewDeltaX(PlConstants.lengthMax);
    final dash = Paint()
      ..color = PlColors.firstPendulum
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    _drawDashedLine(canvas, Offset.zero, Offset(0, maxLen), dash, 4, 7);

    canvas.drawCircle(Offset.zero, 5, Paint()
      ..color = PlColors.firstPendulum
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1);
    canvas.drawCircle(Offset.zero, 2, Paint()..color = Colors.black);

    final tickPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    for (var deg = 0; deg <= 180; deg++) {
      final a = PlConstants.toRadians(deg.toDouble());
      final tickLen = deg % 10 == 0
          ? PlConstants.protractorTick10
          : deg % 5 == 0
              ? PlConstants.protractorTick5
              : PlConstants.protractorTick1;
      final inner = Offset(math.cos(a), math.sin(a)) * PlConstants.protractorRadius;
      final outer =
          Offset(math.cos(a), math.sin(a)) * (PlConstants.protractorRadius + tickLen);
      canvas.drawLine(inner, outer, tickPaint);
    }

    // Pendulum-2 ticks under pendulum-1 ticks (source child order).
    for (var i = 1; i >= 0; i--) {
      final p = pendula[i];
      if (!p.isVisible || !p.isTickVisible) continue;
      _drawPendulumTicks(canvas, p);
    }

    canvas.restore();
  }

  void _drawPendulumTicks(Canvas canvas, Pendulum p) {
    final paint = Paint()
      ..color = PlColors.pendulumColors[p.index]
      ..strokeWidth = 2;
    const r0 = PlConstants.protractorRadius - PlConstants.pendulumTickLength - 2;
    const r1 = PlConstants.protractorRadius - 2;
    void drawAt(double rotation) {
      canvas.save();
      canvas.rotate(rotation);
      canvas.drawLine(const Offset(r0, 0), const Offset(r1, 0), paint);
      canvas.restore();
    }

    drawAt(math.pi / 2 - p.angle);
    drawAt(math.pi / 2 + p.angle);
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset a,
    Offset b,
    Paint paint,
    double dash,
    double gap,
  ) {
    final total = (b - a).distance;
    final dir = (b - a) / total;
    var t = 0.0;
    var draw = true;
    while (t < total) {
      final len = draw ? dash : gap;
      final n = math.min(t + len, total);
      if (draw) {
        canvas.drawLine(a + dir * t, a + dir * n, paint);
      }
      t = n;
      draw = !draw;
    }
  }

  @override
  bool shouldRepaint(covariant ProtractorPainter oldDelegate) =>
      _fingerprintChanged(fingerprint, oldDelegate.fingerprint);
}

class PeriodTracePainter extends CustomPainter {
  PeriodTracePainter({
    required this.pendula,
    required this.traces,
  }) : fingerprint = [
          for (var i = 0; i < pendula.length; i++) ...[
            pendula[i].periodTrace.isVisible,
            pendula[i].periodTrace.numberOfPoints,
            pendula[i].periodTrace.firstAngle,
            pendula[i].periodTrace.secondAngle,
            pendula[i].periodTrace.counterClockwise,
            pendula[i].angle,
            pendula[i].length,
            traces[i].colorAlpha,
          ],
        ];

  final List<Pendulum> pendula;
  final List<PeriodTraceViewState> traces;

  /// Repaint only when a value the paint actually reads has changed.
  final List<Object?> fingerprint;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(_transform.origin.dx, _transform.origin.dy);
    canvas.rotate(math.pi / 2);
    for (var i = 0; i < pendula.length; i++) {
      _paintTrace(canvas, pendula[i], traces[i]);
    }
    canvas.restore();
  }

  void _paintTrace(Canvas canvas, Pendulum pendulum, PeriodTraceViewState view) {
    final trace = pendulum.periodTrace;
    if (!trace.isVisible || trace.numberOfPoints <= 0) return;

    var traceLength = _transform.modelToViewDeltaX(
      pendulum.length * 3.2 / 4 - 0.1 / 2,
    );
    var traceStep = 10.0;
    if (traceStep * 4 > traceLength) {
      traceStep = traceLength / 4;
    }

    final path = Path();
    final n = trace.numberOfPoints;
    final ccw = trace.counterClockwise ?? false;

    void addArc(double r, double start, double end, bool anticlockwise) {
      _arcTo(path, r, start, end, anticlockwise);
    }

    if (n > 1) {
      addArc(traceLength, 0, -(trace.firstAngle ?? 0), !ccw);
      final fa = -(trace.firstAngle ?? 0);
      path.lineTo(
        (traceLength - traceStep) * math.cos(fa),
        (traceLength - traceStep) * math.sin(fa),
      );
      if (n > 2) {
        addArc(
          traceLength - traceStep,
          fa,
          -(trace.secondAngle ?? 0),
          ccw,
        );
        final sa = -(trace.secondAngle ?? 0);
        path.lineTo(
          (traceLength - 2 * traceStep) * math.cos(sa),
          (traceLength - 2 * traceStep) * math.sin(sa),
        );
        if (n > 3) {
          addArc(traceLength - 2 * traceStep, sa, 0, !ccw);
        } else {
          addArc(
            traceLength - 2 * traceStep,
            sa,
            -pendulum.angle,
            !ccw,
          );
        }
      } else {
        addArc(
          traceLength - traceStep,
          fa,
          -pendulum.angle,
          ccw,
        );
      }
    } else {
      addArc(traceLength, 0, -pendulum.angle, !ccw);
    }

    final base = PlColors.pendulumColors[pendulum.index];
    canvas.drawPath(
      path,
      Paint()
        ..color = base.withValues(alpha: view.colorAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  /// kite `Shape.arc` → Flutter sweep.
  void _arcTo(
    Path path,
    double r,
    double start,
    double end,
    bool anticlockwise,
  ) {
    var sweep = end - start;
    if (anticlockwise) {
      if (sweep >= 0) sweep -= 2 * math.pi;
    } else {
      if (sweep <= 0) sweep += 2 * math.pi;
    }
    if (path.getBounds().isEmpty && path.computeMetrics().isEmpty) {
      path.moveTo(r * math.cos(start), r * math.sin(start));
    }
    path.arcTo(
      Rect.fromCircle(center: Offset.zero, radius: r),
      start,
      sweep,
      false,
    );
  }

  @override
  bool shouldRepaint(covariant PeriodTracePainter oldDelegate) =>
      _fingerprintChanged(fingerprint, oldDelegate.fingerprint);
}

class PendulaPainter extends CustomPainter {
  PendulaPainter({required this.pendula})
      : fingerprint = [
          for (final p in pendula) ...[p.isVisible, p.angle, p.length, p.mass],
        ];

  final List<Pendulum> pendula;

  /// Repaint only when a value the paint actually reads has changed.
  final List<Object?> fingerprint;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pendula) {
      if (!p.isVisible) continue;
      _paintPendulum(canvas, p);
    }
  }

  void _paintPendulum(Canvas canvas, Pendulum p) {
    final origin = _transform.origin;
    final viewLen = _transform.modelToViewDeltaX(p.length);
    final scale = PlConstants.massToScale(p.mass);
    final w = PlConstants.bobRectWidth * scale;
    final h = PlConstants.bobRectHeight * scale;
    final color = PlColors.pendulumColors[p.index];

    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(-p.angle);
    canvas.drawLine(
      Offset.zero,
      Offset(0, viewLen),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 1,
    );

    canvas.translate(0, viewLen);
    final rect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
    final shader = ui.Gradient.linear(
      Offset(-w / 2, 0),
      Offset(w / 2, 0),
      [
        PlColors.brighter(color, 0.4),
        PlColors.brighter(color, 0.9),
        color,
      ],
      const [0.0, 0.2, 0.7],
    );
    canvas.drawRect(rect, Paint()..shader = shader);
    canvas.drawLine(
      Offset(-w / 2, 0),
      Offset(w / 2, 0),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 1,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: '${p.index + 1}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32 * 0.9,
          fontWeight: FontWeight.bold,
          fontFamily: 'Arial',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    // centerY: RECT_SIZE.height/4 of unscaled bob → scaled
    tp.paint(
      canvas,
      Offset(-tp.width / 2, h / 4 - tp.height / 2),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PendulaPainter oldDelegate) =>
      _fingerprintChanged(fingerprint, oldDelegate.fingerprint);
}

class VectorArrowsPainter extends CustomPainter {
  VectorArrowsPainter({
    required this.pendula,
    required this.showVelocity,
    required this.showAcceleration,
  }) : fingerprint = [
          showVelocity,
          showAcceleration,
          for (final p in pendula) ...[
            p.isVisible,
            p.position.x,
            p.position.y,
            p.velocity.x,
            p.velocity.y,
            p.acceleration.x,
            p.acceleration.y,
          ],
        ];

  final List<Pendulum> pendula;
  final bool showVelocity;
  final bool showAcceleration;

  /// Repaint only when a value the paint actually reads has changed.
  final List<Object?> fingerprint;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pendula) {
      if (!p.isVisible) continue;
      final pos = _transform.modelToView(p.position);
      if (showVelocity) {
        _arrow(
          canvas,
          pos,
          Offset(
            pos.dx + PlConstants.arrowSizeDefault * p.velocity.x,
            pos.dy - PlConstants.arrowSizeDefault * p.velocity.y,
          ),
          PlColors.velocityArrow,
        );
      }
      if (showAcceleration) {
        _arrow(
          canvas,
          pos,
          Offset(
            pos.dx + PlConstants.arrowSizeDefault * p.acceleration.x,
            pos.dy - PlConstants.arrowSizeDefault * p.acceleration.y,
          ),
          PlColors.accelerationArrow,
        );
      }
    }
  }

  void _arrow(Canvas canvas, Offset tail, Offset tip, Color color) {
    final d = tip - tail;
    final len = d.distance;
    if (len < 1) return;
    final dir = d / len;
    final n = Offset(-dir.dy, dir.dx);
    const headLen = 14.0;
    const headW = PlConstants.arrowHeadWidth / 2;
    const tailW = PlConstants.arrowTailWidth / 2;
    final bodyEnd = tip - dir * math.min(headLen, len);
    final path = Path()
      ..moveTo(tail.dx + n.dx * tailW, tail.dy + n.dy * tailW)
      ..lineTo(bodyEnd.dx + n.dx * tailW, bodyEnd.dy + n.dy * tailW)
      ..lineTo(bodyEnd.dx + n.dx * headW, bodyEnd.dy + n.dy * headW)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(bodyEnd.dx - n.dx * headW, bodyEnd.dy - n.dy * headW)
      ..lineTo(bodyEnd.dx - n.dx * tailW, bodyEnd.dy - n.dy * tailW)
      ..lineTo(tail.dx - n.dx * tailW, tail.dy - n.dy * tailW)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }

  @override
  bool shouldRepaint(covariant VectorArrowsPainter oldDelegate) =>
      _fingerprintChanged(fingerprint, oldDelegate.fingerprint);
}

class DegreeReadoutPainter extends CustomPainter {
  DegreeReadoutPainter({required this.pendula})
      : fingerprint = [
          // paint() renders the rounded degree — sub-degree pointer moves
          // don't change the readout, so don't repaint for them.
          for (final p in pendula) ...[
            p.isUserControlled,
            PlConstants.toDegrees(p.angle).round(),
          ],
        ];

  final List<Pendulum> pendula;

  /// Repaint only when a value the paint actually reads has changed.
  final List<Object?> fingerprint;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = _transform.origin;
    for (final p in pendula) {
      if (!p.isUserControlled) continue;
      final deg = PlConstants.toDegrees(p.angle);
      final tp = TextPainter(
        text: TextSpan(
          text: '${deg.round()}°',
          style: TextStyle(
            color: PlColors.pendulumColors[p.index],
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arial',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final offset = p.index == 0
          ? Offset(origin.dx - 25 - tp.width, origin.dy + 15 - tp.height / 2)
          : Offset(origin.dx + 35, origin.dy + 15 - tp.height / 2);
      tp.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant DegreeReadoutPainter oldDelegate) =>
      _fingerprintChanged(fingerprint, oldDelegate.fingerprint);
}
