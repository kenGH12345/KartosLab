import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/bl_vec2.dart';
import '../model/laser.dart';
import '../screens/stage_scale.dart';
import '../transform/bl_mvt.dart';

/// Scenery-phet LaserPointerNode dims for Bending Light.
const Size kLaserBodySize = Size(70, 30);
const Size kLaserNozzleSize = Size(10, 25);
const double kLaserButtonRadius = 12;
const double kLaserCornerRadius = 2;

/// Laser pointer: tip at emission point, body away from pivot (beam toward pivot).
class LaserPointerWidget extends StatelessWidget {
  const LaserPointerWidget({
    super.key,
    required this.laser,
    required this.mvt,
    this.onPowerTap,
    this.onBodyPanUpdate,
    this.onKnobPanUpdate,
    this.showKnob = false,
  });

  final Laser laser;
  final BlMvt mvt;
  final VoidCallback? onPowerTap;
  final GestureDragUpdateCallback? onBodyPanUpdate;
  final GestureDragUpdateCallback? onKnobPanUpdate;
  final bool showKnob;

  static double get totalLength =>
      kLaserBodySize.width + kLaserNozzleSize.width;

  /// Screen angle of beam direction (toward pivot).
  double get beamScreenAngle {
    final dir = laser.getDirectionUnitVector();
    if (dir.magnitudeSquared < 1e-30) {
      // Fallback: use getAngle model orientation
      final modelAngle = laser.getAngle();
      final viewDelta = mvt.modelToViewDelta(BlVec2(
        math.cos(modelAngle + math.pi),
        math.sin(modelAngle + math.pi),
      ));
      return math.atan2(viewDelta.dy, viewDelta.dx);
    }
    final viewDelta = mvt.modelToViewDelta(dir);
    return math.atan2(viewDelta.dy, viewDelta.dx);
  }

  Offset get tipScreen => mvt.worldToScreen(laser.emissionPoint);

  /// Local button center: tip at (0,0), body along −x.
  static Offset get buttonLocalCenter {
    final nozzleW = kLaserNozzleSize.width + kLaserCornerRadius;
    final bodyRight = -nozzleW + kLaserCornerRadius;
    final bodyLeft = bodyRight - kLaserBodySize.width;
    final bodyCenterX = (bodyLeft + bodyRight) / 2;
    final buttonX = (bodyRight + bodyCenterX) / 2;
    return Offset(buttonX, 0);
  }

  @override
  Widget build(BuildContext context) {
    final view = StageScale.of(context);
    final tip = tipScreen;
    final angle = beamScreenAngle;
    final hitW = (totalLength + (showKnob ? 24 : 8)) * view;
    final hitH = (kLaserBodySize.height + 16) * view;

    return Positioned(
      left: tip.dx - hitW,
      top: tip.dy - hitH / 2,
      width: hitW,
      height: hitH,
      child: Transform.rotate(
        angle: angle,
        alignment: Alignment.centerRight,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) {
            if (onPowerTap == null) return;
            final local = details.localPosition;
            final painter = Offset(local.dx - hitW, local.dy - hitH / 2);
            final btn = buttonLocalCenter * view;
            if ((painter - btn).distance <= (kLaserButtonRadius + 4) * view) {
              onPowerTap!();
            }
          },
          onPanUpdate: onBodyPanUpdate,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: 0,
                top: (hitH - kLaserBodySize.height * view) / 2,
                width: totalLength * view,
                height: kLaserBodySize.height * view,
                child: CustomPaint(
                  painter: LaserPointerPainter(on: laser.on),
                ),
              ),
              if (showKnob)
                Positioned(
                  left: 0,
                  top: (hitH - 31 * 0.58 * view) / 2,
                  width: 34 * 0.58 * view,
                  height: 31 * 0.58 * view,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: onKnobPanUpdate,
                    child: Image.asset(
                      'assets/simulations/bending_light/knob.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints laser with tip at right-center of the canvas.
class LaserPointerPainter extends CustomPainter {
  LaserPointerPainter({required this.on});

  final bool on;

  static const Color _top = Color.fromARGB(255, 170, 170, 170);
  static const Color _highlight = Color.fromARGB(255, 245, 245, 245);
  static const Color _bottom = Color.fromARGB(255, 40, 40, 40);

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / LaserPointerWidget.totalLength;
    canvas.save();
    canvas.scale(unit);
    final nozzleW = kLaserNozzleSize.width + kLaserCornerRadius;
    final nozzleH = kLaserNozzleSize.height;
    final bodyW = kLaserBodySize.width;
    final bodyH = kLaserBodySize.height;
    final cy = kLaserBodySize.height / 2;
    final tipX = LaserPointerWidget.totalLength;

    final nozzleRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(tipX - nozzleW / 2, cy),
        width: nozzleW,
        height: nozzleH,
      ),
      const Radius.circular(kLaserCornerRadius),
    );
    final bodyRight = tipX - nozzleW + kLaserCornerRadius;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bodyRight - bodyW, cy - bodyH / 2, bodyW, bodyH),
      const Radius.circular(kLaserCornerRadius),
    );

    final nozzlePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [_top, _highlight, _bottom],
        stops: const [0, 0.3, 1],
      ).createShader(nozzleRect.outerRect);
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [_top, _highlight, _bottom],
        stops: const [0, 0.3, 1],
      ).createShader(bodyRect.outerRect);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 1;

    canvas.drawRRect(nozzleRect, nozzlePaint);
    canvas.drawRRect(nozzleRect, stroke);
    canvas.drawRRect(bodyRect, bodyPaint);
    canvas.drawRRect(bodyRect, stroke);

    // Match getButtonLocation: rightCenter.blend(center, 0.5)
    final bodyCenter = Offset(bodyRight - bodyW / 2, cy);
    final bodyRightCenter = Offset(bodyRight, cy);
    final buttonCenter = Offset(
      (bodyRightCenter.dx + bodyCenter.dx) / 2,
      cy,
    );

    final buttonPaint = Paint()
      ..color = on ? const Color(0xFFE53935) : const Color(0xFFC62828);
    final buttonHighlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.35);
    canvas.drawCircle(buttonCenter, kLaserButtonRadius, buttonPaint);
    canvas.drawCircle(
      buttonCenter.translate(-3, -3),
      kLaserButtonRadius * 0.35,
      buttonHighlight,
    );
    canvas.drawCircle(
      buttonCenter,
      kLaserButtonRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black54
        ..strokeWidth = 1,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LaserPointerPainter oldDelegate) =>
      oldDelegate.on != on;
}

