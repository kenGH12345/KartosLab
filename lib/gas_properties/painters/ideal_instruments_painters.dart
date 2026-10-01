import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../gas_properties_colors.dart';

/// Vertical thermometer — glass tube + bulb + white readout (PhET ThermometerNode).
class IdealThermometerPainter extends CustomPainter {
  IdealThermometerPainter({
    required this.fill01,
    required this.label,
  });

  final double fill01;
  final String label;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final bulbR = 11.0;
    final bulb = Offset(cx, size.height - bulbR - 2);
    final tubeTop = 28.0;
    final tubeW = 14.0;
    final tubeBottom = bulb.dy - bulbR + 4;

    // Readout card
    final card = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, 72, 24),
      const Radius.circular(4),
    );
    canvas.drawRRect(card, Paint()..color = Colors.white);
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: 54);
    tp.paint(canvas, Offset(5, 12 - tp.height / 2));
    // Dropdown chevron
    final path = Path()
      ..moveTo(58, 9)
      ..lineTo(66, 9)
      ..lineTo(62, 15)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.black87);

    // Glass tube
    final tube = RRect.fromRectAndRadius(
      Rect.fromLTRB(cx - tubeW / 2, tubeTop, cx + tubeW / 2, tubeBottom),
      const Radius.circular(7),
    );
    canvas.drawRRect(tube, Paint()..color = const Color(0xFFF5F5F5));
    canvas.drawRRect(
      tube,
      Paint()
        ..color = const Color(0xFF9E9E9E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Scale ticks
    final tickPaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1;
    for (var i = 0; i <= 8; i++) {
      final y = tubeTop + 6 + (tubeBottom - tubeTop - 12) * (i / 8);
      canvas.drawLine(Offset(cx + 2, y), Offset(cx + tubeW / 2 - 1, y), tickPaint);
    }

    // Mercury in tube
    final fillH = (tubeBottom - tubeTop - 8) * fill01.clamp(0.0, 1.0);
    if (fillH > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            cx - 4,
            tubeBottom - 4 - fillH,
            cx + 4,
            tubeBottom - 2,
          ),
          const Radius.circular(3),
        ),
        Paint()..color = const Color(0xFFE11D48),
      );
    }

    // Bulb
    canvas.drawCircle(bulb, bulbR, Paint()..color = const Color(0xFFE11D48));
    canvas.drawCircle(
      bulb,
      bulbR,
      Paint()
        ..color = const Color(0xFF9F1239)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      bulb + const Offset(-3, -3),
      3,
      Paint()..color = const Color(0x66FFFFFF),
    );
  }

  @override
  bool shouldRepaint(covariant IdealThermometerPainter oldDelegate) =>
      oldDelegate.fill01 != fill01 || oldDelegate.label != label;
}

/// Analog pressure gauge — white dial + red needle + readout (PhET PressureGaugeNode).
class IdealPressureGaugePainter extends CustomPainter {
  IdealPressureGaugePainter({
    required this.fraction,
    required this.label,
  });

  final double fraction;
  final String label;

  @override
  void paint(Canvas canvas, Size size) {
    final dialR = 42.0;
    final c = Offset(size.width / 2, dialR + 4);

    // Bezel
    canvas.drawCircle(c, dialR + 3, Paint()..color = const Color(0xFF6B7280));
    canvas.drawCircle(c, dialR, Paint()..color = Colors.white);

    // Ticks
    for (var i = 0; i <= 10; i++) {
      final a = -math.pi * 0.75 + (math.pi * 1.5) * (i / 10);
      final outer = c + Offset(math.cos(a), math.sin(a)) * (dialR - 4);
      final inner = c + Offset(math.cos(a), math.sin(a)) * (dialR - (i % 5 == 0 ? 14 : 10));
      canvas.drawLine(
        outer,
        inner,
        Paint()
          ..color = Colors.black87
          ..strokeWidth = i % 5 == 0 ? 2 : 1,
      );
    }

    // "Pressure" label
    final title = TextPainter(
      text: const TextSpan(
        text: 'Pressure',
        style: TextStyle(color: Colors.black54, fontSize: 9, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    title.paint(canvas, Offset(c.dx - title.width / 2, c.dy - 18));

    // Needle
    final a = -math.pi * 0.75 + (math.pi * 1.5) * fraction.clamp(0.0, 1.0);
    canvas.drawLine(
      c,
      c + Offset(math.cos(a), math.sin(a)) * (dialR - 16),
      Paint()
        ..color = const Color(0xFFDC2626)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(c, 4.5, Paint()..color = const Color(0xFF111827));

    // Readout
    final cardTop = c.dy + dialR + 6;
    final card = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(c.dx, cardTop + 12), width: 78, height: 24),
      const Radius.circular(4),
    );
    canvas.drawRRect(card, Paint()..color = Colors.white);
    final lp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    lp.paint(canvas, Offset(c.dx - lp.width / 2 - 6, cardTop + 12 - lp.height / 2));
    final chev = Path()
      ..moveTo(c.dx + 28, cardTop + 8)
      ..lineTo(c.dx + 34, cardTop + 8)
      ..lineTo(c.dx + 31, cardTop + 14)
      ..close();
    canvas.drawPath(chev, Paint()..color = Colors.black87);
  }

  @override
  bool shouldRepaint(covariant IdealPressureGaugePainter oldDelegate) =>
      oldDelegate.fraction != fraction || oldDelegate.label != label;
}

/// Bicycle pump body — hose / cylinder / handle / base (PhET BicyclePumpNode style).
class IdealBicyclePumpPainter extends CustomPainter {
  IdealBicyclePumpPainter({this.handleLift = 0});

  /// 0 = down, 1 = fully up (visual only).
  final double handleLift;

  @override
  void paint(Canvas canvas, Size size) {
    final hosePaint = Paint()
      ..color = const Color(0xFF8B8B8B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final hose = Path()
      ..moveTo(0, size.height * 0.42)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.42,
        size.width * 0.12,
        size.height * 0.78,
        size.width * 0.38,
        size.height * 0.86,
      );
    canvas.drawPath(hose, hosePaint);

    final cx = size.width * 0.62;
    final baseY = size.height - 18;
    const cylW = 36.0;
    final cylTop = 28.0 + (1 - handleLift) * 6;
    final cylBottom = baseY - 10;

    final base = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, baseY), width: 58, height: 20),
      const Radius.circular(5),
    );
    canvas.drawRRect(
      base,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD1D5DB), Color(0xFF9CA3AF)],
        ).createShader(base.outerRect),
    );
    canvas.drawRRect(
      base,
      Paint()
        ..color = const Color(0xFF6B7280)
        ..style = PaintingStyle.stroke,
    );

    final cyl = RRect.fromRectAndRadius(
      Rect.fromLTRB(cx - cylW / 2, cylTop, cx + cylW / 2, cylBottom),
      const Radius.circular(5),
    );
    canvas.drawRRect(
      cyl,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF9F8CFF), Color(0xFF5B4DB8), Color(0xFF3B2F8A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(cyl.outerRect),
    );
    canvas.drawRRect(
      cyl,
      Paint()
        ..color = const Color(0xFF2E2A5A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(cx - 4, cylTop + 8, cx + 4, cylBottom - 8),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0x66222244),
    );
    final tick = Paint()
      ..color = const Color(0xCCE0E0FF)
      ..strokeWidth = 1;
    for (var i = 1; i <= 8; i++) {
      final y = cylTop + 10 + (cylBottom - cylTop - 20) * (i / 9);
      canvas.drawLine(Offset(cx + 6, y), Offset(cx + cylW / 2 - 3, y), tick);
    }

    final shaftTop = cylTop - 8 - handleLift * 26;
    canvas.drawLine(
      Offset(cx, shaftTop + 8),
      Offset(cx, cylTop + 24),
      Paint()
        ..color = const Color(0xFFD1D5DB)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(cx - 22, shaftTop),
      Offset(cx + 22, shaftTop),
      Paint()
        ..color = const Color(0xFFB0B0B0)
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round,
    );
    for (final dx in [-14.0, -7.0, 0.0, 7.0, 14.0]) {
      canvas.drawLine(
        Offset(cx + dx, shaftTop - 4),
        Offset(cx + dx, shaftTop + 4),
        Paint()
          ..color = const Color(0xFF6B7280)
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant IdealBicyclePumpPainter oldDelegate) =>
      oldDelegate.handleLift != handleLift;
}

/// Heat/Cool bucket control (PhET HeaterCoolerNode proportions).
/// factor > 0 → flames rise from the opening; factor < 0 → ice stack rises.
class IdealHeaterCoolerPainter extends CustomPainter {
  IdealHeaterCoolerPainter({required this.factor});

  /// −1 cool … 0 … +1 heat
  final double factor;

  @override
  void paint(Canvas canvas, Size size) {
    final intensity = factor.abs().clamp(0.0, 1.0);

    // Opening / back cavity (behind flames & ice)
    final opening = RRect.fromRectAndRadius(
      Rect.fromLTWH(14, 8, size.width - 28, 22),
      const Radius.circular(4),
    );
    canvas.drawRRect(opening, Paint()..color = const Color(0xFF1F2937));

    // Flames / ice emerge from the opening (PhET HeaterCoolerBack)
    if (factor > 0.02) {
      _paintFlames(canvas, size, intensity);
    } else if (factor < -0.02) {
      _paintIce(canvas, size, intensity);
    }

    // Stove body (front)
    final body = Path()
      ..moveTo(8, 28)
      ..lineTo(size.width - 8, 28)
      ..lineTo(size.width - 16, size.height - 6)
      ..lineTo(16, size.height - 6)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFB8B8B8), Color(0xFF7A7A7A), Color(0xFF5A5A5A)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      body,
      Paint()
        ..color = const Color(0xFF404040)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Inner well lip
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(18, 26, size.width - 36, 8),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF333333),
    );

    // Heat (top red) / Cool (bottom blue) bands on slider track
    final trackTop = 40.0;
    final trackH = size.height - 62;
    final track = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width / 2 - 10, trackTop, 20, trackH),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      track,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEF4444), Color(0xFF64748B), Color(0xFF3B82F6)],
          stops: [0.0, 0.5, 1.0],
        ).createShader(track.outerRect),
    );

    for (final (o, label) in [
      (Offset(size.width / 2, 34), 'Heat'),
      (Offset(size.width / 2, size.height - 10), 'Cool'),
    ]) {
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(o.dx - tp.width / 2, o.dy - tp.height / 2));
    }

    // Thumb
    final t = 0.5 - factor * 0.42;
    final thumbY = trackTop + trackH * t;
    final thumb = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, thumbY),
        width: 28,
        height: 16,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(thumb, Paint()..color = const Color(0xFF93C5FD));
    canvas.drawRRect(
      thumb,
      Paint()
        ..color = const Color(0xFF1E3A8A)
        ..style = PaintingStyle.stroke,
    );
  }

  void _paintFlames(Canvas canvas, Size size, double intensity) {
    final cx = size.width / 2;
    final baseY = 30.0;
    final h = 18 + 55 * intensity;
    // Multiple flame tongues
    for (final (dx, scale, color) in [
      (-14.0, 0.75, const Color(0xFFFFB020)),
      (0.0, 1.0, const Color(0xFFFF6A00)),
      (12.0, 0.7, const Color(0xFFFFCC33)),
      (-6.0, 0.55, const Color(0xFFFFEE66)),
      (7.0, 0.5, const Color(0xFFFF8800)),
    ]) {
      final fh = h * scale;
      final fw = 10.0 * scale + 4;
      final path = Path()
        ..moveTo(cx + dx - fw / 2, baseY)
        ..quadraticBezierTo(cx + dx - fw * 0.2, baseY - fh * 0.45, cx + dx, baseY - fh)
        ..quadraticBezierTo(cx + dx + fw * 0.2, baseY - fh * 0.45, cx + dx + fw / 2, baseY)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              color,
              Color.lerp(color, const Color(0xFFFFFFAA), 0.55)!,
              const Color(0x00FFFFFF),
            ],
          ).createShader(Rect.fromLTWH(cx + dx - fw, baseY - fh, fw * 2, fh)),
      );
    }
  }

  void _paintIce(Canvas canvas, Size size, double intensity) {
    final cx = size.width / 2;
    final baseY = 28.0;
    final rise = 12 + 48 * intensity;
    // Stack of ice cubes rising from the opening
    final cubes = <(double, double, double)>[
      (-16, -rise * 0.15, 14),
      (2, -rise * 0.35, 16),
      (-8, -rise * 0.55, 13),
      (10, -rise * 0.7, 12),
      (-2, -rise * 0.9, 11),
    ];
    for (final (dx, dy, s) in cubes) {
      final r = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + dx, baseY + dy),
          width: s,
          height: s * 0.85,
        ),
        const Radius.circular(2),
      );
      canvas.drawRRect(
        r,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F7FF), Color(0xFF7EC8F0), Color(0xFF3B9DD9)],
          ).createShader(r.outerRect),
      );
      canvas.drawRRect(
        r,
        Paint()
          ..color = const Color(0xFF2B6CB0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      // highlight facet
      canvas.drawLine(
        Offset(cx + dx - s * 0.25, baseY + dy - s * 0.2),
        Offset(cx + dx + s * 0.1, baseY + dy + s * 0.15),
        Paint()
          ..color = const Color(0xAAFFFFFF)
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant IdealHeaterCoolerPainter oldDelegate) =>
      oldDelegate.factor != factor;
}

/// Small PhET-style circular time / reset buttons.
class PhETCircleButtonPainter extends CustomPainter {
  PhETCircleButtonPainter({
    required this.fill,
    required this.icon,
  });

  final Color fill;
  final IconData icon;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    canvas.drawCircle(
      c + const Offset(0, 1.5),
      r,
      Paint()..color = const Color(0x66000000),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(fill, Colors.white, 0.25)!,
            fill,
            Color.lerp(fill, Colors.black, 0.15)!,
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant PhETCircleButtonPainter oldDelegate) =>
      oldDelegate.fill != fill;
}

/// Eraser chrome button.
class IdealEraserPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(6),
    );
    canvas.drawRRect(r, Paint()..color = const Color(GasPropertiesColors.eraserButton));
    canvas.drawRRect(
      r,
      Paint()
        ..color = const Color(0xFF9CA3AF)
        ..style = PaintingStyle.stroke,
    );
    // Simple eraser glyph
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.22, size.height * 0.28, size.width * 0.5, size.height * 0.4),
      const Radius.circular(2),
    );
    canvas.drawRRect(body, Paint()..color = const Color(0xFFFB7185));
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.55, size.height * 0.28, size.width * 0.18, size.height * 0.4),
      Paint()..color = const Color(0xFFE5E7EB),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
