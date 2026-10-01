import 'dart:ui';

import '../color_vision_constants.dart';
import 'color_vision_model_base.dart';
import 'event_timer.dart';
import 'single_bulb_photon_beam.dart';
import 'visible_color.dart';

/// PhET `SingleBulbModel.js`.
class SingleBulbModel extends ColorVisionModelBase {
  SingleBulbModel({CvRandom? random}) : _random = random ?? CvRandom() {
    photonBeam = SingleBulbPhotonBeam(
      beamLength: ColorVisionConstants.singleBeamLength,
      getFlashlightOn: () => flashlightOn,
      getFilterVisible: () => filterVisible,
      getFilterWavelength: () => filterWavelength,
      getFlashlightWavelength: () => flashlightWavelength,
      getLightType: () => lightType,
      getBeamType: () => beamType,
      getLastPhotonColor: () => lastPhotonColor,
      setLastPhotonColor: (c) => lastPhotonColor = c,
      random: _random,
    );
    _eventTimer = EventTimer(
      getPeriodBeforeNextEvent: () =>
          1 / ColorVisionConstants.singleBulbPhotonRate,
      onEvent: photonBeam.createPhoton,
    );
  }

  final CvRandom _random;

  LightType lightType = LightType.colored;
  BeamType beamType = BeamType.beam;
  double flashlightWavelength = ColorVisionConstants.defaultWavelength;
  double filterWavelength = ColorVisionConstants.defaultWavelength;
  bool flashlightOn = false;
  bool filterVisible = false;
  Color lastPhotonColor = const Color(0x00000000);

  late final SingleBulbPhotonBeam photonBeam;
  late final EventTimer _eventTimer;

  @override
  Color get perceivedColor {
    if (beamType == BeamType.photon) {
      return lastPhotonColor;
    }
    if (!flashlightOn) {
      return const Color(0xFF000000);
    }
    if (filterVisible && lightType == LightType.colored) {
      final halfWidth = ColorVisionConstants.gaussianWidth / 2;
      late final double alpha;
      if (flashlightWavelength < filterWavelength - halfWidth ||
          flashlightWavelength > filterWavelength + halfWidth) {
        alpha = 0;
      } else {
        alpha = 1 -
            (filterWavelength - flashlightWavelength).abs() / halfWidth;
      }
      return VisibleColor.wavelengthToColor(flashlightWavelength)
          .withValues(alpha: alpha);
    }
    if (filterVisible && lightType == LightType.white) {
      return VisibleColor.wavelengthToColor(filterWavelength);
    }
    if (!filterVisible && lightType == LightType.white) {
      return const Color(0xFFFFFFFF);
    }
    return VisibleColor.wavelengthToColor(flashlightWavelength);
  }

  void setFlashlightWavelength(double nm) {
    flashlightWavelength = nm.clamp(
      ColorVisionConstants.minWavelength,
      ColorVisionConstants.maxWavelength,
    );
    notifyListeners();
  }

  void setFilterWavelength(double nm) {
    filterWavelength = nm.clamp(
      ColorVisionConstants.minWavelength,
      ColorVisionConstants.maxWavelength,
    );
    notifyListeners();
  }

  void setLightType(LightType type) {
    if (lightType == type) return;
    lightType = type;
    notifyListeners();
  }

  void setBeamType(BeamType type) {
    if (beamType == type) return;
    beamType = type;
    notifyListeners();
  }

  void setFlashlightOn(bool value) {
    if (flashlightOn == value) return;
    flashlightOn = value;
    notifyListeners();
  }

  void setFilterVisible(bool value) {
    if (filterVisible == value) return;
    filterVisible = value;
    notifyListeners();
  }

  @override
  void step(double dt) {
    dt = dt < ColorVisionConstants.maxDt ? dt : ColorVisionConstants.maxDt;
    if (!playing) return;
    photonBeam.updateAnimationFrame(dt);
    _eventTimer.step(dt);
    notifyListeners();
  }

  @override
  void manualStep() {
    photonBeam.updateAnimationFrame(ColorVisionConstants.manualStepDt);
    _eventTimer.step(ColorVisionConstants.manualStepDt);
    notifyListeners();
  }

  @override
  void reset() {
    resetBase();
    lightType = LightType.colored;
    beamType = BeamType.beam;
    flashlightWavelength = ColorVisionConstants.defaultWavelength;
    filterWavelength = ColorVisionConstants.defaultWavelength;
    flashlightOn = false;
    filterVisible = false;
    lastPhotonColor = const Color(0x00000000);
    photonBeam.reset();
    notifyListeners();
  }
}
