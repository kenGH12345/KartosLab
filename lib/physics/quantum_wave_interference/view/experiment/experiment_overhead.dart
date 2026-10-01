import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../constants/qwi_constants.dart';
import '../../domain/detector_screen_scale.dart';
import '../../domain/source_type.dart';
import '../common/qwi_layout.dart';
import 'experiment_controller.dart';

/// Top-row overhead apparatus: emitter → slitted barrier → detector (PhET perspective).
///
/// Detector X and the “0.60 m” span follow [OverheadDetectorScreenNode]:
/// `screenCenterX = slitCenterX + distance * (maxScreenCenterX − slitCenterX) / range.max`,
/// span from slit center → detector center with a double-headed arrow.
class ExperimentOverheadView extends StatelessWidget {
  const ExperimentOverheadView({super.key, required this.controller});

  final ExperimentController controller;

  @override
  Widget build(BuildContext context) {
    final slitCenterX = QwiLayout.frontFacingSlitRect.center.dx;
    final frontFacing = QwiLayout.frontFacingDetectorRect;
    final emitterCenterX = QwiLayout.experiment.sourcePanel.centerX;
    final scaleIndex = controller.model.detectorScreenScaleIndex;
    final visibleFrac = DetectorScreenScale.visibleHalfWidthMeters(scaleIndex) /
        DetectorScreenScale.fullDetectorScreenHalfWidthM;

    return Positioned(
      left: 0,
      top: 0,
      width: QwiLayout.designWidth,
      // Stop above the front-facing “5 mm” scale bar so “0.60 m” never overlaps it.
      height: QwiLayout.frontFacingRowTop - QwiLayout.detectorScaleBarBand,
      child: CustomPaint(
        key: ValueKey('qwi_overhead_$scaleIndex'),
        painter: _OverheadPainter(
          emitting: controller.scene.isEmitting,
          wavelengthNm: controller.scene.wavelengthNm,
          isPhoton: controller.scene.sourceType == SourceType.photons,
          slitCenterX: slitCenterX,
          frontFacingScreenRight: frontFacing.right,
          emitterCenterX: emitterCenterX,
          screenDistanceM: controller.scene.screenDistanceM,
          visibleDetectorFraction: visibleFrac.clamp(0.05, 1.0),
        ),
      ),
    );
  }
}

class _OverheadPainter extends CustomPainter {
  _OverheadPainter({
    required this.emitting,
    required this.wavelengthNm,
    required this.isPhoton,
    required this.slitCenterX,
    required this.frontFacingScreenRight,
    required this.emitterCenterX,
    required this.screenDistanceM,
    required this.visibleDetectorFraction,
  });

  final bool emitting;
  final double wavelengthNm;
  final bool isPhoton;
  final double slitCenterX;
  final double frontFacingScreenRight;
  final double emitterCenterX;
  final double screenDistanceM;

  /// 1 = full detector; &lt;1 = zoomed-in window (PhET white stroke).
  final double visibleDetectorFraction;

  static const double _scale = QwiLayout.overheadElementScale;
  static const double _skewScale = QwiLayout.overheadSkewScale;

  // OverheadDoubleSlitNode — visible background is smaller than layout parallelogram.
  static const double _slitBackgroundScale = 0.75 * 1.15;

  @override
  void paint(Canvas canvas, Size size) {
    final beamY = size.height * QwiLayout.overheadBeamYFraction;

    // Layout / beam parallelogram (full size).
    final slitDx = 51 * _scale;
    final slitDy = 21 * _scale * _skewScale;
    final slitH = 50 * _scale;

    final detDx = 90 * _scale;
    final detDy = detDx * (21 / 51) * _skewScale;
    final detH = 48 * _scale;

    // PhET OverheadDetectorScreenNode.updateDetectorScreenPosition
    final maxScreenCenterX = frontFacingScreenRight - detDx / 2;
    final maxCenterDistanceX = math.max(1.0, maxScreenCenterX - slitCenterX);
    final pixelsPerMeter = maxCenterDistanceX / QwiConstants.experimentScreenDistanceMaxM;
    final detCx = slitCenterX + screenDistanceM * pixelsPerMeter;

    final bgScale = _slitBackgroundScale;
    final slitVisDx = slitDx * bgScale;
    final slitVisDy = slitDy * bgScale;
    final slitVisH = slitH * bgScale;

    // Nozzle tip = emitter right edge (OverheadEmitterNode SOURCE_SCALE body+nozzle).
    final emitterTipX = emitterCenterX + (88 + 16) * _scale * 1.15 / 2;

    if (emitting) {
      final beamColor = isPhoton ? _photonColor(wavelengthNm) : const Color(0xFFBBBBBB);
      final beam = Path()
        ..moveTo(emitterTipX, beamY - 6)
        ..lineTo(slitCenterX - slitVisDx * 0.35, beamY - slitVisH * 0.35)
        ..lineTo(slitCenterX - slitVisDx * 0.35, beamY + slitVisH * 0.35)
        ..lineTo(emitterTipX, beamY + 6)
        ..close();
      canvas.drawPath(beam, Paint()..color = beamColor.withValues(alpha: 0.45));

      final fan = Path()
        ..moveTo(slitCenterX + slitVisDx * 0.2, beamY - 4)
        ..lineTo(detCx - detDx * 0.35, beamY - detH * 0.42)
        ..lineTo(detCx - detDx * 0.35, beamY + detH * 0.42)
        ..lineTo(slitCenterX + slitVisDx * 0.2, beamY + 4)
        ..close();
      canvas.drawPath(fan, Paint()..color = beamColor.withValues(alpha: 0.28));
    }

    // Visible slit background (reduced parallelogram, black).
    _drawParallelogram(
      canvas,
      centerX: slitCenterX,
      centerY: beamY,
      dx: slitVisDx,
      dy: slitVisDy,
      leftHeight: slitVisH,
      fill: Colors.black,
      stroke: const Color(0xFF333333),
    );

    // White slit markers (two thin parallelograms).
    final slitLineLength = 18.75 * _scale * 1.15;
    final markerW = 0.75 * _scale;
    final markerDy = markerW * (slitDy / slitDx);
    const visualSpacing = 5.0 * _scale;
    for (final sign in [-1.0, 1.0]) {
      _drawParallelogram(
        canvas,
        centerX: slitCenterX + sign * visualSpacing / 2,
        centerY: beamY + sign * (visualSpacing / 2) * (slitDy / slitDx),
        dx: markerW,
        dy: markerDy,
        leftHeight: slitLineLength,
        fill: Colors.white,
        stroke: Colors.transparent,
      );
    }

    _label(canvas, 'Slitted Barrier', Offset(slitCenterX, beamY - slitVisH * 0.55 - 16));

    // Full overhead detector (black).
    _drawParallelogram(
      canvas,
      centerX: detCx,
      centerY: beamY,
      dx: detDx,
      dy: detDy,
      leftHeight: detH,
      fill: const Color(0xFF1A1A1A),
      stroke: const Color(0xFF444444),
    );
    if (emitting && isPhoton) {
      _drawParallelogram(
        canvas,
        centerX: detCx,
        centerY: beamY,
        dx: detDx * 0.55,
        dy: detDy * 0.55,
        leftHeight: detH * 0.7,
        fill: _photonColor(wavelengthNm).withValues(alpha: 0.55),
        stroke: Colors.transparent,
      );
    }

    // PhET visibleRegionNode: white parallelogram when zoomed in (fraction < 1).
    if (visibleDetectorFraction < 0.999) {
      _drawParallelogram(
        canvas,
        centerX: detCx,
        centerY: beamY,
        dx: detDx * visibleDetectorFraction,
        dy: detDy * visibleDetectorFraction,
        leftHeight: detH * visibleDetectorFraction,
        fill: Colors.transparent,
        stroke: Colors.white,
        strokeWidth: 1.5,
      );
    }

    _label(canvas, 'Detector Screen', Offset(detCx, beamY - detH * 0.55 - 16));

    // Distance span: slit center → detector center (PhET ArrowNode doubleHead).
    final fullH = math.max(slitH + slitDy, detH + detDy);
    final spanY = math.min(beamY + fullH * 0.5 + 12, size.height - 14);
    final leftX = slitCenterX;
    final rightX = detCx;
    _drawDoubleArrow(canvas, leftX, rightX, spanY, head: 5 * _scale);

    final label = '${screenDistanceM.toStringAsFixed(2)} m';
    _label(canvas, label, Offset((leftX + rightX) / 2, spanY - 10));
  }

  void _drawDoubleArrow(Canvas canvas, double leftX, double rightX, double y, {required double head}) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = _scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;
    canvas.drawLine(Offset(leftX + head, y), Offset(rightX - head, y), paint);

    final fill = Paint()..color = Colors.black;
    // Left arrowhead ◀
    canvas.drawPath(
      Path()
        ..moveTo(leftX, y)
        ..lineTo(leftX + head, y - head / 2)
        ..lineTo(leftX + head, y + head / 2)
        ..close(),
      fill,
    );
    // Right arrowhead ▶
    canvas.drawPath(
      Path()
        ..moveTo(rightX, y)
        ..lineTo(rightX - head, y - head / 2)
        ..lineTo(rightX - head, y + head / 2)
        ..close(),
      fill,
    );
    // End ticks
    final tick = 4 * _scale;
    canvas.drawLine(Offset(leftX, y - tick), Offset(leftX, y + tick), paint..strokeWidth = 1);
    canvas.drawLine(Offset(rightX, y - tick), Offset(rightX, y + tick), paint);
  }

  void _drawParallelogram(
    Canvas canvas, {
    required double centerX,
    required double centerY,
    required double dx,
    required double dy,
    required double leftHeight,
    required Color fill,
    required Color stroke,
    double strokeWidth = 1.2,
  }) {
    final left = centerX - dx / 2;
    final top = centerY - leftHeight / 2 - dy / 2;
    final path = Path()
      ..moveTo(left, top)
      ..lineTo(left, top + leftHeight)
      ..lineTo(left + dx, top + leftHeight + dy)
      ..lineTo(left + dx, top + dy)
      ..close();
    if (fill != Colors.transparent) {
      canvas.drawPath(path, Paint()..color = fill);
    }
    if (stroke != Colors.transparent) {
      canvas.drawPath(
        path,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );
    }
  }

  void _label(Canvas canvas, String text, Offset center) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontFamily: 'Arial',
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  Color _photonColor(double nm) {
    if (nm < 450) return const Color(0xFF7F00FF);
    if (nm < 495) return const Color(0xFF0000FF);
    if (nm < 570) return const Color(0xFF00FF00);
    if (nm < 590) return const Color(0xFFFFFF00);
    if (nm < 620) return const Color(0xFFFF7F00);
    return const Color(0xFFFF0000);
  }

  @override
  bool shouldRepaint(covariant _OverheadPainter oldDelegate) {
    return oldDelegate.emitting != emitting ||
        oldDelegate.wavelengthNm != wavelengthNm ||
        oldDelegate.isPhoton != isPhoton ||
        oldDelegate.slitCenterX != slitCenterX ||
        oldDelegate.frontFacingScreenRight != frontFacingScreenRight ||
        oldDelegate.emitterCenterX != emitterCenterX ||
        oldDelegate.screenDistanceM != screenDistanceM ||
        oldDelegate.visibleDetectorFraction != visibleDetectorFraction;
  }
}
