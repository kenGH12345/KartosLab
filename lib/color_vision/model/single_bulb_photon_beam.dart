import 'dart:ui';

import '../color_vision_constants.dart';
import 'cv_photon.dart';
import 'event_timer.dart';
import 'visible_color.dart';

/// PhET `SingleBulbPhotonBeam.js`.
class SingleBulbPhotonBeam {
  SingleBulbPhotonBeam({
    required this.beamLength,
    required this.getFlashlightOn,
    required this.getFilterVisible,
    required this.getFilterWavelength,
    required this.getFlashlightWavelength,
    required this.getLightType,
    required this.getBeamType,
    required this.getLastPhotonColor,
    required this.setLastPhotonColor,
    CvRandom? random,
  }) : random = random ?? CvRandom();

  final double beamLength;
  final bool Function() getFlashlightOn;
  final bool Function() getFilterVisible;
  final double Function() getFilterWavelength;
  final double Function() getFlashlightWavelength;
  final LightType Function() getLightType;
  final BeamType Function() getBeamType;
  final Color Function() getLastPhotonColor;
  final void Function(Color) setLastPhotonColor;
  final CvRandom random;

  final List<SingleBulbPhoton> photons = [];

  /// Set from view: `filterLeftNode.centerX - PHOTON_BEAM_START`.
  double filterOffset = 140;

  static final Color _blackAlpha0 = const Color(0x00000000);

  void updateAnimationFrame(double dt) {
    var probability = 1.0;
    final filterWavelength = getFilterWavelength();

    for (var j = 0; j < photons.length; j++) {
      final photon = photons[j];
      final newX = photon.x + dt * photon.vx;
      final newY = photon.y + dt * photon.vy;

      if (getFilterVisible() && newX < filterOffset && !photon.passedFilter) {
        final halfWidth = ColorVisionConstants.gaussianWidth / 2;

        if (photon.wavelength < filterWavelength - halfWidth ||
            photon.wavelength > filterWavelength + halfWidth) {
          probability = 0;
        } else {
          if (photon.wavelength >= 0) {
            probability =
                1 - (filterWavelength - photon.wavelength).abs() / halfWidth;
          } else {
            probability = -1;
          }
        }

        probability = photon.wasWhite
            ? ColorVisionConstants.whitePhotonFilterProbability
            : probability;

        if (random.nextDouble() >= probability) {
          photons.removeAt(j);
          j--;
          continue;
        } else if (photon.isWhite) {
          photon.color = VisibleColor.wavelengthToColor(filterWavelength);
          photon.isWhite = false;
        } else {
          photon.intensity = probability >= 0
              ? (probability < ColorVisionConstants.minFilteredIntensity
                  ? ColorVisionConstants.minFilteredIntensity
                  : probability)
              : 0;
        }
      }

      if (photon.x < filterOffset) {
        photon.passedFilter = true;
      }

      if (newX > 0 &&
          newY > 0 &&
          newY < ColorVisionConstants.beamHeight) {
        photon.updateAnimationFrame(newX, newY);
      } else {
        late final Color newPerceivedColor;
        if (photon.isWhite) {
          newPerceivedColor = const Color(0xFFFFFFFF);
        } else if (photon.wasWhite) {
          newPerceivedColor = photon.color;
        } else {
          newPerceivedColor = photon.color.withValues(alpha: photon.intensity);
        }

        final last = getLastPhotonColor();
        if (!_colorsEqual(last, newPerceivedColor) &&
            getBeamType() == BeamType.photon) {
          setLastPhotonColor(
            photon.wasWhite
                ? newPerceivedColor.withValues(alpha: 1)
                : newPerceivedColor,
          );
        }

        photons.removeAt(j);
        j--;
      }
    }

    if (probability == 0 && getFilterVisible()) {
      final blackPhoton = SingleBulbPhoton(
        x: filterOffset,
        y: ColorVisionConstants.beamHeight / 2,
        vx: ColorVisionConstants.xVelocity,
        vy: 0,
        intensity: 1,
        color: _blackAlpha0,
        isWhite: false,
      )..passedFilter = true;
      photons.add(blackPhoton);
    }

    if (!getFlashlightOn()) {
      photons.add(SingleBulbPhoton(
        x: beamLength,
        y: ColorVisionConstants.beamHeight / 2,
        vx: ColorVisionConstants.xVelocity,
        vy: 0,
        intensity: 1,
        color: _blackAlpha0,
        isWhite: false,
      ));
    }
  }

  void createPhoton(double timeElapsed) {
    if (!getFlashlightOn()) return;

    final isWhite = getLightType() == LightType.white;
    final newColor = isWhite
        ? _randomVisibleColor()
        : VisibleColor.wavelengthToColor(getFlashlightWavelength());

    final x = beamLength + ColorVisionConstants.xVelocity * timeElapsed;
    final yVelocity = (random.nextDouble() * ColorVisionConstants.fanFactor -
            (ColorVisionConstants.fanFactor / 2)) *
        60;
    final initialY =
        yVelocity * (25 / 60) + (ColorVisionConstants.beamHeight / 2);
    final y = initialY + yVelocity * timeElapsed;

    photons.add(SingleBulbPhoton(
      x: x,
      y: y,
      vx: ColorVisionConstants.xVelocity,
      vy: yVelocity,
      intensity: 1,
      color: newColor,
      isWhite: isWhite,
      wavelength: getFlashlightWavelength(),
    ));
  }

  Color _randomVisibleColor() {
    final wl = random.nextIntBetween(
      ColorVisionConstants.minWavelength.toInt(),
      ColorVisionConstants.maxWavelength.toInt(),
    );
    return VisibleColor.wavelengthToColor(wl.toDouble());
  }

  void reset() {
    for (final p in photons) {
      p.x = 0;
    }
  }

  static bool _colorsEqual(Color a, Color b) =>
      a.toARGB32() == b.toARGB32();
}
