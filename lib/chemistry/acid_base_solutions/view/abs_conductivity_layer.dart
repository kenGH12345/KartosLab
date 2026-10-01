import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/abs_beaker.dart';
import '../model/abs_conductivity_tester.dart';
import '../model/abs_math.dart';
import '../model/abs_view_properties.dart';
import 'abs_assets.dart';

/// Conductivity tester — PhET scenery-phet `ConductivityTesterNode`
/// via ABS `ABSConductivityTesterNode`.
///
/// Chrome: original lightBulbOn/Off + batteryDCell PNGs, cubic wires,
/// rectangular probes with +/- labels, brightness-driven rays + on opacity.
class AbsConductivityLayer extends StatelessWidget {
  const AbsConductivityLayer({
    super.key,
    required this.tester,
    required this.beaker,
    required this.toolMode,
    required this.onPositiveDrag,
    required this.onNegativeDrag,
    required this.onPositivePressed,
    required this.onNegativePressed,
  });

  final AbsConductivityTester tester;
  final AbsBeaker beaker;
  final AbsToolMode toolMode;
  final ValueChanged<Offset> onPositiveDrag;
  final ValueChanged<Offset> onNegativeDrag;
  final ValueChanged<bool> onPositivePressed;
  final ValueChanged<bool> onNegativePressed;

  static const double bulbImageScale = 0.33;
  static const double batteryImageScale = 0.6;
  static const double bulbToBatteryWireLength = 40;
  static const double wireLineWidth = 1.5;
  static const double probeLineWidth = 0.5;

  /// Intrinsic sizes of scenery-phet mipmaps / images.
  static const Size bulbOffIntrinsic = Size(108, 189);
  static const Size bulbOnIntrinsic = Size(136, 203);
  static const Size batteryIntrinsic = Size(103, 53);

  static Size get bulbOffSize => Size(
        bulbOffIntrinsic.width * bulbImageScale,
        bulbOffIntrinsic.height * bulbImageScale,
      );

  static Size get bulbOnSize => Size(
        bulbOnIntrinsic.width * bulbImageScale,
        bulbOnIntrinsic.height * bulbImageScale,
      );

  static Size get batterySize => Size(
        batteryIntrinsic.width * batteryImageScale,
        batteryIntrinsic.height * batteryImageScale,
      );

  @override
  Widget build(BuildContext context) {
    if (toolMode != AbsToolMode.conductivityTester) {
      return const SizedBox.shrink();
    }

    final bulb = tester.bulbPosition;
    final brightness = tester.brightness.clamp(0.0, 1.0);
    final pos = tester.positiveProbePosition;
    final neg = tester.negativeProbePosition;
    final probe = tester.probeSize;

    // Relative to apparatus origin (bulb bottom-center).
    final posLocal = Offset(pos.dx - bulb.dx, pos.dy - bulb.dy);
    final negLocal = Offset(neg.dx - bulb.dx, neg.dy - bulb.dy);

    // Wire end points at top-center of probes (probe origin = bottom center).
    final posWireEnd = Offset(posLocal.dx, posLocal.dy - probe.height);
    final negWireEnd = Offset(negLocal.dx, negLocal.dy - probe.height);

    // Battery right terminal ≈ battery right edge, centerY 0 in apparatus.
    final batteryLeft = bulbToBatteryWireLength;
    final batteryRight = batteryLeft + batterySize.width;
    final posWireStart = Offset(batteryRight, 0);
    // Negative wire from bulb base (source: -5,-5 specific to bulb image).
    final negWireStart = const Offset(-5, -5);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Wires in screen space (absolute).
        CustomPaint(
          painter: _ConductivityWiresPainter(
            bulbOrigin: bulb,
            positiveStart: posWireStart,
            positiveEnd: posWireEnd,
            negativeStart: negWireStart,
            negativeEnd: negWireEnd,
          ),
        ),
        // Apparatus (bulb + battery) at bulb origin.
        Positioned(
          left: bulb.dx - bulbOnSize.width / 2 - 20,
          top: bulb.dy - bulbOnSize.height - 8,
          width: bulbOnSize.width / 2 +
              20 +
              bulbToBatteryWireLength +
              batterySize.width +
              8,
          height: bulbOnSize.height + 16,
          child: _Apparatus(
            brightness: brightness,
            bulbOffSize: bulbOffSize,
            bulbOnSize: bulbOnSize,
            batterySize: batterySize,
          ),
        ),
        // Probes — drag moves both (source ConductivityTesterNode).
        _ProbeHandle(
          position: pos,
          size: probe,
          fill: Colors.red,
          stroke: Colors.black,
          label: _PlusMinusLabel(plus: true, color: Colors.white),
          onPressed: (v) {
            onPositivePressed(v);
            onNegativePressed(v);
          },
          onDragY: (y) {
            onPositiveDrag(Offset(pos.dx, y));
            onNegativeDrag(Offset(neg.dx, y));
          },
        ),
        _ProbeHandle(
          position: neg,
          size: probe,
          fill: Colors.black,
          stroke: Colors.black,
          label: _PlusMinusLabel(plus: false, color: Colors.white),
          onPressed: (v) {
            onPositivePressed(v);
            onNegativePressed(v);
          },
          onDragY: (y) {
            onPositiveDrag(Offset(pos.dx, y));
            onNegativeDrag(Offset(neg.dx, y));
          },
        ),
      ],
    );
  }
}

class _Apparatus extends StatelessWidget {
  const _Apparatus({
    required this.brightness,
    required this.bulbOffSize,
    required this.bulbOnSize,
    required this.batterySize,
  });

  final double brightness;
  final Size bulbOffSize;
  final Size bulbOnSize;
  final Size batterySize;

  @override
  Widget build(BuildContext context) {
    // Local origin at bottom-center of bulb, offset into this widget.
    final originX = 20 + bulbOnSize.width / 2;
    final originY = bulbOnSize.height + 8;
    final onOpacity = brightness > 0
        ? AbsMath.linear(0, 1, 0.3, 1, brightness).clamp(0.3, 1.0)
        : 0.0;
    final bulbRadius = bulbOffSize.width / 2;
    final bulbCenterY = originY - bulbOffSize.height + bulbRadius;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Rays behind bulb
        if (brightness > 0)
          CustomPaint(
            painter: _LightRaysPainter(
              center: Offset(originX, bulbCenterY),
              bulbRadius: bulbRadius,
              brightness: brightness,
            ),
          ),
        // Bulb-to-battery wire
        CustomPaint(
          painter: _SegmentPainter(
            a: Offset(originX, originY),
            b: Offset(
              originX + AbsConductivityLayer.bulbToBatteryWireLength,
              originY,
            ),
            strokeWidth: AbsConductivityLayer.wireLineWidth,
          ),
        ),
        // Battery
        Positioned(
          left: originX + AbsConductivityLayer.bulbToBatteryWireLength,
          top: originY - batterySize.height / 2,
          width: batterySize.width,
          height: batterySize.height,
          child: Image.asset(
            AbsAssets.batteryDCell,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.medium,
          ),
        ),
        // Off bulb
        Positioned(
          left: originX - bulbOffSize.width / 2,
          top: originY - bulbOffSize.height,
          width: bulbOffSize.width,
          height: bulbOffSize.height,
          child: Image.asset(
            AbsAssets.lightBulbOff,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.medium,
          ),
        ),
        // On bulb (opacity from brightness)
        if (brightness > 0)
          Positioned(
            left: originX - bulbOnSize.width / 2,
            top: originY - bulbOnSize.height,
            width: bulbOnSize.width,
            height: bulbOnSize.height,
            child: Opacity(
              opacity: onOpacity,
              child: Image.asset(
                AbsAssets.lightBulbOn,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
      ],
    );
  }
}

class _ProbeHandle extends StatelessWidget {
  const _ProbeHandle({
    required this.position,
    required this.size,
    required this.fill,
    required this.stroke,
    required this.label,
    required this.onDragY,
    required this.onPressed,
  });

  final Offset position;
  final Size size;
  final Color fill;
  final Color stroke;
  final Widget label;
  final ValueChanged<double> onDragY;
  final ValueChanged<bool> onPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - size.width / 2,
      top: position.dy - size.height,
      child: GestureDetector(
        onPanStart: (_) => onPressed(true),
        onPanEnd: (_) => onPressed(false),
        onPanCancel: () => onPressed(false),
        onPanUpdate: (d) => onDragY(position.dy + d.delta.dy),
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: CustomPaint(
            painter: _ProbePainter(fill: fill, stroke: stroke),
            child: Align(
              alignment: const Alignment(0, 0.55),
              child: label,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlusMinusLabel extends StatelessWidget {
  const _PlusMinusLabel({required this.plus, required this.color});

  final bool plus;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(10, 10),
      painter: _PlusMinusPainter(plus: plus, color: color),
    );
  }
}

class _PlusMinusPainter extends CustomPainter {
  _PlusMinusPainter({required this.plus, required this.color});

  final bool plus;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawLine(Offset(2, cy), Offset(size.width - 2, cy), paint);
    if (plus) {
      canvas.drawLine(Offset(cx, 2), Offset(cx, size.height - 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PlusMinusPainter oldDelegate) =>
      oldDelegate.plus != plus || oldDelegate.color != color;
}

class _ProbePainter extends CustomPainter {
  _ProbePainter({required this.fill, required this.stroke});

  final Color fill;
  final Color stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, Paint()..color = fill);
    canvas.drawRect(
      rect,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = AbsConductivityLayer.probeLineWidth,
    );
  }

  @override
  bool shouldRepaint(covariant _ProbePainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.stroke != stroke;
}

class _SegmentPainter extends CustomPainter {
  _SegmentPainter({
    required this.a,
    required this.b,
    required this.strokeWidth,
  });

  final Offset a;
  final Offset b;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      a,
      b,
      Paint()
        ..color = Colors.black
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _SegmentPainter oldDelegate) =>
      oldDelegate.a != a || oldDelegate.b != b;
}

/// Cubic wire — scenery-phet `WireNode`.
class _ConductivityWiresPainter extends CustomPainter {
  _ConductivityWiresPainter({
    required this.bulbOrigin,
    required this.positiveStart,
    required this.positiveEnd,
    required this.negativeStart,
    required this.negativeEnd,
  });

  final Offset bulbOrigin;
  final Offset positiveStart;
  final Offset positiveEnd;
  final Offset negativeStart;
  final Offset negativeEnd;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = AbsConductivityLayer.wireLineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _drawWire(
      canvas,
      paint,
      bulbOrigin + positiveStart,
      bulbOrigin + positiveEnd,
    );
    _drawWire(
      canvas,
      paint,
      bulbOrigin + negativeStart,
      bulbOrigin + negativeEnd,
    );
  }

  void _drawWire(Canvas canvas, Paint paint, Offset start, Offset end) {
    // controlPointOffset: { x: 30, y: -50 }; flip x if endX < startX
    var cpx = 30.0;
    const cpy = -50.0;
    if (end.dx < start.dx) cpx = -cpx;

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        start.dx + cpx,
        start.dy,
        end.dx,
        end.dy + cpy,
        end.dx,
        end.dy,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ConductivityWiresPainter oldDelegate) =>
      oldDelegate.bulbOrigin != bulbOrigin ||
      oldDelegate.positiveEnd != positiveEnd ||
      oldDelegate.negativeEnd != negativeEnd;
}

/// Light rays — scenery-phet `LightRaysNode.setBrightness`.
class _LightRaysPainter extends CustomPainter {
  _LightRaysPainter({
    required this.center,
    required this.bulbRadius,
    required this.brightness,
  });

  final Offset center;
  final double bulbRadius;
  final double brightness;

  static const double raysStartAngle = 3 * math.pi / 4;
  static const double raysArcAngle = 3 * math.pi / 2;
  static const int minRays = 8;
  static const int maxRays = 60;
  static const double maxRayLength = 200;

  @override
  void paint(Canvas canvas, Size size) {
    if (brightness <= 0) return;
    final numberOfRays = minRays +
        AbsMath.roundSymmetric(brightness * (maxRays - minRays)).toInt();
    final rayLength = brightness * maxRayLength;
    var angle = raysStartAngle;
    final delta = numberOfRays > 1 ? raysArcAngle / (numberOfRays - 1) : 0.0;

    var lineWidth = AbsMath.linear(
      0.3 * maxRayLength,
      0.6 * maxRayLength,
      0.5,
      1.5,
      rayLength,
    );
    lineWidth = lineWidth.clamp(0.5, 1.5);

    final paint = Paint()
      ..color = const Color(0xFFFFFF00)
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < numberOfRays; i++) {
      final cosA = math.cos(angle);
      final sinA = math.sin(angle);
      final p1 = Offset(
        center.dx + cosA * bulbRadius,
        center.dy + sinA * bulbRadius,
      );
      final p2 = Offset(
        center.dx + cosA * (bulbRadius + rayLength),
        center.dy + sinA * (bulbRadius + rayLength),
      );
      canvas.drawLine(p1, p2, paint);
      angle += delta;
    }
  }

  @override
  bool shouldRepaint(covariant _LightRaysPainter oldDelegate) =>
      oldDelegate.brightness != brightness ||
      oldDelegate.center != center ||
      oldDelegate.bulbRadius != bulbRadius;
}

/// Light bulb tool icon — original PNG.
class AbsLightBulbIcon extends StatelessWidget {
  const AbsLightBulbIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(AbsAssets.lightBulbIcon, width: 30, height: 30);
  }
}
