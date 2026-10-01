import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/physics/intro_snell.dart';

void main() {
  group('Intro scalar Snell', () {
    const laserAngle45 = 3 * math.pi / 4;

    test('normal incidence theta1=0', () {
      final r = IntroSnell.compute(n1: 1.0, n2: 1.33, laserAngle: math.pi / 2);
      expect(r.theta1, closeTo(0, 1e-12));
      expect(r.theta2, closeTo(0, 1e-12));
      expect(r.hasTransmittedRay, isTrue);
    });

    test('n1 equals n2', () {
      final r = IntroSnell.compute(n1: 1.5, n2: 1.5, laserAngle: laserAngle45);
      expect(r.theta2, closeTo(r.theta1, 1e-12));
      expect(r.hasReflectedRay, isFalse);
      expect(r.hasTransmittedRay, isTrue);
      expect(r.transmittedPowerRatio, closeTo(1.0, 1e-9));
    });

    test('air to water Snell consistency', () {
      const n1 = 1.000293;
      const n2 = 1.333;
      final r = IntroSnell.compute(n1: n1, n2: n2, laserAngle: laserAngle45);
      expect(n1 * math.sin(r.theta1), closeTo(n2 * math.sin(r.theta2), 1e-9));
      expect(r.hasTransmittedRay, isTrue);
    });

    test('air to glass', () {
      final r = IntroSnell.compute(n1: 1.0, n2: 1.5, laserAngle: laserAngle45);
      expect(math.sin(r.theta2), closeTo(math.sin(r.theta1) / 1.5, 1e-9));
    });

    test('water to air TIR at high angle', () {
      const n1 = 1.333;
      const n2 = 1.000293;
      final critical = math.asin(n2 / n1);
      final laserAngle = math.pi / 2 + critical + 0.2;
      final r = IntroSnell.compute(n1: n1, n2: n2, laserAngle: laserAngle);
      expect(r.theta1, greaterThan(critical));
      expect(r.hasTransmittedRay, isFalse);
      expect(r.reflectedPowerRatio, closeTo(1.0, 1e-12));
      expect(r.hasReflectedRay, isTrue);
    });

    test('glass to air critical angle', () {
      const n1 = 1.5;
      const n2 = 1.0;
      final critical = math.asin(n2 / n1);
      final below = IntroSnell.compute(
        n1: n1,
        n2: n2,
        laserAngle: math.pi / 2 + critical - 0.05,
      );
      final above = IntroSnell.compute(
        n1: n1,
        n2: n2,
        laserAngle: math.pi / 2 + critical + 0.05,
      );
      expect(below.hasTransmittedRay, isTrue);
      expect(above.hasTransmittedRay, isFalse);
    });

    test('low and high angle air to water', () {
      final low = IntroSnell.compute(
        n1: 1.0,
        n2: 1.33,
        laserAngle: math.pi / 2 + 0.1,
      );
      final high = IntroSnell.compute(
        n1: 1.0,
        n2: 1.33,
        laserAngle: math.pi / 2 + 1.2,
      );
      expect(low.theta1.abs(), lessThan(high.theta1.abs()));
      expect(low.hasTransmittedRay, isTrue);
      expect(high.hasTransmittedRay, isTrue);
    });

    test('default intro laser angle gives theta1 = pi/4', () {
      final r = IntroSnell.compute(n1: 1.0, n2: 1.33, laserAngle: laserAngle45);
      expect(r.theta1, closeTo(math.pi / 4, 1e-12));
    });
  });
}
