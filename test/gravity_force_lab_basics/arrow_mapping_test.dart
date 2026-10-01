import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab_basics/solver/force_solver.dart';

void main() {
  test('arrowMappedWidth increases with force', () {
    final minF = ForceSolver.getMinForceMagnitude();
    final maxF = ForceSolver.getMaxForce();
    expect(maxF, greaterThan(minF));

    final wLow = ForceSolver.arrowMappedWidth(minF, forceMin: minF, forceMax: maxF);
    final wMid = ForceSolver.arrowMappedWidth(
      (minF + maxF) / 2,
      forceMin: minF,
      forceMax: maxF,
    );
    final wHigh = ForceSolver.arrowMappedWidth(maxF, forceMin: minF, forceMax: maxF);

    expect(wMid, greaterThan(wLow));
    expect(wHigh, greaterThan(wMid));
    expect(wLow, greaterThanOrEqualTo(0.1));
    expect(wHigh, closeTo(400, 1e-6));
  });

  test('tip length = mappedWidth * 8', () {
    expect(ForceSolver.arrowTipLength(1), 8);
    expect(ForceSolver.arrowTipLength(10), 80);
  });
}
