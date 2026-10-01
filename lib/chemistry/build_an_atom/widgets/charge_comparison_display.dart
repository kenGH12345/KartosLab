import 'package:flutter/material.dart';

import '../constants/baa_constants.dart';

/// PhET `ChargeComparisonDisplay` — + / − symbol rows with match box.
class ChargeComparisonDisplay extends StatelessWidget {
  const ChargeComparisonDisplay({
    super.key,
    required this.protonCount,
    required this.electronCount,
    this.maxCharge = BAAConstants.maxProtons,
  });

  final int protonCount;
  final int electronCount;
  final int maxCharge;

  static const double _symbolW = 12;
  static const double _vInset = 5;
  static const double _gap = _symbolW * 0.4;
  static const double _lineW = _symbolW * 0.3;

  @override
  Widget build(BuildContext context) {
    final p = protonCount.clamp(0, maxCharge);
    final e = electronCount.clamp(0, maxCharge);
    final matched = p < e ? p : e;
    final rowW = maxCharge * _symbolW + (maxCharge - 1) * _gap + _gap;
    final h = 2 * _symbolW + 2 * _vInset;

    return SizedBox(
      width: rowW,
      height: h,
      child: CustomPaint(
        painter: _ChargeComparisonPainter(
          protons: p,
          electrons: e,
          matched: matched,
          maxCharge: maxCharge,
        ),
      ),
    );
  }
}

class _ChargeComparisonPainter extends CustomPainter {
  _ChargeComparisonPainter({
    required this.protons,
    required this.electrons,
    required this.matched,
    required this.maxCharge,
  });

  final int protons;
  final int electrons;
  final int matched;
  final int maxCharge;

  static const _symbolW = ChargeComparisonDisplay._symbolW;
  static const _vInset = ChargeComparisonDisplay._vInset;
  static const _gap = ChargeComparisonDisplay._gap;
  static const _lineW = ChargeComparisonDisplay._lineW;

  @override
  void paint(Canvas canvas, Size size) {
    if (matched > 0) {
      final boxW =
          _gap / 2 + matched * _symbolW + (matched - 0.5) * _gap;
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, boxW, size.height),
        const Radius.circular(4),
      );
      canvas.drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.black,
      );
    }

    final plusFill = Paint()..color = const Color(0xFFE65000);
    final minusFill = Paint()..color = const Color(0xFF6464FF);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.black;

    for (var i = 0; i < maxCharge; i++) {
      final cx = _gap / 2 + _symbolW / 2 + i * (_symbolW + _gap);
      if (i < protons) {
        final cy = _vInset + _symbolW / 2;
        _drawPlus(canvas, Offset(cx, cy), plusFill, stroke);
      }
      if (i < electrons) {
        final cy = _vInset + _symbolW * 1.5;
        _drawMinus(canvas, Offset(cx, cy), minusFill, stroke);
      }
    }
  }

  void _drawPlus(Canvas canvas, Offset c, Paint fill, Paint stroke) {
    final hw = _symbolW / 2;
    final t = _lineW / 2;
    final path = Path()
      ..moveTo(c.dx - t, c.dy - t)
      ..lineTo(c.dx - t, c.dy - hw)
      ..lineTo(c.dx + t, c.dy - hw)
      ..lineTo(c.dx + t, c.dy - t)
      ..lineTo(c.dx + hw, c.dy - t)
      ..lineTo(c.dx + hw, c.dy + t)
      ..lineTo(c.dx + t, c.dy + t)
      ..lineTo(c.dx + t, c.dy + hw)
      ..lineTo(c.dx - t, c.dy + hw)
      ..lineTo(c.dx - t, c.dy + t)
      ..lineTo(c.dx - hw, c.dy + t)
      ..lineTo(c.dx - hw, c.dy - t)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawMinus(Canvas canvas, Offset c, Paint fill, Paint stroke) {
    final hw = _symbolW / 2;
    final t = _lineW / 2;
    final path = Path()
      ..addRect(Rect.fromLTRB(c.dx - hw, c.dy - t, c.dx + hw, c.dy + t));
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _ChargeComparisonPainter old) =>
      old.protons != protons ||
      old.electrons != electrons ||
      old.matched != matched ||
      old.maxCharge != maxCharge;
}
