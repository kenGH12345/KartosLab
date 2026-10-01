import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../cck_colors.dart';
import '../cck_constants.dart';
import '../model/cck_vec.dart';
import '../model/enums.dart';
import '../render/cck_mvt.dart';
import '../render/cck_render_data.dart';

class CircuitPainter extends CustomPainter {
  CircuitPainter({
    required this.data,
    required this.mvt,
    required this.images,
  });

  final CckRenderData data;
  final CckMvt mvt;
  final Map<String, ui.Image> images;

  @override
  void paint(Canvas canvas, Size size) {
    for (final v in data.vertices) {
      if (v.connected) _drawSolder(canvas, mvt.toView(v.pos));
    }
    for (final el in data.elements) {
      _drawElement(canvas, el);
    }
    if (data.showCurrent) {
      for (final c in data.charges) {
        _drawCharge(canvas, c);
      }
    }
    for (final v in data.vertices) {
      _drawVertex(canvas, v);
    }
  }

  Offset _p(CckVec v) => mvt.toView(v);

  void _drawSolder(Canvas canvas, Offset c) {
    canvas.drawCircle(
      c,
      CckConstants.solderRadius * mvt.zoom,
      Paint()..color = CckColors.solder,
    );
  }

  void _drawVertex(Canvas canvas, CckRenderVertex v) {
    final c = _p(v.pos);
    final r = CckConstants.vertexRadius * mvt.zoom;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3 * mvt.zoom
      ..color = v.connected ? Colors.black : CckColors.vertexDisconnected;
    _drawDashedCircle(canvas, c, r, stroke);
    if (v.selected) {
      canvas.drawCircle(
        c,
        CckConstants.vertexHighlightRadius * mvt.zoom,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = CckConstants.highlightLineWidth * mvt.zoom
          ..color = CckColors.highlightStroke,
      );
    }
  }

  void _drawDashedCircle(Canvas canvas, Offset c, double r, Paint paint) {
    const dash = 6.0;
    const gap = 4.0;
    final circ = 2 * math.pi * r;
    final n = math.max(1, (circ / (dash + gap)).floor());
    final step = 2 * math.pi / n;
    final path = Path();
    for (var i = 0; i < n; i++) {
      final a0 = i * step;
      final a1 = a0 + step * dash / (dash + gap);
      path.addArc(Rect.fromCircle(center: c, radius: r), a0, a1 - a0);
    }
    canvas.drawPath(path, paint);
  }

  void _drawElement(Canvas canvas, CckRenderElement el) {
    final a = _p(el.start);
    final b = _p(el.end);
    if (el.selected) {
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = CckColors.highlightStroke
          ..strokeWidth = CckConstants.highlightLineWidth * mvt.zoom
          ..strokeCap = StrokeCap.round,
      );
    }
    final schematic = data.viewType == CckViewType.schematic;
    switch (el.kind) {
      case CckElementKind.wire:
        _drawWire(canvas, a, b);
      case CckElementKind.battery:
        if (schematic) {
          _drawBatterySchematic(canvas, a, b);
        } else {
          _drawImageAlong(canvas, images['battery'], a, b);
        }
      case CckElementKind.acSource:
        _drawAc(canvas, a, b, schematic);
      case CckElementKind.resistor:
        _drawResistor(canvas, el, a, b, schematic);
      case CckElementKind.lightBulb:
        _drawBulb(canvas, el, a, b, schematic);
      case CckElementKind.capacitor:
        _drawCapacitor(canvas, a, b, schematic);
      case CckElementKind.inductor:
        _drawInductor(canvas, a, b, schematic, el.inductance);
      case CckElementKind.switch_:
        _drawSwitch(canvas, a, b, schematic, el.closed ?? false);
      case CckElementKind.fuse:
        if (schematic) {
          _drawFuseSchematic(canvas, a, b, el.tripped ?? false);
        } else {
          _drawImageAlong(canvas, images['fuse'], a, b);
        }
        if (el.sparkProgress >= 0) _drawSpark(canvas, a, b, el.sparkProgress);
      case CckElementKind.seriesAmmeter:
        _drawSeriesAmmeter(canvas, a, b, schematic);
    }
    _drawCaption(canvas, a, b, el);
  }

  void _drawWire(Canvas canvas, Offset a, Offset b) {
    if (data.viewType == CckViewType.schematic) {
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = Colors.black
          ..strokeWidth = CckConstants.schematicLineWidth * mvt.zoom
          ..strokeCap = StrokeCap.round,
      );
      return;
    }
    final w = CckConstants.wireLifelikeWidth * mvt.zoom;
    final paint = Paint()
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..shader = ui.Gradient.linear(
        Offset(a.dx, a.dy - w / 2),
        Offset(a.dx, a.dy + w / 2),
        const [
          CckColors.wireStop0,
          CckColors.wireStop1,
          CckColors.wireStop2,
          CckColors.wireStop3,
        ],
        const [0, 0.2, 0.3, 1],
      );
    canvas.drawLine(a, b, paint);
  }

  void _drawResistor(
    Canvas canvas,
    CckRenderElement el,
    Offset a,
    Offset b,
    bool schematic,
  ) {
    if (schematic) {
      _drawZigZag(canvas, a, b);
      return;
    }
    final key = switch (el.resistorKind) {
      CckResistorKind.coin => 'coin',
      CckResistorKind.paperClip => 'paperClip',
      CckResistorKind.pencil => 'pencil',
      CckResistorKind.thinPencil => 'thinPencil',
      CckResistorKind.eraser => 'eraser',
      CckResistorKind.dollarBill => 'dollar',
      _ => 'resistor',
    };
    _drawImageAlong(canvas, images[key], a, b);
  }

  void _drawZigZag(Canvas canvas, Offset a, Offset b) {
    final d = (b - a).distance;
    if (d == 0) return;
    final dir = (b - a) / d;
    final n = Offset(-dir.dy, dir.dx);
    final path = Path()..moveTo(a.dx, a.dy);
    const bumps = 6;
    for (var i = 1; i <= bumps; i++) {
      final t = i / (bumps + 1);
      final p = Offset.lerp(a, b, t)!;
      final s = i.isOdd ? 10.0 : -10.0;
      path.lineTo(p.dx + n.dx * s * mvt.zoom, p.dy + n.dy * s * mvt.zoom);
    }
    path.lineTo(b.dx, b.dy);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = CckConstants.schematicLineWidth * mvt.zoom,
    );
  }

  void _drawBatterySchematic(Canvas canvas, Offset a, Offset b) {
    // BatteryNode.ts IEEE plates: WIDTH=188 GAP=33 scaled to BATTERY_LENGTH.
    const srcW = 188.0;
    const gap = 33.0;
    const small = 50.0;
    const large = 104.0;
    _drawTwoPlates(canvas, a, b, srcW, gap, small, large);
  }

  void _drawCapacitor(Canvas canvas, Offset a, Offset b, bool schematic) {
    if (schematic) {
      const srcW = 188.0;
      const gap = 30.0;
      const plate = 104.0;
      _drawTwoPlates(canvas, a, b, srcW, gap, plate, plate);
      return;
    }
    // Lifelike: scenery-phet CapacitorNode is not in-repo. Two plates + stubs.
    // [视觉近似] vs 3D CapacitorNode scale 0.45.
    _drawTwoPlates(canvas, a, b, 188, 36, 70, 70, fill: true);
    _drawImageAlong(canvas, images['wireIcon'], a, Offset.lerp(a, b, 0.35)!);
    _drawImageAlong(canvas, images['wireIcon'], Offset.lerp(a, b, 0.65)!, b);
  }

  void _drawTwoPlates(
    Canvas canvas,
    Offset a,
    Offset b,
    double srcW,
    double gap,
    double small,
    double large, {
    bool fill = false,
  }) {
    final d = (b - a).distance;
    if (d == 0) return;
    final angle = math.atan2(b.dy - a.dy, b.dx - a.dx);
    final scale = d / srcW;
    canvas.save();
    canvas.translate(a.dx, a.dy);
    canvas.rotate(angle);
    canvas.scale(scale, scale);
    final left = srcW / 2 - gap / 2;
    final right = srcW / 2 + gap / 2;
    final p = Paint()
      ..color = Colors.black
      ..strokeWidth = CckConstants.schematicLineWidth
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(left, 0), p);
    canvas.drawLine(Offset(left, small / 2), Offset(left, -small / 2), p);
    canvas.drawLine(Offset(right, 0), Offset(srcW, 0), p);
    canvas.drawLine(Offset(right, large / 2), Offset(right, -large / 2), p);
    if (fill) {
      canvas.drawRect(
        Rect.fromCenter(center: Offset(left, 0), width: 6, height: small),
        Paint()..color = const Color(0xFFB0B0B0),
      );
      canvas.drawRect(
        Rect.fromCenter(center: Offset(right, 0), width: 6, height: large),
        Paint()..color = const Color(0xFFB0B0B0),
      );
    }
    canvas.restore();
  }

  void _drawAc(Canvas canvas, Offset a, Offset b, bool schematic) {
    // ACVoltageNode.ts: CIRCLE_DIAMETER=54, sine 9*sin(x), x*5.5
    final mid = Offset.lerp(a, b, 0.5)!;
    final r = 27 * mvt.zoom;
    canvas.drawCircle(
      mid,
      r,
      Paint()
        ..color = schematic ? Colors.transparent : Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      mid,
      r,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = (schematic ? 4 : 2) * mvt.zoom,
    );
    final sine = Path();
    var first = true;
    for (var x = 0.0; x < math.pi * 2; x += math.pi / 2 / 100) {
      final px = mid.dx + (x * 5.5 - math.pi * 5.5) * mvt.zoom * 0.55;
      final py = mid.dy + 9 * math.sin(x) * mvt.zoom;
      if (first) {
        sine.moveTo(px, py);
        first = false;
      } else {
        sine.lineTo(px, py);
      }
    }
    canvas.drawPath(
      sine,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4 * mvt.zoom,
    );
    if (!schematic) {
      final sep = 54 * 0.32 * mvt.zoom;
      _plusMinus(canvas, Offset(mid.dx, mid.dy - sep), true);
      _plusMinus(canvas, Offset(mid.dx, mid.dy + sep), false);
    }
  }

  void _plusMinus(Canvas canvas, Offset c, bool plus) {
    final p = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.5 * mvt.zoom
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(c.dx - 5 * mvt.zoom, c.dy), Offset(c.dx + 5 * mvt.zoom, c.dy), p);
    if (plus) {
      canvas.drawLine(Offset(c.dx, c.dy - 5 * mvt.zoom), Offset(c.dx, c.dy + 5 * mvt.zoom), p);
    }
  }

  void _drawInductor(
    Canvas canvas,
    Offset a,
    Offset b,
    bool schematic,
    double inductance,
  ) {
    final d = (b - a).distance;
    if (d == 0) return;
    final angle = math.atan2(b.dy - a.dy, b.dx - a.dx);
    canvas.save();
    canvas.translate(a.dx, a.dy);
    canvas.rotate(angle);
    if (schematic) {
      const bumps = 4;
      const margin = 20.0;
      final width = CckConstants.inductorLength;
      final arcR = (width - margin * 2) / bumps / 2;
      final sx = d / width;
      canvas.scale(sx, sx);
      final path = Path()..moveTo(0, 0)..lineTo(margin, 0);
      for (var i = 0; i < bumps; i++) {
        final cx = margin + arcR * (2 * i + 1);
        path.arcTo(
          Rect.fromCircle(center: Offset(cx, 0), radius: arcR),
          math.pi,
          -math.pi,
          false,
        );
      }
      path.lineTo(width, 0);
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = CckConstants.schematicLineWidth,
      );
    } else {
      // InductorNode.ts lifelike cylinder + loops from inductance.
      const height = 60.0;
      const inset = 7.0;
      const rx = 5.0;
      final width = d;
      final ry = height / 2 * mvt.zoom;
      final body = Path()
        ..addOval(Rect.fromCenter(center: Offset(inset, 0), width: rx * 2, height: height))
        ..addRRect(RRect.fromLTRBR(inset, -ry, width - inset, ry, const Radius.circular(4)));
      canvas.drawPath(body, Paint()..color = Colors.white);
      canvas.drawPath(
        body,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(inset, 0), width: rx * 2, height: height),
        Paint()..color = CckColors.inductorEndCap,
      );
      final t = ((inductance - 5) / 5).clamp(0.0, 1.0);
      final numLoops = (12 + t * 8).round();
      for (var i = 0; i < numLoops; i++) {
        final x = ui.lerpDouble(width * 0.2, width * 0.8, i / (numLoops - 1))!;
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x, 0), width: 10, height: height),
          Paint()
            ..color = CckColors.inductorWire
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );
      }
    }
    canvas.restore();
  }

  void _drawSwitch(
    Canvas canvas,
    Offset a,
    Offset b,
    bool schematic,
    bool closed,
  ) {
    final d = (b - a).distance;
    if (d == 0) return;
    final angle = math.atan2(b.dy - a.dy, b.dx - a.dx);
    canvas.save();
    canvas.translate(a.dx, a.dy);
    canvas.rotate(angle);
    final s = d / CckConstants.switchLength;
    canvas.scale(s, s);
    const len = CckConstants.switchLength;
    const start = CckConstants.switchStart;
    const end = CckConstants.switchEnd;
    const thick = 16.0;
    final fill = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, -thick / 2),
        const Offset(0, thick / 2),
        const [CckColors.switchFill0, CckColors.switchFill1, CckColors.switchFill2],
        const [0, 0.3, 1],
      );
    final stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = schematic ? 0 : 1;
    canvas.drawRRect(
      RRect.fromLTRBR(0, -thick / 2, len * start, thick / 2, const Radius.circular(8)),
      fill,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(0, -thick / 2, len * start, thick / 2, const Radius.circular(8)),
      stroke,
    );
    canvas.save();
    canvas.translate(len * start, 0);
    canvas.rotate(closed ? 0 : -math.pi / 4);
    canvas.drawRect(const Rect.fromLTWH(0, -thick / 2, len * (end - start), thick), fill);
    canvas.drawRect(const Rect.fromLTWH(0, -thick / 2, len * (end - start), thick), stroke);
    canvas.restore();
    canvas.drawRRect(
      RRect.fromLTRBR(len * end, -thick / 2, len, thick / 2, const Radius.circular(8)),
      fill,
    );
    canvas.drawCircle(Offset(len * start, 0), thick * 0.6, Paint()..color = CckColors.switchHinge);
    canvas.drawCircle(
      Offset(len * start, 0),
      thick * 0.6,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    if (schematic) {
      canvas.drawCircle(Offset(len * end, 0), thick * 0.6, Paint()..color = Colors.black);
    }
    canvas.restore();
  }

  void _drawFuseSchematic(Canvas canvas, Offset a, Offset b, bool tripped) {
    _drawZigZag(canvas, a, b);
    if (tripped) {
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = Colors.red.withValues(alpha: 0.4)
          ..strokeWidth = 2,
      );
    }
  }

  void _drawSeriesAmmeter(Canvas canvas, Offset a, Offset b, bool schematic) {
    if (!schematic && images['ammeterBody'] != null) {
      _drawImageAlong(canvas, images['ammeterBody'], a, b);
      return;
    }
    final mid = Offset.lerp(a, b, 0.5)!;
    canvas.drawLine(a, b, Paint()..color = Colors.black..strokeWidth = 4 * mvt.zoom);
    canvas.drawCircle(mid, 18 * mvt.zoom, Paint()..color = Colors.white);
    canvas.drawCircle(
      mid,
      18 * mvt.zoom,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * mvt.zoom,
    );
    final tp = TextPainter(
      text: const TextSpan(text: 'A', style: TextStyle(color: Colors.black, fontSize: 14)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, mid - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawBulb(
    Canvas canvas,
    CckRenderElement el,
    Offset a,
    Offset b,
    bool schematic,
  ) {
    if (schematic) {
      final mid = Offset.lerp(a, b, 0.5)!;
      canvas.drawLine(a, b, Paint()..color = Colors.black..strokeWidth = 4 * mvt.zoom);
      canvas.drawCircle(
        mid,
        16 * mvt.zoom,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 * mvt.zoom,
      );
      canvas.drawLine(
        mid + Offset(-8, -8) * mvt.zoom,
        mid + Offset(8, 8) * mvt.zoom,
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2 * mvt.zoom,
      );
      canvas.drawLine(
        mid + Offset(8, -8) * mvt.zoom,
        mid + Offset(-8, 8) * mvt.zoom,
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2 * mvt.zoom,
      );
      return;
    }
    _drawImageAlong(canvas, images['lightBulbBack'], a, b);
    if (el.brightness > 0 && images['lightBulbMiddle'] != null) {
      canvas.saveLayer(null, Paint());
      _drawImageAlong(canvas, images['lightBulbMiddle'], a, b);
      canvas.drawRect(
        Rect.fromPoints(a, b).inflate(80),
        Paint()
          ..color = Colors.white.withValues(alpha: 1 - el.brightness)
          ..blendMode = BlendMode.dstOut,
      );
      canvas.restore();
    }
    _drawImageAlong(canvas, images['lightBulbFront'], a, b);
  }

  void _drawSpark(Canvas canvas, Offset a, Offset b, double t) {
    // FuseTripAnimation.ts: scale 0.75→2, opacity 1→0 after 0.8, duration 0.3, quadratic in-out
    final eased = t < 0.5 ? 2 * t * t : 1 - math.pow(-2 * t + 2, 2) / 2;
    final scale = ui.lerpDouble(0.75, 2, eased)!;
    final opacity = t < 0.8 ? 1.0 : (1 - (t - 0.8) / 0.2).clamp(0.0, 1.0);
    final mid = Offset.lerp(a, b, 0.5)!;
    canvas.save();
    canvas.translate(mid.dx, mid.dy);
    canvas.scale(scale * mvt.zoom);
    final p = Paint()
      ..color = CckColors.fuseSpark.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    const polylines = [
      '29.2,11.5 34.3,1.9 34.7,12.8 50.7,1.8 38.7,16.9 49.6,17.6 39.8,22.5',
      '11.1,22.5 1.5,17.3 12.4,16.9 1.3,1 16.5,13 17.2,2.1 22.1,11.8',
      '22.8,40.5 17.7,50.1 17.3,39.2 1.3,50.2 13.3,35.1 2.4,34.4 12.2,29.5',
      '40.9,29.5 50.5,34.7 39.6,35.1 50.7,51 35.5,39 34.8,49.9 29.9,40.2',
    ];
    for (final line in polylines) {
      final path = Path();
      final pts = line.split(' ');
      for (var i = 0; i < pts.length; i++) {
        final xy = pts[i].split(',');
        final o = Offset(double.parse(xy[0]) - 26, double.parse(xy[1]) - 26);
        if (i == 0) {
          path.moveTo(o.dx, o.dy);
        } else {
          path.lineTo(o.dx, o.dy);
        }
      }
      canvas.drawPath(path, p);
    }
    canvas.restore();
  }

  void _drawCharge(Canvas canvas, CckRenderCharge c) {
    final p = mvt.toView(CckVec(c.x, c.y));
    if (data.currentType == CckCurrentType.conventional) {
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(c.angle);
      final path = Path()
        ..moveTo(10, 0)
        ..lineTo(-6, -6)
        ..lineTo(-6, 6)
        ..close();
      canvas.drawPath(path, Paint()..color = CckColors.conventionalArrowFill);
      canvas.drawPath(
        path,
        Paint()
          ..color = CckColors.conventionalArrowStroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      canvas.restore();
      return;
    }
    final r = CckConstants.electronRadius * mvt.zoom;
    canvas.drawCircle(
      p,
      r + 0.5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawCircle(
      p,
      r,
      Paint()..color = CckColors.electronBlue.withValues(alpha: 0.75),
    );
    canvas.drawLine(
      Offset(p.dx - r * 0.4, p.dy),
      Offset(p.dx + r * 0.4, p.dy),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.75)
        ..strokeWidth = 2,
    );
  }

  void _drawCaption(Canvas canvas, Offset a, Offset b, CckRenderElement el) {
    final mid = Offset.lerp(a, b, 0.5)!;
    final parts = <String>[
      if (el.label != null) el.label!,
      if (el.valueText != null) el.valueText!,
    ];
    if (parts.isEmpty) return;
    final tp = TextPainter(
      text: TextSpan(
        text: parts.join('\n'),
        style: TextStyle(
          color: CckColors.textFill,
          fontSize: CckConstants.fontSize * mvt.zoom.clamp(0.7, 1.2),
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(mid.dx - tp.width / 2, mid.dy + 14 * mvt.zoom));
  }

  void _drawImageAlong(Canvas canvas, ui.Image? image, Offset a, Offset b) {
    if (image == null) {
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = Colors.black54
          ..strokeWidth = 8 * mvt.zoom,
      );
      return;
    }
    final d = (b - a).distance;
    if (d == 0) return;
    final angle = math.atan2(b.dy - a.dy, b.dx - a.dx);
    final h = image.height * d / image.width;
    canvas.save();
    canvas.translate(a.dx, a.dy);
    canvas.rotate(angle);
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, -h / 2, d, h),
      image: image,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.medium,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CircuitPainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.mvt.zoom != mvt.zoom;
}
