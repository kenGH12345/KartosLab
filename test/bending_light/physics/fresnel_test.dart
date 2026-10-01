import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/physics/fresnel.dart';

void main() {
  group('Fresnel s-polarized', () {
    test('normal incidence R+T approx 1 (air to glass)', () {
      const n1 = 1.000293;
      const n2 = 1.5;
      const cos1 = 1.0;
      const cos2 = 1.0;
      final r = Fresnel.getReflectedPower(n1, n2, cos1, cos2);
      final t = Fresnel.getTransmittedPower(n1, n2, cos1, cos2);
      expect(r, greaterThanOrEqualTo(0));
      expect(t, greaterThanOrEqualTo(0));
      expect(r, lessThanOrEqualTo(1));
      expect(t, lessThanOrEqualTo(1));
      expect(r + t, closeTo(1.0, 1e-9));
    });

    test('low angle still conserves power', () {
      const n1 = 1.0;
      const n2 = 1.33;
      final theta1 = 10 * math.pi / 180;
      final theta2 = math.asin(n1 / n2 * math.sin(theta1));
      final r = Fresnel.getReflectedPower(
          n1, n2, math.cos(theta1), math.cos(theta2));
      final t = Fresnel.getTransmittedPower(
          n1, n2, math.cos(theta1), math.cos(theta2));
      expect(r + t, closeTo(1.0, 1e-9));
    });

    test('high angle air to glass', () {
      const n1 = 1.0;
      const n2 = 1.5;
      final theta1 = 60 * math.pi / 180;
      final theta2 = math.asin(n1 / n2 * math.sin(theta1));
      final r = Fresnel.getReflectedPower(
          n1, n2, math.cos(theta1), math.cos(theta2));
      final t = Fresnel.getTransmittedPower(
          n1, n2, math.cos(theta1), math.cos(theta2));
      expect(r + t, closeTo(1.0, 1e-9));
      expect(r, greaterThan(0));
    });

    test('clamp01', () {
      expect(Fresnel.clamp01(1.2), 1.0);
      expect(Fresnel.clamp01(-0.1), 0.0);
    });

    test('n1 equals n2 implies R approx 0', () {
      final r = Fresnel.getReflectedPower(1.5, 1.5, 0.8, 0.8);
      expect(r, closeTo(0.0, 1e-12));
    });
  });
}
