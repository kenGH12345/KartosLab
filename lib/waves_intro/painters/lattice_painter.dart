import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/lattice.dart';
import '../model/scene_kind.dart';
import '../waves_intro_constants.dart';

/// Heatmap of lattice interpolated values.
///
/// Water: blue-ish; Sound: gray; Light: wavelength-colored [视觉近似].
class LatticePainter extends CustomPainter {
  LatticePainter({
    required this.lattice,
    required this.kind,
    this.wavelengthNm,
  });

  final Lattice lattice;
  final SceneKind kind;
  final double? wavelengthNm;

  @override
  void paint(Canvas canvas, Size size) {
    final visW = lattice.visibleMaxX - lattice.visibleMinX;
    final visH = lattice.visibleMaxY - lattice.visibleMinY;
    if (visW <= 0 || visH <= 0) return;

    final cellW = size.width / visW;
    final cellH = size.height / visH;
    final paint = Paint()..style = PaintingStyle.fill;

    // Subsample for performance on large lattices
    final step = math.max(1, (visW / 120).ceil());

    for (var i = lattice.visibleMinX; i < lattice.visibleMaxX; i += step) {
      for (var j = lattice.visibleMinY; j < lattice.visibleMaxY; j += step) {
        final v = lattice.getInterpolatedValue(i, j);
        paint.color = _colorForValue(v);
        final dx = (i - lattice.visibleMinX) * cellW;
        final dy = (j - lattice.visibleMinY) * cellH;
        canvas.drawRect(
          Rect.fromLTWH(dx, dy, cellW * step + 0.5, cellH * step + 0.5),
          paint,
        );
      }
    }
  }

  Color _colorForValue(double v) {
    // Normalize roughly against calibrated amplitude display range
    final t = (v / 8).clamp(-1.0, 1.0);
    switch (kind) {
      case SceneKind.water:
        final base = const Color(0xFF58C0FA);
        if (t >= 0) {
          return Color.lerp(base, Colors.white, t * 0.55)!;
        }
        return Color.lerp(base, const Color(0xFF0B4F8A), -t * 0.7)!;
      case SceneKind.sound:
        final g = (180 + t * 60).clamp(40, 240).round();
        return Color.fromARGB(255, g, g, g);
      case SceneKind.light:
        final argb = WavesIntroConstants.wavelengthToArgb(
          wavelengthNm ?? WavesIntroConstants.wavelength(
            waveSpeedValue: WavesIntroConstants.lightWaveSpeed,
            frequency: WavesIntroConstants.rangeMidpoint(
              WavesIntroConstants.lightFreqMin,
              WavesIntroConstants.lightFreqMax,
            ),
          ),
        );
        final base = Color(argb);
        if (t.abs() < 0.02) return Colors.black;
        final intensity = t.abs().clamp(0.0, 1.0);
        return Color.lerp(Colors.black, base, intensity)!;
    }
  }

  @override
  bool shouldRepaint(covariant LatticePainter oldDelegate) => true;
}
