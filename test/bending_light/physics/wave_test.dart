import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/bending_light_constants.dart';
import 'package:kratos/bending_light/model/bl_vec2.dart';
import 'package:kratos/bending_light/model/enums.dart';
import 'package:kratos/bending_light/model/light_ray.dart';
import 'package:kratos/bending_light/physics/wave_math.dart';

void main() {
  group('Wave model', () {
    test('t=0 cos arg', () {
      final arg = WaveMath.cosArg(
        wavelengthInMedium: 650e-9,
        indexOfRefraction: 1.0,
        distanceAlongRay: 0,
        time: 0,
        numWavelengthsPhaseOffset: 0,
      );
      expect(arg, closeTo(0, 1e-12));
      expect(math.cos(arg), closeTo(1, 1e-12));
    });

    test('t>0 shifts phase', () {
      final a0 = WaveMath.cosArg(
        wavelengthInMedium: 650e-9,
        indexOfRefraction: 1.0,
        distanceAlongRay: 0,
        time: 0,
        numWavelengthsPhaseOffset: 0,
      );
      final a1 = WaveMath.cosArg(
        wavelengthInMedium: 650e-9,
        indexOfRefraction: 1.0,
        distanceAlongRay: 0,
        time: 1e-16,
        numWavelengthsPhaseOffset: 0,
      );
      expect(a1, isNot(closeTo(a0, 0)));
    });

    test('LightRay.getCosArg matches WaveMath', () {
      final ray = LightRay(
        trapeziumWidth: 1e-6,
        tail: BlVec2.zero,
        tip: const BlVec2(1e-6, 0),
        indexOfRefraction: 1.33,
        wavelength: 650e-9 / 1.33,
        wavelengthInVacuum: 650,
        powerFraction: 1,
        colorArgb: 0xFFFF0000,
        waveWidth: 1e-6,
        numWavelengthsPhaseOffset: 0.5,
        extend: true,
        extendBackwards: false,
        laserView: LaserViewEnum.wave,
        rayType: 'incident',
      );
      ray.setTime(1e-16);
      final fromRay = ray.getCosArg(1e-7);
      final fromMath = WaveMath.cosArg(
        wavelengthInMedium: ray.wavelength,
        indexOfRefraction: ray.indexOfRefraction,
        distanceAlongRay: 1e-7,
        time: 1e-16,
        numWavelengthsPhaseOffset: 0.5,
      );
      expect(fromRay, closeTo(fromMath, 1e-9));
    });

    test('wave magnitude uses √power · cos(phase+π)', () {
      final m = WaveMath.waveMagnitude(powerFraction: 1.0, cosArgument: 0);
      expect(m, closeTo(-1.0, 1e-12));
    });

    test('dt NORMAL vs SLOW', () {
      expect(WaveMath.dtForSpeed(normal: true), 1e-16);
      expect(WaveMath.dtForSpeed(normal: false), 0.5e-16);
    });

    test('medium slows wave (v=c/n)', () {
      final ray = LightRay(
        trapeziumWidth: 1e-6,
        tail: BlVec2.zero,
        tip: const BlVec2(1e-6, 0),
        indexOfRefraction: 1.5,
        wavelength: 650e-9 / 1.5,
        wavelengthInVacuum: 650,
        powerFraction: 1,
        colorArgb: 0xFFFF0000,
        waveWidth: 1e-6,
        numWavelengthsPhaseOffset: 0,
        extend: true,
        extendBackwards: false,
        laserView: LaserViewEnum.ray,
        rayType: 'transmitted',
      );
      expect(
        ray.getSpeed(),
        closeTo(BendingLightConstants.speedOfLight / 1.5, 1e-3),
      );
    });
  });
}
