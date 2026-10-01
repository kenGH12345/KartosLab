import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/plinko_probability/model/ball_phase.dart';
import 'package:kratos/plinko_probability/model/intro_model.dart';
import 'package:kratos/plinko_probability/model/lab_model.dart';
import 'package:kratos/plinko_probability/model/plinko_common_model.dart';
import 'package:kratos/plinko_probability/model/plinko_random.dart';
import 'package:kratos/plinko_probability/plinko_constants.dart';

void main() {
  group('IntroModel', () {
    test('play oneBall enqueues 1', () {
      final m = IntroModel(random: PlinkoRandom(1));
      m.setBallMode(BallMode.oneBall);
      m.play();
      expect(m.ballsToCreateNumber, 1);
    });

    test('play tenBalls enqueues 10', () {
      final m = IntroModel(random: PlinkoRandom(1));
      m.setBallMode(BallMode.tenBalls);
      m.play();
      expect(m.ballsToCreateNumber, 10);
    });

    test('step creates ball after 150ms', () {
      final m = IntroModel(random: PlinkoRandom(1));
      m.setBallMode(BallMode.oneBall);
      m.play();
      m.step(0.05);
      expect(m.balls, isEmpty);
      m.step(0.11);
      expect(m.balls.length, 1);
      expect(m.launchedBallsNumber, 1);
    });

    test('erase clears queue and balls', () {
      final m = IntroModel(random: PlinkoRandom(1));
      m.setBallMode(BallMode.tenBalls);
      m.play();
      m.step(0.2);
      m.erase();
      expect(m.balls, isEmpty);
      expect(m.ballsToCreateNumber, 0);
      expect(m.launchedBallsNumber, 0);
      expect(m.histogram.landedBallsNumber, 0);
    });

    test('changing probability erases', () {
      final m = IntroModel(random: PlinkoRandom(1));
      m.play();
      m.step(0.2);
      expect(m.balls, isNotEmpty);
      m.setProbability(0.7);
      expect(m.balls, isEmpty);
      expect(m.probability, 0.7);
    });
  });

  group('LabModel', () {
    test('oneBall play adds one ball', () {
      final m = LabModel(random: PlinkoRandom(2));
      m.setBallMode(BallMode.oneBall);
      m.playPressed();
      expect(m.balls.length, 1);
    });

    test('continuous play sets isPlaying and spawns on interval', () {
      final m = LabModel(random: PlinkoRandom(2));
      m.setBallMode(BallMode.continuous);
      m.playPressed();
      expect(m.isPlaying, isTrue);
      m.step(0.11);
      expect(m.balls.length, greaterThanOrEqualTo(1));
    });

    test('path mode lands immediately', () {
      final m = LabModel(random: PlinkoRandom(3));
      m.setHopperMode(HopperMode.path);
      m.setBallMode(BallMode.oneBall);
      m.playPressed();
      expect(m.balls.length, 1);
      m.step(0.001);
      expect(m.balls.first.phase, BallPhase.collected);
      expect(m.histogram.landedBallsNumber, 1);
    });

    test('reset restores defaults', () {
      final m = LabModel(random: PlinkoRandom(4));
      m.setNumberOfRows(20);
      m.setProbability(0.2);
      m.setBallMode(BallMode.continuous);
      m.setPlaying(true);
      m.reset();
      expect(m.numberOfRows, PlinkoConstants.rowsDefault);
      expect(m.probability, PlinkoConstants.binaryProbabilityDefault);
      expect(m.ballMode, BallMode.oneBall);
      expect(m.isPlaying, isFalse);
      expect(m.balls, isEmpty);
    });
  });
}
