import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kratos/energy_forms_and_changes/common/model/beaker.dart';
import 'package:kratos/energy_forms_and_changes/common/transform/efac_mvt.dart';
import 'package:kratos/energy_forms_and_changes/efac_colors.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';
import 'package:kratos/energy_forms_and_changes/efac_strings.dart';

/// Layer for PhET `BeakerView` split (`backNode` / `frontNode` / `grabNode`).
enum BeakerPaintLayer { back, front, grab }

/// PhET BeakerView + PerspectiveWaterNode geometry.
///
/// Evidence:
/// - `js/common/view/BeakerView.ts`
/// - `js/common/view/PerspectiveWaterNode.ts`
/// - `PERSPECTIVE_PROPORTION = -Z_TO_Y_OFFSET_MULTIPLIER` (= 0.25)
class BeakerPainter extends CustomPainter {
  BeakerPainter({
    required this.beaker,
    required this.mvt,
    required this.energyChunksVisible,
    this.layer = BeakerPaintLayer.front,
  });

  final Beaker beaker;
  final EfacMvt mvt;
  final bool energyChunksVisible;
  final BeakerPaintLayer layer;

  /// `-EFACConstants.Z_TO_Y_OFFSET_MULTIPLIER`
  static const double perspectiveProportion =
      -EfacConstants.zToYOffsetMultiplier; // 0.25

  static const Color outlineColor = Color.fromARGB(255, 160, 160, 160);
  static const Color beakerGlass = Color.fromARGB(99, 250, 250, 250); // α≈0.39
  static const double outlineWidth = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final ellipseH = w * perspectiveProportion;

    switch (layer) {
      case BeakerPaintLayer.back:
        _paintBack(canvas, w, h, ellipseH);
      case BeakerPaintLayer.front:
        _paintFront(canvas, w, h, ellipseH);
      case BeakerPaintLayer.grab:
        canvas.drawRect(
          Rect.fromLTWH(0, 0, w, h),
          Paint()..color = const Color(0x01FFFFFF),
        );
    }
  }

  void _paintBack(Canvas canvas, double w, double h, double ellipseH) {
    // BeakerView backNode: bottom ellipse, top ellipse, invisible hit rect.
    final fill = Paint()..color = beakerGlass;
    final stroke = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = outlineWidth;

    final top = Rect.fromCenter(
      center: Offset(w / 2, ellipseH / 2),
      width: w,
      height: ellipseH,
    );
    final bottom = Rect.fromCenter(
      center: Offset(w / 2, h - ellipseH / 2),
      width: w,
      height: ellipseH,
    );
    canvas.drawOval(bottom, fill);
    canvas.drawOval(bottom, stroke);
    canvas.drawOval(top, fill);
    canvas.drawOval(top, stroke);
  }

  void _paintFront(Canvas canvas, double w, double h, double ellipseH) {
    final fluidH = h * beaker.fluidProportion;
    final fluidColor = beaker.beakerType == BeakerType.water
        ? EfacColors.waterInBeaker
        : EfacColors.oliveOilInBeaker;
    // PerspectiveWaterNode: fluid top at maxY - fluidHeight
    final fluidTop = h - fluidH;
    final halfW = w / 2;
    final halfE = ellipseH / 2;
    final fluidAlpha = energyChunksVisible ? 0.45 : 0.75;

    // Liquid body (PerspectiveWaterNode.liquidWaterBodyShape)
    final body = Path()
      ..moveTo(0, fluidTop)
      ..arcTo(
        Rect.fromCenter(
          center: Offset(halfW, fluidTop),
          width: w,
          height: ellipseH,
        ),
        math.pi,
        -math.pi,
        false,
      )
      ..lineTo(w, h)
      ..arcTo(
        Rect.fromCenter(
          center: Offset(halfW, h),
          width: w,
          height: ellipseH,
        ),
        0,
        math.pi,
        false,
      )
      ..close();
    canvas.drawPath(
      body,
      Paint()..color = fluidColor.withValues(alpha: fluidAlpha),
    );
    canvas.drawPath(
      body,
      Paint()
        ..color = Color.lerp(fluidColor, Colors.black, 0.2)!
            .withValues(alpha: fluidAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Meniscus / liquid top ellipse (brighter fill + darker stroke)
    final meniscus = Rect.fromCenter(
      center: Offset(halfW, fluidTop),
      width: w,
      height: ellipseH,
    );
    canvas.drawOval(
      meniscus,
      Paint()
        ..color = Color.lerp(fluidColor, Colors.white, 0.25)!
            .withValues(alpha: fluidAlpha),
    );
    canvas.drawOval(
      meniscus,
      Paint()
        ..color = Color.lerp(fluidColor, Colors.black, 0.2)!
            .withValues(alpha: fluidAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Glass body (BeakerView front Path) — over fluid sides
    final glass = Path()
      ..moveTo(0, halfE)
      ..arcTo(
        Rect.fromCenter(
          center: Offset(halfW, halfE),
          width: w,
          height: ellipseH,
        ),
        math.pi,
        -math.pi,
        false,
      )
      ..lineTo(w, h)
      ..arcTo(
        Rect.fromCenter(
          center: Offset(halfW, h),
          width: w,
          height: ellipseH,
        ),
        0,
        math.pi,
        false,
      )
      ..close();
    canvas.drawPath(glass, Paint()..color = beakerGlass);
    canvas.drawPath(
      glass,
      Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = outlineWidth,
    );

    // Tick marks — elliptical arcs on left wall (BeakerView.ts)
    final numberOfMajorTicks =
        (beaker.height / beaker.majorTickMarkDistance).floor().clamp(1, 8);
    const minorPerMajor = 4;
    final numberOfTicks = numberOfMajorTicks * (minorPerMajor + 1);
    final space = (h * beaker.majorTickMarkDistance / beaker.height) /
        (minorPerMajor + 1);
    final majorAngle = 0.13 * math.pi;
    final minorAngle = majorAngle / 2;
    const xOriginAngle = 0.1 * math.pi;
    var yPosition = h;
    final tickPath = Path();
    for (var tickIndex = 0; tickIndex < numberOfTicks; tickIndex++) {
      yPosition -= space;
      if (yPosition < halfE) break;
      final startAngle = math.pi - xOriginAngle;
      final tickLen = (tickIndex + 1) % (minorPerMajor + 1) == 0
          ? majorAngle
          : minorAngle;
      final endAngle = startAngle - tickLen;
      tickPath.addArc(
        Rect.fromCenter(
          center: Offset(halfW, yPosition),
          width: w,
          height: ellipseH,
        ),
        startAngle,
        endAngle - startAngle,
      );
    }
    canvas.drawPath(
      tickPath,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final label = beaker.beakerType == BeakerType.water
        ? EfacStrings.water
        : EfacStrings.oliveOil;
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 26 * (w / 200).clamp(0.5, 1.0),
          color: Colors.black.withValues(alpha: energyChunksVisible ? 0.5 : 1),
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w * 0.7);
    // Just below front top water line (BeakerView.ts:219-221)
    tp.paint(
      canvas,
      Offset((w - tp.width) / 2, fluidTop + ellipseH * 1.1),
    );
  }

  @override
  bool shouldRepaint(covariant BeakerPainter oldDelegate) =>
      oldDelegate.beaker.fluidProportion != beaker.fluidProportion ||
      oldDelegate.beaker.temperature != beaker.temperature ||
      oldDelegate.energyChunksVisible != energyChunksVisible ||
      oldDelegate.layer != layer ||
      oldDelegate.beaker.beakerType != beaker.beakerType;
}
