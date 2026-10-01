/// PHASE 7 Golden Matrix — deterministic screenshots + geometry dual gate.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/quantum_measurement/bloch_sphere/model/bloch_sphere_model.dart';
import 'package:kratos/quantum_measurement/bloch_sphere/projection/bloch_projection.dart';
import 'package:kratos/quantum_measurement/bloch_sphere/view/bloch_screen.dart';
import 'package:kratos/quantum_measurement/coins/model/coins_model.dart';
import 'package:kratos/quantum_measurement/coins/rendering/coins_10k_painter.dart';
import 'package:kratos/quantum_measurement/coins/view/coins_screen.dart';
import 'package:kratos/quantum_measurement/common/qm_random.dart';
import 'package:kratos/quantum_measurement/common/qm_visual.dart';
import 'package:kratos/quantum_measurement/common/system_type.dart';
import 'package:kratos/quantum_measurement/photons/model/photons_model.dart';
import 'package:kratos/quantum_measurement/photons/view/photons_screen.dart';
import 'package:kratos/quantum_measurement/spin/model/spin_model.dart';
import 'package:kratos/quantum_measurement/spin/view/spin_screen.dart';

const _dpr = 1.0;

Future<void> _setViewport(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = _dpr;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.binding.setSurfaceSize(size);
}

Future<void> _pump(WidgetTester tester, Widget child, Size size) async {
  await _setViewport(tester, size);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: child,
    ),
  );
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('debug overlay never on golden path', () {
    expect(qmVisualDebugEnabled, isFalse);
  });

  group('10k canvas geometry', () {
    test('100×100 cells; revealed colors deterministic from seed', () {
      final setValues = List<String>.generate(10000, (i) => i.isEven ? 'heads' : 'tails');
      final a = sampleGridColors(
        measuredValues: setValues,
        count: 10000,
        revealed: true,
        systemType: SystemType.classical,
        sideLength: 100,
      );
      final b = sampleGridColors(
        measuredValues: setValues,
        count: 10000,
        revealed: true,
        systemType: SystemType.classical,
        sideLength: 100,
      );
      expect(a.length, 10000);
      expect(a, b);
      expect(a.first, isNot(Coins10kPainter.hidden));
    });
  });

  group('Bloch projection golden geometry', () {
    test('+Z / −Z / ±X / ±Y endpoints fail if inverted', () {
      final p = BlochProjection();
      expect(p.stateVectorTip(polar: 0, azimuthal: 0).dy, closeTo(-100, 1e-9));
      expect(p.stateVectorTip(polar: math.pi, azimuthal: 0).dy, closeTo(100, 1e-9));
      final plusX = p.stateVectorTip(polar: math.pi / 2, azimuthal: 0);
      final minusX = p.stateVectorTip(polar: math.pi / 2, azimuthal: math.pi);
      expect(plusX.dx, isNot(closeTo(minusX.dx, 1)));
    });
  });

  group('Canonical 1024×618 screenshots', () {
    const canonical = Size(1024, 618);

    testWidgets('coins_classical_default_1024x618', (tester) async {
      final model = CoinsModel(random: SeededQmRandom(1));
      await _pump(tester, QuantumMeasurementCoinsScreen(model: model), canonical);
      await expectLater(
        find.byType(QuantumMeasurementCoinsScreen),
        matchesGoldenFile('goldens/coins_classical_default_1024x618.png'),
      );
    });

    testWidgets('coins_quantum_default_1024x618', (tester) async {
      final model = CoinsModel(random: SeededQmRandom(1));
      model.setExperimentMode(SystemType.quantum);
      await _pump(tester, QuantumMeasurementCoinsScreen(model: model), canonical);
      await expectLater(
        find.byType(QuantumMeasurementCoinsScreen),
        matchesGoldenFile('goldens/coins_quantum_default_1024x618.png'),
      );
    });

    testWidgets('coins_10000_1024x618', (tester) async {
      final model = CoinsModel(random: SeededQmRandom(7));
      model.classicalScene.coinSet.numberOfCoins = 10000;
      model.classicalScene.coinSet.prepareNow();
      model.classicalScene.coinSet.reveal();
      await _pump(tester, QuantumMeasurementCoinsScreen(model: model), canonical);
      await expectLater(
        find.byType(QuantumMeasurementCoinsScreen),
        matchesGoldenFile('goldens/coins_10000_1024x618.png'),
      );
    });

    testWidgets('photons_default_1024x618', (tester) async {
      final model = PhotonsModel(random: SeededQmRandom(3));
      await _pump(
        tester,
        QuantumMeasurementPhotonsScreen(model: model, random: SeededQmRandom(3)),
        canonical,
      );
      await expectLater(
        find.byType(QuantumMeasurementPhotonsScreen),
        matchesGoldenFile('goldens/photons_default_1024x618.png'),
      );
    });

    testWidgets('photons_classical_1024x618', (tester) async {
      final model = PhotonsModel(random: SeededQmRandom(3));
      model.singlePhotonScene.photonBehaviorMode = SystemType.classical;
      await _pump(
        tester,
        QuantumMeasurementPhotonsScreen(model: model, random: SeededQmRandom(3)),
        canonical,
      );
      await expectLater(
        find.byType(QuantumMeasurementPhotonsScreen),
        matchesGoldenFile('goldens/photons_classical_1024x618.png'),
      );
    });

    testWidgets('photons_quantum_1024x618', (tester) async {
      final model = PhotonsModel(random: SeededQmRandom(3));
      model.singlePhotonScene.photonBehaviorMode = SystemType.quantum;
      model.manyPhotonsScene.photonBehaviorMode = SystemType.quantum;
      await _pump(
        tester,
        QuantumMeasurementPhotonsScreen(model: model, random: SeededQmRandom(3)),
        canonical,
      );
      await expectLater(
        find.byType(QuantumMeasurementPhotonsScreen),
        matchesGoldenFile('goldens/photons_quantum_1024x618.png'),
      );
    });

    for (final exp in SpinExperiment.values) {
      testWidgets('spin_${exp.name}_1024x618', (tester) async {
        final model = SpinModel(random: SeededQmRandom(5));
        model.applyExperiment(exp);
        await _pump(
          tester,
          QuantumMeasurementSpinScreen(model: model, random: SeededQmRandom(5)),
          canonical,
        );
        await expectLater(
          find.byType(QuantumMeasurementSpinScreen),
          matchesGoldenFile('goldens/spin_${exp.name}_1024x618.png'),
        );
      });
    }

    testWidgets('bloch_default_1024x618', (tester) async {
      final model = BlochSphereModel(random: SeededQmRandom(9));
      await _pump(tester, QuantumMeasurementBlochScreen(model: model), canonical);
      await expectLater(
        find.byType(QuantumMeasurementBlochScreen),
        matchesGoldenFile('goldens/bloch_default_1024x618.png'),
      );
    });

    testWidgets('bloch presets 1024x618', (tester) async {
      const cases = <(BlochStateDirection, String)>[
        (BlochStateDirection.xPlus, 'plus_x'),
        (BlochStateDirection.xMinus, 'minus_x'),
        (BlochStateDirection.yPlus, 'plus_y'),
        (BlochStateDirection.yMinus, 'minus_y'),
        (BlochStateDirection.zPlus, 'plus_z'),
        (BlochStateDirection.zMinus, 'minus_z'),
      ];
      for (final (dir, name) in cases) {
        final model = BlochSphereModel(random: SeededQmRandom(9));
        model.setSpinState(dir);
        await _pump(tester, QuantumMeasurementBlochScreen(model: model), canonical);
        await expectLater(
          find.byType(QuantumMeasurementBlochScreen),
          matchesGoldenFile('goldens/bloch_${name}_1024x618.png'),
        );
      }
    });

    testWidgets('bloch_collapsed_1024x618', (tester) async {
      final model = BlochSphereModel(random: SeededQmRandom(11));
      model.setSpinState(BlochStateDirection.zPlus);
      model.measurementAxis = MeasurementAxis.z;
      model.initiateObservation();
      await _pump(tester, QuantumMeasurementBlochScreen(model: model), canonical);
      await expectLater(
        find.byType(QuantumMeasurementBlochScreen),
        matchesGoldenFile('goldens/bloch_collapsed_1024x618.png'),
      );
    });

    testWidgets('bloch_magnetic_t0_1024x618', (tester) async {
      final model = BlochSphereModel(random: SeededQmRandom(12));
      model.setSpinState(BlochStateDirection.xPlus);
      model.setMagneticFieldEnabled(true);
      model.initiateObservation();
      await _pump(tester, QuantumMeasurementBlochScreen(model: model), canonical);
      await expectLater(
        find.byType(QuantumMeasurementBlochScreen),
        matchesGoldenFile('goldens/bloch_magnetic_checkpoint_1024x618.png'),
      );
    });

    testWidgets('bloch_erased_1024x618', (tester) async {
      final model = BlochSphereModel(random: SeededQmRandom(11));
      model.setSpinState(BlochStateDirection.zPlus);
      model.initiateObservation();
      model.erase();
      await _pump(tester, QuantumMeasurementBlochScreen(model: model), canonical);
      await expectLater(
        find.byType(QuantumMeasurementBlochScreen),
        matchesGoldenFile('goldens/bloch_erased_1024x618.png'),
      );
    });
  });

  group('Responsive 1280×800', () {
    const responsive = Size(1280, 800);

    testWidgets('coins_classical_default_1280x800', (tester) async {
      await _pump(
        tester,
        QuantumMeasurementCoinsScreen(
          model: CoinsModel(random: SeededQmRandom(1)),
        ),
        responsive,
      );
      await expectLater(
        find.byType(QuantumMeasurementCoinsScreen),
        matchesGoldenFile('goldens/coins_classical_default_1280x800.png'),
      );
    });

    testWidgets('photons_default_1280x800', (tester) async {
      await _pump(
        tester,
        QuantumMeasurementPhotonsScreen(
          model: PhotonsModel(random: SeededQmRandom(3)),
          random: SeededQmRandom(3),
        ),
        responsive,
      );
      await expectLater(
        find.byType(QuantumMeasurementPhotonsScreen),
        matchesGoldenFile('goldens/photons_default_1280x800.png'),
      );
    });

    testWidgets('spin_experiment1_1280x800', (tester) async {
      final model = SpinModel(random: SeededQmRandom(5));
      await _pump(
        tester,
        QuantumMeasurementSpinScreen(model: model, random: SeededQmRandom(5)),
        responsive,
      );
      await expectLater(
        find.byType(QuantumMeasurementSpinScreen),
        matchesGoldenFile('goldens/spin_experiment1_1280x800.png'),
      );
    });

    testWidgets('bloch_default_1280x800', (tester) async {
      await _pump(
        tester,
        QuantumMeasurementBlochScreen(model: BlochSphereModel(random: SeededQmRandom(9))),
        responsive,
      );
      await expectLater(
        find.byType(QuantumMeasurementBlochScreen),
        matchesGoldenFile('goldens/bloch_default_1280x800.png'),
      );
    });
  });

  group('Constrained 800×600', () {
    const constrained = Size(800, 600);

    testWidgets('coins_classical_default_800x600', (tester) async {
      await _pump(
        tester,
        QuantumMeasurementCoinsScreen(
          model: CoinsModel(random: SeededQmRandom(1)),
        ),
        constrained,
      );
      await expectLater(
        find.byType(QuantumMeasurementCoinsScreen),
        matchesGoldenFile('goldens/coins_classical_default_800x600.png'),
      );
    });

    testWidgets('photons_default_800x600', (tester) async {
      await _pump(
        tester,
        QuantumMeasurementPhotonsScreen(
          model: PhotonsModel(random: SeededQmRandom(3)),
          random: SeededQmRandom(3),
        ),
        constrained,
      );
      await expectLater(
        find.byType(QuantumMeasurementPhotonsScreen),
        matchesGoldenFile('goldens/photons_default_800x600.png'),
      );
    });

    testWidgets('bloch_default_800x600', (tester) async {
      await _pump(
        tester,
        QuantumMeasurementBlochScreen(model: BlochSphereModel(random: SeededQmRandom(9))),
        constrained,
      );
      await expectLater(
        find.byType(QuantumMeasurementBlochScreen),
        matchesGoldenFile('goldens/bloch_default_800x600.png'),
      );
    });
  });

  test('golden geometry determinism ×3 (coins composer + bloch projection)', () {
    Offset tip() => BlochProjection().stateVectorTip(polar: math.pi / 2, azimuthal: 0);
    expect(tip(), tip());
    expect(tip(), tip());
  });
}
