import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../pm_assets.dart';
import '../pm_colors.dart';
import '../pm_constants.dart';
import '../transform/pm_transform.dart';
import '../view/pm_image_cache.dart';

/// CannonNode.ts 的 Flutter 等价（CustomPainter 高保真重建）。
///
/// 关键几何（CannonNode.ts:48-53, 141-163, 354-440）：
/// - 枢轴 = 发射点 modelToView(0, h)
/// - scaleMagnitude = modelToViewDeltaX(4) / 275（cannonBarrelTop 宽）
/// - barrel 图 326×142，centerY=0，right=275（local）
/// - base 图：bottom 160×135 top-center(0,0)；top 160×39 bottom-center(0,0)
/// - 底座椭圆 420×40（local），圆柱中心 x = modelToViewX(1.3)
class PmCannonPainter extends CustomPainter {
  PmCannonPainter({
    required this.transform,
    required this.images,
    required this.height,
    required this.angleDegrees,
    required this.muzzleFlashAge,
    required this.showHeightCue,
  });

  final PmTransform transform;
  final PmImageCache images;
  final double height; // m
  final double angleDegrees;

  /// 0..0.4s，null = 未激活
  final double? muzzleFlashAge;
  final bool showHeightCue;

  static const double _ellipseWidth = 420; // CannonNode:49
  static const double _ellipseHeight = 40; // :50
  static const double _crosshairLength = 120; // :53

  /// 大炮 scaleMagnitude（CannonNode:423）
  double get scaleMagnitude =>
      transform.modelToViewDeltaX(PmConstants.cannonLength) / 275;

  /// 枢轴（发射点）屏坐标
  Offset get pivot => transform.modelToView(Offset(0, height));

  @override
  void paint(Canvas canvas, Size size) {
    final s = scaleMagnitude;
    final origin = transform.origin; // (70, 510)
    final p = pivot;
    final cylinderX =
        transform.origin.dx + transform.modelToViewDeltaX(PmConstants.cylinderDistanceFromOrigin);
    final rx = _ellipseWidth / 2 * s;
    final ry = _ellipseHeight / 2 * s;
    final cylinderTopY = p.dy + 125 * s; // 见 PHASE 记录：P.y + 135s − 10s

    // ── 裁剪：地面以上 + 洞口椭圆下半（CannonNode:373-383）────────────────
    final clipPath = Path()
      ..addRect(Rect.fromLTRB(
          -10000, -10000, 10000, origin.dy)) // 地面以上
      ..addOval(Rect.fromCenter(
          center: Offset(cylinderX, origin.dy), width: rx * 2, height: ry * 2));

    // ── 洞口（groundCircle，:117-125）───────────────────────────────────
    final groundFill = Paint()
      ..shader = ui.Gradient.linear(
        Offset(cylinderX - rx, 0),
        Offset(cylinderX + rx, 0),
        const [Colors.grey, Colors.white, Colors.grey],
        const [0.0, 0.3, 1.0],
      );
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cylinderX, origin.dy), width: rx * 2, height: ry * 2),
        groundFill);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cylinderX, origin.dy), width: rx * 2, height: ry * 2),
        Paint()
          ..color = PmColors.cannonBrightGray
          ..style = PaintingStyle.stroke);

    canvas.save();
    canvas.clipPath(clipPath);

    // ── 圆柱（CannonNode:364-371）────────────────────────────────────────
    // kite ellipticalArc(..., PI, 0, anticlockwise=true) = 顶椭圆从左经下沿到右
    // kite ellipticalArc(..., 0, PI, anticlockwise=false) = 地椭圆从右经下沿到左
    if (cylinderTopY < origin.dy) {
      final topEllipse = Rect.fromCenter(
          center: Offset(cylinderX, cylinderTopY), width: rx * 2, height: ry * 2);
      final groundEllipse = Rect.fromCenter(
          center: Offset(cylinderX, origin.dy), width: rx * 2, height: ry * 2);
      final sidePath = Path()
        ..moveTo(cylinderX - rx, origin.dy)
        ..lineTo(cylinderX - rx, cylinderTopY)
        ..arcTo(topEllipse, math.pi, -math.pi, false)
        ..lineTo(cylinderX + rx, origin.dy)
        ..arcTo(groundEllipse, 0, math.pi, false)
        ..close();
      final sideFill = Paint()
        ..shader = ui.Gradient.linear(
          Offset(cylinderX - rx, 0),
          Offset(cylinderX + rx, 0),
          const [
            PmColors.cannonDarkGray,
            PmColors.cannonBrightGray,
            PmColors.cannonDarkGray,
          ],
          const [0.0, 0.3, 1.0],
        );
      canvas.drawPath(sidePath, sideFill);
      canvas.drawPath(
          sidePath,
          Paint()
            ..color = PmColors.cannonBrightGray
            ..style = PaintingStyle.stroke);
      // 圆柱顶
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cylinderX, cylinderTopY),
              width: rx * 2,
              height: ry * 2),
          Paint()..color = PmColors.cannonDarkGray);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cylinderX, cylinderTopY),
              width: rx * 2,
              height: ry * 2),
          Paint()
            ..color = PmColors.cannonBrightGray
            ..style = PaintingStyle.stroke);
    }

    // ── 炮管（旋转 -θ，:141-151, 336）───────────────────────────────────
    canvas.save();
    canvas.translate(p.dx, p.dy);
    canvas.rotate(-angleDegrees * math.pi / 180);
    canvas.scale(s);
    final barrel = images[PmAssets.cannonBarrel];
    if (barrel != null) {
      // centerY=0, right=275 → left = 275−326 = −51
      canvas.drawImageRect(
        barrel,
        Rect.fromLTWH(0, 0, barrel.width.toDouble(), barrel.height.toDouble()),
        Rect.fromLTWH(-51, -71, 326, 142),
        Paint()..filterQuality = FilterQuality.medium,
      );
    }
    // ── 炮口火焰（:272-298, 304-317）──────────────────────────────────
    final flashAge = muzzleFlashAge;
    if (flashAge != null) {
      final t = (flashAge / PmConstants.muzzleFlashDuration).clamp(0.0, 1.0);
      final anim = -math.pow(2, -10 * t) + 1; // easeOut（:557-558）
      final flashScale = 0.4 + (1.5 - 0.4) * anim;
      final flashOpacity = 1.0 - anim;
      final flashPath = _tearDropPath(100);
      canvas.save();
      canvas.translate(275, 0);
      canvas.scale(flashScale);
      canvas.drawPath(
          flashPath,
          Paint()
            ..color = PmColors.flameOuter.withValues(alpha: flashOpacity));
      canvas.save();
      canvas.scale(0.7);
      canvas.drawPath(
          flashPath,
          Paint()
            ..color = PmColors.flameInner.withValues(alpha: flashOpacity));
      canvas.restore();
      canvas.restore();
    }
    canvas.restore();

    // ── 炮座（:154-163）─────────────────────────────────────────────────
    canvas.save();
    canvas.translate(p.dx, p.dy);
    canvas.scale(s);
    final baseTop = images[PmAssets.cannonBaseTop];
    if (baseTop != null) {
      canvas.drawImageRect(
        baseTop,
        Rect.fromLTWH(
            0, 0, baseTop.width.toDouble(), baseTop.height.toDouble()),
        Rect.fromLTWH(-80, -39, 160, 39),
        Paint()..filterQuality = FilterQuality.medium,
      );
    }
    final baseBottom = images[PmAssets.cannonBaseBottom];
    if (baseBottom != null) {
      canvas.drawImageRect(
        baseBottom,
        Rect.fromLTWH(0, 0, baseBottom.width.toDouble(),
            baseBottom.height.toDouble()),
        Rect.fromLTWH(-80, 0, 160, 135),
        Paint()..filterQuality = FilterQuality.medium,
      );
    }
    canvas.restore();

    canvas.restore(); // clipPath

    // ── 高度标尺（:166-222, 388-406）────────────────────────────────────
    final leaderX = transform.origin.dx +
        transform.modelToViewDeltaX(PmConstants.heightLeaderLineX);
    final dashPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;
    var ly = origin.dy;
    while (ly > p.dy) {
      canvas.drawLine(Offset(leaderX, ly), Offset(leaderX, ly - 5), dashPaint);
      ly -= 10;
    }
    // 双头箭头（:178-190，head 5×5）
    _drawArrowHead(canvas, Offset(leaderX, origin.dy), math.pi / 2, 5);
    _drawArrowHead(canvas, Offset(leaderX, p.dy), -math.pi / 2, 5);
    // 端帽（:193-203）
    final capPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;
    canvas.drawLine(Offset(leaderX - 6, origin.dy), Offset(leaderX + 6, origin.dy),
        capPaint);
    canvas.drawLine(
        Offset(leaderX - 6, p.dy), Offset(leaderX + 6, p.dy), capPaint);
    // 高度读数（:397-405）："{h} m" 2 位小数，top = tipY − 5
    _drawLabelWithBackground(
      canvas,
      '${PmConstants.toFixedNumber(height, 2)} m',
      Offset(leaderX, p.dy - 5),
      topAnchor: true,
    );
    // Intro 高度 cue 箭头（:222-231）
    if (showHeightCue) {
      final cuePaint = Paint()..color = PmColors.cueArrowFill;
      final cueStroke = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      for (final dy in [-20.0, 25.0]) {
        final up = dy < 0;
        final tipY = p.dy + dy + (up ? -7 : 7);
        final path = Path()
          ..moveTo(leaderX, tipY)
          ..lineTo(leaderX - 7, tipY + (up ? 6 : -6))
          ..lineTo(leaderX - 4, tipY + (up ? 6 : -6))
          ..lineTo(leaderX - 4, p.dy + dy)
          ..lineTo(leaderX + 4, p.dy + dy)
          ..lineTo(leaderX + 4, tipY + (up ? 6 : -6))
          ..lineTo(leaderX + 7, tipY + (up ? 6 : -6))
          ..close();
        canvas.drawPath(path, cuePaint);
        canvas.drawPath(path, cueStroke);
      }
    }

    // ── 角度指示（:234-269, 335-348）────────────────────────────────────
    canvas.save();
    canvas.translate(origin.dx, p.dy);
    final crossPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;
    canvas.drawLine(const Offset(-_crosshairLength / 4, 0),
        const Offset(_crosshairLength, 0), crossPaint);
    canvas.drawLine(const Offset(0, -_crosshairLength),
        const Offset(0, _crosshairLength), crossPaint);
    final darkPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3;
    const d = _crosshairLength / 15;
    canvas.drawLine(const Offset(-d, 0), const Offset(d, 0), darkPaint);
    canvas.drawLine(const Offset(0, -d), const Offset(0, d), darkPaint);
    // 角度弧（半径 2/3·120 = 80）
    final angleRad = angleDegrees * math.pi / 180;
    if (angleRad.abs() > 1e-9) {
      canvas.drawArc(
          Rect.fromCircle(center: Offset.zero, radius: _crosshairLength * 2 / 3),
          0,
          -angleRad,
          false,
          crossPaint);
    }
    // 角度读数 "{θ}°"（left = 90, bottom = −5）
    _drawLabelWithBackground(
      canvas,
      '${PmConstants.toFixedNumber(angleDegrees, 2)}${String.fromCharCode(0x00B0)}',
      Offset(_crosshairLength * 2 / 3 + 10, -5),
      bottomAnchor: true,
    );
    canvas.restore();
  }

  /// 泪滴火焰（CannonNode:276-284）
  static Path _tearDropPath(double radius) {
    final path = Path()..moveTo(0, 0); // left=0：平移 +radius
    for (var t = math.pi / 24; t < 2 * math.pi; t += math.pi / 24) {
      final x = math.cos(t) * radius + radius;
      final y = math.sin(t) * math.pow(math.sin(0.5 * t), 3) * radius;
      path.lineTo(x, y);
    }
    return path..close();
  }

  static void _drawArrowHead(
      Canvas canvas, Offset tip, double direction, double size) {
    final base = Offset(tip.dx - size * math.cos(direction),
        tip.dy - size * math.sin(direction));
    final perp = Offset(-math.sin(direction), math.cos(direction)) * size / 2;
    final tri = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(base.dx + perp.dx, base.dy + perp.dy)
      ..lineTo(base.dx - perp.dx, base.dy - perp.dy)
      ..close();
    canvas.drawPath(tri, Paint()..color = Colors.black);
  }

  void _drawLabelWithBackground(Canvas canvas, String text, Offset anchor,
      {bool topAnchor = false, bool bottomAnchor = false}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: PmConstants.uiText),
      textDirection: TextDirection.ltr,
    )..layout();
    final pos = topAnchor
        ? Offset(anchor.dx - tp.width / 2, anchor.dy)
        : bottomAnchor
            ? Offset(anchor.dx, anchor.dy - tp.height)
            : Offset(anchor.dx - tp.width / 2, anchor.dy - tp.height / 2);
    canvas.drawRect(
        Rect.fromLTWH(pos.dx - 1, pos.dy, tp.width + 2, tp.height),
        Paint()..color = PmColors.labelBackground);
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(PmCannonPainter oldDelegate) =>
      oldDelegate.height != height ||
      oldDelegate.angleDegrees != angleDegrees ||
      oldDelegate.muzzleFlashAge != muzzleFlashAge ||
      oldDelegate.showHeightCue != showHeightCue ||
      oldDelegate.transform.zoom != transform.zoom ||
      oldDelegate.images.isLoaded != images.isLoaded;
}
