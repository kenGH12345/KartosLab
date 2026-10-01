import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/model/bl_vec2.dart';
import 'package:kratos/bending_light/physics/vector_snell.dart';

void main() {
  group('Vector Snell (Prisms)', () {
    test('normal incidence along -normal', () {
      const L = BlVec2(0, -1);
      const n = BlVec2(0, 1);
      final r = VectorSnell.compute(L: L, n: n, n1: 1.0, n2: 1.5);
      expect(r.totalInternalReflection, isFalse);
      expect(r.cosTheta1, closeTo(1.0, 1e-9));
      expect(r.reflectedPower + r.transmittedPower, closeTo(1.0, 1e-6));
      expect(r.vRefract.y, lessThan(0));
    });

    test('TIR when n1 greater than n2 at grazing', () {
      final theta = 1.2;
      final L = BlVec2(math.sin(theta), -math.cos(theta));
      const n = BlVec2(0, 1);
      final r = VectorSnell.compute(L: L, n: n, n1: 1.5, n2: 1.0);
      expect(r.totalInternalReflection, isTrue);
      expect(r.reflectedPower, 1.0);
      expect(r.transmittedPower, 0.0);
    });

    test('no NaN in refraction direction', () {
      final L = const BlVec2(0.3, -0.954).normalize();
      const n = BlVec2(0, 1);
      final r = VectorSnell.compute(L: L, n: n, n1: 1.0, n2: 1.33);
      expect(r.vRefract.x.isFinite, isTrue);
      expect(r.vRefract.y.isFinite, isTrue);
      expect(r.vReflect.x.isFinite, isTrue);
      expect(r.vRefract.magnitude, closeTo(1.0, 1e-9));
    });

    test('n1 equals n2 transmitted approx incident', () {
      final L = BlVec2(0.5, -math.sqrt(0.75)).normalize();
      const n = BlVec2(0, 1);
      final r = VectorSnell.compute(L: L, n: n, n1: 1.4, n2: 1.4);
      expect(r.vRefract.x, closeTo(L.x, 1e-6));
      expect(r.vRefract.y, closeTo(L.y, 1e-6));
      expect(r.reflectedPower, closeTo(0, 1e-9));
    });
  });
}
