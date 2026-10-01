/// PHASE 3 component / composer / 10k rendering tests.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/quantum_measurement/coins/composer/coins_composer.dart';
import 'package:kratos/quantum_measurement/coins/components/classical_coin_display.dart';
import 'package:kratos/quantum_measurement/coins/components/coin_controls.dart';
import 'package:kratos/quantum_measurement/coins/components/coin_count_selector.dart';
import 'package:kratos/quantum_measurement/coins/components/multi_coin_display.dart';
import 'package:kratos/quantum_measurement/coins/components/quantum_coin_display.dart';
import 'package:kratos/quantum_measurement/coins/model/coins_model.dart';
import 'package:kratos/quantum_measurement/coins/rendering/coin_render_mode.dart';
import 'package:kratos/quantum_measurement/coins/rendering/coins_10k_painter.dart';
import 'package:kratos/quantum_measurement/coins/view/coins_screen.dart';
import 'package:kratos/quantum_measurement/common/experiment_measurement_state.dart';
import 'package:kratos/quantum_measurement/common/qm_random.dart';
import 'package:kratos/quantum_measurement/common/system_type.dart';
import 'package:kratos/quantum_measurement/layout/qm_coins_layout_spec.dart';
import 'package:kratos/quantum_measurement/layout/qm_global_layout_spec.dart';

void main() {
  group('CoinRenderMode', () {
    test('10 and 100 are individual; 10000 is pixelCanvas', () {
      expect(coinRenderModeForCount(10), CoinRenderMode.individual);
      expect(coinRenderModeForCount(100), CoinRenderMode.individual);
      expect(coinRenderModeForCount(10000), CoinRenderMode.pixelCanvas);
    });
  });

  group('CoinsComposer', () {
    const composer = CoinsComposer();

    test('1024×618 preparing divider and prep center', () {
      final g = composer.compose(
        viewport: const Size(1024, 618),
        preparing: true,
      );
      expect(g.dividerX, 389);
      expect(g.prepCenter.dx, 389 / 2);
      expect(g.designSize, const Size(qmDesignWidth, qmDesignHeight));
      expect(g.singleTestBox.width, QmCoinsLayoutSpec.singleCoinTestBoxWidth);
      expect(g.multiTestBox.width, QmCoinsLayoutSpec.multiCoinTestBoxSize);
    });

    test('1024×618 measurement divider', () {
      final g = composer.compose(
        viewport: const Size(1024, 618),
        preparing: false,
      );
      expect(g.dividerX, 205);
      expect(g.prepCenter.dx, 205 / 2);
    });

    test('1280×800 and 800×600 uniform scale', () {
      final a = composer.designFrame(const Size(1280, 800));
      final b = composer.designFrame(const Size(800, 600));
      expect(a.scale, closeTo(1280 / 1024 < 800 / 618 ? 1280 / 1024 : 800 / 618, 1e-9));
      expect(b.scale, closeTo(800 / 1024 < 600 / 618 ? 800 / 1024 : 600 / 618, 1e-9));
      // No stretch: scale is min of both axes.
      expect(a.scale, lessThanOrEqualTo(1280 / 1024));
      expect(a.scale, lessThanOrEqualTo(800 / 618));
    });

    test('classical/quantum share geometry for same preparing flag', () {
      final prep = composer.compose(
        viewport: const Size(1024, 618),
        preparing: true,
      );
      expect(prep.dividerRect.height, qmDividerHeight);
      expect(prep.sceneOrigin.dy, QmCoinsLayoutSpec.sceneTranslationY);
    });
  });

  group('10k canvas', () {
    test('side length is 100 and sample is deterministic', () {
      final side = const QmCoinsLayoutSpec().pixelGridSideLength;
      expect(side, 100);

      final values = List<String>.generate(
        10000,
        (i) => i.isEven ? 'heads' : 'tails',
      );
      final a = sampleGridColors(
        measuredValues: values,
        count: 10000,
        revealed: true,
        systemType: SystemType.classical,
        sideLength: side,
      );
      final b = sampleGridColors(
        measuredValues: values,
        count: 10000,
        revealed: true,
        systemType: SystemType.classical,
        sideLength: side,
      );
      expect(a.length, 10000);
      expect(a, b);
      expect(identical(a, b), isFalse);
    });

    testWidgets('10000 mode does not create 10000 widgets', (tester) async {
      final values = List<String>.filled(10000, 'heads');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiCoinDisplay(
              systemType: SystemType.classical,
              measuredValues: values,
              count: 10000,
              revealed: true,
            ),
          ),
        ),
      );
      expect(find.byType(CustomPaint), findsWidgets);
      // Individual mini cells are not spawned for 10k.
      expect(tester.allWidgets.whereType<Positioned>().length, lessThan(50));
    });
  });

  group('coin positions determinism', () {
    test('same index/count/box → same center', () {
      final a = coinPositionForIndex(index: 3, count: 10, boxSize: 200);
      final b = coinPositionForIndex(index: 3, count: 10, boxSize: 200);
      expect(a, b);
      final c = coinPositionForIndex(index: 42, count: 100, boxSize: 200);
      final d = coinPositionForIndex(index: 42, count: 100, boxSize: 200);
      expect(c, d);
    });
  });

  group('component smoke', () {
    testWidgets('ClassicalCoinDisplay + CoinControls + CoinCountSelector',
        (tester) async {
      final face = ValueNotifier('heads');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ClassicalCoinDisplay(face: face, radius: 20),
                CoinControls(
                  systemType: SystemType.classical,
                  measurementState: ExperimentMeasurementState.revealed,
                  enabled: true,
                  onRevealOrObserve: () {},
                  onHide: () {},
                  onPrepare: () {},
                  onPrepareAndReveal: () {},
                ),
                CoinCountSelector(value: 100, onChanged: (_) {}),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Hide'), findsOneWidget);
      expect(find.text('Flip'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      face.dispose();
    });

    testWidgets('QuantumCoinDisplay + quantum controls labels', (tester) async {
      final state = ValueNotifier('superposition');
      final p = ValueNotifier(0.5);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                QuantumCoinDisplay(
                  coinState: state,
                  upProbability: p,
                  radius: 20,
                  showSuperposition: true,
                ),
                CoinControls(
                  systemType: SystemType.quantum,
                  measurementState: ExperimentMeasurementState.readyToBeMeasured,
                  enabled: true,
                  onRevealOrObserve: () {},
                  onHide: () {},
                  onPrepare: () {},
                  onPrepareAndReveal: () {},
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Observe'), findsOneWidget);
      expect(find.text('Reprepare'), findsOneWidget);
      state.dispose();
      p.dispose();
    });

    testWidgets('Coins screen mounts Classical and switches to Quantum',
        (tester) async {
      final model = CoinsModel(random: SeededQmRandom(42));
      await tester.pumpWidget(
        MaterialApp(
          home: QuantumMeasurementCoinsScreen(model: model),
        ),
      );
      await tester.pump();
      expect(find.text('Classical Coin'), findsOneWidget);
      expect(find.text("Quantum 'Coin'"), findsOneWidget);

      await tester.tap(find.text("Quantum 'Coin'"));
      await tester.pump();
      expect(model.experimentMode, SystemType.quantum);

      // Scene switch must not reset the inactive model bias.
      model.classicalScene.setUpProbability(0.7);
      model.setExperimentMode(SystemType.classical);
      await tester.pump();
      expect(model.classicalScene.upProbability, 0.7);
    });
  });
}
