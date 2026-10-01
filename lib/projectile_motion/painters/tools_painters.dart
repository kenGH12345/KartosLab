import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../model/data_probe.dart';
import '../model/measuring_tape.dart';
import '../model/target.dart';
import '../pm_assets.dart';
import '../pm_colors.dart';
import '../pm_constants.dart';
import '../pm_strings.dart';
import '../transform/pm_transform.dart';

/// TargetNode.ts：三同心椭圆（红/白/红）+ 距离读数。
class PmTargetPainter extends CustomPainter {
  PmTargetPainter({required this.transform, required this.target});

  final PmTransform transform;
  final PmTarget target;

  @override
  void paint(Canvas canvas, Size size) {
    final viewRadius =
        transform.modelToViewDeltaX(PmConstants.targetWidth) / 2;
    final ry = viewRadius * PmConstants.targetHeight / PmConstants.targetWidth;
    final center = transform.modelToView(Offset(target.x, 0));

    final rings = [
      (1.0, Colors.red, 1.0),
      (2 / 3, Colors.white, 0.5),
      (1 / 3, Colors.red, 0.5),
    ];
    for (final (scale, fill, strokeW) in rings) {
      final rect = Rect.fromCenter(
          center: center,
          width: viewRadius * 2 * scale,
          height: ry * 2 * scale);
      canvas.drawOval(rect, Paint()..color = fill);
      canvas.drawOval(
          rect,
          Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeW);
    }

    final tp = TextPainter(
      text: TextSpan(
          text: '${target.x.toStringAsFixed(1)} m',
          style: PmConstants.uiText),
      textDirection: TextDirection.ltr,
    )..layout();
    final top = center.dy + ry + 2;
    final pos = Offset(center.dx - tp.width / 2, top);
    canvas.drawRect(
        Rect.fromLTWH(pos.dx - 2, pos.dy, tp.width + 4, tp.height),
        Paint()..color = PmColors.numberDisplayBackground);
    canvas.drawRect(
        Rect.fromLTWH(pos.dx - 2, pos.dy, tp.width + 4, tp.height),
        Paint()
          ..color = PmColors.numberDisplayStroke
          ..style = PaintingStyle.stroke);
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(PmTargetPainter oldDelegate) =>
      oldDelegate.target.x != target.x ||
      oldDelegate.transform.zoom != transform.zoom;
}

/// MeasuringTape + DataProbe（对照 MeasuringTapeNode / DataProbeNode）。
class PmToolsPainter extends CustomPainter {
  PmToolsPainter({
    required this.transform,
    required this.measuringTape,
    required this.dataProbe,
  });

  final PmTransform transform;
  final PmMeasuringTape measuringTape;
  final PmDataProbe dataProbe;

  static const double _crossR = 15; // CIRCLE_AROUND_CROSSHAIR_RADIUS
  static const double _probeContentW = 155; // DATA_PROBE_CONTENT_WIDTH
  static const double _probeRightPad = 6;
  static const double _probeH = 95;
  static const double _spacing = 4;
  static const double _bgW = 60; // createInformationBox backgroundWidth
  static const double _readoutXMargin = 7;
  static const double _tapeBaseScale = 0.8;
  static const double _crosshairSize = 5;
  static const double _tipCircleR = 10;

  @override
  void paint(Canvas canvas, Size size) {
    if (measuringTape.isActive) _paintTape(canvas);
    if (dataProbe.isActive) _paintProbe(canvas);
  }

  @override
  bool? hitTest(Offset position) {
    if (dataProbe.isActive &&
        PmToolsHitTest.hitProbe(transform, dataProbe, position)) {
      return true;
    }
    if (measuringTape.isActive) {
      if (PmToolsHitTest.hitTapeTip(transform, measuringTape, position) ||
          PmToolsHitTest.hitTapeBase(transform, measuringTape, position)) {
        return true;
      }
    }
    return false;
  }

  // ── MeasuringTapeNode.ts ──────────────────────────────────────────────
  void _paintTape(Canvas canvas) {
    final base = transform.modelToView(measuringTape.basePosition);
    final tip = transform.modelToView(measuringTape.tipPosition);
    final lengthM =
        (measuringTape.tipPosition - measuringTape.basePosition).distance;
    final angle = math.atan2(tip.dy - base.dy, tip.dx - base.dx);

    // tapeline（gray, lineWidth 2）
    canvas.drawLine(
        base,
        tip,
        Paint()
          ..color = PmColors.tapeLine
          ..strokeWidth = 2);

    // base 橙色十字
    _drawOrangeCross(canvas, base, angle);

    // 壳体改由 PmScene Image.asset 叠层绘制（不依赖 ui.Image 缓存）
    // 避免 CustomPainter 未加载到 measuringTape.png 时只剩灰线+十字。

    // tip 半透明圆 + 十字
    canvas.drawCircle(tip, _tipCircleR, Paint()..color = PmColors.tipCircle);
    _drawOrangeCross(canvas, tip, angle);

    // 读数（ScreenView: significantFigures 2, textBackground translucent white）
    final tp = TextPainter(
      text: TextSpan(
        text: '${lengthM.toStringAsFixed(2)} m',
        style: PmConstants.uiText.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    // textPosition (0, 30) relative to base image center
    final textPos =
        base + Offset(0, 30 * _tapeBaseScale) - Offset(tp.width / 2, 0);
    final bg = RRect.fromRectAndRadius(
        Rect.fromLTWH(textPos.dx - 4, textPos.dy - 2, tp.width + 8, tp.height + 4),
        const Radius.circular(2));
    canvas.drawRRect(bg, Paint()..color = const Color(0x99FFFFFF));
    tp.paint(canvas, textPos);
  }

  static void _drawOrangeCross(Canvas canvas, Offset c, double angle) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(angle);
    final paint = Paint()
      ..color = PmColors.tapeCrosshair
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        const Offset(-_crosshairSize, 0), const Offset(_crosshairSize, 0), paint);
    canvas.drawLine(
        const Offset(0, -_crosshairSize), const Offset(0, _crosshairSize), paint);
    canvas.restore();
  }

  // ── DataProbeNode.ts（createInformationBox 布局）─────────────────────
  void _paintProbe(Canvas canvas) {
    final origin = transform.modelToView(dataProbe.position);

    // crosshair + circle
    final crossPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5;
    canvas.drawCircle(
        origin, _crossR, Paint()..color = Colors.white.withValues(alpha: 0.2));
    canvas.drawLine(Offset(origin.dx - _crossR, origin.dy),
        Offset(origin.dx + _crossR, origin.dy), crossPaint);
    canvas.drawLine(Offset(origin.dx, origin.dy - _crossR),
        Offset(origin.dx, origin.dy + _crossR), crossPaint);
    canvas.drawCircle(
        origin,
        _crossR,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    // grey mount（0.4 * radius）
    final mountW = 0.4 * _crossR;
    final mountLeft = origin.dx + _crossR;
    canvas.drawRect(
        Rect.fromLTWH(mountLeft, origin.dy - mountW / 2, mountW, mountW),
        Paint()..color = Colors.grey);

    // blue box（opacity 0.8）
    final boxLeft = mountLeft + mountW;
    final boxTop = origin.dy - _probeH / 2;
    final boxW = _probeContentW + _probeRightPad;
    final box = RRect.fromRectAndRadius(
        Rect.fromLTWH(boxLeft, boxTop, boxW, _probeH),
        const Radius.circular(8));
    canvas.saveLayer(box.outerRect.inflate(6), Paint());
    canvas.drawRRect(
        box, Paint()..color = PmColors.dataProbeOpaqueBlue.withValues(alpha: 0.8));
    canvas.drawRRect(
        box,
        Paint()
          ..color = Colors.grey
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4);
    canvas.restore();

    // rows：Time / Range / Height + 白底读数盒（createInformationBox）
    final point = dataProbe.dataPoint;
    String fmt(double? v, String unit) => v == null
        ? PmStrings.noValue
        : '${PmConstants.toFixedNumber(v, 2)} $unit';
    final rows = [
      (PmStrings.time, fmt(point?.time, 's')),
      (PmStrings.range, fmt(point?.x, 'm')),
      (PmStrings.heightReadout, fmt(point?.y, 'm')),
    ];
    var y = boxTop + 2 * _spacing;
    for (final (label, value) in rows) {
      y += _paintInfoRow(canvas, boxLeft + 2 * _spacing, y, _probeContentW, label, value);
      y += _spacing;
    }

    // halo
    if (point != null) {
      final haloCenter = transform.modelToView(point.position);
      final isMajor =
          (point.time * 1000).round() % 1000 == 0 && !point.apex;
      final radius = isMajor
          ? PmConstants.largeDotRadius * 5
          : PmConstants.smallDotRadius * 5;
      final haloColor = point.apex
          ? const Color(0xCC32FF32)
          : const Color(0xCCFFFF00);
      canvas.drawCircle(
        haloCenter,
        radius,
        Paint()
          ..shader = ui.Gradient.radial(
            haloCenter,
            radius,
            [
              Colors.black,
              Colors.black,
              haloColor,
              haloColor,
              haloColor.withValues(alpha: 0)
            ],
            const [0.0, 0.2, 0.2, 0.4, 1.0],
          ),
      );
    }
  }

  /// createInformationBox：左标签 + 右白底读数；返回行高。
  static double _paintInfoRow(Canvas canvas, double left, double top,
      double maxWidth, String label, String value) {
    final labelTp = TextPainter(
      text: TextSpan(
          text: label,
          style: PmConstants.uiText.copyWith(color: Colors.white)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth - _bgW - 25);
    final valueTp = TextPainter(
      text: TextSpan(text: value, style: PmConstants.uiText),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: _bgW - 6);

    final bgH = valueTp.height + 2 * _spacing;
    final bgTop = top;
    final bgLeft = left + maxWidth - _bgW - 2 * _spacing;
    final bg = RRect.fromRectAndRadius(
        Rect.fromLTWH(bgLeft, bgTop, _bgW, bgH), const Radius.circular(4));
    canvas.drawRRect(bg, Paint()..color = Colors.white);
    canvas.drawRRect(
        bg,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5);

    labelTp.paint(
        canvas, Offset(left, bgTop + (bgH - labelTp.height) / 2));
    if (value == PmStrings.noValue || value == '-') {
      valueTp.paint(
          canvas,
          Offset(bgLeft + (_bgW - valueTp.width) / 2,
              bgTop + (bgH - valueTp.height) / 2));
    } else {
      valueTp.paint(
          canvas,
          Offset(bgLeft + _bgW - _readoutXMargin - valueTp.width,
              bgTop + (bgH - valueTp.height) / 2));
    }
    return bgH;
  }

  @override
  bool shouldRepaint(PmToolsPainter oldDelegate) => true;
}

/// Toolbox 内 DataProbe 图标 = DataProbeNode.createIcon × 0.4
class PmDataProbeIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 未缩放本征约 191×95，按 fit 缩放到 size
    const intrinsicW = 191.0;
    const intrinsicH = 95.0;
    final s = math.min(size.width / intrinsicW, size.height / intrinsicH);
    canvas.save();
    canvas.translate(
        (size.width - intrinsicW * s) / 2, (size.height - intrinsicH * s) / 2);
    canvas.scale(s);

    const origin = Offset(15, 47.5); // circle center
    const crossR = 15.0;

    // circle + crosshair
    canvas.drawCircle(
        origin, crossR, Paint()..color = Colors.white.withValues(alpha: 0.2));
    final cross = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(origin.dx - crossR, origin.dy),
        Offset(origin.dx + crossR, origin.dy), cross);
    canvas.drawLine(Offset(origin.dx, origin.dy - crossR),
        Offset(origin.dx, origin.dy + crossR), cross);
    canvas.drawCircle(
        origin,
        crossR,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    final mountW = 0.4 * crossR;
    final mountLeft = origin.dx + crossR;
    canvas.drawRect(
        Rect.fromLTWH(mountLeft, origin.dy - mountW / 2, mountW, mountW),
        Paint()..color = Colors.grey);

    const contentW = 155.0;
    final boxLeft = mountLeft + mountW;
    final boxTop = origin.dy - 95 / 2;
    final box = RRect.fromRectAndRadius(
        Rect.fromLTWH(boxLeft, boxTop, contentW, 95),
        const Radius.circular(8));
    canvas.drawRRect(
        box, Paint()..color = PmColors.dataProbeOpaqueBlue.withValues(alpha: 0.8));
    canvas.drawRRect(
        box,
        Paint()
          ..color = Colors.grey
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4);

    var y = boxTop + 8.0;
    for (final label in [
      PmStrings.time,
      PmStrings.range,
      PmStrings.heightReadout
    ]) {
      y += PmToolsPainter._paintInfoRow(
              canvas, boxLeft + 8, y, contentW, label, PmStrings.noValue) +
          4;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(PmDataProbeIconPainter oldDelegate) => false;
}

/// Toolbox 内 MeasuringTape 图标 = MeasuringTapeNode.createIcon × 0.8
class PmMeasuringTapeIconPainter extends CustomPainter {
  const PmMeasuringTapeIconPainter();
  @override
  void paint(Canvas canvas, Size size) {
    const tapeLen = 30.0;
    const imgW = 51 * 0.8;
    const imgH = 51 * 0.8;
    final base = const Offset(imgW, imgH);
    final tip = Offset(base.dx + tapeLen, base.dy);

    canvas.drawLine(
        base,
        tip,
        Paint()
          ..color = PmColors.tapeLine
          ..strokeWidth = 2);
    final xPaint = Paint()
      ..color = PmColors.tapeCrosshair
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (final c in [base, tip]) {
      canvas.drawLine(
          c + const Offset(-5, 0), c + const Offset(5, 0), xPaint);
      canvas.drawLine(
          c + const Offset(0, -5), c + const Offset(0, 5), xPaint);
    }
    canvas.drawCircle(tip, 10, Paint()..color = PmColors.tipCircle);
  }

  @override
  bool shouldRepaint(PmMeasuringTapeIconPainter oldDelegate) => false;
}

class PmMeasuringTapeHousing extends StatelessWidget {
  const PmMeasuringTapeHousing({
    super.key,
    required this.transform,
    required this.tape,
  });

  final PmTransform transform;
  final PmMeasuringTape tape;

  @override
  Widget build(BuildContext context) {
    const scale = 0.8;
    const iw = 51 * scale;
    const ih = 51 * scale;
    final base = transform.modelToView(tape.basePosition);
    final tip = transform.modelToView(tape.tipPosition);
    final angle = math.atan2(tip.dy - base.dy, tip.dx - base.dx);
    return Positioned(
      left: base.dx - iw,
      top: base.dy - ih,
      width: iw,
      height: ih,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: angle,
          alignment: Alignment.bottomRight,
          child: Image.asset(
            PmAssets.measuringTape,
            width: iw,
            height: ih,
            filterQuality: FilterQuality.medium,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => ColoredBox(
              color: const Color(0xFFF5E000),
              child: Center(
                child: Container(
                  width: ih * 0.56,
                  height: ih * 0.56,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4AA3E0),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 拖拽命中测试辅助
abstract final class PmToolsHitTest {
  static bool hitTapeBase(PmTransform t, PmMeasuringTape tape, Offset viewPos) {
    final base = t.modelToView(tape.basePosition);
    // MeasuringTapeNode touchArea = localBounds.dilated(20)
    final body = Rect.fromLTWH(base.dx - 70, base.dy - 56, 90, 76);
    return body.contains(viewPos) || (base - viewPos).distance <= 28;
  }

  static bool hitTapeTip(PmTransform t, PmMeasuringTape tape, Offset viewPos) =>
      (t.modelToView(tape.tipPosition) - viewPos).distance <= 28;

  static bool hitTape(PmTransform t, PmMeasuringTape tape, Offset viewPos) {
    final a = t.modelToView(tape.basePosition);
    final b = t.modelToView(tape.tipPosition);
    return _distanceToSegment(viewPos, a, b) <= 16;
  }

  static bool hitProbe(PmTransform t, PmDataProbe probe, Offset viewPos) {
    final origin = t.modelToView(probe.position);
    if ((origin - viewPos).distance <= 28) return true;
    final box = Rect.fromLTWH(origin.dx + 15, origin.dy - 47.5, 161, 95);
    return box.inflate(12).contains(viewPos);
  }

  static double _distanceToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (len2 == 0) return (p - a).distance;
    var t = ((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2;
    t = t.clamp(0.0, 1.0);
    return (p - (a + ab * t)).distance;
  }
}
