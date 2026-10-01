import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// PhET `SpectrumDiagram` (greenhouse-effect/js/micro/view/SpectrumDiagram.js).
///
/// Frequency axis is logarithmic from 10^3 Hz to 10^21 Hz across 657 px.
/// Wavelength ticks use c = 299792458 m/s. Visible band is
/// `WavelengthSpectrumNode` between 400 THz and 790 THz, rotated so red is
/// on the low-frequency side.
class SpectrumDiagramPainter extends CustomPainter {
  const SpectrumDiagramPainter();

  static const subsectionWidth = 657.0;
  static const stripHeight = 87.0;
  static const minFrequency = 1e3;
  static const maxFrequency = 1e21;
  static const tickHeight = 11.0;
  static const speedOfLight = 299792458.0;
  static const arrowHead = 54.0;
  static const spacing = 20.0;

  /// Logical height: frequency arrow, strip+ticks, wavelength arrow, chirp.
  static const logicalHeight = 54 + 20 + 160 + 20 + 54 + 20 + 65.7;

  static double offsetFromFrequency(double frequency) {
    assert(frequency > 0);
    final logRange = _log10(maxFrequency) - _log10(minFrequency);
    final offset =
        (_log10(frequency) - _log10(minFrequency)) / logRange * subsectionWidth;
    return offset.isFinite ? offset : 0;
  }

  static double _log10(double value) => math.log(value) / math.ln10;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / subsectionWidth, size.height / logicalHeight);
    canvas.save();
    canvas.translate(
      (size.width - subsectionWidth * scale) / 2,
      (size.height - logicalHeight * scale) / 2,
    );
    canvas.scale(scale);

    var y = 0.0;
    _arrow(
      canvas,
      y,
      pointRight: true,
      label: 'Increasing frequency and energy',
      left: Colors.white,
      right: const Color.fromRGBO(5, 255, 255, 1),
    );
    y += arrowHead + spacing;

    const bandTopPad = 36.0;
    final stripTop = y + bandTopPad;
    _strip(canvas, stripTop);
    y += bandTopPad + stripHeight + 36 + spacing;

    _arrow(
      canvas,
      y,
      pointRight: false,
      label: 'Increasing wavelength',
      left: Colors.white,
      right: const Color.fromRGBO(255, 5, 255, 1),
    );
    y += arrowHead + spacing;
    _chirp(canvas, y);
    canvas.restore();
  }

  void _arrow(
    Canvas canvas,
    double top, {
    required bool pointRight,
    required String label,
    required Color left,
    required Color right,
  }) {
    final rect = Rect.fromLTWH(0, top, subsectionWidth, arrowHead);
    final paint = Paint()
      ..shader = ui.Gradient.linear(rect.centerLeft, rect.centerRight, [left, right]);
    final path = Path();
    const tail = 34.0;
    final mid = top + arrowHead / 2;
    if (pointRight) {
      path
        ..moveTo(0, mid - tail / 2)
        ..lineTo(subsectionWidth - arrowHead, mid - tail / 2)
        ..lineTo(subsectionWidth - arrowHead, top)
        ..lineTo(subsectionWidth, mid)
        ..lineTo(subsectionWidth - arrowHead, top + arrowHead)
        ..lineTo(subsectionWidth - arrowHead, mid + tail / 2)
        ..lineTo(0, mid + tail / 2)
        ..close();
    } else {
      path
        ..moveTo(subsectionWidth, mid - tail / 2)
        ..lineTo(arrowHead, mid - tail / 2)
        ..lineTo(arrowHead, top)
        ..lineTo(0, mid)
        ..lineTo(arrowHead, top + arrowHead)
        ..lineTo(arrowHead, mid + tail / 2)
        ..lineTo(subsectionWidth, mid + tail / 2)
        ..close();
    }
    canvas.drawPath(path, paint);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black
        ..strokeWidth = 1,
    );
    _text(canvas, label, subsectionWidth / 2, mid, 16);
  }

  void _strip(Canvas canvas, double stripTop) {
    final strip = Rect.fromLTWH(0, stripTop, subsectionWidth, stripHeight);
    canvas.drawRect(strip, Paint()..color = const Color.fromRGBO(237, 243, 246, 1));
    _visibleRainbow(canvas, stripTop);
    _dividers(canvas, stripTop);
    canvas.drawRect(
      strip,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = Colors.black,
    );
    _frequencyTicks(canvas, stripTop);
    _wavelengthTicks(canvas, stripTop + stripHeight);
    _bandLabels(canvas, stripTop);
    _text(canvas, 'Hz', subsectionWidth - 16, stripTop - tickHeight - 18, 14);
    _text(canvas, 'm', subsectionWidth - 12, stripTop + stripHeight + tickHeight + 16, 14);
  }

  void _visibleRainbow(Canvas canvas, double stripTop) {
    final left = offsetFromFrequency(400e12);
    final right = offsetFromFrequency(790e12);
    final rect = Rect.fromLTWH(left, stripTop + 1.25, right - left, stripHeight - 2.5);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(rect.left, rect.center.dy),
          Offset(rect.right, rect.center.dy),
          const [
            Color(0xFFFF0000),
            Color(0xFFFF7F00),
            Color(0xFFFFFF00),
            Color(0xFF00FF00),
            Color(0xFF00FFFF),
            Color(0xFF0000FF),
            Color(0xFF8B00FF),
          ],
          const [0.0, 1 / 6, 2 / 6, 3 / 6, 4 / 6, 5 / 6, 1.0],
        ),
    );
    final center = (left + right) / 2;
    _text(canvas, 'Visible', center, stripTop - 22, 14);
    canvas.drawLine(
      Offset(center, stripTop - 12),
      Offset(center, stripTop),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2,
    );
  }

  void _dividers(Canvas canvas, double stripTop) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.5;
    for (final f in [1e9, 3e11, 1e16, 1e19]) {
      final x = offsetFromFrequency(f);
      for (var i = 0; i < 5; i++) {
        final y0 = stripTop + 2 * i * stripHeight / 9;
        canvas.drawLine(Offset(x, y0), Offset(x, y0 + stripHeight / 9), paint);
      }
    }
  }

  void _frequencyTicks(Canvas canvas, double stripTop) {
    // Source: for (i = 4; i <= 20; i++) addFrequencyTickMark(10^i)
    // Offset uses log10, so exponent maps linearly: (i - 3) / 18 * 657.
    const logMin = 3.0;
    const logMax = 21.0;
    for (var i = 4; i <= 20; i++) {
      final x = (i - logMin) / (logMax - logMin) * subsectionWidth;
      if (!x.isFinite) continue;
      canvas.drawLine(
        Offset(x, stripTop),
        Offset(x, stripTop - tickHeight),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2,
      );
      if (i.isEven) {
        _text(canvas, '10^$i', x, stripTop - tickHeight - 10, 10);
      }
    }
  }

  void _wavelengthTicks(Canvas canvas, double stripBottom) {
    // Source: for (j = -12; j <= 4; j++) wavelength = 10^j meters.
    for (var j = -12; j <= 4; j++) {
      final wavelength = math.pow(10.0, j).toDouble();
      final frequency = speedOfLight / wavelength;
      if (frequency < minFrequency || frequency > maxFrequency) continue;
      final x = offsetFromFrequency(frequency);
      if (!x.isFinite || x < 0 || x > subsectionWidth) continue;
      canvas.drawLine(
        Offset(x, stripBottom),
        Offset(x, stripBottom + tickHeight),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2,
      );
      if (j.isEven) {
        _text(canvas, '10^$j', x, stripBottom + tickHeight + 12, 10);
      }
    }
  }

  void _bandLabels(Canvas canvas, double stripTop) {
    const bands = <(double, double, String)>[
      (1e3, 1e9, 'Radio'),
      (1e9, 3e11, 'Microwave'),
      (3e11, 6e14, 'Infrared'),
      (1e15, 8e15, 'Ultra-\nviolet'),
      (1e16, 1e19, 'X-ray'),
      (1e19, 1e21, 'Gamma\nray'),
    ];
    for (final (lo, hi, name) in bands) {
      final x = (offsetFromFrequency(lo) + offsetFromFrequency(hi)) / 2;
      _text(canvas, name, x, stripTop + stripHeight / 2, 12);
    }
  }

  void _chirp(Canvas canvas, double top) {
    const height = 65.7;
    final box = Rect.fromLTWH(0, top, subsectionWidth, height);
    canvas.drawRect(box, Paint()..color = const Color.fromRGBO(237, 243, 246, 1));
    canvas.drawRect(
      box,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = Colors.black,
    );
    final path = Path()..moveTo(0, top + height / 2);
    const n = 400;
    for (var i = 0; i < n; i++) {
      final x = i * (subsectionWidth / (n - 1));
      final t = x / subsectionWidth;
      const f0 = 1.0;
      const k = 2.0;
      const tScale = 4.5;
      final sinTerm = math.sin(
        2 * math.pi * f0 * (math.pow(k, t * tScale) - 1) / math.log(k),
      );
      final y = sinTerm * height * 0.40 + height / 2;
      path.lineTo(x, top + y);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.black,
    );
  }

  void _text(Canvas canvas, String value, double x, double y, double size) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(color: Colors.black, fontSize: size, height: 1.05),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 120);
    painter.paint(canvas, Offset(x - painter.width / 2, y - painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant SpectrumDiagramPainter oldDelegate) => false;
}
