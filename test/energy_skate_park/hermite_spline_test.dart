import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/energy_skate_park/solver/hermite_spline.dart';

void main() {
  group('HermiteSpline (numeric.spline natural)', () {
    test('straight line through points', () {
      final s = HermiteSpline.fit([0, 1, 2], [0, 1, 2]);
      expect(s.at(0), closeTo(0, 1e-10));
      expect(s.at(1), closeTo(1, 1e-10));
      expect(s.at(2), closeTo(2, 1e-10));
      expect(s.at(1.5), closeTo(1.5, 1e-9));
      for (final k in s.kl) {
        expect(k, closeTo(1, 1e-9));
      }
    });

    test('parabola-like through (0,0),(0.5,1),(1,0)', () {
      final s = HermiteSpline.fit([0, 0.5, 1], [0, 1, 0]);
      expect(s.at(0), closeTo(0, 1e-12));
      expect(s.at(0.5), closeTo(1, 1e-12));
      expect(s.at(1), closeTo(0, 1e-12));
      expect(s.at(0.25), closeTo(0.6875, 1e-12));
      expect(s.kl[0], closeTo(3, 1e-12));
      expect(s.kl[1], closeTo(0, 1e-12));
      expect(s.kl[2], closeTo(-3, 1e-12));
    });

    test('evaluate endpoints', () {
      final s = HermiteSpline.fit([-4, 0, 4], [6, 0, 6]);
      expect(s.at(-4), closeTo(6, 1e-10));
      expect(s.at(4), closeTo(6, 1e-10));
      expect(s.at(0), closeTo(0, 1e-10));
    });

    test('derivative consistency at midpoint of hill', () {
      final s = HermiteSpline.fit([0, 0.5, 1], [0, 1, 0]);
      final d = s.diff();
      expect(d.at(0.5), closeTo(0, 1e-9));
      // Left side rising, right side falling.
      expect(d.at(0.25), greaterThan(0));
      expect(d.at(0.75), lessThan(0));
    });
  });
}