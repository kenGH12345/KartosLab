import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../bending_light_constants.dart';
import '../physics/fresnel.dart';
import '../physics/intro_snell.dart';
import '../physics/sensor_intersection.dart';
import '../physics/wave_math.dart';
import 'bending_light_model.dart';
import 'bl_vec2.dart';
import 'enums.dart';
import 'intensity_meter.dart';
import 'laser_color.dart';
import 'light_ray.dart';
import 'reading.dart';
import 'substance.dart';

/// Intro / shared dual-medium model (`IntroModel.ts`).
class IntroModel extends BendingLightModel {
  IntroModel({
    required Substance bottomSubstance,
    required this.horizontalPlayAreaOffset,
  }) : super(
          laserAngle: math.pi * 3 / 4,
          topLeftQuadrant: true,
          laserDistanceFromPivot:
              BendingLightConstants.defaultLaserDistanceFromPivot,
        ) {
    topMedium = Medium(
      substance: Substance.air,
      colorArgb: mediumColorFactory
          .getColor(Substance.air.indexOfRefractionForRedLight),
    );
    bottomMedium = Medium(
      substance: bottomSubstance,
      colorArgb: mediumColorFactory
          .getColor(bottomSubstance.indexOfRefractionForRedLight),
    );
    _initialTop = topMedium;
    _initialBottom = bottomMedium;

    intensityMeter = IntensityMeter(
      sensorX: -modelWidth * (horizontalPlayAreaOffset ? 0.34 : 0.48),
      sensorY: -modelHeight * 0.285,
      bodyX: -modelWidth * (horizontalPlayAreaOffset ? 0.282 : 0.421),
      bodyY: -modelHeight * 0.312,
    );
    // Subclasses (MoreTools) finish sensor init before first updateModel.
  }

  final bool horizontalPlayAreaOffset;
  late Medium topMedium;
  late Medium bottomMedium;
  late Medium _initialTop;
  late Medium _initialBottom;
  late final IntensityMeter intensityMeter;
  double time = 0;

  /// Time-only frames. Wave painters listen here so a tick does not rebuild controls.
  final ValueNotifier<int> waveFrame = ValueNotifier(0);

  double get indexOfRefractionOfTopMedium =>
      topMedium.getIndexOfRefraction(laser.getWavelength());

  double get indexOfRefractionOfBottomMedium =>
      bottomMedium.getIndexOfRefraction(laser.getWavelength());

  void setTopSubstance(Substance s) {
    topMedium = Medium(
      substance: s,
      colorArgb: mediumColorFactory.getColor(s.indexOfRefractionForRedLight),
    );
    updateModel();
  }

  void setBottomSubstance(Substance s) {
    bottomMedium = Medium(
      substance: s,
      colorArgb: mediumColorFactory.getColor(s.indexOfRefractionForRedLight),
    );
    updateModel();
  }

  void setCustomIndex({required bool top, required double indexForRed}) {
    final s = Substance.customWith(indexForRed);
    if (top) {
      setTopSubstance(s);
    } else {
      setBottomSubstance(s);
    }
  }

  @override
  void updateModel() {
    intensityMeter.clearRayReadings();
    super.updateModel();
  }

  @override
  void propagateRays() {
    if (!laser.on) return;

    final tail = laser.emissionPoint;
    final n1 = indexOfRefractionOfTopMedium;
    final n2 = indexOfRefractionOfBottomMedium;
    final snell = IntroSnell.compute(
      n1: n1,
      n2: n2,
      laserAngle: laser.getAngle(),
    );

    const sourcePower = 1.0;
    final a = BendingLightConstants.characteristicLength * 4;
    final sourceWaveWidth = a / 2;
    final colorArgb = wavelengthToArgb(laser.getWavelength());
    final wavelengthInTopMedium = laser.color.wavelength / n1;
    final trapeziumWidth =
        (sourceWaveWidth / math.sin(laser.getAngle())).abs();
    final vacuumNm = laser.getWavelength() * 1e9;

    final incidentRay = LightRay(
      trapeziumWidth: trapeziumWidth,
      tail: tail,
      tip: BlVec2.zero,
      indexOfRefraction: n1,
      wavelength: wavelengthInTopMedium,
      wavelengthInVacuum: vacuumNm,
      powerFraction: sourcePower,
      colorArgb: colorArgb,
      waveWidth: sourceWaveWidth,
      numWavelengthsPhaseOffset: 0,
      extend: true,
      extendBackwards: false,
      laserView: laserView,
      rayType: 'incident',
    );

    final rayAbsorbed = _addAndAbsorb(incidentRay, 'incident');
    if (rayAbsorbed) return;

    var reflectedPowerRatio = snell.reflectedPowerRatio;
    var hasTransmittedRay = snell.hasTransmittedRay;

    // Recompute powers with exact IntroModel branching for Fresnel when TIR
    final theta1 = snell.theta1;
    final theta2 = snell.theta2;
    final thetaTir = snell.thetaCritical;
    hasTransmittedRay =
        thetaTir.isNaN || theta1 < thetaTir;
    if (hasTransmittedRay) {
      reflectedPowerRatio = Fresnel.getReflectedPower(
        n1,
        n2,
        math.cos(theta1),
        math.cos(theta2),
      );
    } else {
      reflectedPowerRatio = 1.0;
    }
    if (reflectedPowerRatio == 1.0) {
      hasTransmittedRay = false;
    }

    final showReflected = reflectedPowerRatio >= 0.005;
    if (showReflected) {
      final reflectedRay = LightRay(
        trapeziumWidth: trapeziumWidth,
        tail: BlVec2.zero,
        tip: BlVec2.polar(
          BendingLightConstants.beamLength,
          math.pi - laser.getAngle(),
        ),
        indexOfRefraction: n1,
        wavelength: wavelengthInTopMedium,
        wavelengthInVacuum: vacuumNm,
        powerFraction: reflectedPowerRatio * sourcePower,
        colorArgb: colorArgb,
        waveWidth: sourceWaveWidth,
        numWavelengthsPhaseOffset: incidentRay.getNumberOfWavelengths(),
        extend: true,
        extendBackwards: true,
        laserView: laserView,
        rayType: 'reflected',
      );
      _addAndAbsorb(reflectedRay, 'reflected');
    } else {
      reflectedPowerRatio = 0;
    }

    if (hasTransmittedRay && !theta2.isNaN && theta2.isFinite) {
      final transmittedWavelength = incidentRay.wavelength / n2 * n1;
      var transmittedPowerRatio = Fresnel.getTransmittedPower(
        n1,
        n2,
        math.cos(theta1),
        math.cos(theta2),
      );
      if (!showReflected) {
        transmittedPowerRatio = 1;
      }
      final beamHalfWidth = a / 2;
      final extentInterceptedHalfWidth =
          beamHalfWidth / math.sin(math.pi / 2 - theta1) / 2;
      final transmittedBeamHalfWidth =
          math.cos(theta2) * extentInterceptedHalfWidth;
      final transmittedWaveWidth = transmittedBeamHalfWidth * 2;

      final transmittedRay = LightRay(
        trapeziumWidth: trapeziumWidth,
        tail: BlVec2.zero,
        tip: BlVec2.polar(
          BendingLightConstants.beamLength,
          theta2 - math.pi / 2,
        ),
        indexOfRefraction: n2,
        wavelength: transmittedWavelength,
        wavelengthInVacuum: vacuumNm,
        powerFraction: transmittedPowerRatio * sourcePower,
        colorArgb: colorArgb,
        waveWidth: transmittedWaveWidth,
        numWavelengthsPhaseOffset: incidentRay.getNumberOfWavelengths(),
        extend: true,
        extendBackwards: true,
        laserView: laserView,
        rayType: 'transmitted',
      );
      _addAndAbsorb(transmittedRay, 'transmitted');
    }
  }

  bool _addAndAbsorb(LightRay ray, String rayType) {
    final angleOffset = rayType == 'incident' ? math.pi : 0.0;
    final hits = intensityMeter.enabled
        ? rayCircleHits(
            origin: rayType == 'incident' ? ray.tip : ray.tail,
            directionAngle: ray.getAngle() + angleOffset,
            center: intensityMeter.sensorPosition,
            radius: IntensityMeter.sensorRadius,
          )
        : const <BlVec2>[];
    final sample = sensorSamplePoint(hits);

    var rayAbsorbed = sample != null;
    if (rayAbsorbed) {
      final distance = sample.magnitude;
      final interrupted = LightRay(
        trapeziumWidth: ray.trapeziumWidth,
        tail: ray.tail,
        tip: BlVec2.polar(distance, ray.getAngle() + angleOffset),
        indexOfRefraction: ray.indexOfRefraction,
        wavelength: ray.wavelength,
        wavelengthInVacuum: ray.wavelengthInVacuum,
        powerFraction: ray.powerFraction,
        colorArgb: ray.colorArgb,
        waveWidth: ray.waveWidth,
        numWavelengthsPhaseOffset: ray.numWavelengthsPhaseOffset,
        extend: false,
        extendBackwards: ray.extendBackwards,
        laserView: laserView,
        rayType: rayType,
      );
      final isForward = ray.toVector().dot(interrupted.toVector()) > 0;
      if (interrupted.getLength() < ray.getLength() && isForward) {
        addRay(interrupted);
      } else {
        addRay(ray);
        rayAbsorbed = false;
      }
    } else {
      addRay(ray);
    }

    if (rayAbsorbed) {
      intensityMeter.addRayReading(Reading(ray.powerFraction));
    } else {
      intensityMeter.addRayReading(Reading.miss);
    }
    return rayAbsorbed;
  }

  BlVec2 getVelocity(BlVec2 position) {
    for (final ray in rays) {
      if (ray.contains(position, waveMode: laserView == LaserViewEnum.wave)) {
        return ray.getVelocityVector();
      }
    }
    return BlVec2.zero;
  }

  ({double time, double magnitude})? getWaveValue(BlVec2 position) {
    for (final ray in rays) {
      if (ray.contains(position, waveMode: laserView == LaserViewEnum.wave)) {
        final u = ray.getUnitVector();
        final dx = position.x - ray.tail.x;
        final dy = position.y - ray.tail.y;
        final distanceAlongRay = u.x * dx + u.y * dy;
        final phase = ray.getCosArg(distanceAlongRay);
        return (
          time: ray.time,
          magnitude: WaveMath.waveMagnitude(
            powerFraction: ray.powerFraction,
            cosArgument: phase,
          ),
        );
      }
    }
    return null;
  }

  void togglePlaying() {
    isPlaying = !isPlaying;
    notifyListeners();
  }

  void setSpeed(TimeSpeed value) {
    speed = value;
    notifyListeners();
  }

  /// One clock tick. [step] only advances while playing; this always advances.
  void stepOnce() => updateSimulationTimeAndWaveShape(speed);

  void step() {
    if (isPlaying) {
      updateSimulationTimeAndWaveShape(speed);
    }
  }

  void updateSimulationTimeAndWaveShape(TimeSpeed spd) {
    time += WaveMath.dtForSpeed(normal: spd == TimeSpeed.normal);
    for (final ray in rays) {
      ray.setTime(time);
    }
    afterTimeStep();
  }

  /// Hook for sensors that sample after the clock moves. Does not rebuild controls.
  void afterTimeStep() {
    waveFrame.value = waveFrame.value + 1;
  }

  @override
  void dispose() {
    waveFrame.dispose();
    super.dispose();
  }

  @override
  void reset() {
    super.reset();
    topMedium = _initialTop;
    bottomMedium = _initialBottom;
    intensityMeter.reset();
    time = 0;
    updateModel();
  }

  /// Expose IntroSnell for tests without full propagate.
  IntroSnellResult computeSnell() => IntroSnell.compute(
        n1: indexOfRefractionOfTopMedium,
        n2: indexOfRefractionOfBottomMedium,
        laserAngle: laser.getAngle(),
      );
}
