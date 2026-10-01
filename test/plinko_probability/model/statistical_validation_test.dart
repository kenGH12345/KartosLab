import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/plinko_probability/model/lab_model.dart';
import 'package:kratos/plinko_probability/model/plinko_common_model.dart';
import 'package:kratos/plinko_probability/model/plinko_random.dart';

/// Statistical validation: many balls → empirical mean ≈ n p.
void main() {
  test('Lab path mode: 3000 balls mean ≈ μ (seeded)', () {
    final m = LabModel(random: PlinkoRandom(999));
    m.setNumberOfRows(12);
    m.setProbability(0.5);
    m.setHopperMode(HopperMode.path);
    m.setBallMode(BallMode.continuous);
    m.setPlaying(true);

    // Spawn & land quickly in path mode
    for (var i = 0; i < 3000; i++) {
      m.ballCreationTimeElapsed = 1;
      m.step(0.02);
    }

    expect(m.histogram.landedBallsNumber, greaterThanOrEqualTo(2500));
    final mu = m.theoreticalAverage; // 6.0
    expect(m.histogram.average, closeTo(mu, 0.2));
    expect(
      m.histogram.standardDeviation,
      closeTo(m.theoreticalStandardDeviation, 0.25),
    );
  });
}
