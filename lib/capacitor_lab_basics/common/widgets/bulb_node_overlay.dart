import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../clb_constants.dart';
import '../render/circuit_render_data.dart';

/// Light bulb visual — `BulbNode.js` `drawBulbNode`.
///
/// Local frame (pre-`rotate(π)`): origin at left of base / right of glass neck.
/// Glass = cubic Bezier; filament = kite `zigZagToPoint`; base = original PNG.
class BulbNodeOverlay extends StatelessWidget {
  const BulbNodeOverlay({super.key, required this.data});

  final CircuitRenderData data;

  /// PhET AABB before rotation: ~BULB_HEIGHT × BULB_WIDTH.
  static double get layoutWidth => ClbConstants.bulbViewHeight; // 130
  static double get layoutHeight => ClbConstants.bulbViewWidth; // 65

  static const double _baseImageW = 89;
  static const double _baseImageH = 71;

  static double get _baseScale => ClbConstants.bulbBaseViewWidth / _baseImageH;
  static double get _baseScaledW => _baseImageW * _baseScale;
  static double get _baseScaledH => ClbConstants.bulbBaseViewWidth;
  static double get _bulbBodyHeight =>
      ClbConstants.bulbViewHeight - _baseScaledW;

  @override
  Widget build(BuildContext context) {
    final center = data.bulbViewCenter;
    if (center == null || !data.hasLightBulb) {
      return const SizedBox.shrink();
    }

    final w = layoutWidth;
    final h = layoutHeight;
    final originX = _bulbBodyHeight;
    final originY = h / 2;

    return Positioned(
      left: center.dx - w / 2,
      top: center.dy - h / 2,
      width: w,
      height: h,
      child: Transform.rotate(
        angle: math.pi,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // fill → supports → filament → halo
            CustomPaint(
              size: Size(w, h),
              painter: _BulbBodyPainter(
                originX: originX,
                originY: originY,
                bulbBodyHeight: _bulbBodyHeight,
                haloScale: data.bulbHaloScale,
                lit: data.bulbLit && data.bulbHaloScale >= 0.1,
              ),
            ),
            // base PNG
            Positioned(
              left: originX,
              top: originY - _baseScaledH / 2,
              width: _baseScaledW,
              height: _baseScaledH,
              child: Image.asset(
                ClbConstants.assetLightBulbBase,
                width: _baseScaledW,
                height: _baseScaledH,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.medium,
              ),
            ),
            // outline last — BulbNode.js child order
            CustomPaint(
              size: Size(w, h),
              painter: _BulbOutlinePainter(
                originX: originX,
                originY: originY,
                bulbBodyHeight: _bulbBodyHeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Path _bulbGlassPath({
  required double originX,
  required double originY,
  required double bulbBodyHeight,
}) {
  const bulbWidth = 65.0;
  const bulbBaseWidth = 42.0;
  final neck = bulbBaseWidth * 0.85;
  final cpy = bulbWidth * 0.7;
  Offset p(double x, double y) => Offset(originX + x, originY + y);
  return Path()
    ..moveTo(p(0, -neck / 2).dx, p(0, -neck / 2).dy)
    ..cubicTo(
      p(-bulbBodyHeight * 0.33, -cpy).dx,
      p(-bulbBodyHeight * 0.33, -cpy).dy,
      p(-bulbBodyHeight * 0.95, -cpy).dx,
      p(-bulbBodyHeight * 0.95, -cpy).dy,
      p(-bulbBodyHeight, 0).dx,
      p(-bulbBodyHeight, 0).dy,
    )
    ..cubicTo(
      p(-bulbBodyHeight * 0.95, cpy).dx,
      p(-bulbBodyHeight * 0.95, cpy).dy,
      p(-bulbBodyHeight * 0.33, cpy).dx,
      p(-bulbBodyHeight * 0.33, cpy).dy,
      p(0, neck / 2).dx,
      p(0, neck / 2).dy,
    )
    ..close();
}

/// kite `Shape.zigZagToPoint`
Path _zigZagPath(
  Offset start,
  Offset end,
  double amplitude,
  int numberZigZags, {
  required bool symmetrical,
}) {
  final path = Path()..moveTo(start.dx, start.dy);
  final delta = end - start;
  final mag = delta.distance;
  if (mag < 1e-9 || numberZigZags <= 0) {
    path.lineTo(end.dx, end.dy);
    return path;
  }
  final dir = Offset(delta.dx / mag, delta.dy / mag);
  final normal = Offset(-dir.dy * amplitude, dir.dx * amplitude);
  final wavelength =
      symmetrical ? mag / (numberZigZags + 0.5) : mag / numberZigZags;

  for (var i = 0; i < numberZigZags; i++) {
    final waveOrigin = start + dir * (i * wavelength);
    final topPoint = waveOrigin + dir * (wavelength / 4) + normal;
    final bottomPoint = waveOrigin + dir * (3 * wavelength / 4) - normal;
    path.lineTo(topPoint.dx, topPoint.dy);
    path.lineTo(bottomPoint.dx, bottomPoint.dy);
  }
  if (symmetrical) {
    final waveOrigin = start + dir * (numberZigZags * wavelength);
    final topPoint = waveOrigin + dir * (wavelength / 4) + normal;
    path.lineTo(topPoint.dx, topPoint.dy);
  }
  path.lineTo(end.dx, end.dy);
  return path;
}

class _BulbBodyPainter extends CustomPainter {
  _BulbBodyPainter({
    required this.originX,
    required this.originY,
    required this.bulbBodyHeight,
    required this.haloScale,
    required this.lit,
  });

  final double originX;
  final double originY;
  final double bulbBodyHeight;
  final double haloScale;
  final bool lit;

  static const double _bulbWidth = 65;
  static const double _bulbBaseWidth = 42;
  static const int _numZigZags = 8;
  static const double _zigZagSpan = 8;

  Offset _p(double x, double y) => Offset(originX + x, originY + y);

  @override
  void paint(Canvas canvas, Size size) {
    final glass = _bulbGlassPath(
      originX: originX,
      originY: originY,
      bulbBodyHeight: bulbBodyHeight,
    );
    final glassCenter = glass.getBounds().center;
    canvas.drawPath(
      glass,
      Paint()
        ..shader = RadialGradient(
          colors: const [Color(0xFFEEEEEE), Color(0xFFBBCCBB)],
        ).createShader(
          Rect.fromCircle(center: glassCenter, radius: _bulbWidth / 2),
        ),
    );

    final filamentWireHeight = bulbBodyHeight * 0.6;
    final filamentTop = _p(-filamentWireHeight, -_bulbWidth * 0.3);
    final filamentBottom = _p(-filamentWireHeight, _bulbWidth * 0.3);
    final supports = Path()
      ..moveTo(_p(0, -_bulbBaseWidth * 0.3).dx, _p(0, -_bulbBaseWidth * 0.3).dy)
      ..cubicTo(
        _p(-filamentWireHeight * 0.3, -_bulbBaseWidth * 0.3).dx,
        _p(-filamentWireHeight * 0.3, -_bulbBaseWidth * 0.3).dy,
        _p(-filamentWireHeight * 0.4, -_bulbWidth * 0.3).dx,
        _p(-filamentWireHeight * 0.4, -_bulbWidth * 0.3).dy,
        filamentTop.dx,
        filamentTop.dy,
      )
      ..moveTo(_p(0, _bulbBaseWidth * 0.3).dx, _p(0, _bulbBaseWidth * 0.3).dy)
      ..cubicTo(
        _p(-filamentWireHeight * 0.3, _bulbBaseWidth * 0.3).dx,
        _p(-filamentWireHeight * 0.3, _bulbBaseWidth * 0.3).dy,
        _p(-filamentWireHeight * 0.4, _bulbWidth * 0.3).dx,
        _p(-filamentWireHeight * 0.4, _bulbWidth * 0.3).dy,
        filamentBottom.dx,
        filamentBottom.dy,
      );
    canvas.drawPath(
      supports,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawPath(
      _zigZagPath(
        filamentBottom,
        filamentTop,
        _zigZagSpan,
        _numZigZags,
        symmetrical: true,
      ),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    if (lit) {
      final s = haloScale.clamp(0.1, ClbConstants.bulbMaxHaloScale);
      final filamentCenter = Offset(
        (filamentTop.dx + filamentBottom.dx) / 2,
        (filamentTop.dy + filamentBottom.dy) / 2,
      );
      final t = s / ClbConstants.bulbMaxHaloScale;
      final outer = (_bulbWidth * 0.55) * t;
      void halo(double radius, double opacity) {
        canvas.drawCircle(
          filamentCenter,
          radius,
          Paint()..color = Color.fromRGBO(255, 255, 255, opacity),
        );
      }

      halo(outer, 0.46);
      halo(outer * (3.75 / 5.0), 0.51);
      halo(outer * (2.0 / 5.0), 1.0);
    }
  }

  @override
  bool shouldRepaint(covariant _BulbBodyPainter oldDelegate) =>
      oldDelegate.haloScale != haloScale ||
      oldDelegate.lit != lit ||
      oldDelegate.bulbBodyHeight != bulbBodyHeight;
}

class _BulbOutlinePainter extends CustomPainter {
  _BulbOutlinePainter({
    required this.originX,
    required this.originY,
    required this.bulbBodyHeight,
  });

  final double originX;
  final double originY;
  final double bulbBodyHeight;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _bulbGlassPath(
        originX: originX,
        originY: originY,
        bulbBodyHeight: bulbBodyHeight,
      ),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _BulbOutlinePainter oldDelegate) =>
      oldDelegate.bulbBodyHeight != bulbBodyHeight;
}
