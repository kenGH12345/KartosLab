import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/quantum_measurement/common/qm_random.dart';
import 'package:kratos/quantum_measurement/spin/model/spin_model.dart';

void main() {
  group('SpinExperiment presets', () {
    test('all 7 experiments present with correct SG chains', () {
      expect(SpinExperiment.values.length, 7);
      expect(SpinExperiment.experiment1.experimentSetting.single.isZOriented, isTrue);
      expect(SpinExperiment.experiment2.experimentSetting.single.isZOriented, isFalse);
      expect(
        SpinExperiment.experiment3.experimentSetting.map((s) => s.isZOriented),
        [true, false, false],
      );
      expect(
        SpinExperiment.experiment4.experimentSetting.map((s) => s.isZOriented),
        [true, true, true],
      );
      expect(
        SpinExperiment.experiment5.experimentSetting.map((s) => s.isZOriented),
        [false, true, true],
      );
      expect(
        SpinExperiment.experiment6.experimentSetting.map((s) => s.isZOriented),
        [false, false, false],
      );
      expect(SpinExperiment.custom.usingSingleApparatus, isFalse);
    });
  });

  group('SternGerlach probability', () {
    test('SGz on |+Z⟩ → P(up)=1', () {
      final sg = SternGerlachModel(isZOriented: true);
      expect(sg.calculateProbability((x: 0, z: 1)), closeTo(1.0, 1e-12));
    });

    test('SGz on |-Z⟩ → P(up)=0', () {
      final sg = SternGerlachModel(isZOriented: true);
      expect(sg.calculateProbability((x: 0, z: -1)), closeTo(0.0, 1e-12));
    });

    test('SGz on |+X⟩ → P(up)=0.5', () {
      final sg = SternGerlachModel(isZOriented: true);
      expect(sg.calculateProbability((x: 1, z: 0)), closeTo(0.5, 1e-12));
    });

    test('SGx on |+X⟩ → P(up)=1', () {
      final sg = SternGerlachModel(isZOriented: false);
      expect(sg.calculateProbability((x: 1, z: 0)), closeTo(1.0, 1e-12));
    });

    test('P(up)+P(down)=1', () {
      final sg = SternGerlachModel(isZOriented: true);
      sg.updateProbability((x: 0.6, z: 0.8)); // not unit but formula still sums
      expect(sg.upProbability + sg.downProbability, closeTo(1.0, 1e-12));
    });
  });

  group('Block Up / Down', () {
    test('blockUp stops up particles after SG0', () {
      final model = SpinModel(random: SeededQmRandom(1));
      model.applyExperiment(SpinExperiment.experiment3);
      model.spinState = SpinDirection.zPlus; // always up at SGz
      model.sternGerlachs[0].blockingMode = BlockingMode.blockUp;
      final path = model.fireSingleParticle();
      expect(path, [true]); // only SG0, blocked
      expect(model.sternGerlachs[1].upCount + model.sternGerlachs[1].downCount, 0);
    });

    test('noBlocker continues to second SG', () {
      final model = SpinModel(random: SeededQmRandom(2));
      model.applyExperiment(SpinExperiment.experiment3);
      model.spinState = SpinDirection.zPlus;
      model.sternGerlachs[0].blockingMode = BlockingMode.noBlocker;
      final path = model.fireSingleParticle();
      expect(path.length, 2);
    });
  });

  group('Alpha / beta', () {
    test('α² + β² = 1', () {
      final model = SpinModel(random: SeededQmRandom(1));
      model.setAlphaSquared(0.25);
      expect(model.alphaSquared + model.betaSquared, closeTo(1.0, 1e-12));
    });
  });

  group('Spin determinism', () {
    test('same seed ⇒ same measurement sequence', () {
      List<List<bool>> run(int seed) {
        final model = SpinModel(random: SeededQmRandom(seed));
        model.applyExperiment(SpinExperiment.experiment1);
        model.spinState = SpinDirection.xPlus;
        return List.generate(20, (_) => model.fireSingleParticle());
      }

      expect(run(55), run(55));
      expect(run(55), isNot(run(56)));
    });
  });

  group('SpinModel reset', () {
    test('reset restores Experiment 1 and α²=1', () {
      final model = SpinModel(random: SeededQmRandom(1));
      model.applyExperiment(SpinExperiment.experiment5);
      model.setAlphaSquared(0.3);
      model.reset();
      expect(model.experiment, SpinExperiment.experiment1);
      expect(model.alphaSquared, 1.0);
      expect(model.sternGerlachs[0].isZOriented, isTrue);
    });
  });
}
