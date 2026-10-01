import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/vector_addition/model/enums.dart';
import 'package:kratos/vector_addition/model/va_vec.dart';
import 'package:kratos/vector_addition/snap/snap_policy.dart';

void main() {
  final bounds = VaBounds.defaultGraph;

  group('CartesianSnapPolicy', () {
    final snap = SnapPolicy(
      mode: CoordinateSnapMode.cartesian,
      orientation: GraphOrientation.twoDimensional,
      graphBounds: bounds,
    );

    test('tip snaps to integer grid inside bounds', () {
      final tip = snap.snapTip(
        tail: const VaVec(0, 0),
        proposedTip: const VaVec(3.4, 2.6),
      );
      expect(tip, const VaVec(3, 3));
    });

    test('rejects zero-magnitude tip', () {
      final tip = snap.snapTip(
        tail: const VaVec(5, 5),
        proposedTip: const VaVec(5.2, 5.2),
      );
      // rounds to (5,5) == tail → null
      expect(tip, isNull);
    });

    test('tail snaps to integer within eroded bounds', () {
      final t = snap.snapTail(
        proposedTail: const VaVec(1.6, 2.4),
        xyComponents: const VaVec(2, 0),
      );
      expect(t, const VaVec(2, 2));
    });
  });

  group('PolarSnapPolicy', () {
    final snap = SnapPolicy(
      mode: CoordinateSnapMode.polar,
      orientation: GraphOrientation.twoDimensional,
      graphBounds: bounds,
    );

    test('tip magnitude integer and angle multiple of 5°', () {
      // ~10 units at ~7° → mag 10, angle 5° or 10°
      final tip = snap.snapTip(
        tail: const VaVec(0, 0),
        proposedTip: VaVec(10 * math.cos(7 * math.pi / 180),
            10 * math.sin(7 * math.pi / 180)),
      )!;
      final xy = tip - VaVec.zero;
      expect(xy.magnitude, closeTo(10, 1e-6));
      final deg = xy.angle * 180 / math.pi;
      expect(deg % 5, closeTo(0, 1e-6));
    });

    test('tail attracts to other tip within polarSnapDistance', () {
      final otherTip = const VaVec(5, 0);
      final t = snap.snapTail(
        proposedTail: const VaVec(5.4, 0.2),
        xyComponents: const VaVec(2, 0),
        otherEndpoints: [(tail: const VaVec(0, 0), tip: otherTip)],
      );
      expect(t, otherTip);
    });
  });

  group('GraphOrientation', () {
    test('horizontal locks tip.y', () {
      final snap = SnapPolicy(
        mode: CoordinateSnapMode.cartesian,
        orientation: GraphOrientation.horizontal,
        graphBounds: bounds,
      );
      final tip = snap.snapTip(
        tail: const VaVec(0, 2),
        proposedTip: const VaVec(4, 9),
      );
      expect(tip!.y, 2);
      expect(tip.x, 4);
    });
  });
}
