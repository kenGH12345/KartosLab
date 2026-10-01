import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/detector_screen_scale.dart';
import '../../render/experiment/detector_renderer.dart';
import '../../render_data/experiment/detector_render_data.dart';
import '../common/qwi_coordinate_transform.dart';
import '../common/qwi_layout.dart';
import 'experiment_controller.dart';

/// Front-facing Experiment detector — PhET `FrontFacingDetectorScreenNode`.
///
/// Top-left ± = horizontal zoom ([DetectorScreenScale]). Scale bar sits in the
/// band above the black rect (PhET `SPAN_ARROW_Y ≈ -10`), never over the ±.
class ExperimentDetectorView extends StatelessWidget {
  const ExperimentDetectorView({super.key, required this.controller});

  final ExperimentController controller;

  static const double _scaleBarH = QwiLayout.detectorScaleBarBand;
  static const double _targetScaleMm = 5;

  @override
  Widget build(BuildContext context) {
    final designRect = QwiLayout.frontFacingDetectorRect;
    final localRect = Rect.fromLTWH(0, 0, designRect.width, designRect.height);
    final zoom = controller.model.detectorScreenScaleIndex;
    final transform = QwiCoordinateTransform(
      detectorRect: localRect,
      scaleIndex: zoom,
      fullHalfWidthM: DetectorScreenScale.fullDetectorScreenHalfWidthM,
    );
    final data = DetectorRenderData.fromModel(controller.model);
    final visibleMm = DetectorScreenScale.visibleFullWidthMm(zoom);
    final scaleMm = visibleMm >= _targetScaleMm ? _targetScaleMm : visibleMm * 0.25;
    final scalePx = (scaleMm / visibleMm) * designRect.width;

    return Positioned(
      left: designRect.left,
      top: designRect.top - _scaleBarH,
      width: designRect.width,
      height: designRect.height + _scaleBarH,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Black detector (below scale band).
          Positioned(
            left: 0,
            top: _scaleBarH,
            width: designRect.width,
            height: designRect.height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    key: const Key('qwi_detector_canvas'),
                    painter: DetectorPainter(data: data, transform: transform),
                  ),
                  Positioned(
                    left: 6,
                    top: 8,
                    child: Material(
                      color: Colors.white,
                      elevation: 1,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ZoomBtn(
                            key: const Key('qwi_zoom_out'),
                            label: '−',
                            enabled: zoom > 0,
                            onTap: () => controller.setDetectorScreenScaleIndex(zoom - 1),
                          ),
                          _ZoomBtn(
                            key: const Key('qwi_zoom_in'),
                            label: '+',
                            enabled: zoom < DetectorScreenScale.options.length - 1,
                            onTap: () => controller.setDetectorScreenScaleIndex(zoom + 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Scale indicator — clipped to band so paint never spills onto ±.
          Positioned(
            left: 2,
            top: 0,
            width: designRect.width - 2,
            height: _scaleBarH,
            child: CustomPaint(
              key: ValueKey('qwi_scale_bar_${zoom}_$scalePx'),
              painter: _ScaleBarPainter(
                widthPx: scalePx,
                label: '${scaleMm.toStringAsFixed(scaleMm >= 1 ? 0 : 1)} mm',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScaleBarPainter extends CustomPainter {
  _ScaleBarPainter({required this.widthPx, required this.label});

  final double widthPx;
  final String label;

  @override
  void paint(Canvas canvas, Size size) {
    // Arrow near bottom of band; label to the right — both fully inside band.
    final y = size.height - 7;
    final p = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;
    // Keep scale short so “5 mm” sits clear of the ± box (~56px wide).
    final w = widthPx.clamp(8.0, math.min(size.width * 0.4, 64.0)).toDouble();

    canvas.drawLine(Offset(0, y), Offset(w, y), p);
    canvas.drawLine(Offset(0, y - 4), Offset(0, y + 4), p);
    canvas.drawLine(Offset(w, y - 4), Offset(w, y + 4), p);
    final head = Path()
      ..moveTo(0, y)
      ..lineTo(4, y - 3)
      ..lineTo(4, y + 3)
      ..close();
    canvas.drawPath(head, Paint()..color = Colors.black);
    final headR = Path()
      ..moveTo(w, y)
      ..lineTo(w - 4, y - 3)
      ..lineTo(w - 4, y + 3)
      ..close();
    canvas.drawPath(headR, Paint()..color = Colors.black);

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(fontFamily: 'Arial', fontSize: 11, color: Colors.black, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final labelX = (w + 4).clamp(0.0, size.width - tp.width).toDouble();
    final labelY = (y - tp.height / 2).clamp(0.0, size.height - tp.height).toDouble();
    tp.paint(canvas, Offset(labelX, labelY));
  }

  @override
  bool shouldRepaint(covariant _ScaleBarPainter old) => old.widthPx != widthPx || old.label != label;
}

class _ZoomBtn extends StatelessWidget {
  const _ZoomBtn({
    super.key,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: SizedBox(
        width: 28,
        height: 26,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: enabled ? Colors.black87 : Colors.black26,
            ),
          ),
        ),
      ),
    );
  }
}
