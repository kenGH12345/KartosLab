import 'package:flutter/material.dart';
import '../model/wave_engine.dart';

/// Wave visualization type.
enum WaveType {
  /// Water waves: blue heatmap (default).
  water,

  /// Light waves: visible-spectrum color mapping (ROYGBIV).
  light,

  /// Sound waves: grayscale pressure visualization.
  sound,
}

/// Paints the 2D wave field as a color heatmap.
///
/// Supports three visualization modes:
/// - Water: blue palette (trough=dark blue, crest=light blue/white)
/// - Light: visible spectrum mapping (amplitude → wavelength → color)
/// - Sound: grayscale (compression=white, rarefaction=black)
class WaveHeatmapPainter extends CustomPainter {
  final WaveEngine engine;
  final int gridW;
  final int gridH;
  final WaveType waveType;

  WaveHeatmapPainter(
    this.engine, {
    this.gridW = 80,
    this.gridH = 55,
    this.waveType = WaveType.water,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / gridW;
    final cellH = size.height / gridH;

    for (int i = 0; i < gridW && i < engine.width; i++) {
      for (int j = 0; j < gridH && j < engine.height; j++) {
        double val = engine.current[i][j];
        Color color;
        switch (waveType) {
          case WaveType.water:
            color = _waterColor(val);
          case WaveType.light:
            color = _lightColor(val);
          case WaveType.sound:
            color = _soundColor(val);
        }
        final paint = Paint()..color = color;
        canvas.drawRect(
          Rect.fromLTWH(i * cellW, j * cellH, cellW + 0.5, cellH + 0.5),
          paint,
        );
      }
    }
  }

  /// Water wave: blue heatmap palette.
  Color _waterColor(double v) {
    double t = (v / 2.0).clamp(-1.0, 1.0);
    if (t < 0) {
      double f = -t;
      return Color.fromARGB(255,
        (51 * (1 - f)).round(),
        (128 * (1 - f)).round(),
        (204 * (1 - f) + 40 * f).round(),
      );
    } else {
      double f = t;
      return Color.fromARGB(255,
        (51 + (204 * f)).round(),
        (128 + (127 * f)).round(),
        (204 + (51 * f)).round(),
      );
    }
  }

  /// Light wave: visible-spectrum mapping.
  /// Positive crest → red/orange, near zero → green, negative trough → blue/violet.
  Color _lightColor(double v) {
    double t = (v / 2.0).clamp(-1.0, 1.0);
    // Map [-1, 1] to visible spectrum (violet→red)
    // t=-1 → violet (380nm), t=0 → green (530nm), t=1 → red (700nm)
    double wavelength = 530 - t * 170; // 360-700 nm range
    return _wavelengthToColor(wavelength);
  }

  /// Sound wave: grayscale pressure.
  /// Positive (compression) → white, zero → mid-gray, negative (rarefaction) → black.
  Color _soundColor(double v) {
    double t = ((v / 2.0).clamp(-1.0, 1.0) + 1.0) / 2.0; // [0, 1]
    int gray = (t * 255).round();
    return Color.fromARGB(255, gray, gray, gray);
  }

  /// Convert wavelength (nm) to RGB color using piecewise linear approximation.
  Color _wavelengthToColor(double wl) {
    double r = 0, g = 0, b = 0;
    if (wl >= 380 && wl < 440) {
      r = -(wl - 440) / (440 - 380);
      b = 1;
    } else if (wl >= 440 && wl < 490) {
      g = (wl - 440) / (490 - 440);
      b = 1;
    } else if (wl >= 490 && wl < 510) {
      g = 1;
      b = -(wl - 510) / (510 - 490);
    } else if (wl >= 510 && wl < 580) {
      r = (wl - 510) / (580 - 510);
      g = 1;
    } else if (wl >= 580 && wl < 645) {
      r = 1;
      g = -(wl - 645) / (645 - 580);
    } else if (wl >= 645 && wl <= 780) {
      r = 1;
    }
    // Intensity fall-off near edges
    double factor = 1.0;
    if (wl > 700) {
      factor = 0.3 + 0.7 * (780 - wl) / 80;
    } else if (wl < 420) {
      factor = 0.3 + 0.7 * (wl - 380) / 40;
    }
    return Color.fromARGB(255,
      ((r * factor * 255).round()).clamp(0, 255),
      ((g * factor * 255).round()).clamp(0, 255),
      ((b * factor * 255).round()).clamp(0, 255),
    );
  }

  @override
  bool shouldRepaint(covariant WaveHeatmapPainter old) => true;
}