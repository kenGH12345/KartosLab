import 'dart:ui';
import '../solver/photon_beam.dart';

/// Mutable state for the color-vision simulation.
///
/// Holds simulation data that changes each tick.
/// Owned by the screen's StatefulWidget.
class ColorVisionState {
  final List<PhotonBeam> beams;
  double redIntensity;
  double greenIntensity;
  double blueIntensity;
  double personPosition;

  ColorVisionState({
    required this.beams,
    this.redIntensity = 100,
    this.greenIntensity = 100,
    this.blueIntensity = 100,
    this.personPosition = 300,
  });

  /// Mixed color at the overlap zone (additive RGB).
  Color get mixedColor {
    int r = (redIntensity / 100 * 255).clamp(0, 255).round();
    int g = (greenIntensity / 100 * 255).clamp(0, 255).round();
    int b = (blueIntensity / 100 * 255).clamp(0, 255).round();
    return Color.fromARGB(255, r, g, b);
  }

  void stepInTime(double dt) {
    for (final b in beams) {
      b.stepInTime(dt);
    }
  }

  void updateIntensity(int channel, double value) {
    switch (channel) {
      case 0: redIntensity = value; break;
      case 1: greenIntensity = value; break;
      case 2: blueIntensity = value; break;
    }
    if (channel < beams.length) {
      beams[channel].setIntensity(value);
    }
  }

  void dispose() {
    for (final b in beams) {
      b.clear();
    }
  }
}
