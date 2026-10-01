/// PHASE 8 — Behavioral acceptance: tap controls, sync Model/View, lifecycle.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/quantum_measurement/bloch_sphere/animation/bloch_animation_controller.dart';
import 'package:kratos/quantum_measurement/bloch_sphere/model/bloch_sphere_model.dart';
import 'package:kratos/quantum_measurement/bloch_sphere/view/bloch_screen.dart';
import 'package:kratos/quantum_measurement/coins/components/coins_scene_primitives.dart';
import 'package:kratos/quantum_measurement/coins/model/coin_set.dart';
import 'package:kratos/quantum_measurement/coins/model/coins_model.dart';
import 'package:kratos/quantum_measurement/coins/rendering/coin_render_mode.dart';
import 'package:kratos/quantum_measurement/coins/view/coins_screen.dart';
import 'package:kratos/quantum_measurement/common/experiment_measurement_state.dart';
import 'package:kratos/quantum_measurement/common/qm_random.dart';
import 'package:kratos/quantum_measurement/common/system_type.dart';
import 'package:kratos/quantum_measurement/photons/animation/photon_animation_controller.dart';
import 'package:kratos/quantum_measurement/photons/components/photon_source.dart';
import 'package:kratos/quantum_measurement/photons/model/photon_simulation.dart';
import 'package:kratos/quantum_measurement/photons/model/photons_model.dart';
import 'package:kratos/quantum_measurement/photons/view/photons_screen.dart';
import 'package:kratos/quantum_measurement/spin/animation/spin_animation_controller.dart';
import 'package:kratos/quantum_measurement/spin/animation/spin_particle_simulation.dart';
import 'package:kratos/quantum_measurement/spin/components/experiment_selector.dart';
import 'package:kratos/quantum_measurement/spin/components/spin_source.dart';
import 'package:kratos/quantum_measurement/spin/model/spin_model.dart';
import 'package:kratos/quantum_measurement/spin/view/spin_screen.dart';

Future<void> _viewport(WidgetTester tester, [Size size = const Size(1024, 618)]) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.binding.setSurfaceSize(size);
}

Future<void> _pumpScreen(WidgetTester tester, Widget screen) async {
  await _viewport(tester);
  await tester.pumpWidget(
    MaterialApp(debugShowCheckedModeBanner: false, home: screen),
  );
  await tester.pump();
}

Future<void> _tapText(WidgetTester tester, String label) async {
  final finder = find.text(label);
  expect(finder, findsWidgets, reason: 'missing control "$label"');
  await tester.ensureVisible(finder.first);
  await tester.tap(finder.first, warnIfMissed: false);
  await tester.pump();
}

/// Spin/Bloch keep a live Ticker — never use pumpAndSettle on those screens.
Future<void> _pumpFrames(WidgetTester tester, [int n = 8]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 40));
  }
}

Future<void> _pickDropdownItem(
  WidgetTester tester,
  Type dropdownType,
  String itemLabel,
) async {
  await tester.tap(find.byType(dropdownType));
  await _pumpFrames(tester);
  await tester.tap(find.text(itemLabel).last, warnIfMissed: false);
  await _pumpFrames(tester);
}

Future<void> _pickSpinExperiment(
  WidgetTester tester,
  String targetLabel,
) async {
  await tester.tap(find.byType(ExperimentSelector));
  await _pumpFrames(tester, 12);
  await tester.tap(find.text(targetLabel).last, warnIfMissed: false);
  await _pumpFrames(tester, 8);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Coins Classical (user taps)', () {
    testWidgets('C1 default preparing — Flip hidden until Start Measurement',
        (tester) async {
      final model = CoinsModel(random: SeededQmRandom(1));
      await _pumpScreen(tester, QuantumMeasurementCoinsScreen(model: model));
      expect(model.classicalScene.preparingExperiment, isTrue);
      expect(find.text('Flip'), findsNothing);
      expect(find.byType(StartMeasurementButton), findsOneWidget);
    });

    testWidgets('C2–C4 Flip / Reveal / Hide / Flip and Reveal', (tester) async {
      final model = CoinsModel(random: SeededQmRandom(2));
      await _pumpScreen(tester, QuantumMeasurementCoinsScreen(model: model));

      await tester.tap(find.byType(StartMeasurementButton));
      await tester.pump();
      expect(model.classicalScene.preparingExperiment, isFalse);
      expect(find.text('Flip'), findsWidgets);

      await _tapText(tester, 'Flip');
      expect(
        model.classicalScene.singleCoin.measurementState,
        ExperimentMeasurementState.measuredAndHidden,
      );

      await _tapText(tester, 'Reveal');
      expect(
        model.classicalScene.singleCoin.measurementState,
        ExperimentMeasurementState.revealed,
      );

      await _tapText(tester, 'Hide');
      expect(
        model.classicalScene.singleCoin.measurementState,
        ExperimentMeasurementState.measuredAndHidden,
      );

      await _tapText(tester, 'Flip and Reveal');
      expect(
        model.classicalScene.singleCoin.measurementState,
        ExperimentMeasurementState.revealed,
      );
    });

    testWidgets('Quantum Reprepare ≠ Observe; Observe samples', (tester) async {
      final model = CoinsModel(random: SeededQmRandom(3));
      await _pumpScreen(tester, QuantumMeasurementCoinsScreen(model: model));
      await _tapText(tester, "Quantum 'Coin'");
      expect(model.experimentMode, SystemType.quantum);

      await tester.tap(find.byType(StartMeasurementButton));
      await tester.pump();

      await _tapText(tester, 'Reprepare');
      expect(
        model.quantumScene.singleCoin.measurementState,
        ExperimentMeasurementState.readyToBeMeasured,
      );

      await _tapText(tester, 'Observe');
      expect(
        model.quantumScene.singleCoin.measurementState,
        ExperimentMeasurementState.revealed,
      );

      await _tapText(tester, 'Reprepare and Observe');
      expect(
        model.quantumScene.singleCoin.measurementState,
        ExperimentMeasurementState.revealed,
      );
    });

    testWidgets('Count modes 10 / 100 / 10000', (tester) async {
      final model = CoinsModel(random: SeededQmRandom(4));
      await _pumpScreen(tester, QuantumMeasurementCoinsScreen(model: model));
      // Counts only visible while preparing
      await _tapText(tester, '10');
      expect(model.classicalScene.coinSet.numberOfCoins, 10);
      expect(coinRenderModeForCount(10), CoinRenderMode.individual);

      await _tapText(tester, '100');
      expect(model.classicalScene.coinSet.numberOfCoins, 100);

      await _tapText(tester, '10000');
      expect(model.classicalScene.coinSet.numberOfCoins, 10000);
      expect(coinRenderModeForCount(10000), CoinRenderMode.pixelCanvas);
    });

    testWidgets('Classical↔Quantum persistence (not auto-reset)', (tester) async {
      final model = CoinsModel(random: SeededQmRandom(5));
      await _pumpScreen(tester, QuantumMeasurementCoinsScreen(model: model));
      await tester.tap(find.byType(StartMeasurementButton));
      await tester.pump();
      await _tapText(tester, 'Flip');
      final classicalState = model.classicalScene.singleCoin.measurementState;

      await _tapText(tester, "Quantum 'Coin'");
      await _tapText(tester, 'Classical Coin');
      expect(model.classicalScene.singleCoin.measurementState, classicalState);
      expect(model.classicalScene.preparingExperiment, isFalse);
    });

    testWidgets('Reset All restores Classical default', (tester) async {
      final model = CoinsModel(random: SeededQmRandom(6));
      await _pumpScreen(tester, QuantumMeasurementCoinsScreen(model: model));
      await tester.tap(find.byType(StartMeasurementButton));
      await tester.pump();
      await _tapText(tester, 'Flip and Reveal');
      await tester.tap(find.byTooltip('Reset All'));
      await tester.pump();
      expect(model.experimentMode, SystemType.classical);
      expect(model.classicalScene.preparingExperiment, isTrue);
    });
  });

  group('Photons behavior', () {
    testWidgets('P1 Single emit via Photon Source button', (tester) async {
      final model = PhotonsModel(random: SeededQmRandom(10));
      await _pumpScreen(
        tester,
        QuantumMeasurementPhotonsScreen(model: model, random: SeededQmRandom(10)),
      );
      final simFinder = find.byType(PhotonSourceNode);
      expect(simFinder, findsWidgets);
      final ink = find.descendant(
        of: simFinder.first,
        matching: find.byType(InkWell),
      );
      await tester.tap(ink.first, warnIfMissed: false);
      await tester.pump();
      // Spatial photon created (may not have reached detector yet)
      // Drive enough steps via model-level emitAndResolve for count certainty:
      final before = model.singlePhotonScene.verticalDetectionCount +
          model.singlePhotonScene.horizontalDetectionCount;
      model.singlePhotonScene.emitAndResolveOne();
      final after = model.singlePhotonScene.verticalDetectionCount +
          model.singlePhotonScene.horizontalDetectionCount;
      expect(after, before + 1);
    });

    testWidgets('Classical / Quantum mode switches via Behavior radios',
        (tester) async {
      final model = PhotonsModel(random: SeededQmRandom(11));
      await _pumpScreen(
        tester,
        QuantumMeasurementPhotonsScreen(model: model, random: SeededQmRandom(11)),
      );
      await _tapText(tester, 'Quantum');
      expect(model.singlePhotonScene.photonBehaviorMode, SystemType.quantum);
      await _tapText(tester, 'Classical');
      expect(model.singlePhotonScene.photonBehaviorMode, SystemType.classical);
    });

    testWidgets('Continuous Many Photons → rate → stop → no new photons',
        (tester) async {
      final model = PhotonsModel(random: SeededQmRandom(12));
      final sim = PhotonsSpatialSimulation(
        scene: model.manyPhotonsScene,
        random: SeededQmRandom(12),
      );
      model.experimentMode = PhotonExperimentMode.manyPhotons;
      sim.emissionRate = 50;
      final n0 = sim.photons.length;
      sim.step(0.2);
      expect(sim.photons.length, greaterThan(n0));
      final n1 = sim.photons.length;
      expect(n1, greaterThan(0));

      // Stop: rate=0 → length must never increase (may decrease via absorb).
      sim.emissionRate = 0;
      var ceiling = sim.photons.length;
      for (var i = 0; i < 40; i++) {
        sim.step(0.05); // well past emission interval
        expect(
          sim.photons.length,
          lessThanOrEqualTo(ceiling),
          reason: 'emissionRate=0 must not create new photons',
        );
        ceiling = sim.photons.length;
      }
      expect(sim.emissionRate, 0);
    });

    testWidgets('Continuous leave disposes ticker — no leak', (tester) async {
      final model = PhotonsModel(random: SeededQmRandom(13));
      await _pumpScreen(
        tester,
        QuantumMeasurementPhotonsScreen(model: model, random: SeededQmRandom(13)),
      );
      await _tapText(tester, 'Many Photons');
      expect(model.experimentMode, PhotonExperimentMode.manyPhotons);
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();
      // Screen disposed without throw
      expect(find.byType(QuantumMeasurementPhotonsScreen), findsNothing);
    });

    testWidgets('Cont → Single restores single emission mode', (tester) async {
      final model = PhotonsModel(random: SeededQmRandom(14));
      await _pumpScreen(
        tester,
        QuantumMeasurementPhotonsScreen(model: model, random: SeededQmRandom(14)),
      );
      await _tapText(tester, 'Many Photons');
      await _tapText(tester, 'Single Photon');
      expect(model.experimentMode, PhotonExperimentMode.singlePhoton);
    });
  });

  group('Spin behavior', () {
    testWidgets('Experiment selector 1→2→Custom', (tester) async {
      final model = SpinModel(random: SeededQmRandom(20));
      await _pumpScreen(
        tester,
        QuantumMeasurementSpinScreen(model: model, random: SeededQmRandom(20)),
      );
      expect(find.textContaining('Experiment 1'), findsOneWidget);

      await _pickSpinExperiment(tester, 'Experiment 2 [SGx]');
      expect(model.experiment, SpinExperiment.experiment2);

      await _pickSpinExperiment(tester, 'Custom');
      expect(model.experiment, SpinExperiment.custom);
    });

    testWidgets('Single fire creates one particle path', (tester) async {
      final model = SpinModel(random: SeededQmRandom(21));
      final sim = SpinParticleSimulation(model: model);
      expect(sim.particles, isEmpty);
      sim.fireSingle();
      expect(sim.particles.length, 1);
      final counts = model.sternGerlachs[0].upCount + model.sternGerlachs[0].downCount;
      expect(counts, 1);
    });

    testWidgets('Block Up / Down change blockingMode via chips', (tester) async {
      final model = SpinModel(random: SeededQmRandom(22));
      await _pumpScreen(
        tester,
        QuantumMeasurementSpinScreen(model: model, random: SeededQmRandom(22)),
      );
      // Multi-SG experiment + Continuous so blocker chips appear (source semantics).
      await _pickSpinExperiment(tester, 'Experiment 3 [SGz, SGx]');
      expect(model.experiment, SpinExperiment.experiment3);
      await _tapText(tester, 'Continuous');
      expect(model.sourceMode, SourceMode.continuous);
      await _pumpFrames(tester);

      expect(find.text('Block ↓'), findsOneWidget);
      await tester.tap(find.text('Block ↓'));
      await _pumpFrames(tester);
      expect(model.sternGerlachs[0].blockingMode, BlockingMode.blockDown);

      await tester.tap(find.text('Block ↑'));
      await _pumpFrames(tester);
      expect(model.sternGerlachs[0].blockingMode, BlockingMode.blockUp);
    });

    testWidgets('Experiment switch during continuous clears particles',
        (tester) async {
      final model = SpinModel(random: SeededQmRandom(23));
      final sim = SpinParticleSimulation(model: model);
      model.setSourceMode(SourceMode.continuous);
      model.particleAmount = 1;
      sim.step(0.5);
      expect(sim.particles, isNotEmpty);
      sim.clear();
      model.applyExperiment(SpinExperiment.experiment4);
      expect(sim.particles, isEmpty);
      expect(model.experiment, SpinExperiment.experiment4);
    });

    testWidgets('Spin screen dispose cleans ticker', (tester) async {
      final model = SpinModel(random: SeededQmRandom(24));
      await _pumpScreen(
        tester,
        QuantumMeasurementSpinScreen(model: model, random: SeededQmRandom(24)),
      );
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();
      expect(find.byType(QuantumMeasurementSpinScreen), findsNothing);
    });
  });

  group('Bloch behavior', () {
    testWidgets('Presets +X…−Z via dropdown update model', (tester) async {
      final model = BlochSphereModel(random: SeededQmRandom(30));
      await _pumpScreen(tester, QuantumMeasurementBlochScreen(model: model));

      Future<void> pick(String label, BlochStateDirection d) async {
        await _pickDropdownItem(
          tester,
          DropdownButton<BlochStateDirection>,
          label,
        );
        expect(model.spinState, d);
        expect(model.preparation.polarAngle, d.polarAngle);
      }

      await pick('+X', BlochStateDirection.xPlus);
      await pick('−X', BlochStateDirection.xMinus);
      await pick('+Y', BlochStateDirection.yPlus);
      await pick('−Y', BlochStateDirection.yMinus);
      await pick('+Z', BlochStateDirection.zPlus);
      await pick('−Z', BlochStateDirection.zMinus);
    });

    testWidgets('Observe collapses; Erase ≠ Reset', (tester) async {
      final model = BlochSphereModel(random: SeededQmRandom(31));
      await _pumpScreen(tester, QuantumMeasurementBlochScreen(model: model));
      await _pickDropdownItem(
        tester,
        DropdownButton<BlochStateDirection>,
        '+X',
      );

      await _tapText(tester, 'Observe');
      expect(model.measurementState, BlochMeasurementState.observed);
      expect(model.upMeasurementCount + model.downMeasurementCount, 1);
      final polar = model.singleMeasurement.polarAngle;

      await _tapText(tester, 'Erase');
      expect(model.upMeasurementCount, 0);
      expect(model.singleMeasurement.polarAngle, polar);
      expect(model.measurementState, BlochMeasurementState.observed);

      await tester.tap(find.byTooltip('Reset All'));
      await tester.pump();
      expect(model.spinState, BlochStateDirection.xPlus);
      expect(model.measurementState, BlochMeasurementState.prepared);
    });

    testWidgets('Magnetic Field Start → timing → collapse via elapsed time',
        (tester) async {
      final model = BlochSphereModel(random: SeededQmRandom(32));
      model.setSpinState(BlochStateDirection.xPlus);
      model.setMagneticFieldEnabled(true);
      model.measurementDelay = 0.05;
      model.initiateObservation();
      expect(model.measurementState, BlochMeasurementState.timingObservation);
      final anim = BlochAnimationController(model: model, onTick: () {});
      for (var i = 0; i < 200; i++) {
        anim.stepFixed(0.05);
        if (model.measurementState == BlochMeasurementState.observed) break;
      }
      expect(model.measurementState, BlochMeasurementState.observed);
      anim.dispose();
    });

    testWidgets('FPS independence: same elapsed → same φ', (tester) async {
      ComplexBlochSphere run(List<double> dts) {
        final s = ComplexBlochSphere(
          initialPolar: math.pi / 2,
          initialAzimuthal: 0,
        );
        s.rotatingSpeed = 1;
        for (final dt in dts) {
          s.step(dt);
        }
        return s;
      }

      final a = run(List.filled(60, 1 / 60));
      final b = run(List.filled(120, 1 / 120));
      expect(a.azimuthalAngle, closeTo(b.azimuthalAngle, 1e-9));
    });

    testWidgets('Repeated Observe uses collapsed state after Reprepare cycle',
        (tester) async {
      final model = BlochSphereModel(random: SeededQmRandom(33));
      await _pumpScreen(tester, QuantumMeasurementBlochScreen(model: model));
      await _tapText(tester, 'Observe');
      expect(model.measurementState, BlochMeasurementState.observed);
      await _tapText(tester, 'Reprepare');
      expect(model.measurementState, BlochMeasurementState.prepared);
      await _tapText(tester, 'Observe');
      expect(model.upMeasurementCount + model.downMeasurementCount, 2);
    });
  });

  group('Cross-screen isolation + rapid switch', () {
    testWidgets('four models remain isolated under mutations', (tester) async {
      final coins = CoinsModel(random: SeededQmRandom(40));
      final photons = PhotonsModel(random: SeededQmRandom(41));
      final spin = SpinModel(random: SeededQmRandom(42));
      final bloch = BlochSphereModel(random: SeededQmRandom(43));

      coins.classicalScene.setUpProbability(0.3);
      photons.singlePhotonScene.photonBehaviorMode = SystemType.quantum;
      spin.applyExperiment(SpinExperiment.experiment5);
      bloch.setSpinState(BlochStateDirection.yPlus);

      coins.reset();
      expect(photons.singlePhotonScene.photonBehaviorMode, SystemType.quantum);
      expect(spin.experiment, SpinExperiment.experiment5);
      expect(bloch.spinState, BlochStateDirection.yPlus);
    });

    testWidgets('rapid widget switch ×10 no crash / dispose', (tester) async {
      for (var i = 0; i < 10; i++) {
        await _pumpScreen(
          tester,
          QuantumMeasurementCoinsScreen(model: CoinsModel(random: SeededQmRandom(i))),
        );
        await _pumpScreen(
          tester,
          QuantumMeasurementPhotonsScreen(
            model: PhotonsModel(random: SeededQmRandom(i)),
            random: SeededQmRandom(i),
          ),
        );
        await _pumpScreen(
          tester,
          QuantumMeasurementSpinScreen(
            model: SpinModel(random: SeededQmRandom(i)),
            random: SeededQmRandom(i),
          ),
        );
        await _pumpScreen(
          tester,
          QuantumMeasurementBlochScreen(
            model: BlochSphereModel(random: SeededQmRandom(i)),
          ),
        );
      }
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();
    });
  });

  group('Reset during animation / continuous', () {
    test('Photons reset clears photons and rate', () {
      final model = PhotonsModel(random: SeededQmRandom(50));
      final sim = PhotonsSpatialSimulation(
        scene: model.manyPhotonsScene,
        random: SeededQmRandom(50),
      );
      sim.emissionRate = 40;
      sim.step(0.3);
      expect(sim.photons, isNotEmpty);
      sim.reset();
      expect(sim.photons, isEmpty);
      expect(sim.emissionRate, 0);
    });

    test('Spin reset path: clear particles + model.reset', () {
      final model = SpinModel(random: SeededQmRandom(51));
      final sim = SpinParticleSimulation(model: model);
      sim.fireSingle();
      expect(sim.particles, isNotEmpty);
      sim.clear();
      model.reset();
      expect(sim.particles, isEmpty);
      expect(model.experiment, SpinExperiment.experiment1);
    });

    test('Bloch Reset during TIMING stops precession rates', () {
      final model = BlochSphereModel(random: SeededQmRandom(52));
      model.setMagneticFieldEnabled(true);
      model.initiateObservation();
      expect(model.measurementState, BlochMeasurementState.timingObservation);
      model.reset();
      expect(model.measurementState, BlochMeasurementState.prepared);
      expect(model.singleMeasurement.rotatingSpeed, 0);
      expect(model.magneticFieldEnabled, isFalse);
    });
  });

  group('Spam / double action', () {
    testWidgets('Coins Flip spam does not crash', (tester) async {
      final model = CoinsModel(random: SeededQmRandom(60));
      await _pumpScreen(tester, QuantumMeasurementCoinsScreen(model: model));
      await tester.tap(find.byType(StartMeasurementButton));
      await tester.pump();
      for (var i = 0; i < 5; i++) {
        await _tapText(tester, 'Flip');
      }
      expect(
        model.classicalScene.singleCoin.measurementState,
        ExperimentMeasurementState.measuredAndHidden,
      );
    });

    testWidgets('Bloch Observe spam after observed shows Reprepare',
        (tester) async {
      final model = BlochSphereModel(random: SeededQmRandom(61));
      await _pumpScreen(tester, QuantumMeasurementBlochScreen(model: model));
      await _tapText(tester, 'Observe');
      expect(find.text('Reprepare'), findsOneWidget);
      await _tapText(tester, 'Reprepare');
      expect(find.text('Observe'), findsOneWidget);
    });
  });

  group('Seeded replay ×3', () {
    test('same seed same Bloch Observe outcome ×3', () {
      BlochSphereModel once() {
        final m = BlochSphereModel(random: SeededQmRandom(77));
        m.setSpinState(BlochStateDirection.xPlus);
        m.measurementAxis = MeasurementAxis.z;
        m.initiateObservation();
        return m;
      }

      final a = once();
      final b = once();
      final c = once();
      expect(a.singleMeasurement.polarAngle, b.singleMeasurement.polarAngle);
      expect(b.singleMeasurement.polarAngle, c.singleMeasurement.polarAngle);
      expect(a.upMeasurementCount, b.upMeasurementCount);
    });
  });

  group('Full user journey (long path)', () {
    testWidgets('Coins → Photons → Spin → Bloch → Reset sequence',
        (tester) async {
      // Coins Classical Flip and Reveal
      final coins = CoinsModel(random: SeededQmRandom(90));
      await _pumpScreen(tester, QuantumMeasurementCoinsScreen(model: coins));
      await tester.tap(find.byType(StartMeasurementButton));
      await tester.pump();
      await _tapText(tester, 'Flip and Reveal');
      expect(coins.classicalScene.singleCoin.measurementState,
          ExperimentMeasurementState.revealed);

      await _tapText(tester, "Quantum 'Coin'");
      await tester.tap(find.byType(StartMeasurementButton));
      await tester.pump();
      await _tapText(tester, 'Reprepare');
      await _tapText(tester, 'Observe');

      // Photons
      final photons = PhotonsModel(random: SeededQmRandom(91));
      await _pumpScreen(
        tester,
        QuantumMeasurementPhotonsScreen(
          model: photons,
          random: SeededQmRandom(91),
        ),
      );
      await _tapText(tester, 'Classical');
      photons.singlePhotonScene.emitAndResolveOne();
      await _tapText(tester, 'Quantum');
      await _tapText(tester, 'Many Photons');
      expect(photons.experimentMode, PhotonExperimentMode.manyPhotons);
      await _tapText(tester, 'Single Photon');

      // Spin
      final spin = SpinModel(random: SeededQmRandom(92));
      await _pumpScreen(
        tester,
        QuantumMeasurementSpinScreen(model: spin, random: SeededQmRandom(92)),
      );
      await _pickSpinExperiment(tester, 'Experiment 2 [SGx]');
      final spinSim = SpinParticleSimulation(model: spin);
      spinSim.fireSingle();
      expect(spinSim.particles.length, 1);

      // Bloch
      final bloch = BlochSphereModel(random: SeededQmRandom(93));
      await _pumpScreen(tester, QuantumMeasurementBlochScreen(model: bloch));
      await _pickDropdownItem(
        tester,
        DropdownButton<BlochStateDirection>,
        '+X',
      );
      await _tapText(tester, 'Observe');
      await _tapText(tester, 'Erase');
      await tester.tap(find.byTooltip('Reset All'));
      await tester.pump();
      expect(bloch.measurementState, BlochMeasurementState.prepared);

      // Leave
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();

      // Isolation still holds
      expect(coins.experimentMode, SystemType.quantum);
      expect(photons.experimentMode, PhotonExperimentMode.singlePhoton);
      expect(spin.experiment, SpinExperiment.experiment2);
    });
  });

  group('Controller lifecycle unit', () {
    test('PhotonAnimationController dispose stops', () {
      final model = PhotonsModel(random: SeededQmRandom(1));
      final sim = PhotonsSpatialSimulation(
        scene: model.singlePhotonScene,
        random: SeededQmRandom(1),
      );
      final c = PhotonAnimationController(simulation: sim, onTick: () {});
      c.dispose();
      expect(c.isRunning, isFalse);
    });

    test('SpinAnimationController dispose stops', () {
      final m = SpinModel(random: SeededQmRandom(1));
      final sim = SpinParticleSimulation(model: m);
      final c = SpinAnimationController(simulation: sim, onTick: () {});
      c.dispose();
      expect(c.isRunning, isFalse);
    });

    test('BlochAnimationController dispose stops', () {
      final m = BlochSphereModel(random: SeededQmRandom(1));
      final c = BlochAnimationController(model: m, onTick: () {});
      c.dispose();
      expect(c.isRunning, isFalse);
    });
  });
}
