import 'package:flutter/material.dart';

import '../../domain/slit_configuration.dart';
import '../../domain/source_type.dart';
import '../common/qwi_colors.dart';
import '../common/qwi_layout.dart';
import 'experiment_controller.dart';

/// Front-facing double-slit view — PhET `FrontFacingSlitNode`.
///
/// Black rounded plate + two **vertical white** slit rectangles (left/right).
class ExperimentBarrierView extends StatelessWidget {
  const ExperimentBarrierView({super.key, required this.controller});

  final ExperimentController controller;

  @override
  Widget build(BuildContext context) {
    final rect = QwiLayout.frontFacingSlitRect;
    final scene = controller.scene;
    final sepMm = scene.slitSeparationMm;
    final maxSep = scene.defaults.slitSeparationMaxMm;

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: CustomPaint(
        key: const Key('qwi_barrier_canvas'),
        painter: _BarrierPainter(
          config: scene.slitConfiguration,
          separationMm: sepMm,
          maxSeparationMm: maxSep,
          slitWidthMm: scene.slitWidthMm,
          isPhoton: scene.sourceType == SourceType.photons,
          emitting: scene.isEmitting,
          wavelengthNm: scene.wavelengthNm,
          sourceStrength: scene.sourceStrength,
        ),
      ),
    );
  }
}

class _BarrierPainter extends CustomPainter {
  _BarrierPainter({
    required this.config,
    required this.separationMm,
    required this.maxSeparationMm,
    required this.slitWidthMm,
    required this.isPhoton,
    required this.emitting,
    required this.wavelengthNm,
    required this.sourceStrength,
  });

  final SlitConfiguration config;
  final double separationMm;
  final double maxSeparationMm;
  final double slitWidthMm;
  final bool isPhoton;
  final bool emitting;
  final double wavelengthNm;
  final double sourceStrength;

  static const double _corner = 10;
  static const double _hPad = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(_corner));
    canvas.drawRRect(bg, Paint()..color = Colors.black);

    // Beam tint on barrier when emitting (PhET beamOverlay).
    if (emitting) {
      final beam = isPhoton ? _photonColor(wavelengthNm) : QwiColors.particleBeam;
      final t = sourceStrength.clamp(0.0, 1.0);
      final alpha = t <= 0.5 ? 0.15 + 0.35 * (t / 0.5) : 0.5 + 0.3 * ((t - 0.5) / 0.5);
      canvas.drawRRect(bg, Paint()..color = beam.withValues(alpha: alpha));
    }

    // Physical → view X (PhET FrontFacingSlitNode mmToViewX).
    final maxPad = isPhoton ? 2 * _hPad : _hPad;
    final denom = isPhoton ? maxSeparationMm : maxSeparationMm + slitWidthMm;
    final mmToX = denom > 0 ? (size.width - 2 * maxPad) / denom : 1.0;
    final slitW = (slitWidthMm * mmToX).clamp(2.0, size.width * 0.2);
    final halfSep = (separationMm * mmToX) / 2;
    final cx = size.width / 2;

    // Slit height with padding (PhET SLIT_HEIGHT ≈ nearly full view height).
    final slitPad = (size.height - 130).clamp(4.0, 20.0) / 2;
    final slitY = slitPad;
    final slitH = size.height - 2 * slitPad;

    final leftCovered = config == SlitConfiguration.leftCovered;
    final rightCovered = config == SlitConfiguration.rightCovered;

    final leftRect = Rect.fromLTWH(cx - halfSep - slitW / 2, slitY, slitW, slitH);
    final rightRect = Rect.fromLTWH(cx + halfSep - slitW / 2, slitY, slitW, slitH);

    void drawSlit(Rect r, {required bool covered}) {
      canvas.drawRect(
        r,
        Paint()..color = covered ? QwiColors.slitCoverFill : Colors.white,
      );
    }

    if (config != SlitConfiguration.noBarrier) {
      drawSlit(leftRect, covered: leftCovered);
      drawSlit(rightRect, covered: rightCovered);
    }

    // Detector overlays (PhET yellow translucent). Domain top/bottom ↔ left/right.
    void drawDetector(Rect slit) {
      final d = Rect.fromLTRB(slit.left - 3, slit.top - 3, slit.right + 3, slit.bottom + 3);
      canvas.drawRect(
        d,
        Paint()..color = QwiColors.detectorOverlayFill.withValues(alpha: 0.3),
      );
      canvas.drawRect(
        d,
        Paint()
          ..color = QwiColors.detectorOverlayStroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    if (config.hasDetectorOnTop) drawDetector(leftRect);
    if (config.hasDetectorOnBottom) drawDetector(rightRect);

    final widthUm = slitWidthMm * 1000;
    final sepUm = separationMm * 1000;
    _paintWidthSpan(canvas, leftRect, '${widthUm.toStringAsFixed(widthUm >= 1 ? 0 : 1)} µm');
    _paintSepSpan(canvas, leftRect, rightRect, size.height, '${sepUm.toStringAsFixed(0)} µm');
  }

  void _paintWidthSpan(Canvas canvas, Rect leftSlit, String label) {
    final y = 10.0;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;
    canvas.drawLine(Offset(leftSlit.left, y - 4), Offset(leftSlit.left, y + 4), paint);
    canvas.drawLine(Offset(leftSlit.right, y - 4), Offset(leftSlit.right, y + 4), paint);
    canvas.drawLine(Offset(leftSlit.left, y), Offset(leftSlit.right, y), paint);
    _label(canvas, label, Offset(leftSlit.right + 4, y - 6), Colors.white);
  }

  void _paintSepSpan(Canvas canvas, Rect left, Rect right, double viewH, String label) {
    final y = viewH - 12;
    final paint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1;
    canvas.drawLine(Offset(left.center.dx, y - 4), Offset(left.center.dx, y + 4), paint);
    canvas.drawLine(Offset(right.center.dx, y - 4), Offset(right.center.dx, y + 4), paint);
    canvas.drawLine(Offset(left.center.dx, y), Offset(right.center.dx, y), paint);
    _label(canvas, label, Offset(right.center.dx + 4, y - 6), Colors.white70);
  }

  void _label(Canvas canvas, String text, Offset at, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontFamily: 'Arial', fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at);
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
  bool shouldRepaint(covariant _BarrierPainter old) {
    return old.config != config ||
        old.separationMm != separationMm ||
        old.maxSeparationMm != maxSeparationMm ||
        old.slitWidthMm != slitWidthMm ||
        old.isPhoton != isPhoton ||
        old.emitting != emitting ||
        old.wavelengthNm != wavelengthNm ||
        old.sourceStrength != sourceStrength;
  }
}
