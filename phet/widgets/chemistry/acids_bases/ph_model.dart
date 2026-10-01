/// PhET pH Model — pH, acids, bases, H3O+, OH-.
library;

import 'dart:math';
import 'package:flutter/material.dart';

enum SolutionType { acid, base, neutral }

class PHModel {
  double pH;
  double temperature;

  PHModel({this.pH = 7.0, this.temperature = 298.0});

  SolutionType get type {
    if (pH < 6.5) return SolutionType.acid;
    if (pH > 7.5) return SolutionType.base;
    return SolutionType.neutral;
  }

  /// [H3O+] concentration in mol/L.
  double get h3oConcentration => pow(10, -pH).toDouble();

  /// [OH-] concentration in mol/L.
  double get ohConcentration => pow(10, -(14 - pH)).toDouble();

  /// Set pH from [H3O+] concentration.
  set h3oConcentration(double c) => pH = -log(c) / ln10;

  /// Set pH from [OH-] concentration.
  set ohConcentration(double c) => pH = 14 + log(c) / ln10;

  /// pH color (red for acid, blue for base, green for neutral).
  Color get color {
    if (pH < 3) return const Color(0xffe53935);
    if (pH < 6) return const Color(0xffff7043);
    if (pH < 7.5) return const Color(0xff66bb6a);
    if (pH < 11) return const Color(0xff42a5f5);
    return const Color(0xff7e57c2);
  }

  /// Add acid (decrease pH).
  void addAcid(double amount) {
    pH = (pH - amount).clamp(0.0, 14.0);
  }

  /// Add base (increase pH).
  void addBase(double amount) {
    pH = (pH + amount).clamp(0.0, 14.0);
  }

  /// Reset to neutral.
  void reset() {
    pH = 7.0;
    temperature = 298.0;
  }
}

/// pH meter display widget (reuses measurement_tool pattern).
class PHMeterPainter extends CustomPainter {
  final double pH;
  const PHMeterPainter({required this.pH});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(8)),
      Paint()..color = const Color(0xff0d2255).withValues(alpha: 0.95),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(8)),
      Paint()..color = Colors.lightBlueAccent..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );

    // pH value
    final tp = TextPainter(
      text: TextSpan(
        text: 'pH = ${pH.toStringAsFixed(1)}',
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(10, h / 2 - tp.height / 2));

    // Color indicator
    final model = PHModel(pH: pH);
    canvas.drawCircle(Offset(w - 20, h / 2), 10, Paint()..color = model.color);
  }

  @override
  bool shouldRepaint(PHMeterPainter old) => old.pH != pH;
}
