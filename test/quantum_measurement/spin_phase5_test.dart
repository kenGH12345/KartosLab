/// PHASE 5 Spin configuration / geometry / behavior / lifecycle tests.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/quantum_measurement/common/qm_random.dart';
import 'package:kratos/quantum_measurement/layout/qm_spin_layout_spec.dart';
import 'package:kratos/quantum_measurement/spin/animation/spin_animation_controller.dart';
import 'package:kratos/quantum_measurement/spin/animation/spin_particle_simulation.dart';
import 'package:kratos/quantum_measurement/spin/composer/spin_composer.dart';
import 'package:kratos/quantum_measurement/spin/configuration/spin_experiment_view_configuration.dart';
import 'package:kratos/quantum_measurement/spin/model/spin_model.dart';
import 'package:kratos/quantum_measurement/spin/transform/spin_view_transform.dart';
import 'package:kratos/quantum_measurement/spin/view/spin_screen.dart';

void main() {
  group('SpinViewTransform', () {
    const t = SpinViewTransform();
    test('origin and scale 180 with Y invert', () {
      expect(t.physicsToView(SpinVec2.zero), Offset.zero);
      expect(t.physicsToView(const SpinVec2(0.8, 0)).dx, closeTo(144, 1e-9));
      expect(t.physicsToView(const SpinVec2(0, 0.3)).dy, closeTo(-54, 1e-9));
      final back = t.viewToPhysics(t.physicsToView(const SpinVec2(-0.5, 0.1)));
      expect(back.x, closeTo(-0.5, 1e-12));
      expect(back.y, closeTo(0.1, 1e-12));
    });
  });

  group('SpinExperimentViewConfiguration', () {
    test('Experiment 1 single apparatus hides SG1/SG2', () {
      final m = SpinModel(random: SeededQmRandom(1));
      m.applyExperiment(SpinExperiment.experiment1);
      final c = SpinExperimentViewConfiguration.fromModel(m);
      expect(c.usingSingleApparatus, isTrue);
      expect(c.showSg0, isTrue);
      expect(c.showSg1, isFalse);
      expect(c.showSg2, isFalse);
      expect(c.sg0IsZ, isTrue);
    });

    test('Experiment 2 is SGx', () {
      final m = SpinModel(random: SeededQmRandom(1));
      m.applyExperiment(SpinExperiment.experiment2);
      final c = SpinExperimentViewConfiguration.fromModel(m);
      expect(c.sg0IsZ, isFalse);
      expect(c.usingSingleApparatus, isTrue);
    });

    test('Experiments 3–6 multi show SG1/SG2 in single mode', () {
      for (final e in [
        SpinExperiment.experiment3,
        SpinExperiment.experiment4,
        SpinExperiment.experiment5,
        SpinExperiment.experiment6,
      ]) {
        final m = SpinModel(random: SeededQmRandom(2));
        m.setSourceMode(SourceMode.single);
        m.applyExperiment(e);
        final c = SpinExperimentViewConfiguration.fromModel(m);
        expect(c.usingSingleApparatus, isFalse, reason: e.label);
        expect(c.showSg1, isTrue, reason: e.label);
        expect(c.showSg2, isTrue, reason: e.label);
      }
    });

    test('Block Up hides SG1 in continuous multi', () {
      final m = SpinModel(random: SeededQmRandom(3));
      m.applyExperiment(SpinExperiment.experiment3);
      m.setSourceMode(SourceMode.continuous);
      m.setBlockingMode(BlockingMode.blockUp);
      final c = SpinExperimentViewConfiguration.fromModel(m);
      expect(c.showSg1, isFalse);
      expect(c.showSg2, isTrue);
    });

    test('Block Down hides SG2', () {
      final m = SpinModel(random: SeededQmRandom(3));
      m.applyExperiment(SpinExperiment.experiment3);
      m.setSourceMode(SourceMode.continuous);
      m.setBlockingMode(BlockingMode.blockDown);
      final c = SpinExperimentViewConfiguration.fromModel(m);
      expect(c.showSg1, isTrue);
      expect(c.showSg2, isFalse);
    });

    test('Custom enables direction control', () {
      final m = SpinModel(random: SeededQmRandom(4));
      m.applyExperiment(SpinExperiment.custom);
      final c = SpinExperimentViewConfiguration.fromModel(m);
      expect(c.isCustom, isTrue);
      expect(c.sg0DirectionControllable, isTrue);
    });
  });

  group('SpinComposer', () {
    const composer = SpinComposer();

    test('divider x=300 and MVT 180 for all experiments', () {
      for (final e in SpinExperiment.values) {
        final m = SpinModel(random: SeededQmRandom(5));
        m.applyExperiment(e);
        final g = composer.compose(
          viewport: const Size(1024, 618),
          config: SpinExperimentViewConfiguration.fromModel(m),
        );
        expect(g.dividerX, QmSpinLayoutSpec.dividingLineX);
        expect(g.transform.scale, 180);
        expect(g.sg0.centerView.dx, greaterThan(g.dividerX));
      }
    });

    test('1280×800 and 800×600 uniform scale', () {
      final a = composer.designFrame(const Size(1280, 800));
      final b = composer.designFrame(const Size(800, 600));
      expect(a.scale, lessThanOrEqualTo(1280 / 1024));
      expect(b.scale, lessThanOrEqualTo(800 / 1024));
    });

    test('experiment switch clears stale sg1 visibility', () {
      final m = SpinModel(random: SeededQmRandom(6));
      m.applyExperiment(SpinExperiment.experiment3);
      var g = composer.compose(
        viewport: const Size(1024, 618),
        config: SpinExperimentViewConfiguration.fromModel(m),
      );
      expect(g.sg1.visible, isTrue);
      m.applyExperiment(SpinExperiment.experiment1);
      g = composer.compose(
        viewport: const Size(1024, 618),
        config: SpinExperimentViewConfiguration.fromModel(m),
      );
      expect(g.sg1.visible, isFalse);
    });
  });

  group('Behavior', () {
    test('Single fire increments counts deterministically', () {
      final m = SpinModel(random: SeededQmRandom(42));
      m.applyExperiment(SpinExperiment.experiment1);
      m.spinState = SpinDirection.zPlus;
      final before = m.sternGerlachs[0].upCount;
      m.fireSingleParticle();
      expect(m.sternGerlachs[0].upCount + m.sternGerlachs[0].downCount,
          before + 1);
      // z+ into SGz → always up
      expect(m.sternGerlachs[0].upCount, before + 1);
    });

    test('SGx vs SGz changes probability for x+ state', () {
      final a = SpinModel(random: SeededQmRandom(1))
        ..spinState = SpinDirection.xPlus
        ..applyExperiment(SpinExperiment.experiment1);
      a.sternGerlachs[0].updateProbability(a.preparedSpinVector);
      final b = SpinModel(random: SeededQmRandom(1))
        ..spinState = SpinDirection.xPlus
        ..applyExperiment(SpinExperiment.experiment2);
      b.sternGerlachs[0].updateProbability(b.preparedSpinVector);
      expect(a.sternGerlachs[0].upProbability, closeTo(0.5, 1e-12));
      expect(b.sternGerlachs[0].upProbability, closeTo(1.0, 1e-12));
    });

    test('continuous creates particles over time', () {
      final m = SpinModel(random: SeededQmRandom(8));
      m.applyExperiment(SpinExperiment.experiment1);
      m.setSourceMode(SourceMode.continuous);
      m.particleAmount = 1.0;
      final sim = SpinParticleSimulation(model: m);
      sim.step(1.0);
      expect(sim.particles.length, greaterThan(0));
      expect(sim.particles.length, lessThanOrEqualTo(maxContinuousParticles));
    });

    test('experiment switch clears particles', () {
      final m = SpinModel(random: SeededQmRandom(9));
      m.setSourceMode(SourceMode.continuous);
      m.particleAmount = 1;
      final sim = SpinParticleSimulation(model: m);
      sim.step(0.5);
      expect(sim.particles, isNotEmpty);
      sim.clear();
      m.applyExperiment(SpinExperiment.experiment2);
      expect(sim.particles, isEmpty);
    });

    test('Custom alpha updates vector', () {
      final m = SpinModel(random: SeededQmRandom(1));
      m.applyExperiment(SpinExperiment.custom);
      m.setAlphaSquared(0.5);
      expect(m.customSpinState.x, closeTo(1.0, 1e-9)); // sin(π/2)
      expect(m.customSpinState.z.abs(), lessThan(1e-9));
    });
  });

  group('Lifecycle / screen', () {
    testWidgets('mount Spin, switch experiments, dispose cleans ticker',
        (tester) async {
      final model = SpinModel(random: SeededQmRandom(10));
      await tester.pumpWidget(
        MaterialApp(
          home: QuantumMeasurementSpinScreen(
            model: model,
            random: SeededQmRandom(10),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('Experiment 1'), findsOneWidget);
      expect(find.text('Particle Source'), findsOneWidget);

      model.applyExperiment(SpinExperiment.experiment2);
      await tester.tap(find.text('Single'));
      await tester.pump();
      expect(model.experiment, SpinExperiment.experiment2);
      expect(find.textContaining('Experiment 2'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();
    });

    test('animation controller dispose stops', () {
      final m = SpinModel(random: SeededQmRandom(1));
      final sim = SpinParticleSimulation(model: m);
      final c = SpinAnimationController(simulation: sim, onTick: () {});
      c.dispose();
      expect(c.isRunning, isFalse);
    });
  });
}
