/// Chart Intro 核子渐变球。视觉对标 shred `ParticleNode`，
/// 与 Decay [NucleusPainter] 同配方，但不依赖 Decay State。
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../model/nucleon.dart';
import '../chart_intro_visuals.dart';

class NucleonBall {
  const NucleonBall._();

  static Color colorFor(NucleonType type) => type == NucleonType.proton
      ? ChartIntroVisuals.proton
      : ChartIntroVisuals.neutron;

  /// [已确认] ParticleNode.updateFill：中心偏左上 (-0.4r,-0.4r)、半径 1.6r、白→基色；描边=基色
  static void paint(
    Canvas canvas,
    Offset center,
    double r,
    Color base, {
    double opacity = 1,
  }) {
    if (opacity <= 0) return;
    if (opacity < 1) {
      canvas.saveLayer(
        Rect.fromCircle(center: center, radius: r + 2),
        Paint()..color = Color.fromRGBO(255, 255, 255, opacity),
      );
    }
    final gradientCenter = Offset(center.dx - r * 0.4, center.dy - r * 0.4);
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          gradientCenter,
          r * 1.6,
          [Colors.white, base],
        ),
    );
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = base,
    );
    if (opacity < 1) canvas.restore();
  }
}
