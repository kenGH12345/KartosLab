import '../color_vision_constants.dart';
import 'cv_photon.dart';
import 'event_timer.dart';

/// PhET `RGBPhotonBeam.js`.
class RgbPhotonBeam {
  RgbPhotonBeam({
    required this.colorHex,
    required this.getIntensity,
    required this.setPerceivedIntensity,
    required this.beamLength,
    CvRandom? random,
  }) : random = random ?? CvRandom();

  /// CSS-like color string used by the view (`#ff0000` etc.).
  final String colorHex;
  final double Function() getIntensity;
  final void Function(double) setPerceivedIntensity;
  final double beamLength;
  final CvRandom random;

  final List<RgbPhoton> photons = [];

  void updateAnimationFrame(double dt) {
    for (var i = 0; i < photons.length; i++) {
      final p = photons[i];
      final newX = p.x + dt * p.vx;
      final newY = p.y + dt * p.vy;

      if (newX > 0 &&
          newY > 0 &&
          newY < ColorVisionConstants.beamHeight) {
        p.updateAnimationFrame(newX, newY);
      } else {
        setPerceivedIntensity(p.intensity);
        photons.removeAt(i);
        i--;
      }
    }

    if (getIntensity() == 0) {
      photons.add(RgbPhoton(
        x: beamLength,
        y: ColorVisionConstants.beamHeight / 2,
        vx: ColorVisionConstants.xVelocity,
        vy: 0,
        intensity: 0,
      ));
    }
  }

  void createPhoton(double timeElapsed) {
    final intensity = getIntensity();
    if (intensity <= 0) return;

    final x = beamLength + ColorVisionConstants.xVelocity * timeElapsed;
    final yVelocity = (random.nextDouble() * ColorVisionConstants.fanFactor -
            (ColorVisionConstants.fanFactor / 2)) *
        60;
    final initialY =
        yVelocity * (25 / 60) + (ColorVisionConstants.beamHeight / 2);
    final y = initialY + yVelocity * timeElapsed;

    photons.add(RgbPhoton(
      x: x,
      y: y,
      vx: ColorVisionConstants.xVelocity,
      vy: yVelocity,
      intensity: intensity,
    ));
  }

  void reset() {
    photons.clear();
  }
}
