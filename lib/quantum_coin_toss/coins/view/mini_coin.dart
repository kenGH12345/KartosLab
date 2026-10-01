// Copyright 2024-2026, University of Colorado Boulder
/// Small coin cells for multi-coin grids.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common/qct_assets.dart';
import '../../common/quantum_measurement_colors.dart';

class MiniCoin extends StatelessWidget {
  const MiniCoin({
    super.key,
    required this.value,
    required this.radius,
    required this.isQuantum,
  });

  final String value;
  final double radius;
  final bool isQuantum;

  @override
  Widget build(BuildContext context) {
    if (value == 'hidden') {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: QuantumMeasurementColors.maskedFill,
          border: Border.all(color: QuantumMeasurementColors.coinStroke),
        ),
      );
    }

    if (isQuantum) {
      final isUp = value == 'up';
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isUp
              ? QuantumMeasurementColors.upFill
              : QuantumMeasurementColors.downFill,
          border: Border.all(color: QuantumMeasurementColors.coinStroke),
        ),
        child: CustomPaint(
          painter: MiniArrowPainter(
            up: isUp,
            color: isUp
                ? QuantumMeasurementColors.upColor
                : QuantumMeasurementColors.downColor,
          ),
        ),
      );
    }

    final isHeads = value == 'heads';
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isHeads
            ? QuantumMeasurementColors.headsFill
            : QuantumMeasurementColors.tailsFill,
        border: Border.all(color: QuantumMeasurementColors.coinStroke),
      ),
      child: Padding(
        padding: EdgeInsets.all(radius * 0.2),
        child: SvgPicture.asset(
          isHeads
              ? QctAssets.classicalCoinHeads
              : QctAssets.classicalCoinTails,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class MiniArrowPainter extends CustomPainter {
  const MiniArrowPainter({required this.up, required this.color});

  final bool up;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final h = size.height * 0.55;
    final headH = h * 0.35;
    final headW = size.width * 0.45;
    final tailW = size.width * 0.14;

    final path = Path();
    if (up) {
      final tipY = cy - h / 2;
      final baseY = cy + h / 2;
      final neckY = tipY + headH;
      path
        ..moveTo(cx, tipY)
        ..lineTo(cx + headW / 2, neckY)
        ..lineTo(cx + tailW / 2, neckY)
        ..lineTo(cx + tailW / 2, baseY)
        ..lineTo(cx - tailW / 2, baseY)
        ..lineTo(cx - tailW / 2, neckY)
        ..lineTo(cx - headW / 2, neckY)
        ..close();
    } else {
      final tipY = cy + h / 2;
      final baseY = cy - h / 2;
      final neckY = tipY - headH;
      path
        ..moveTo(cx, tipY)
        ..lineTo(cx + headW / 2, neckY)
        ..lineTo(cx + tailW / 2, neckY)
        ..lineTo(cx + tailW / 2, baseY)
        ..lineTo(cx - tailW / 2, baseY)
        ..lineTo(cx - tailW / 2, neckY)
        ..lineTo(cx - headW / 2, neckY)
        ..close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant MiniArrowPainter old) =>
      old.up != up || old.color != color;
}
