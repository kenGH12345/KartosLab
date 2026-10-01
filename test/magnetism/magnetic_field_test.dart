import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/magnetism/magnet_and_compass/model/magnetic_field.dart';

void main() {
  const magnet = Offset.zero;
  const halfLen = 250.0;
  const strength = 0.75;

  Offset b({
    required Offset p,
    Offset magnetPos = magnet,
    double angle = 0,
    double s = strength,
    bool flipped = false,
    bool earthField = false,
  }) =>
      MagneticField.compute(p, magnetPos, angle, halfLen, s, flipped, earthField);

  group('MagneticField.compute dipole', () {
    test('far-field |B| falls with distance; strength scales linearly', () {
      final near = b(p: const Offset(2000, 0));
      final far = b(p: const Offset(4000, 0));
      final magNear = MagneticField.magnitude(near);
      final magFar = MagneticField.magnitude(far);

      expect(magNear, greaterThan(0));
      expect(magFar, greaterThan(0));
      expect(magNear, greaterThan(magFar));

      // Point-dipole far-field |B| ∝ 1/r³. r doubles → ratio ≈ 8.
      expect(magNear / magFar, closeTo(8.0, 1.5));

      final half = b(p: const Offset(2000, 0), s: strength / 2);
      expect(
        MagneticField.magnitude(half) / magNear,
        closeTo(0.5, 1e-9),
      );
    });

    test('flipped polarity reverses B', () {
      const p = Offset(800, 40);
      final n = b(p: p);
      final f = b(p: p, flipped: true);
      expect(f.dx, closeTo(-n.dx, 1e-9));
      expect(f.dy, closeTo(-n.dy, 1e-9));
    });

    test('magnet angle and position move the field', () {
      const p = Offset(600, 0);
      final alongX = b(p: p);
      final rotated = b(p: p, angle: pi / 2);
      expect(alongX.dx.abs(), greaterThan(alongX.dy.abs()));
      expect(rotated.dy.abs(), greaterThan(rotated.dx.abs()));

      const shift = Offset(100, 50);
      final atOrigin = b(p: const Offset(700, 80));
      final translated = b(
        p: const Offset(700, 80) + shift,
        magnetPos: shift,
      );
      expect(translated.dx, closeTo(atOrigin.dx, 1e-9));
      expect(translated.dy, closeTo(atOrigin.dy, 1e-9));
    });
  });

  group('MagneticField.compute earthField', () {
    test('ignores magnet angle; unflipped B on vertical axis is vertical', () {
      const p = Offset(0, -800);
      final a0 = b(p: p, earthField: true, angle: 0);
      final a90 = b(p: p, earthField: true, angle: pi / 2);
      expect(a0.dx, closeTo(a90.dx, 1e-9));
      expect(a0.dy, closeTo(a90.dy, 1e-9));

      expect(a0.dx.abs(), lessThan(a0.dy.abs()));
      expect(a0.dy, isNegative);

      final flipped = b(p: p, earthField: true, flipped: true);
      expect(flipped.dx, closeTo(-a0.dx, 1e-9));
      expect(flipped.dy, closeTo(-a0.dy, 1e-9));
    });
  });

  group('MagneticField helpers and edges', () {
    test('sample at a pole is finite; magnitude and fieldAngle match B', () {
      final pole = Offset(halfLen, 0);
      final atPole = b(p: pole);
      expect(atPole.dx.isFinite, isTrue);
      expect(atPole.dy.isFinite, isTrue);

      final mag = MagneticField.magnitude(atPole);
      expect(mag, closeTo(sqrt(atPole.dx * atPole.dx + atPole.dy * atPole.dy), 1e-9));
      expect(MagneticField.fieldAngle(atPole), closeTo(atan2(atPole.dy, atPole.dx), 1e-12));

      for (final sample in [
        const Offset(0, 0),
        const Offset(400, 0),
        const Offset(0, 400),
        const Offset(-300, 200),
      ]) {
        final v = b(p: sample);
        expect(v.dx.isFinite, isTrue, reason: '$sample');
        expect(v.dy.isFinite, isTrue, reason: '$sample');
      }
    });
  });
}
