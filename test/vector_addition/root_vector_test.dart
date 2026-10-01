import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/vector_addition/model/enums.dart';
import 'package:kratos/vector_addition/model/root_vector.dart';
import 'package:kratos/vector_addition/model/va_vec.dart';

void main() {
  group('RootVector canonical state', () {
    test('tip / magnitude / angle are derived from tail + xy', () {
      final v = RootVector(
        tailPosition: const VaVec(2, 3),
        xyComponents: const VaVec(4, 0),
      );
      expect(v.tip, const VaVec(6, 3));
      expect(v.magnitude, 4);
      expect(v.angle, closeTo(0, 1e-9));
    });

    test('setTip keeps tail and updates xy', () {
      final v = RootVector(
        tailPosition: const VaVec(1, 1),
        xyComponents: const VaVec(2, 0),
      );
      v.setTip(const VaVec(1, 5));
      expect(v.tailPosition, const VaVec(1, 1));
      expect(v.xyComponents, const VaVec(0, 4));
      expect(v.tip, const VaVec(1, 5));
    });

    test('setTail keeps tip and updates xy', () {
      final v = RootVector(
        tailPosition: const VaVec(0, 0),
        xyComponents: const VaVec(3, 4),
      );
      v.setTail(const VaVec(1, 1));
      expect(v.tip, const VaVec(3, 4));
      expect(v.xyComponents.x, closeTo(2, 1e-9));
      expect(v.xyComponents.y, closeTo(3, 1e-9));
    });

    test('zero magnitude angle is null', () {
      final v = RootVector(
        tailPosition: VaVec.zero,
        xyComponents: VaVec.zero,
      );
      expect(v.angle, isNull);
      expect(v.getAngleDegrees(AngleConvention.signed), isNull);
    });
  });
}
