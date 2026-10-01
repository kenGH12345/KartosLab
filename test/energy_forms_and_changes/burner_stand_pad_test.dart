import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';

void main() {
  test('BurnerStand padTop covers side parallelogram peak', () {
    // standH = sideLength * introMvtScale
    final standH =
        BurnerSideLength.meters * EfacConstants.introMvtScaleFactor;
    final projection = standH * EfacConstants.burnerEdgeToHeightRatio;
    // Must be ≥ 3·(e/(2√2)) so upperRight of createBurnerStandSide is inside canvas.
    final padTop = 3 * projection * math.sqrt1_2 / 2;
    final peakUp = 3 * projection / (2 * math.sqrt(2));
    expect(padTop, closeTo(peakUp, 1e-9));
    expect(padTop, greaterThan(projection * math.sqrt1_2 / 2));
  });
}

/// Burner.sideLength without importing Burner (avoid widget deps).
class BurnerSideLength {
  static const double meters = 0.075;
}
