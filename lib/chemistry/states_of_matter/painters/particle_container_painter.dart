import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../som_constants.dart';
import '../transform/som_coordinate_transform.dart';

/// Particle container walls + elliptical lid — PhET `ParticleContainerNode` bevel.
///
/// Visual-only; does not change MVT / physics particle bounds.
class ParticleContainerPainter extends CustomPainter {
  ParticleContainerPainter({
    required this.mvt,
    required this.containerHeight,
    this.isExploded = false,
    this.volumeControlEnabled = false,
  });

  final SomCoordinateTransform mvt;
  final double containerHeight;
  final bool isExploded;

  /// Phase Changes: PhET `HandleNode` on lid (scale 0.28).
  final bool volumeControlEnabled;

  /// From `ParticleContainerNode.ts`
  static const double containerXMargin = 5;
  static const double perspectiveTiltFactor = 0.15;
  static const double bevelWidth = 9;
  static const double cutoutXMargin = 25;
  static const double cutoutYMargin = 20;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = mvt.particleContainerViewBounds(
      containerHeight: containerHeight.clamp(
        1.0,
        SomConstants.containerInitialHeight * 2,
      ),
    );
    final initialBounds = mvt.particleContainerViewBounds();
    final bottom = initialBounds.bottom;
    final left = initialBounds.left;
    final right = initialBounds.right;
    final initialTop = initialBounds.top;
    final lidTop = bounds.top;
    final width = right - left;
    final centerX = (left + right) / 2;
    final containerH = bottom - initialTop;

    final containerWidthWithMargin = width + 2 * containerXMargin;
    final topEllipseRadiusX = containerWidthWithMargin / 2;
    final topEllipseRadiusY = topEllipseRadiusX * perspectiveTiltFactor;
    final outerShapeTilt = topEllipseRadiusY * 1.28;
    final cutoutShapeTilt = outerShapeTilt * 0.55;

    final outerLeft = centerX - topEllipseRadiusX;
    final outerRight = centerX + topEllipseRadiusX;

    double ellipseLowerEdgeY(double distanceFromLeftEdge) {
      final x = distanceFromLeftEdge - topEllipseRadiusX;
      final under = 1 - (x * x) / (topEllipseRadiusX * topEllipseRadiusX);
      return topEllipseRadiusY * math.sqrt(under.clamp(0.0, 1.0));
    }

    final cutoutHeight = containerH - 2 * cutoutYMargin;
    final cutoutTopY =
        ellipseLowerEdgeY(cutoutXMargin) + cutoutYMargin;
    final cutoutBottomY = cutoutTopY + cutoutHeight;
    final cutoutWidth = containerWidthWithMargin - 2 * cutoutXMargin;
    final cutoutLeft = outerLeft + cutoutXMargin;

    // Opening ellipse (behind particles via screen layering; stroke only)
    final openingCenter = Offset(centerX, initialTop);
    canvas.drawOval(
      Rect.fromCenter(
        center: openingCenter,
        width: topEllipseRadiusX * 2,
        height: topEllipseRadiusY * 2,
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF444444),
    );

    // Main container front face with window cutout
    final mainPath = Path()
      ..moveTo(outerLeft, initialTop)
      ..cubicTo(
        outerLeft,
        initialTop + outerShapeTilt,
        outerRight,
        initialTop + outerShapeTilt,
        outerRight,
        initialTop,
      )
      ..lineTo(outerRight, bottom)
      ..cubicTo(
        outerRight,
        bottom + outerShapeTilt,
        outerLeft,
        bottom + outerShapeTilt,
        outerLeft,
        bottom,
      )
      ..lineTo(outerLeft, initialTop)
      // Cutout (opposite winding)
      ..moveTo(cutoutLeft, initialTop + cutoutTopY)
      ..lineTo(cutoutLeft, initialTop + cutoutBottomY)
      ..quadraticBezierTo(
        centerX,
        initialTop + cutoutBottomY + cutoutShapeTilt,
        cutoutLeft + cutoutWidth,
        initialTop + cutoutBottomY,
      )
      ..lineTo(cutoutLeft + cutoutWidth, initialTop + cutoutTopY)
      ..quadraticBezierTo(
        centerX,
        initialTop + cutoutTopY + cutoutShapeTilt,
        cutoutLeft,
        initialTop + cutoutTopY,
      )
      ..close();
    mainPath.fillType = PathFillType.evenOdd;

    canvas.drawPath(
      mainPath,
      Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xE66D6D6D)
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            Color(0xFF6D6D6D),
            Color(0xFF8B8B8B),
            Color(0xFFAEAFAF),
            Color(0xFFBABABA),
            Color(0xFFA3A4A4),
            Color(0xFF8E8E8E),
            Color(0xFF737373),
            Color(0xFF646565),
          ],
          stops: const [0.0, 0.1, 0.2, 0.4, 0.7, 0.75, 0.8, 0.9],
        ).createShader(
          Rect.fromLTRB(outerLeft, initialTop, outerRight, bottom),
        ),
    );

    // Bevel around cutout (opacity 0.9)
    final bevelOrigin = Offset(cutoutLeft, initialTop + cutoutTopY);
    canvas.saveLayer(
      Rect.fromLTWH(
        cutoutLeft - 1,
        initialTop + cutoutTopY - 1,
        cutoutWidth + 2,
        cutoutHeight + 2,
      ),
      Paint()..color = const Color(0xE6FFFFFF),
    );

    // Left bevel edge
    final leftBevel = Path()
      ..moveTo(bevelOrigin.dx, bevelOrigin.dy)
      ..lineTo(bevelOrigin.dx, bevelOrigin.dy + cutoutHeight)
      ..lineTo(
        bevelOrigin.dx + bevelWidth,
        bevelOrigin.dy + cutoutHeight - bevelWidth,
      )
      ..lineTo(bevelOrigin.dx + bevelWidth, bevelOrigin.dy + bevelWidth)
      ..close();
    canvas.drawPath(
      leftBevel,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFF525252),
            Color(0xFF515151),
            Color(0xFF4E4E4E),
            Color(0xFF424242),
            Color(0xFF353535),
            Color(0xFF2A2A2A),
            Color(0xFF292929),
          ],
          stops: const [0.0, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8],
        ).createShader(
          Rect.fromLTWH(
            bevelOrigin.dx,
            bevelOrigin.dy,
            bevelWidth,
            cutoutHeight,
          ),
        ),
    );

    // Right bevel edge
    final rightBevel = Path()
      ..moveTo(
        bevelOrigin.dx + cutoutWidth - bevelWidth,
        bevelOrigin.dy + bevelWidth,
      )
      ..lineTo(
        bevelOrigin.dx + cutoutWidth - bevelWidth,
        bevelOrigin.dy + cutoutHeight - bevelWidth,
      )
      ..lineTo(
        bevelOrigin.dx + cutoutWidth,
        bevelOrigin.dy + cutoutHeight,
      )
      ..lineTo(bevelOrigin.dx + cutoutWidth, bevelOrigin.dy)
      ..close();
    canvas.drawPath(
      rightBevel,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFF8A8A8A),
            Color(0xFF747474),
            Color(0xFF525252),
            Color(0xFF8A8A8A),
            Color(0xFFA2A2A2),
            Color(0xFF616161),
          ],
          stops: const [0.0, 0.2, 0.3, 0.6, 0.9, 0.95],
        ).createShader(
          Rect.fromLTWH(
            bevelOrigin.dx + cutoutWidth - bevelWidth,
            bevelOrigin.dy,
            bevelWidth,
            cutoutHeight,
          ),
        ),
    );

    // Top bevel edge
    final topBevel = Path()
      ..moveTo(bevelOrigin.dx, bevelOrigin.dy)
      ..quadraticBezierTo(
        centerX,
        bevelOrigin.dy + cutoutShapeTilt,
        bevelOrigin.dx + cutoutWidth,
        bevelOrigin.dy,
      )
      ..lineTo(
        bevelOrigin.dx + cutoutWidth - bevelWidth,
        bevelOrigin.dy + bevelWidth,
      )
      ..quadraticBezierTo(
        centerX,
        bevelOrigin.dy + cutoutShapeTilt + bevelWidth,
        bevelOrigin.dx + bevelWidth,
        bevelOrigin.dy + bevelWidth,
      )
      ..close();
    canvas.drawPath(
      topBevel,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            Color(0xFF2E2E2E),
            Color(0xFF323232),
            Color(0xFF363636),
            Color(0xFF3E3E3E),
            Color(0xFF4B4B4B),
            Color(0xFF525252),
          ],
          stops: const [0.0, 0.2, 0.3, 0.4, 0.5, 0.9],
        ).createShader(
          Rect.fromLTWH(
            bevelOrigin.dx,
            bevelOrigin.dy,
            cutoutWidth,
            bevelWidth + cutoutShapeTilt,
          ),
        ),
    );

    // Bottom bevel edge
    final bottomBevel = Path()
      ..moveTo(
        bevelOrigin.dx + bevelWidth,
        bevelOrigin.dy + cutoutHeight - bevelWidth,
      )
      ..quadraticBezierTo(
        centerX,
        bevelOrigin.dy + cutoutHeight - bevelWidth + cutoutShapeTilt,
        bevelOrigin.dx + cutoutWidth - bevelWidth,
        bevelOrigin.dy + cutoutHeight - bevelWidth,
      )
      ..lineTo(
        bevelOrigin.dx + cutoutWidth,
        bevelOrigin.dy + cutoutHeight,
      )
      ..quadraticBezierTo(
        centerX,
        bevelOrigin.dy + cutoutHeight + cutoutShapeTilt,
        bevelOrigin.dx,
        bevelOrigin.dy + cutoutHeight,
      )
      ..close();
    canvas.drawPath(
      bottomBevel,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            Color(0xFF5D5D5D),
            Color(0xFF717171),
            Color(0xFF7C7C7C),
            Color(0xFF8D8D8D),
            Color(0xFFA2A2A2),
            Color(0xFFA3A3A3),
          ],
          stops: const [0.0, 0.2, 0.3, 0.4, 0.5, 0.9],
        ).createShader(
          Rect.fromLTWH(
            bevelOrigin.dx,
            bevelOrigin.dy + cutoutHeight - bevelWidth,
            cutoutWidth,
            bevelWidth + cutoutShapeTilt,
          ),
        ),
    );

    canvas.restore();

    // Lid ellipse at current container top
    final lidCenter = Offset(centerX, lidTop);
    final lidRect = Rect.fromCenter(
      center: lidCenter,
      width: topEllipseRadiusX * 2,
      height: topEllipseRadiusY * 2,
    );
    if (!isExploded) {
      canvas.drawOval(lidRect, Paint()..color = const Color(0xCC7E7E7E));
      canvas.drawOval(
        lidRect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0xFF555555),
      );

      if (volumeControlEnabled) {
        // Inner handle hit area (scaled ellipse, PhET Matrix3.scale(0.8))
        canvas.drawOval(
          Rect.fromCenter(
            center: lidCenter,
            width: topEllipseRadiusX * 2 * 0.8,
            height: topEllipseRadiusY * 2 * 0.8,
          ),
          Paint()
            ..color = const Color(0x80C8C8C8)
            ..style = PaintingStyle.fill,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: lidCenter,
            width: topEllipseRadiusX * 2 * 0.8,
            height: topEllipseRadiusY * 2 * 0.8,
          ),
          Paint()
            ..color = const Color(0xFF888888)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );

        // HandleNode scale 0.28: grip ≈ 28×12, black attachment stubs
        const gripW = 28.0;
        const gripH = 12.0;
        final gripRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(centerX, lidTop - 2),
            width: gripW,
            height: gripH,
          ),
          const Radius.circular(2),
        );
        // Attachment stubs (black)
        final stubPaint = Paint()..color = Colors.black;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(centerX - gripW * 0.28, lidTop + 4),
              width: 4,
              height: 8,
            ),
            const Radius.circular(1),
          ),
          stubPaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(centerX + gripW * 0.28, lidTop + 4),
              width: 4,
              height: 8,
            ),
            const Radius.circular(1),
          ),
          stubPaint,
        );
        canvas.drawRRect(
          gripRect,
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFB7B8B9),
                Color(0xFFE8E8E8),
                Color(0xFFB7B8B9),
                Color(0xFF7A7A7A),
              ],
              stops: [0, 0.4, 0.7, 1],
            ).createShader(gripRect.outerRect),
        );
        canvas.drawRRect(
          gripRect,
          Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      }
    } else {
      canvas.save();
      canvas.translate(centerX + 40, lidTop - 20);
      canvas.rotate(math.pi / 8);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: topEllipseRadiusX * 2,
          height: topEllipseRadiusY * 2,
        ),
        Paint()..color = const Color(0xAA7E7E7E),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ParticleContainerPainter oldDelegate) {
    return oldDelegate.containerHeight != containerHeight ||
        oldDelegate.isExploded != isExploded ||
        oldDelegate.volumeControlEnabled != volumeControlEnabled ||
        oldDelegate.mvt.layoutWidth != mvt.layoutWidth;
  }
}
