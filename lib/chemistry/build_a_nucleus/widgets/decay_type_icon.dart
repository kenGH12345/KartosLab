/// Available Decays 键旁示意图。对标 `IconFactory.createDecayIcon`。
///
/// 核子/电子是 ParticleNode 渐变球，不是位图；原版也是程序绘制。
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../ban_constants.dart';
import '../data/decay_type.dart';

class DecayTypeIcon extends StatelessWidget {
  const DecayTypeIcon({
    super.key,
    required this.type,
    this.height = 28,
  });

  final NucleusDecayType type;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(height * 2.6, height),
      painter: DecayTypeIconPainter(type: type),
    );
  }
}

class DecayTypeIconPainter extends CustomPainter {
  const DecayTypeIconPainter({required this.type});

  final NucleusDecayType type;

  static const proton = Color(BanConstants.protonColorValue);
  static const neutron = Color(BanConstants.neutronColorValue);
  static const electron = Color(BanConstants.electronColorValue);
  static const positron = Color(0xFF35B64A);
  static const arrow = Color(BanConstants.legendArrowColorValue);

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.height * 0.22;
    switch (type) {
      case NucleusDecayType.alphaDecay:
        _paintAlpha(canvas, Offset(size.width * 0.5, size.height * 0.5), r);
      case NucleusDecayType.betaMinusDecay:
        _paintBeta(canvas, size, r, fromNeutron: true);
      case NucleusDecayType.betaPlusDecay:
        _paintBeta(canvas, size, r, fromNeutron: false);
      case NucleusDecayType.protonEmission:
        _paintEmission(canvas, size, r, proton);
      case NucleusDecayType.neutronEmission:
        _paintEmission(canvas, size, r, neutron);
    }
  }

  void _paintAlpha(Canvas canvas, Offset c, double r) {
    final d = r * 0.95;
    _ball(canvas, c + Offset(-d, 0), r, proton);
    _ball(canvas, c + Offset(d, 0), r, proton);
    _ball(canvas, c + Offset(0, -d), r, neutron);
    _ball(canvas, c + Offset(0, d), r, neutron);
  }

  void _paintBeta(Canvas canvas, Size size, double r, {required bool fromNeutron}) {
    final y = size.height * 0.5;
    final left = Offset(r + 2, y);
    final mid = Offset(size.width * 0.42, y);
    final rightNuc = Offset(size.width * 0.62, y);
    final lepton = Offset(size.width * 0.88, y);
    _ball(canvas, left, r, fromNeutron ? neutron : proton);
    _arrow(canvas, left.dx + r + 2, mid.dx - r - 2, y);
    _ball(canvas, rightNuc, r, fromNeutron ? proton : neutron);
    _plus(canvas, Offset((rightNuc.dx + lepton.dx) / 2, y));
    _ball(canvas, lepton, r * 0.85, fromNeutron ? electron : positron);
  }

  void _paintEmission(Canvas canvas, Size size, double r, Color color) {
    final y = size.height * 0.5;
    final start = Offset(r + 4, y);
    final end = Offset(size.width - r - 2, y);
    _motionLines(canvas, start);
    _arrow(canvas, start.dx + r + 4, end.dx - r - 4, y);
    _ball(canvas, end, r, color);
  }

  void _motionLines(Canvas canvas, Offset c) {
    final p = Paint()
      ..color = arrow
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (final dy in [-6.0, 0.0, 6.0]) {
      canvas.drawLine(c + Offset(-8, dy), c + Offset(2, dy * 0.3), p);
    }
  }

  void _arrow(Canvas canvas, double x0, double x1, double y) {
    final p = Paint()
      ..color = arrow
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x0, y), Offset(x1 - 4, y), p);
    final head = Path()
      ..moveTo(x1, y)
      ..lineTo(x1 - 7, y - 4)
      ..lineTo(x1 - 7, y + 4)
      ..close();
    canvas.drawPath(head, Paint()..color = arrow);
  }

  void _plus(Canvas canvas, Offset c) {
    final p = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(c + const Offset(-4.5, 0), c + const Offset(4.5, 0), p);
    canvas.drawLine(c + const Offset(0, -4.5), c + const Offset(0, 4.5), p);
  }

  void _ball(Canvas canvas, Offset center, double r, Color base) {
    final gc = Offset(center.dx - r * 0.4, center.dy - r * 0.4);
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = ui.Gradient.radial(gc, r * 1.6, [Colors.white, base]),
    );
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = base,
    );
  }

  @override
  bool shouldRepaint(covariant DecayTypeIconPainter oldDelegate) =>
      oldDelegate.type != type;
}
