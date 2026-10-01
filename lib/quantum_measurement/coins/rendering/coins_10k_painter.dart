/// 100×100 pixel-grid painter for 10000 coins -?CoinSetPixelRepresentation.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:kratos/quantum_coin_toss/common/quantum_measurement_colors.dart';

import '../../common/system_type.dart';

/// Paints an N×N cell grid (N=100 for 10000 coins) from measured outcomes.
class Coins10kPainter extends CustomPainter {
  Coins10kPainter({
    required this.measuredValues,
    required this.count,
    required this.revealed,
    required this.systemType,
    required this.sideLength,
  }) : assert(sideLength * sideLength >= count);

  final List<String> measuredValues;
  final int count;
  final bool revealed;
  final SystemType systemType;
  final int sideLength;

  static const Color hidden = Color(0xFFAAAAAA);

  static Color colorForValue(String value) {
    switch (value) {
      case 'heads':
        return QuantumMeasurementColors.headsColor;
      case 'tails':
        return QuantumMeasurementColors.tailsColor;
      case 'up':
        return QuantumMeasurementColors.upColor;
      case 'down':
        return QuantumMeasurementColors.downColor;
      default:
        return hidden;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / sideLength;
    final cellH = size.height / sideLength;
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < count; i++) {
      final row = i ~/ sideLength;
      final col = i % sideLength;
      paint.color = revealed ? colorForValue(measuredValues[i]) : hidden;
      canvas.drawRect(
        Rect.fromLTWH(col * cellW, row * cellH, cellW, cellH),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant Coins10kPainter oldDelegate) {
    return oldDelegate.revealed != revealed ||
        oldDelegate.count != count ||
        oldDelegate.systemType != systemType ||
        !identical(oldDelegate.measuredValues, measuredValues);
  }
}

/// Deterministic paint-input sample for tests (same inputs -?same colors).
List<Color> sampleGridColors({
  required List<String> measuredValues,
  required int count,
  required bool revealed,
  required SystemType systemType,
  required int sideLength,
}) {
  final out = <Color>[];
  final n = math.min(count, sideLength * sideLength);
  for (var i = 0; i < n; i++) {
    out.add(revealed ? Coins10kPainter.colorForValue(measuredValues[i]) : Coins10kPainter.hidden);
  }
  return out;
}
