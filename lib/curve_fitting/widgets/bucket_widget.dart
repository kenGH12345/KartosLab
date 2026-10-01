import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../curve_fitting_colors.dart';
import '../curve_fitting_constants.dart';
import '../model/curve_fitting_model.dart';
import '../model/data_point.dart';
import '../transform/math_coordinate_transform.dart';

/// Geometric bucket + per-ball drag — PhET `BucketNode` /
/// scenery-phet `BucketHole` + `BucketFront` (no Material icons / PNG).
///
/// Hole/front painters are [IgnorePointer] so they never steal hits from
/// individual decorative balls (CustomPaint defaults to full-rect hitTest).
class BucketWidget extends StatelessWidget {
  const BucketWidget({
    super.key,
    required this.model,
    required this.transform,
    required this.layoutKey,
    this.onBumpOut,
  });

  final CurveFittingModel model;
  final MathCoordinateTransform transform;
  final GlobalKey layoutKey;
  final VoidCallback? onBumpOut;

  static const _holeEllipseHeightProportion = 0.25;

  Offset get _bucketModel => const Offset(
        CurveFittingConstants.bucketPositionX,
        CurveFittingConstants.bucketPositionY,
      );

  @override
  Widget build(BuildContext context) {
    final holeCenter = transform.modelToView(_bucketModel);
    final s = transform.scale;
    final modelW = CurveFittingConstants.bucketWidth;
    final modelH = CurveFittingConstants.bucketHeight;
    final viewW = modelW * s;

    final containerHeight =
        modelH * (1 - (_holeEllipseHeightProportion / 2)) * s;
    final holeRy = modelH * _holeEllipseHeightProportion / 2 * s;
    final paintH = containerHeight * 0.8 +
        modelH * _holeEllipseHeightProportion * 0.6 * s +
        holeRy +
        8;
    final paintW = viewW + 8;

    // pointsNode.center = bucketHoleNode.center.plusXY(0, -6)
    const pointsOffsetY = -6.0;
    final r = CurveFittingConstants.pointRadius;
    final hitPad = CurveFittingConstants.pointHitDilation;

    return Positioned(
      left: holeCenter.dx - paintW / 2,
      top: holeCenter.dy - holeRy - 4,
      width: paintW,
      height: paintH + 8,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IgnorePointer(
            child: CustomPaint(
              size: Size(paintW, paintH),
              painter: _BucketPainter(
                holeCenterInPainter: Offset(paintW / 2, holeRy + 4),
                scale: s,
                modelWidth: modelW,
                modelHeight: modelH,
                layer: _BucketPaintLayer.hole,
              ),
            ),
          ),
          // Decorative points — each has its own GestureDetector (not bucket-wide).
          for (var i = 0;
              i < CurveFittingConstants.bucketDecorativePointOffsets.length;
              i++)
            Positioned(
              left: paintW / 2 +
                  CurveFittingConstants.bucketDecorativePointOffsets[i].dx -
                  r -
                  hitPad,
              top: holeRy +
                  4 +
                  pointsOffsetY +
                  CurveFittingConstants.bucketDecorativePointOffsets[i].dy -
                  r -
                  hitPad,
              width: (r + hitPad) * 2,
              height: (r + hitPad) * 2,
              child: _BucketDecorativePoint(
                key: ValueKey('cf-bucket-ball-$i'),
                model: model,
                transform: transform,
                layoutKey: layoutKey,
                onBumpOut: onBumpOut,
              ),
            ),
          IgnorePointer(
            child: CustomPaint(
              size: Size(paintW, paintH),
              painter: _BucketPainter(
                holeCenterInPainter: Offset(paintW / 2, holeRy + 4),
                scale: s,
                modelWidth: modelW,
                modelHeight: modelH,
                layer: _BucketPaintLayer.front,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _BucketPaintLayer { hole, front }

class _BucketPainter extends CustomPainter {
  _BucketPainter({
    required this.holeCenterInPainter,
    required this.scale,
    required this.modelWidth,
    required this.modelHeight,
    required this.layer,
  });

  final Offset holeCenterInPainter;
  final double scale;
  final double modelWidth;
  final double modelHeight;
  final _BucketPaintLayer layer;

  static const _holeEllipseHeightProportion = 0.25;
  static const _baseColor = CurveFittingColors.bucket;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(holeCenterInPainter.dx, holeCenterInPainter.dy);

    final s = scale;
    final w = modelWidth;
    final h = modelHeight;
    final holeRx = w / 2 * s;
    final holeRy = h * _holeEllipseHeightProportion / 2 * s;

    if (layer == _BucketPaintLayer.hole) {
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: holeRx * 2,
        height: holeRy * 2,
      );
      final holePaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(-holeRx, 0),
          Offset(holeRx, 0),
          const [Colors.black, Color(0xFFC0C0C0)],
        );
      canvas.drawOval(rect, holePaint);
      canvas.drawOval(
        rect,
        Paint()
          ..color = const Color(0xFF777777)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    } else {
      final containerHeight =
          h * (1 - (_holeEllipseHeightProportion / 2)) * s;
      final path = Path()
        ..moveTo(-w * 0.5 * s, 0)
        ..lineTo(-w * 0.4 * s, containerHeight * 0.8)
        ..cubicTo(
          -w * 0.3 * s,
          containerHeight * 0.8 + h * _holeEllipseHeightProportion * 0.6 * s,
          w * 0.3 * s,
          containerHeight * 0.8 + h * _holeEllipseHeightProportion * 0.6 * s,
          w * 0.4 * s,
          containerHeight * 0.8,
        )
        ..lineTo(w * 0.5 * s, 0);
      path.arcTo(
        Rect.fromCenter(
          center: Offset.zero,
          width: holeRx * 2,
          height: holeRy * 2,
        ),
        0.01 * math.pi,
        0.98 * math.pi,
        false,
      );
      path.close();

      final bounds = path.getBounds();
      final lighter = _luminanceShift(_baseColor, 0.5);
      final darker = _luminanceShift(_baseColor, -0.5);
      canvas.drawPath(
        path,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(bounds.left, 0),
            Offset(bounds.right, 0),
            [lighter, darker],
          ),
      );
    }

    canvas.restore();
  }

  static Color _luminanceShift(Color base, double factor) {
    if (factor >= 0) {
      return Color.lerp(base, Colors.white, factor.clamp(0.0, 1.0))!;
    }
    return Color.lerp(base, Colors.black, (-factor).clamp(0.0, 1.0))!;
  }

  @override
  bool shouldRepaint(covariant _BucketPainter oldDelegate) =>
      oldDelegate.scale != scale ||
      oldDelegate.holeCenterInPainter != holeCenterInPainter ||
      oldDelegate.layer != layer;
}

/// One bucket ball — creates a model [DataPoint] on pan start (PhET BucketNode).
class _BucketDecorativePoint extends StatefulWidget {
  const _BucketDecorativePoint({
    super.key,
    required this.model,
    required this.transform,
    required this.layoutKey,
    this.onBumpOut,
  });

  final CurveFittingModel model;
  final MathCoordinateTransform transform;
  final GlobalKey layoutKey;
  final VoidCallback? onBumpOut;

  @override
  State<_BucketDecorativePoint> createState() => _BucketDecorativePointState();
}

class _BucketDecorativePointState extends State<_BucketDecorativePoint> {
  DataPoint? _active;

  /// global → interaction-layer local (must match [MathCoordinateTransform] space).
  Offset? _layoutLocal(Offset global) {
    final box =
        widget.layoutKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.globalToLocal(global);
  }

  @override
  Widget build(BuildContext context) {
    final r = CurveFittingConstants.pointRadius;
    final hitPad = CurveFittingConstants.pointHitDilation;
    final visual = r * 2;
    final hit = (r + hitPad) * 2;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (e) {
        final local = _layoutLocal(e.position);
        if (local == null) return;
        final modelPos = widget.transform.viewToModel(local);
        final point = DataPoint(
          x: modelPos.dx,
          y: modelPos.dy,
          dragging: true,
        );
        _active = point;
        widget.model.addPoint(point);
      },
      onPointerMove: (e) {
        final point = _active;
        if (point == null || !point.dragging) return;
        final local = _layoutLocal(e.position);
        if (local == null) return;
        final modelPos = widget.transform.viewToModel(local);
        point.setPosition(modelPos.dx, modelPos.dy);
      },
      onPointerUp: (_) => _endDrag(),
      onPointerCancel: (_) => _endDrag(),
      child: SizedBox(
        width: hit,
        height: hit,
        child: Center(
          child: Container(
            width: visual,
            height: visual,
            decoration: BoxDecoration(
              color: CurveFittingColors.pointFill,
              shape: BoxShape.circle,
              border: Border.all(
                color: CurveFittingColors.pointStroke,
                width: CurveFittingConstants.pointLineWidth,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _endDrag() {
    final point = _active;
    _active = null;
    if (point == null || !point.dragging) return;
    point.setDragging(false);
    widget.model.pointUpdated();
    widget.onBumpOut?.call();
  }
}
